import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tz_voucher_recharge/localizations/language_provider.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return IconButton(
          icon: const Icon(Icons.language),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Select Language'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Text('🇺🇸'),
                      title: const Text('English'),
                      trailing: languageProvider.isEnglish 
                          ? const Icon(Icons.check) 
                          : null,
                      onTap: () {
                        languageProvider.changeLanguage('en');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Text('🇹🇿'),
                      title: const Text('Kiswahili'),
                      trailing: languageProvider.isSwahili 
                          ? const Icon(Icons.check) 
                          : null,
                      onTap: () {
                        languageProvider.changeLanguage('sw');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}