import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'l10n/generated/app_localizations.dart';
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';
import 'providers/usage_provider.dart';
import 'providers/lesson_timer_provider.dart';
import 'screens/home/home_screen.dart';
import 'services/activity_recognition_service.dart';
import 'services/family_sync_scheduler.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();
  ActivityRecognitionService.instance.start(); // asks once; OS remembers the decision after that
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(url: SupabaseConfig.url, anonKey: SupabaseConfig.anonKey);
    FamilySyncScheduler.instance.start();
  }

  // Draw the app's content behind the Android system navigation bar
  // (Back/Home/Recent area) too, so the app's real background shows
  // through there — the actual icon/bar colors are set reactively
  // below (AnnotatedRegion), based on the active theme's brightness,
  // so they stay legible regardless of which theme/background is chosen.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const FocusLifeTrackerApp());
}

class FocusLifeTrackerApp extends StatelessWidget {
  const FocusLifeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasksForSelectedDay()),
        ChangeNotifierProvider(create: (_) => UsageProvider()),
        ChangeNotifierProvider(create: (_) => LessonTimerProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  settings.themeData.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarDividerColor: Colors.transparent,
              systemNavigationBarIconBrightness:
                  settings.themeData.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
            ),
            child: MaterialApp(
              title: 'Focus & Life Tracker',
              debugShowCheckedModeBanner: false,
              theme: settings.themeData,
              locale: Locale(settings.settings.locale),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('uz'),
                Locale('am'),
                Locale('ar'),
                Locale('az'),
                Locale('bg'),
                Locale('bn'),
                Locale('bs'),
                Locale('cs'),
                Locale('da'),
                Locale('de'),
                Locale('el'),
                Locale('en'),
                Locale('es'),
                Locale('fa'),
                Locale('fi'),
                Locale('fr'),
                Locale('he'),
                Locale('hi'),
                Locale('hr'),
                Locale('hu'),
                Locale('hy'),
                Locale('id'),
                Locale('it'),
                Locale('ja'),
                Locale('ka'),
                Locale('kk'),
                Locale('ko'),
                Locale('ky'),
                Locale('mn'),
                Locale('ms'),
                Locale('nl'),
                Locale('no'),
                Locale('pa'),
                Locale('pl'),
                Locale('ps'),
                Locale('pt'),
                Locale('ro'),
                Locale('ru'),
                Locale('sk'),
                Locale('sr'),
                Locale('sv'),
                Locale('sw'),
                Locale('ta'),
                Locale('te'),
                Locale('tg'),
                Locale('th'),
                Locale('tk'),
                Locale('tl'),
                Locale('tr'),
                Locale('uk'),
                Locale('ur'),
                Locale('vi'),
                Locale('zh'),
              ],
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(settings.settings.fontScale),
                  ),
                  child: child!,
                );
              },
              home: settings.isLoading
                  ? const _SplashScreen()
                  : const HomeScreen(),
            ),
          );
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
