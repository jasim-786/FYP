import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart'
    hide TextDirection; // Hide in case of conflict
import 'package:flutter/material.dart' as material
    show TextDirection; // Import explicitly
import 'package:flutter/services.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/SplashScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);
  await Hive.openBox('offline_feedbacks');
  await Hive.openBox('offline_detections');

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Get saved language preference
  final prefs = await SharedPreferences.getInstance();
  String? savedLanguage = prefs.getString('language_code');

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ur'),
        Locale('pa'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: savedLanguage != null ? Locale(savedLanguage) : null,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void _hideNavBarAgain() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: const _LocalizedApp(),
      onTap: _hideNavBarAgain,
    );
  }
}

class _LocalizedApp extends StatelessWidget {
  const _LocalizedApp();

  @override
  Widget build(BuildContext context) {
    // Determine text direction based on language
    final isRtlLanguage = context.locale.languageCode == 'ar' ||
        context.locale.languageCode == 'ur' ||
        context.locale.languageCode == 'pa';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      theme: ThemeData.light(), // Use light theme by default
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      // Add this builder to ensure proper RTL support
      builder: (context, child) {
        return Directionality(
          // Use fully qualified path to TextDirection
          textDirection: isRtlLanguage
              ? material.TextDirection.rtl
              : material.TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
}
