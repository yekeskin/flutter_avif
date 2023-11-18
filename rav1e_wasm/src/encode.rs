use avif_serialize::Aviffy;
use rav1e::color::ChromaSampling;
use rav1e::prelude::*;
use rgb::RGBA;

const BIT_DEPTH: usize = 8;

fn split_rgb_planes(pixels: &[RGBA<u8>]) -> (Vec<u8>, Vec<u8>, Vec<u8>, Vec<u8>) {
    let mut r_plane = Vec::new();
    let mut g_plane = Vec::new();
    let mut b_plane = Vec::new();
    let mut a_plane = Vec::new();

    pixels.to_vec().iter().for_each(|pixel| {
        r_plane.push(pixel.r);
        g_plane.push(pixel.g);
        b_plane.push(pixel.b);
        a_plane.push(pixel.a);
    });

    return (g_plane, b_plane, r_plane, a_plane);
}

fn encode_to_av1(
    width: usize,
    height: usize,
    speed: u8,
    max_threads: usize,
    timescale: u64,
    max_quantizer: usize,
    min_quantizer: u8,
    planes: &[&[u8]],
) -> Result<Vec<u8>, Box<dyn std::error::Error + Send + Sync>> {
    let encoder_config = EncoderConfig {
        width: width,
        height: height,
        speed_settings: SpeedSettings::from_preset(speed),
        bit_depth: BIT_DEPTH,
        chroma_sampling: ChromaSampling::Cs444,
        chroma_sample_position: ChromaSamplePosition::Colocated,
        pixel_range: PixelRange::Full,
        color_description: Some(ColorDescription {
            transfer_characteristics: TransferCharacteristics::SRGB,
            color_primaries: ColorPrimaries::BT601,
            matrix_coefficients: MatrixCoefficients::Identity,
        }),
        still_picture: true,
        quantizer: max_quantizer,
        min_quantizer: min_quantizer,
        ..Default::default()
    };

    let config = Config::new()
        .with_threads(max_threads)
        .with_encoder_config(encoder_config);

    let mut ctx: Context<u8> = config.new_context()?;
    let mut frame = ctx.new_frame();

    for (dst, src) in frame.planes.iter_mut().zip(planes) {
        dst.copy_from_raw_u8(src, width, 1);
    }

    ctx.send_frame(frame)?;
    ctx.flush();

    let mut result = Vec::new();

    loop {
        match ctx.receive_packet() {
            Ok(mut packet) => match packet.frame_type {
                FrameType::KEY => result.append(&mut packet.data),
                _ => continue,
            },
            Err(EncoderStatus::Encoded) => (),
            Err(EncoderStatus::LimitReached) => break,
            Err(err) => Err(err)?,
        }
    }

    return Ok(result);
}

pub fn encode_to_avif(
    width: usize,
    height: usize,
    speed: u8,
    max_threads: usize,
    timescale: u64,
    max_quantizer: usize,
    min_quantizer: u8,
    max_quantizer_alpha: usize,
    min_quantizer_alpha: u8,
    pixels: &[RGBA<u8>],
) -> Result<Vec<u8>, Box<dyn std::error::Error + Send + Sync>> {
    let (y, u, v, a) = split_rgb_planes(pixels);

    let use_alpha: bool = a.iter().copied().any(|val| val != 255);

    let planes: Vec<&[u8]> = vec![&y, &u, &v];
    let alpha_plane: Vec<&[u8]> = vec![&a];

    let chroma = encode_to_av1(
        width,
        height,
        speed,
        max_threads,
        timescale,
        max_quantizer,
        min_quantizer,
        &planes,
    );
    let alpha = match use_alpha {
        true => Some(encode_to_av1(
            width,
            height,
            speed,
            max_threads,
            timescale,
            max_quantizer_alpha,
            min_quantizer_alpha,
            &alpha_plane,
        )),
        false => None,
    };

    let (chroma, alpha) = (chroma?, alpha.transpose()?);

    let result = Aviffy::new().premultiplied_alpha(false).to_vec(
        &chroma,
        alpha.as_deref(),
        width as u32,
        height as u32,
        BIT_DEPTH as u8,
    );

    return Ok(result);
}
