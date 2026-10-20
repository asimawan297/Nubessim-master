import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:nubesim/core/di/service_locator.dart';
import 'package:nubesim/modules/common/repo/session_repo.dart';

Future<String> getDeviceName() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final info = await deviceInfo.androidInfo;
    return "${info.manufacturer} ${info.model}";
  } else if (Platform.isIOS) {
    final info = await deviceInfo.iosInfo;
    return "${info.name} ${info.model}";
  }
  return "Unknown Device";
}
    final sessionRepo = sl<SessionRepository>();

Future<void> getLocation() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw Exception('Location permission not granted');
    }
  }
  Position pos = await Geolocator.getCurrentPosition();
  List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
  Placemark place = placemarks.first;
  final location = "${place.locality}, ${place.country}";
  // debugger();
  sessionRepo.setLocation(location);
}

Future<String> loadEmailTemplate({
  required String name,
  required String instructionsLink,
  String? locationDetails
}) async {
  String template = await rootBundle.loadString('assets/templates/login.html');

  // Gather dynamic values
  String date = DateFormat('MM/dd/yyyy').format(DateTime.now().toUtc());
  String time = "${DateFormat('hh:mm a').format(DateTime.now().toUtc())} UTC";
  String device = await getDeviceName();
  String location = locationDetails ?? "Unknow Location!";
  String platform = Platform.isAndroid
      ? "Android"
      : Platform.isIOS
          ? "iOS"
          : Platform.isMacOS
              ? "MacOS"
              : Platform.isWindows
                  ? "Windows"
                  : Platform.isLinux
                      ? "Linux"
                      : "Unknown";
  // "android", "ios", etc.

  // Replace placeholders
  template = template.replaceAll('{Name}', name);
  template = template.replaceAll('{instructionsLink}', instructionsLink);
  template = template.replaceAll('{Date}', date);
  template = template.replaceAll('{Time}', time);
  template = template.replaceAll('{Device}', device);
  template = template.replaceAll('{Location}', location);
  template = template.replaceAll('{Platform}', platform);
  // debugger();
  return template;
}


Future<String> loadOTPTemplate({
  required String name,
  required String OTP,
}) async {
  String template = await rootBundle.loadString('assets/templates/otp.html');


  // Replace placeholders
  template = template.replaceAll('{Name}', name);
  template = template.replaceAll('{VerificationCode}', OTP);

  return template;
}

String _htmlEsc(String? s) {
  if (s == null || s.isEmpty) return '';
  return s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}

/// Single QR image row (remote `https://...` URL from eSIM Access `qrCodeUrl`).
String buildOrderConfirmationEsimQrImageSection(String? qrCodeUrl) {
  if (qrCodeUrl == null || qrCodeUrl.trim().isEmpty) return '';
  final src = _htmlEsc(qrCodeUrl.trim());
  return '''
                    <tr>
                        <td align="center" style="padding:24px 32px 8px 32px; background-color:#ffffff; border-top:1px solid #eeeeee;">
                            <p style="margin:0 0 12px 0; font-size:16px; color:#111111;">Scan to install your eSIM</p>
                            <img src="$src" alt="eSIM QR Code" width="240" style="display:block;margin:0 auto;border:0;outline:none;max-width:240px;height:auto;" />
                        </td>
                    </tr>
''';
}

