// This is a generated file - do not edit.
//
// Generated from encode_frame.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use encodeFrameDescriptor instead')
const EncodeFrame$json = {
  '1': 'EncodeFrame',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 12, '10': 'data'},
    {
      '1': 'duration_in_timescale',
      '3': 2,
      '4': 1,
      '5': 13,
      '10': 'durationInTimescale'
    },
  ],
};

/// Descriptor for `EncodeFrame`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List encodeFrameDescriptor = $convert.base64Decode(
    'CgtFbmNvZGVGcmFtZRISCgRkYXRhGAEgASgMUgRkYXRhEjIKFWR1cmF0aW9uX2luX3RpbWVzY2'
    'FsZRgCIAEoDVITZHVyYXRpb25JblRpbWVzY2FsZQ==');
