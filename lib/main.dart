import 'package:flutter/material.dart';
import 'package:random_image/state/image_state.dart';
import 'package:random_image/state/theme_state.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';
import 'image_page.dart';

void main() {
  // Disable verbose Signals logging in production
  SignalsObserver.instance = null;

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create theme state at the top level
    return MultiProvider(
      providers: [
        Provider<ThemeState>(
          create: (_) => ThemeState(),
          dispose: (_, state) => state.dispose(),
        ),
      ],
      child: const MainAppContent(),
    );
  }
}

class MainAppContent extends StatelessWidget {
  const MainAppContent({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = context.read<ThemeState>();

    return Watch((context) {
      return MaterialApp(
        key: const ValueKey('main_app'),
        title: 'Random Image Display',
        theme: ThemeData(
          brightness: Brightness.light,
          useMaterial3: true,
          colorSchemeSeed: Colors.amber,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorSchemeSeed: Colors.amber,
        ),
        themeMode: themeState.themeMode.value,
        debugShowCheckedModeBanner: false,
        home: Builder(
          builder: (context) {
            final supportsAnnounce = MediaQuery.of(context).supportsAnnounce;

            return Provider<ImageState>(
              create: (_) =>
                  ImageState(useSemanticAnnouncements: supportsAnnounce),
              dispose: (_, state) => state.dispose(),
              child: const ImagePage(key: ValueKey('image_page')),
            );
          },
        ),
        // Builder to provide semantic labels for navigation
        builder: (context, child) {
          return Semantics(
            label: 'Random Image Display',
            child: child ?? const SizedBox.shrink(),
          );
        },
      );
    });
  }
}
