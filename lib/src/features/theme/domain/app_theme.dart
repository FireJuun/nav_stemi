// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// source: https://github.com/MayJuun/wvems_protocols/tree/main/lib/src/features/theme

ThemeMode _themeModeFromString(String data) {
  return switch (data) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    'system' => ThemeMode.system,
    String() => ThemeMode.light,
  };
}

class AppTheme extends Equatable {
  const AppTheme({
    required this.themeMode,
    required this.seedColor,
    this.secondarySeedColor,
    this.tertiarySeedColor,
  });

  final ThemeMode themeMode;
  final Color seedColor;
  final Color? secondarySeedColor;
  final Color? tertiarySeedColor;

  AppTheme copyWith({
    ThemeMode? themeMode,
    Color? seedColor,
    Color? secondarySeedColor,
    Color? tertiarySeedColor,
  }) {
    return AppTheme(
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
      secondarySeedColor: secondarySeedColor ?? this.secondarySeedColor,
      tertiarySeedColor: tertiarySeedColor ?? this.tertiarySeedColor,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'themeMode': themeMode.name,
      'seedColor': seedColor.value,
      'secondarySeedColor': secondarySeedColor?.value,
      'tertiarySeedColor': tertiarySeedColor?.value,
    };
  }

  factory AppTheme.fromMap(Map<String, dynamic> map) {
    return AppTheme(
      themeMode: _themeModeFromString(map['themeMode'] as String),
      seedColor: Color(map['seedColor'] as int),
      secondarySeedColor: map['secondarySeedColor'] != null
          ? Color(map['secondarySeedColor'] as int)
          : null,
      tertiarySeedColor: map['tertiarySeedColor'] != null
          ? Color(map['tertiarySeedColor'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppTheme.fromJson(String source) =>
      AppTheme.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props =>
      [themeMode, seedColor, secondarySeedColor, tertiarySeedColor];
}
