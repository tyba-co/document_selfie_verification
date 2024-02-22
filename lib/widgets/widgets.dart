library document_selfie_verification.widgets;

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_ml_kit/google_ml_kit.dart' as mlkit;
import 'package:system_info_plus/system_info_plus.dart';
import '../models/models.dart';
import '../enums/enums.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import '../top_level_functions/top_level_functions.dart';

part 'custom_paint.dart';
part 'document_selfie_verification.dart';
part 'mobile.dart';
part 'base.dart';
part 'web.dart';
