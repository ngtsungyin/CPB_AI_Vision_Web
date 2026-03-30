import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cpbaivision_app/features/auth/services/session_notice.dart';

class SessionTimeoutWrapper extends StatefulWidget {
  final Widget child;
  final Duration timeout;

  const SessionTimeoutWrapper({
    super.key,
    required this.child,
    this.timeout = const Duration(minutes: 15),
  });

  @override
  State<SessionTimeoutWrapper> createState() => _SessionTimeoutWrapperState();
}

class _SessionTimeoutWrapperState extends State<SessionTimeoutWrapper>
    with WidgetsBindingObserver {
  Timer? _idleTimer;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _idleTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isSigningOut) return;

    if (state == AppLifecycleState.resumed) {
      _resetTimer();
    }
  }

  void _resetTimer() {
    if (_isSigningOut) return;

    _idleTimer?.cancel();
    _idleTimer = Timer(widget.timeout, _handleTimeout);
  }

  Future<void> _handleTimeout() async {
    if (_isSigningOut) return;
    _isSigningOut = true;

    try {
      SessionNotice.show('Session expired due to inactivity. Please sign in again.');
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      SessionNotice.show('Session expired. Please sign in again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerSignal: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}