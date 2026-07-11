// This is a generated file - do not edit.
//
// Generated from encode_request.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'encode_frame.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

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
    final result = create();
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (speed != null) result.speed = speed;
    if (maxThreads != null) result.maxThreads = maxThreads;
    if (timescale != null) result.timescale = timescale;
    if (maxQuantizer != null) result.maxQuantizer = maxQuantizer;
    if (minQuantizer != null) result.minQuantizer = minQuantizer;
    if (maxQuantizerAlpha != null) result.maxQuantizerAlpha = maxQuantizerAlpha;
    if (minQuantizerAlpha != null) result.minQuantizerAlpha = minQuantizerAlpha;
    if (imageList != null) result.imageList.addAll(imageList);
    if (exifData != null) result.exifData = exifData;
    return result;
  }

  EncodeRequest._();

  factory EncodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EncodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EncodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'models'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'width', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'speed', fieldType: $pb.PbFieldType.OS3)
    ..aI(4, _omitFieldNames ? '' : 'maxThreads', fieldType: $pb.PbFieldType.OS3)
    ..aI(5, _omitFieldNames ? '' : 'timescale', fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'maxQuantizer',
        fieldType: $pb.PbFieldType.OS3)
    ..aI(7, _omitFieldNames ? '' : 'minQuantizer',
        fieldType: $pb.PbFieldType.OS3)
    ..aI(8, _omitFieldNames ? '' : 'maxQuantizerAlpha',
        fieldType: $pb.PbFieldType.OS3)
    ..aI(9, _omitFieldNames ? '' : 'minQuantizerAlpha',
        fieldType: $pb.PbFieldType.OS3)
    ..pPM<$0.EncodeFrame>(10, _omitFieldNames ? '' : 'imageList',
        subBuilder: $0.EncodeFrame.create)
    ..a<$core.List<$core.int>>(
        11, _omitFieldNames ? '' : 'exifData', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncodeRequest copyWith(void Function(EncodeRequest) updates) =>
      super.copyWith((message) => updates(message as EncodeRequest))
          as EncodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EncodeRequest create() => EncodeRequest._();
  @$core.override
  EncodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EncodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EncodeRequest>(create);
  static EncodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get width => $_getIZ(0);
  @$pb.TagNumber(1)
  set width($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWidth() => $_has(0);
  @$pb.TagNumber(1)
  void clearWidth() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get height => $_getIZ(1);
  @$pb.TagNumber(2)
  set height($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get speed => $_getIZ(2);
  @$pb.TagNumber(3)
  set speed($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSpeed() => $_has(2);
  @$pb.TagNumber(3)
  void clearSpeed() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get maxThreads => $_getIZ(3);
  @$pb.TagNumber(4)
  set maxThreads($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMaxThreads() => $_has(3);
  @$pb.TagNumber(4)
  void clearMaxThreads() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get timescale => $_getIZ(4);
  @$pb.TagNumber(5)
  set timescale($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimescale() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimescale() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get maxQuantizer => $_getIZ(5);
  @$pb.TagNumber(6)
  set maxQuantizer($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxQuantizer() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxQuantizer() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get minQuantizer => $_getIZ(6);
  @$pb.TagNumber(7)
  set minQuantizer($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMinQuantizer() => $_has(6);
  @$pb.TagNumber(7)
  void clearMinQuantizer() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get maxQuantizerAlpha => $_getIZ(7);
  @$pb.TagNumber(8)
  set maxQuantizerAlpha($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMaxQuantizerAlpha() => $_has(7);
  @$pb.TagNumber(8)
  void clearMaxQuantizerAlpha() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get minQuantizerAlpha => $_getIZ(8);
  @$pb.TagNumber(9)
  set minQuantizerAlpha($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMinQuantizerAlpha() => $_has(8);
  @$pb.TagNumber(9)
  void clearMinQuantizerAlpha() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<$0.EncodeFrame> get imageList => $_getList(9);

  @$pb.TagNumber(11)
  $core.List<$core.int> get exifData => $_getN(10);
  @$pb.TagNumber(11)
  set exifData($core.List<$core.int> value) => $_setBytes(10, value);
  @$pb.TagNumber(11)
  $core.bool hasExifData() => $_has(10);
  @$pb.TagNumber(11)
  void clearExifData() => $_clearField(11);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
