import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Model for the exit survey data
class SurveyResponseModel extends Equatable {
  const SurveyResponseModel({
    required this.appHelpfulness,
    required this.appDifficulty,
    required this.improvementSuggestion,
    this.surveySubmittedOn,
  });

  factory SurveyResponseModel.fromMap(Map<String, dynamic> map) {
    return SurveyResponseModel(
      appHelpfulness: map['appHelpfulness'] as int,
      appDifficulty: map['appDifficulty'] as int,
      improvementSuggestion: map['improvementSuggestion'] as String,
      surveySubmittedOn: map['surveySubmittedOn'] as Timestamp?,
    );
  }

  factory SurveyResponseModel.fromJson(String source) =>
      SurveyResponseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  /// How helpful was the app in managing this case?
  /// 1: Not helpful at all
  /// 2: Mildly helpful
  /// 3: Moderately helpful
  /// 4: Very helpful
  final int appHelpfulness;

  /// How difficult was it to use the app? (reverse coded)
  /// 1: Very easy
  /// 2: Mostly easy
  /// 3: Somewhat difficult
  /// 4: Very difficult
  final int appDifficulty;

  /// What's one thing you would improve or change about the app?
  final String improvementSuggestion;

  /// Timestamp when the survey was submitted
  final Timestamp? surveySubmittedOn;

  SurveyResponseModel copyWith({
    int? appHelpfulness,
    int? appDifficulty,
    String? improvementSuggestion,
    Timestamp? surveySubmittedOn,
  }) {
    return SurveyResponseModel(
      appHelpfulness: appHelpfulness ?? this.appHelpfulness,
      appDifficulty: appDifficulty ?? this.appDifficulty,
      improvementSuggestion:
          improvementSuggestion ?? this.improvementSuggestion,
      surveySubmittedOn: surveySubmittedOn ?? this.surveySubmittedOn,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'appHelpfulness': appHelpfulness,
      'appDifficulty': appDifficulty,
      'improvementSuggestion': improvementSuggestion,
      'surveySubmittedOn': surveySubmittedOn,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  bool get stringify => true;

  @override
  List<Object?> get props =>
      [appHelpfulness, appDifficulty, improvementSuggestion, surveySubmittedOn];
}
