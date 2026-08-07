import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = [
    (icon: Icons.calendar_month, title: 'Reja', body: "Kun tartibingizni tuzing: vazifa, uyqu, ovqat, "
        "odat va ta'til. Takrorlanuvchi rejalar uchun davomiylik ham belgilanadi."),
    (icon: Icons.timer, title: 'Fokus', body: "Pomodoro yoki stopwatch bilan ishlang. Telefon "
        "qulflansa ham taymer bildirishnomada ko'rinib turadi."),
    (icon: Icons.insights, title: 'Tahlil', body: "Kunlik bajarilish foizi va chalg'ituvchi "
        "ilovalarga sarflangan vaqt shu yerda ko'rinadi."),
    (icon: Icons.settings, title: 'Sozlama', body: "Mavzu, soat/taymer ko'rinishi, orqa fon "
        "naqshi — hammasi shu yerdan tanlanadi."),
    (icon: Icons.apps, title: 'Boshqa', body: "O'qituvchi rejasi, Sport, O'qish, Ibodat, Sanoq, "
        "IDP, Qadam va O'qish rejimi — qo'shimcha bo'limlar shu yerda."),
  ];

  void _finish() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(onPressed: _finish, child: const Text("O'tkazib yuborish")),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(p.icon, size: 72, color: scheme.primary),
                        const SizedBox(height: 24),
                        Text(p.title, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 12),
                        Text(p.body, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _index ? scheme.primary : scheme.primary.withOpacity(0.2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  if (_index == _pages.length - 1) {
                    _finish();
                  } else {
                    _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.ease);
                  }
                },
                child: Text(_index == _pages.length - 1 ? 'Tayyor' : 'Keyingisi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
