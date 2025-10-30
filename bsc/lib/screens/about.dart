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

              // (przeniesione na dół) belki logotypów będą wyświetlone po treści

              // Informacja o dotacji / innowacjach społecznych ROPS (pełna formuła)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Informacja o dofinansowaniu', style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 8),
                      Text(
                        'Projekt jest realizowany w ramach V Osi Priorytetowej programu Fundusze Europejskie dla Rozwoju Społecznego 2021-2027 '
                        '(Działanie 5.1: Innowacje społeczne) współfinansowanego ze środków Europejskiego Funduszu Społecznego+, '
                        'na zlecenie Ministerstwa Funduszy i Polityki Regionalnej.',
                      ),
                    ],
                  ),
                ),
              ),

              // Belka logotypów UE – bezpośrednio po informacji o dofinansowaniu
              const SizedBox(height: 8),
              Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () { ClickSounds.play(); Haptics.tap(context); _launchUrl('https://www.rozwojspoleczny.gov.pl/strony/dowiedz-sie-wiecej-o-programie/promocja-programu/'); },
                  child: Image.asset(
                    'assets/images/eu_banner.jpg',
                    fit: BoxFit.fitWidth,
                    semanticLabel: 'Belka logotypów UE',
                    errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                  ),
                ),
              ),

              // Licencja CC BY 4.0
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Licencja materiałów', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/cc_by_4.0.png',
                            height: 32,
                            fit: BoxFit.contain,
                            semanticLabel: 'Licencja Creative Commons Uznanie autorstwa 4.0 (CC BY 4.0)',
                            errorBuilder: (context, error, stack) => const SizedBox(),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Materiały (o ile nie zaznaczono inaczej) udostępniane są na licencji CC BY 4.0.',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          TextButton.icon(
                            onPressed: () { ClickSounds.play(); Haptics.tap(context); _launchUrl('https://creativecommons.org/licenses/by/4.0/deed.pl'); },
                            icon: const Icon(Icons.link),
                            label: const Text('Skrót treści licencji'),
                          ),
                          TextButton.icon(
                            onPressed: () { ClickSounds.play(); Haptics.tap(context); _launchUrl('https://creativecommons.org/licenses/by/4.0/legalcode.pl'); },
                            icon: const Icon(Icons.description_outlined),
                            label: const Text('Pełna treść licencji'),
                          ),
                        ],
                      ),
                    ],
                  ),
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

              // Belka logotypów realizatorów (partnerzy) – na dole
              const SizedBox(height: 12),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/partners_banner.png',
                  fit: BoxFit.fitWidth,
                  semanticLabel: 'Belka logotypów partnerów',
                  errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                ),
              ),

              // (EU belka przeniesiona powyżej, tu usunięta)
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
