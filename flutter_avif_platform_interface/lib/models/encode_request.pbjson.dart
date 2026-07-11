// This is a generated file - do not edit.
//
// Generated from encode_request.proto.

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

@$core.Deprecated('Use encodeRequestDescriptor instead')
const EncodeRequest$json = {
  '1': 'EncodeRequest',
  '2': [
    {'1': 'width', '3': 1, '4': 1, '5': 13, '10': 'width'},
    {'1': 'height', '3': 2, '4': 1, '5': 13, '10': 'height'},
    {'1': 'speed', '3': 3, '4': 1, '5': 17, '10': 'speed'},
    {'1': 'max_threads', '3': 4, '4': 1, '5': 17, '10': 'maxThreads'},
    {'1': 'timescale', '3': 5, '4': 1, '5': 13, '10': 'timescale'},
    {'1': 'max_quantizer', '3': 6, '4': 1, '5': 17, '10': 'maxQuantizer'},
    {'1': 'min_quantizer', '3': 7, '4': 1, '5': 17, '10': 'minQuantizer'},
    {
      '1': 'max_quantizer_alpha',
      '3': 8,
      '4': 1,
      '5': 17,
      '10': 'maxQuantizerAlpha'
    },
    {
      '1': 'min_quantizer_alpha',
      '3': 9,
      '4': 1,
      '5': 17,
      '10': 'minQuantizerAlpha'
    },
    {
      '1': 'image_list',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.models.EncodeFrame',
      '10': 'imageList'
    },
    {'1': 'exif_data', '3': 11, '4': 1, '5': 12, '10': 'exifData'},
  ],
};

/// Descriptor for `EncodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List encodeRequestDescriptor = $convert.base64Decode(
    'Cg1FbmNvZGVSZXF1ZXN0EhQKBXdpZHRoGAEgASgNUgV3aWR0aBIWCgZoZWlnaHQYAiABKA1SBm'
    'hlaWdodBIUCgVzcGVlZBgDIAEoEVIFc3BlZWQSHwoLbWF4X3RocmVhZHMYBCABKBFSCm1heFRo'
    'cmVhZHMSHAoJdGltZXNjYWxlGAUgASgNUgl0aW1lc2NhbGUSIwoNbWF4X3F1YW50aXplchgGIA'
    'EoEVIMbWF4UXVhbnRpemVyEiMKDW1pbl9xdWFudGl6ZXIYByABKBFSDG1pblF1YW50aXplchIu'
    'ChNtYXhfcXVhbnRpemVyX2FscGhhGAggASgRUhFtYXhRdWFudGl6ZXJBbHBoYRIuChNtaW5fcX'
    'VhbnRpemVyX2FscGhhGAkgASgRUhFtaW5RdWFudGl6ZXJBbHBoYRIyCgppbWFnZV9saXN0GAog'
    'AygLMhMubW9kZWxzLkVuY29kZUZyYW1lUglpbWFnZUxpc3QSGwoJZXhpZl9kYXRhGAsgASgMUg'
    'hleGlmRGF0YQ==');
