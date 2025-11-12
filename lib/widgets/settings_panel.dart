import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';

import '../state/theme_state.dart';
import '../style/app_layout.dart';

/// Settings panel that slides up from the bottom
class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = context.read<ThemeState>();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: AppLayout.contentPadding(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close settings',
                  ),
                ],
              ),
              SizedBox(height: AppLayout.spacingLarge(context)),

              // Theme switcher
              Watch((context) {
                final isDark = themeState.isDarkMode;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Theme'),
                  subtitle: Text(isDark ? 'Dark mode' : 'Light mode'),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (value) {
                      themeState.setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                  onTap: () => themeState.toggleTheme(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
