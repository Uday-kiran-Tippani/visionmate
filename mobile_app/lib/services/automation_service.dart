import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class AutomationService {
  Future<void> launchApp(String packageName) async {
    // Basic implementation for launching apps using Intent
    // Note: This requires the package name to be known
    final intent = AndroidIntent(
      action: 'android.intent.action.MAIN',
      category: 'android.intent.category.LAUNCHER',
      package: packageName,
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  }

  Future<void> makeCall(String contactName) async {
    // 1. Search for contact
    if (await FlutterContacts.requestPermission()) {
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);
      Contact? target = contacts.firstWhere(
        (c) => c.displayName.toLowerCase().contains(contactName.toLowerCase()),
        orElse: () => Contact(), // Return empty if not found
      );

      if (target.phones.isNotEmpty) {
        final Uri launchUri = Uri(
          scheme: 'tel',
          path: target.phones.first.number,
        );
        await launchUrl(launchUri);
      } else {
        throw "Contact or phone number not found";
      }
    } else {
      throw "Permission denied";
    }
  }

  Future<void> sendSMS(String contactName, String message) async {
    // Similar logic to call, but use sms scheme
    if (await FlutterContacts.requestPermission()) {
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);
      Contact? target = contacts.firstWhere(
        (c) => c.displayName.toLowerCase().contains(contactName.toLowerCase()),
        orElse: () => Contact(),
      );

      if (target.phones.isNotEmpty) {
        final Uri launchUri = Uri(
          scheme: 'sms',
          path: target.phones.first.number,
          queryParameters: <String, String>{
            'body': message,
          },
        );
        await launchUrl(launchUri);
      } else {
        throw "Contact or phone number not found";
      }
    }
  }

  Future<void> openGoogleMaps(String destination) async {
    // Use Google Maps Intent
    final intent = AndroidIntent(
      action: 'android.intent.action.VIEW',
      data: 'google.navigation:q=$destination',
      package: 'com.google.android.apps.maps',
    );
    await intent.launch();
  }
}
