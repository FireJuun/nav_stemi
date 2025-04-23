import 'package:easy_debounce/easy_debounce.dart';

const kDebounceDuration = Duration(milliseconds: 250);

void localDebouncer(
  String tag,
  EasyDebounceCallback onExecute, [
  Duration duration = kDebounceDuration,
]) =>
    EasyDebounce.debounce(tag, duration, onExecute);

void cancelLocalDebouncer(String tag) => EasyDebounce.cancel(tag);
