import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/providers/language_provider.dart';
import 'core/services/storage_service.dart';
import 'features/midi/bloc/midi_bloc.dart';
import 'presentation/screens/splash_screen.dart';
import 'shared/constants/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await StorageService().initialize();

  runApp(const HymnesApp());
}

class HymnesApp extends StatelessWidget {
  const HymnesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(
          create: (context) => LanguageBloc()..add(LoadLanguage()),
        ),
        ChangeNotifierProvider(
          create: (context) => MidiBloc(),
        ),
      ],
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, languageState) {
          final locale = languageState is LanguageLoaded
              ? languageState.locale
              : const Locale('fr', 'FR');

          return MaterialApp(
            title: 'Hymnes',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LanguageBloc.supportedLocales,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
