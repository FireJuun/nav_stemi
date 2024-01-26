import 'package:equatable/equatable.dart';

class DirectionDuration extends Equatable {
  const DirectionDuration({this.text, this.value});

  final String? text;
  final int? value;

  factory DirectionDuration.fromJson(Map<String, Object?> json) =>
      DirectionDuration(
        text: json['text'] as String?,
        value: json['value'] as int?,
      );

  Map<String, Object?> toJson() => {
        'text': text,
        'value': value,
      };

  DirectionDuration copyWith({
    String? text,
    int? value,
  }) {
    return DirectionDuration(
      text: text ?? this.text,
      value: value ?? this.value,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [text, value];
}
