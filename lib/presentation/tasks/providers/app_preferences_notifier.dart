import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/di/providers.dart';

class AppPreferencesState {
  const AppPreferencesState({
    required this.themeMode,
    required this.archiveAfterDays,
  });

  final ThemeMode themeMode;
  final int archiveAfterDays;

  AppPreferencesState copyWith({
    ThemeMode? themeMode,
    int? archiveAfterDays,
  }) {
    return AppPreferencesState(
      themeMode: themeMode ?? this.themeMode,
      archiveAfterDays: archiveAfterDays ?? this.archiveAfterDays,
    );
  }
}

final appPreferencesProvider =
    NotifierProvider<AppPreferencesNotifier, AppPreferencesState>(
  AppPreferencesNotifier.new,
);

class AppPreferencesNotifier extends Notifier<AppPreferencesState> {
  @override
  AppPreferencesState build() {
    _settingsBox = ref.watch(settingsBoxProvider);
    final settingsBox = _settingsBox!;
    return AppPreferencesState(
      themeMode: _readThemeMode(settingsBox),
      archiveAfterDays: (settingsBox.get('archive_after_days') as int?) ?? 7,
    );
  }

  Box<dynamic>? _settingsBox;

  static ThemeMode _readThemeMode(Box<dynamic> box) {
    final raw = box.get('theme_mode') as String?;
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _settingsBox?.put('theme_mode', mode.name);
  }

  Future<void> cycleThemeMode() async {
    final next = switch (state.themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setThemeMode(next);
  }

  Future<void> setArchiveAfterDays(int days) async {
    final normalized = days.clamp(1, 365);
    state = state.copyWith(archiveAfterDays: normalized);
    await _settingsBox?.put('archive_after_days', normalized);
  }
}

