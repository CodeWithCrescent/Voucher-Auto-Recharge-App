import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Voucher Recharge',
      'quick_recharge': 'Quick Recharge',
      'scan_or_enter': 'Scan or enter your voucher',
      'voucher_details': 'Voucher Details',
      'enter_voucher': 'Enter voucher number',
      'voucher_hint': '1234 5678 9012 3456',
      'scan': 'Scan',
      'recharge_now': 'Recharge Now',
      'align_voucher': 'Align voucher number within frame',
      'enter_or_scan': 'Please enter or scan a voucher number',
      'voucher_length': 'Voucher must be 12-16 digits',
      'recharge_failed': 'Recharge failed',
      'no_valid_voucher': 'No valid voucher found. Please try again.',
      'camera_failed': 'Failed to initialize camera',
    },
    'sw': {
      'app_title': 'Kuweka Vocha',
      'quick_recharge': 'Kuweka Haraka',
      'scan_or_enter': 'Skani au andika namba ya vocha yako',
      'voucher_details': 'Maelezo ya Vocha',
      'enter_voucher': 'Andika namba ya vocha',
      'voucher_hint': '1234 5678 9012 3456',
      'scan': 'Skani',
      'recharge_now': 'Weka Vocha Sasa',
      'align_voucher': 'Weka namba ya vocha ndani ya mstari',
      'enter_or_scan': 'Tafadhali andika au skani namba ya vocha',
      'voucher_length': 'Vocha lazima iwe na tarakimu 12-16',
      'recharge_failed': 'Kuweka vocha imefeli',
      'no_valid_voucher': 'Hakuna vocha halali iliyopatikana. Jaribu tena.',
      'camera_failed': 'Imefeli kuwasha kamera',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['app_title']!;
  String get quickRecharge => _localizedValues[locale.languageCode]!['quick_recharge']!;
  String get scanOrEnter => _localizedValues[locale.languageCode]!['scan_or_enter']!;
  String get voucherDetails => _localizedValues[locale.languageCode]!['voucher_details']!;
  String get enterVoucher => _localizedValues[locale.languageCode]!['enter_voucher']!;
  String get voucherHint => _localizedValues[locale.languageCode]!['voucher_hint']!;
  String get scan => _localizedValues[locale.languageCode]!['scan']!;
  String get rechargeNow => _localizedValues[locale.languageCode]!['recharge_now']!;
  String get alignVoucher => _localizedValues[locale.languageCode]!['align_voucher']!;
  String get enterOrScan => _localizedValues[locale.languageCode]!['enter_or_scan']!;
  String get voucherLength => _localizedValues[locale.languageCode]!['voucher_length']!;
  String get rechargeFailed => _localizedValues[locale.languageCode]!['recharge_failed']!;
  String get noValidVoucher => _localizedValues[locale.languageCode]!['no_valid_voucher']!;
  String get cameraFailed => _localizedValues[locale.languageCode]!['camera_failed']!;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'sw'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}