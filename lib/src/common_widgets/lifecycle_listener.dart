import 'package:flutter/widgets.dart';

/// A widget that listens to the application lifecycle state changes.
///
/// This widget allows registering callbacks for various app lifecycle events
/// such as show, resume, hide, inactive, pause, detach, and restart.
///
/// The [child] widget will be rendered with the lifecycle listener attached.
class LifecycleListener extends StatefulWidget {
  const LifecycleListener({
    required this.child,
    super.key,
    this.onShow,
    this.onResume,
    this.onHide,
    this.onInactive,
    this.onPause,
    this.onDetach,
    this.onRestart,
    this.onStateChange,
  });

  final VoidCallback? onShow;
  final VoidCallback? onResume;
  final VoidCallback? onHide;
  final VoidCallback? onInactive;
  final VoidCallback? onPause;
  final VoidCallback? onDetach;
  final VoidCallback? onRestart;
  final ValueChanged<AppLifecycleState>? onStateChange;
  final Widget child;

  @override
  State<LifecycleListener> createState() => _LifecycleListenerState();
}

class _LifecycleListenerState extends State<LifecycleListener> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();

    _listener = AppLifecycleListener(
      onShow: widget.onShow,
      onResume: widget.onResume,
      onHide: widget.onHide,
      onInactive: widget.onInactive,
      onPause: widget.onPause,
      onDetach: widget.onDetach,
      onRestart: widget.onRestart,
      onStateChange: widget.onStateChange,
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
