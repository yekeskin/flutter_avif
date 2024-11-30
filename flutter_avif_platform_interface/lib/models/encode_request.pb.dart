//
//  Generated code. Do not modify.
//  source: encode_request.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'encode_frame.pb.dart' as $0;

class EncodeRequest extends $pb.GeneratedMessage {
  factory EncodeRequest({
    $core.int? width,
    $core.int? height,
    $core.int? speed,
    $core.int? maxThreads,
    $core.int? timescale,
    $core.int? maxQuantizer,
    $core.int? minQuantizer,
    $core.int? maxQuantizerAlpha,
    $core.int? minQuantizerAlpha,
    $core.Iterable<$0.EncodeFrame>? imageList,
    $core.List<$core.int>? exifData,
  }) {
    final $result = create();
    if (width != null) {
      $result.width = width;
    }
    if (height != null) {
      $result.height = height;
    }
    if (speed != null) {
      $result.speed = speed;
    }
    if (maxThreads != null) {
      $result.maxThreads = maxThreads;
    }
    if (timescale != null) {
      $result.timescale = timescale;
    }
    if (maxQuantizer != null) {
      $result.maxQuantizer = maxQuantizer;
    }
    if (minQuantizer != null) {
      $result.minQuantizer = minQuantizer;
    }
    if (maxQuantizerAlpha != null) {
      $result.maxQuantizerAlpha = maxQuantizerAlpha;
    }
    if (minQuantizerAlpha != null) {
      $result.minQuantizerAlpha = minQuantizerAlpha;
    }
    if (imageList != null) {
      $result.imageList.addAll(imageList);
    }
    if (exifData != null) {
      $result.exifData = exifData;
    }
    return $result;
  }
  EncodeRequest._() : super();
  factory EncodeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EncodeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EncodeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'models'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'width', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'speed', $pb.PbFieldType.OS3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'maxThreads', $pb.PbFieldType.OS3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'timescale', $pb.PbFieldType.OU3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'maxQuantizer', $pb.PbFieldType.OS3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'minQuantizer', $pb.PbFieldType.OS3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'maxQuantizerAlpha', $pb.PbFieldType.OS3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'minQuantizerAlpha', $pb.PbFieldType.OS3)
    ..pc<$0.EncodeFrame>(10, _omitFieldNames ? '' : 'imageList', $pb.PbFieldType.PM, subBuilder: $0.EncodeFrame.create)
    ..a<$core.List<$core.int>>(11, _omitFieldNames ? '' : 'exifData', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EncodeRequest clone() => EncodeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EncodeRequest copyWith(void Function(EncodeRequest) updates) => super.copyWith((message) => updates(message as EncodeRequest)) as EncodeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EncodeRequest create() => EncodeRequest._();
  EncodeRequest createEmptyInstance() => create();
  static $pb.PbList<EncodeRequest> createRepeated() => $pb.PbList<EncodeRequest>();
  @$core.pragma('dart2js:noInline')
  static EncodeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EncodeRequest>(create);
  static EncodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get width => $_getIZ(0);
  @$pb.TagNumber(1)
  set width($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWidth() => $_has(0);
  @$pb.TagNumber(1)
  void clearWidth() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get height => $_getIZ(1);
  @$pb.TagNumber(2)
  set height($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get speed => $_getIZ(2);
  @$pb.TagNumber(3)
  set speed($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSpeed() => $_has(2);
  @$pb.TagNumber(3)
  void clearSpeed() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get maxThreads => $_getIZ(3);
  @$pb.TagNumber(4)
  set maxThreads($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasMaxThreads() => $_has(3);
  @$pb.TagNumber(4)
  void clearMaxThreads() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get timescale => $_getIZ(4);
  @$pb.TagNumber(5)
  set timescale($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTimescale() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimescale() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get maxQuantizer => $_getIZ(5);
  @$pb.TagNumber(6)
  set maxQuantizer($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMaxQuantizer() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxQuantizer() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get minQuantizer => $_getIZ(6);
  @$pb.TagNumber(7)
  set minQuantizer($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMinQuantizer() => $_has(6);
  @$pb.TagNumber(7)
  void clearMinQuantizer() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get maxQuantizerAlpha => $_getIZ(7);
  @$pb.TagNumber(8)
  set maxQuantizerAlpha($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasMaxQuantizerAlpha() => $_has(7);
  @$pb.TagNumber(8)
  void clearMaxQuantizerAlpha() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get minQuantizerAlpha => $_getIZ(8);
  @$pb.TagNumber(9)
  set minQuantizerAlpha($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasMinQuantizerAlpha() => $_has(8);
  @$pb.TagNumber(9)
  void clearMinQuantizerAlpha() => clearField(9);

  @$pb.TagNumber(10)
  $core.List<$0.EncodeFrame> get imageList => $_getList(9);

  @$pb.TagNumber(11)
  $core.List<$core.int> get exifData => $_getN(10);
  @$pb.TagNumber(11)
  set exifData($core.List<$core.int> v) { $_setBytes(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasExifData() => $_has(10);
  @$pb.TagNumber(11)
  void clearExifData() => clearField(11);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
