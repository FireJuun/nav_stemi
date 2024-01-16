import 'package:equatable/equatable.dart';

class Distance extends Equatable {
  const Distance({this.text, this.value});

  final String? text;
  final int? value;

  factory Distance.fromJson(Map<String, Object?> json) => Distance(
        text: json['text'] as String?,
        value: json['value'] as int?,
      );

  Map<String, Object?> toJson() => {
        'text': text,
        'value': value,
      };

  Distance copyWith({
    String? text,
    int? value,
  }) {
    return Distance(
      text: text ?? this.text,
      value: value ?? this.value,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [text, value];
}
