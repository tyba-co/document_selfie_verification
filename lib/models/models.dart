library document_selfie_verification.models;

import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

import '../constants/constants.dart';
import '../js/text_and_image_processing_web.dart';
import '../enums/enums.dart';
import '../extensions/extensions.dart';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';

part 'compress_object.dart';
part 'document_selfie_verification.dart';
part 'document_selfie_verification_stream.dart';
part 'abstract_document_selfie_verification.dart';
part 'ml_text_response.dart';