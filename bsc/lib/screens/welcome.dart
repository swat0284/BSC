import 'package:flutter/material.dart';
import 'menu.dart';
import '../click_sounds.dart';
import '../haptics.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Container(
          color: Colors.black38, // lekkie przyciemnienie dla czytelności
          child: SafeArea(
            child: Column(
              children: [
                const _PartnersLogosBar(),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo aplikacji
                        Image.asset(
                          'assets/Logo/Bezpieczny Świat Cyfrowy Icon.png',
                          width: 160,
                          height: 160,
                        ),
                        const SizedBox(height: 25),

                        // Tytuł aplikacji
                        const Text(
                          "Aplikacja edukacyjna",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black54,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Przycisk start
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4B483), // beżowy odcień
                            padding: const EdgeInsets.symmetric(
                                horizontal: 60, vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 6,
                            shadowColor: Colors.black54,
                          ),
                          onPressed: () {
                            ClickSounds.play();
                            Haptics.tap(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MenuScreen()),
                            );
                          },
                          child: const Text(
                            "Rozpocznij",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const _EULogosBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PartnersLogosBar extends StatelessWidget {
  const _PartnersLogosBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Belka logotypów partnerów',
          child: Semantics(
            label: 'Belka logotypów partnerów',
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(
                'assets/images/partners_banner.png',
                fit: BoxFit.fitWidth,
                semanticLabel: 'Belka logotypów partnerów',
                errorBuilder: (context, error, stack) => Icon(
                  Icons.handshake,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _EULogosBar extends StatelessWidget {
  const _EULogosBar();

  static final Uri _infoUri = Uri.parse(
    'https://www.rozwojspoleczny.gov.pl/strony/dowiedz-sie-wiecej-o-programie/promocja-programu/',
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Belka logotypów Unii Europejskiej',
          child: Semantics(
            label: 'Belka logotypów Unii Europejskiej',
            child: InkWell(
              onTap: () async {
                try { await launchUrl(_infoUri, mode: LaunchMode.externalApplication); } catch (_) {}
              },
              child: SizedBox(
                width: double.infinity,
                child: Image.asset(
                  'assets/images/eu_banner.jpg',
                  fit: BoxFit.fitWidth,
                  semanticLabel: 'Belka logotypów UE',
                  errorBuilder: (context, error, stack) => Icon(
                    Icons.flag,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
