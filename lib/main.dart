import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';

void registerAppLicense() {
  LicenseRegistry.addLicense(() async* {
    final licenseText = await rootBundle.loadString('LICENCE');
    yield LicenseEntryWithLineBreaks(['AIOconvert'], licenseText);
  });
}

void main() {
  registerAppLicense();
  runApp(const AioConvertApp());
}
