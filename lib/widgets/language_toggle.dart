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
          icon: const Icon(Icons.language, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Select Language',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFF1F2F6),
                          child: Text('🇺🇸', style: TextStyle(fontSize: 20)),
                        ),
                        title: const Text('English'),
                        trailing: languageProvider.isEnglish
                            ? const Icon(Icons.check, color: Color(0xFF3498DB))
                            : null,
                        onTap: () {
                          languageProvider.changeLanguage('en');
                          Navigator.pop(context);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFF1F2F6),
                          child: Text('🇹🇿', style: TextStyle(fontSize: 20)),
                        ),
                        title: const Text('Kiswahili'),
                        trailing: languageProvider.isSwahili
                            ? const Icon(Icons.check, color: Color(0xFF3498DB))
                            : null,
                        onTap: () {
                          languageProvider.changeLanguage('sw');
                          Navigator.pop(context);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}