/// Optional block for [assets/templates/order.html] placeholder `{EsimDetailsSection}`.
String buildOrderConfirmationEsimDetailsSection({
  String? qrImageSrc,
  String? activationCode,
  String? iccid,
  String? apn,
  String? esimStatus,
  String? iosUniversalLink,
  String? androidUniversalLink,
}) {
  final hasQr = qrImageSrc != null && qrImageSrc.trim().isNotEmpty;
  final hasText = (activationCode != null && activationCode.trim().isNotEmpty) ||
      (iccid != null && iccid.trim().isNotEmpty);
  if (!hasQr && !hasText) return '';

  final img = hasQr
      ? '<img src="${_htmlEsc(qrImageSrc)}" alt="eSIM QR" width="220" '
          'style="display:block;margin:12px auto;border:0;outline:none;" />'
      : '';

  final rows = StringBuffer();
  if (activationCode != null && activationCode.trim().isNotEmpty) {
    rows.write(
      '<p style="margin:6px 0;font-size:14px;color:#333;"><strong>Activation (AC):</strong> '
      '<code style="word-break:break-all;">${_htmlEsc(activationCode)}</code></p>',
    );
  }
  if (iccid != null && iccid.trim().isNotEmpty) {
    rows.write(
      '<p style="margin:6px 0;font-size:14px;color:#333;"><strong>ICCID:</strong> '
      '${_htmlEsc(iccid)}</p>',
    );
  }
  if (apn != null && apn.trim().isNotEmpty) {
    rows.write(
      '<p style="margin:6px 0;font-size:14px;color:#333;"><strong>APN:</strong> '
      '${_htmlEsc(apn)}</p>',
    );
  }
  if (esimStatus != null && esimStatus.trim().isNotEmpty) {
    rows.write(
      '<p style="margin:6px 0;font-size:14px;color:#333;"><strong>eSIM status:</strong> '
      '${_htmlEsc(esimStatus)}</p>',
    );
  }
  if (iosUniversalLink != null && iosUniversalLink.trim().isNotEmpty) {
    rows.write(
      '<p style="margin:6px 0;font-size:14px;"><a href="${_htmlEsc(iosUniversalLink)}" '
      'target="_blank" rel="noopener">Open on iOS (universal link)</a></p>',
    );
  }
  if (androidUniversalLink != null && androidUniversalLink.trim().isNotEmpty) {
    rows.write(
      '<p style="margin:6px 0;font-size:14px;"><a href="${_htmlEsc(androidUniversalLink)}" '
      'target="_blank" rel="noopener">Open on Android (universal link)</a></p>',
    );
  }

  // Full-width row on the main email table, directly above the "Access Your eSIM" CTA row.
  return '''
                    <tr>
                        <td align="center" style="padding:24px 32px 8px 32px; background-color:#ffffff; border-top:1px solid #eeeeee;">
                            <h3 style="margin:0 0 12px 0; font-size:18px; color:#111111;">Your eSIM</h3>
                            $img
                            $rows
                        </td>
                    </tr>
''';
}

Future<String> loadOrderConfirmationEmailTemplate({
  required String name,
  required String orderNumber,
  required String orderDate,
  required String paymentType,
  required String totalCost,
  required String viewLink,
  String esimDetailsSection = '',
}) async {
  String template = await rootBundle.loadString('assets/templates/order.html');

  template = template.replaceAll('{Name}', name);
  template = template.replaceAll('{OrderNumber}', orderNumber);
  template = template.replaceAll('{OrderDate}', orderDate);
  template = template.replaceAll('{PaymentType}', paymentType);
  template = template.replaceAll('{TotalCost}', totalCost);
  template = template.replaceAll('{ViewLink}', "https://www.nubessim.com/auth");
  template = template.replaceAll('{EsimDetailsSection}', esimDetailsSection);

  return template;
}

Future<String> loadEsimReadyEmailTemplate({
  required String name,
  required String orderNumber,
  required String instructionsLink,
}) async {
  String template = await rootBundle.loadString('assets/templates/ready.html');

  template = template.replaceAll('{name}', name);
  template = template.replaceAll('{orderNumber}', orderNumber);
  template = template.replaceAll('{instructionsLink}', instructionsLink);

  return template;
}

Future<String> loadEsimActivationEmailTemplate({
  required String name,
  required String accessLink,
}) async {
  String template =
      await rootBundle.loadString('assets/templates/connected.html');

  template = template.replaceAll('{Name}', name);
  template = template.replaceAll('{AccessLink}', accessLink);

  return template;
}
