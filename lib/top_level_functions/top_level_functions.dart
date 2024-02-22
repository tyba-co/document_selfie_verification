export 'top_level_functions_base.dart'
    if (dart.library.js) 'top_level_functions_web.dart'
    if (dart.library.io) 'top_level_functions_mobile.dart';
