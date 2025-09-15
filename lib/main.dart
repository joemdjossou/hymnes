import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
        ChangeNotifierProvider(create: (_) => MidiBloc()),
      ],
      child: MaterialApp(
        title: 'Hymnes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
