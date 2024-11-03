//
//  Generated code. Do not modify.
//  source: encode_frame.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class EncodeFrame extends $pb.GeneratedMessage {
  factory EncodeFrame({
    $core.List<$core.int>? data,
    $core.int? durationInTimescale,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    if (durationInTimescale != null) {
      $result.durationInTimescale = durationInTimescale;
    }
    return $result;
  }
  EncodeFrame._() : super();
  factory EncodeFrame.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EncodeFrame.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EncodeFrame', package: const $pb.PackageName(_omitMessageNames ? '' : 'models'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'durationInTimescale', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EncodeFrame clone() => EncodeFrame()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EncodeFrame copyWith(void Function(EncodeFrame) updates) => super.copyWith((message) => updates(message as EncodeFrame)) as EncodeFrame;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EncodeFrame create() => EncodeFrame._();
  EncodeFrame createEmptyInstance() => create();
  static $pb.PbList<EncodeFrame> createRepeated() => $pb.PbList<EncodeFrame>();
  @$core.pragma('dart2js:noInline')
  static EncodeFrame getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EncodeFrame>(create);
  static EncodeFrame? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get durationInTimescale => $_getIZ(1);
  @$pb.TagNumber(2)
  set durationInTimescale($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDurationInTimescale() => $_has(1);
  @$pb.TagNumber(2)
  void clearDurationInTimescale() => clearField(2);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
