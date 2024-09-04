import 'package:flutter/material.dart';

class BottomSheetPage<T> extends Page<T> {
  final Widget child;

  const BottomSheetPage({required this.child});

  @override
  Route<T> createRoute(BuildContext context) {
    return BottomSheetRoute<T>(builder: (context) => child);
  }
}

class BottomSheetRoute<T> extends ModalRoute<T> {
  final WidgetBuilder builder;

  BottomSheetRoute({required this.builder});

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  String get barrierLabel => 'Dismiss';

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  @override
  bool get opaque => true;
}
