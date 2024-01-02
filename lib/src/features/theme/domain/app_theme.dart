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
  const AppTheme({required this.themeMode, required this.seedColor});

  final ThemeMode themeMode;
  final Color seedColor;

  @override
  List<Object> get props => [themeMode, seedColor];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'themeMode': themeMode.name,
      'seedColor': seedColor.value,
    };
  }

  factory AppTheme.fromMap(Map<String, dynamic> map) => AppTheme(
        themeMode: _themeModeFromString(map['themeMode'] as String),
        seedColor: Color(map['seedColor'] as int),
      );

  String toJson() => json.encode(toMap());

  factory AppTheme.fromJson(String source) =>
      AppTheme.fromMap(json.decode(source) as Map<String, dynamic>);
}
