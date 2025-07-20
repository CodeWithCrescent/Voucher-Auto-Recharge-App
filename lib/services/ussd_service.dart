import 'package:url_launcher/url_launcher.dart';

class UssdService {
  static Future<void> rechargeVoucher(String voucherNumber) async {
    final ussdCode = '*104*$voucherNumber#';
    final uri = Uri.parse('tel:$ussdCode');
    
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalNonBrowserApplication,
    )) {
      throw Exception('Could not launch USSD code');
    }
  }
}