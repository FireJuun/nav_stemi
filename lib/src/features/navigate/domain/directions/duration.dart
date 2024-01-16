import 'package:equatable/equatable.dart';

class Duration extends Equatable {
  const Duration({this.text, this.value});

  final String? text;
  final int? value;

  factory Duration.fromJson(Map<String, Object?> json) => Duration(
        text: json['text'] as String?,
        value: json['value'] as int?,
      );

  Map<String, Object?> toJson() => {
        'text': text,
        'value': value,
      };

  Duration copyWith({
    String? text,
    int? value,
  }) {
    return Duration(
      text: text ?? this.text,
      value: value ?? this.value,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [text, value];
}
