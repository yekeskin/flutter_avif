use avif_serialize::Aviffy;
use avif_serialize::FrameInfo;
use rav1e::color::ChromaSampling;
use rav1e::prelude::*;
use rgb::RGBA;

const BIT_DEPTH: usize = 8;

fn clamp(val: f32) -> u8 {
    return (val.round() as u8).max(0_u8).min(255_u8);
}

#[cfg(not(target_feature = "simd128"))]
fn to_ycbcr(pixel: &RGBA<u8>) -> (u8, u8, u8, u8) {
    let r = pixel.r as f32;
    let g = pixel.g as f32;
    let b = pixel.b as f32;

    let y = 16_f32 + (65.481 * r + 128.553 * g + 24.966 * b) / 255_f32;
    let cb = 128_f32 + (-37.797 * r - 74.203 * g + 112.000 * b) / 255_f32;
    let cr = 128_f32 + (112.000 * r - 93.786 * g - 18.214 * b) / 255_f32;

    return (clamp(y), clamp(cb), clamp(cr), pixel.a);
}

pub fn rgb_to_ycbcr(pixels: &[RGBA<u8>]) -> (Vec<u8>, Vec<u8>, Vec<u8>, Vec<u8>) {
    let mut y_plane = Vec::new();
    let mut cb_plane = Vec::new();
    let mut cr_plane = Vec::new();
    let mut a_plane = Vec::new();

    pixels
        .to_vec()
        .iter()
        .map(to_ycbcr)
        .for_each(|(y, cb, cr, a)| {
            y_plane.push(y);
            cb_plane.push(cb);
            cr_plane.push(cr);
            a_plane.push(a);
        });

    return (y_plane, cb_plane, cr_plane, a_plane);
}

fn encode_to_av1(
    width: usize,
    height: usize,
    speed: u8,
    max_threads: usize,
    _timescale: u64,
    max_quantizer: usize,
    min_quantizer: u8,
    planes: &[&[u8]],
    durations: &[u8],
) -> Result<EncodeData, Box<dyn std::error::Error + Send + Sync>> {
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
            matrix_coefficients: MatrixCoefficients::BT709,
        }),
        still_picture: match durations.len() {
            1 => true,
            _ => false,
        },
        quantizer: max_quantizer,
        min_quantizer: min_quantizer,
        ..Default::default()
    };

    let config = Config::new()
        .with_threads(max_threads)
        .with_encoder_config(encoder_config);

    let mut ctx: Context<u8> = config.new_context()?;

    let frame_size = width * height as usize;
    let frame_count = planes[0].len() / frame_size;

    for i in 0..frame_count {
        let mut frame = ctx.new_frame();

        for k in 0..planes.len() {
            let stride = (width + frame.planes[k].cfg.xdec) >> frame.planes[k].cfg.xdec;
            frame.planes[k].copy_from_raw_u8(
                &planes[k][(i * frame_size)..((i + 1) * frame_size)],
                stride,
                1,
            )
        }

        ctx.send_frame(frame)?;
    }
    ctx.flush();

    let mut data = Vec::new();
    let mut info: Vec<FrameInfo> = Vec::new();
    let mut frame_index = 0;

    loop {
        match ctx.receive_packet() {
            Ok(mut packet) => match packet.frame_type {
                FrameType::KEY => {
                    info.push(FrameInfo {
                        duration_in_timescales: durations[frame_index] as u64,
                        sync: true,
                        size: packet.data.len() as u32,
                    });
                    data.append(&mut packet.data);
                    frame_index += 1;
                }
                _ => {
                    info.push(FrameInfo {
                        duration_in_timescales: durations[frame_index] as u64,
                        sync: false,
                        size: packet.data.len() as u32,
                    });
                    data.append(&mut packet.data);
                    frame_index += 1;
                }
            },
            Err(EncoderStatus::Encoded) => (),
            Err(EncoderStatus::LimitReached) => break,
            Err(err) => Err(err)?,
        }
    }

    return Ok(EncodeData {
        data: data,
        info: info,
    });
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
    durations: &[u8],
    exif_data: &[u8],
) -> Result<Vec<u8>, Box<dyn std::error::Error + Send + Sync>> {
    // let (y, u, v, a) = split_rgb_planes(pixels);
    let (y, u, v, a) = rgb_to_ycbcr(pixels);

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
        durations,
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
            durations,
        )),
        false => None,
    };

    let (chroma, alpha) = (chroma?, alpha.transpose()?);

    let result = Aviffy::new()
        .matrix_coefficients(avif_serialize::constants::MatrixCoefficients::Bt709)
        .transfer_characteristics(avif_serialize::constants::TransferCharacteristics::Srgb)
        .color_primaries(avif_serialize::constants::ColorPrimaries::Bt601)
        .full_color_range(true)
        .premultiplied_alpha(false)
        .to_vec(
            &chroma.data,
            match alpha.as_ref() {
                Some(_alpha) => Some(&_alpha.data),
                _ => None,
            },
            width as u32,
            height as u32,
            BIT_DEPTH as u8,
            timescale as u32,
            match durations.len() {
                1 => None,
                _ => Some(&chroma.info),
            },
            match durations.len() {
                1 => None,
                _ => match alpha.as_ref() {
                    Some(_alpha) => Some(&_alpha.info),
                    _ => None,
                },
            },
            exif_data,
        );

    return Ok(result);
}

struct EncodeData {
    pub data: Vec<u8>,
    pub info: Vec<FrameInfo>,
}
