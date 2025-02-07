import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> callDestination(String phoneNumber) async {
  final contactUri = Uri(scheme: 'tel', path: phoneNumber);

  final canLaunch = await canLaunchUrl(contactUri);
  if (canLaunch) {
    debugPrint('Calling $phoneNumber');
    return launchUrl(contactUri);
  } else {
    debugPrint('Unable to call $phoneNumber');
    return false;
  }
}
