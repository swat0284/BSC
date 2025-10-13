// lib/screens/about.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart'; // pubspec: package_info_plus: ^8.0.0
import 'package:url_launcher/url_launcher.dart';          // pubspec: url_launcher: ^6.2.6
import '../click_sounds.dart';
import '../haptics.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snap) {
        final info = snap.data;
        final appName = info?.appName ?? 'Bezpieczny Świat Cyfrowy';
        final version = info == null ? '—' : '${info.version}+${info.buildNumber}';

        return Scaffold(
          appBar: AppBar(title: const Text('O aplikacji')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        child: const Icon(Icons.shield_outlined),
                      ),
                      title: Text(appName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Wersja $version'),
                      trailing: IconButton(
                        tooltip: 'Kopiuj wersję',
                        icon: const Icon(Icons.copy),
                        onPressed: () async {
                          ClickSounds.play(); Haptics.tap(context);
                          await Clipboard.setData(ClipboardData(text: version));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Skopiowano wersję')),
                            );
                          }
                        },
                      ),
                    ),
                    const Divider(height: 1),

                    
                    ListTile(
                      leading: const Icon(Icons.article_outlined),
                      title: const Text('Licencje open-source'),
                      onTap: () { ClickSounds.play(); Haptics.tap(context); showLicensePage(
                        context: context,
                        applicationName: appName,
                        applicationVersion: version,
                      ); },
                    ),
                    const Divider(height: 1),

                    ListTile(
                      leading: const Icon(Icons.mail_outline),
                      title: const Text('Kontakt'),
                      subtitle: const Text('kontakt@malansoft.pl'),
                      onTap: () { ClickSounds.play(); Haptics.tap(context); _launchUrl('mailto:kontakt@malansoft.pl'); },
                    ),

                    // (opcjonalnie) strona projektu:
                    // const Divider(height: 1),
                    // ListTile(
                    //   leading: const Icon(Icons.public),
                    //   title: const Text('Strona projektu'),
                    //   onTap: () => _launchUrl('https://twojadomena.pl'),
                    // ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Aplikacja edukacyjna ucząca bezpiecznych reakcji na oszustwa '
                    'telefoniczne, SMS i web. Działa offline. Wersje testowe mogą '
                    'zawierać uproszczone treści i efekty.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
