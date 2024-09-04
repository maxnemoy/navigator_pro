import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:navigator_pro/bs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      routeInformationParser: MyRouteInformationParser(),
      routerDelegate: MyRouterDelegate(),
    );
  }
}

class MyRouteInformationParser extends RouteInformationParser<RouteInformation> {
  @override
  Future<RouteInformation> parseRouteInformation(RouteInformation routeInformation) async {
    return routeInformation;
  }

  @override
  RouteInformation restoreRouteInformation(RouteInformation configuration) {
    return configuration;
  }
}

class MyRouterDelegate extends RouterDelegate<RouteInformation> with ChangeNotifier {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppRouter(
        initial: RouteSetting(path: '/home', page: const MaterialPage(child: HomePage())),
        child: Builder(
          builder: (context) => ValueListenableBuilder<RouteConfig>(
            valueListenable: AppRouter.of(context).currentConfig,
            builder: (context, config, _) => Scaffold(
              body: Navigator(
                pages: AppRouter.of(context).currentStack.toPages(),
                onPopPage: (route, result) {
                  return route.didPop(result);
                },
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: AppRouter.of(context).currentSegment.value == 'home' ? 0 : 1,
                onTap: (index) {
                  if (index == 0) {
                    AppRouter.of(context)
                        .push(RouteSetting(path: '/home', page: const MaterialPage(child: HomePage())));
                  } else {
                    AppRouter.of(context)
                        .push(RouteSetting(path: '/settings', page: const MaterialPage(child: SettingPage())));
                  }
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    notifyListeners();
  }

  @override
  Future<bool> popRoute() async {
    return true;
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        leading: const CustomBackButton(),
      ),
      body: Column(
        children: [
          Text('homePage'),
          ElevatedButton(
            onPressed: () {
              AppRouter.of(context).push(RouteSetting(path: '/home/sub', page: const MaterialPage(child: SubPage())));
            },
            child: const Text('TO sub page'),
          ),
        ],
      ),
    );
  }
}

class SubPage extends StatelessWidget {
  const SubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sub Page'),
        leading: const CustomBackButton(),
      ),
      body: ElevatedButton(
        onPressed: () {
          final router = AppRouter.of(context);
          router.push(
            RouteSetting(
              path: router.currentSegment.value + '/sub',
              page: const BottomSheetPage(child: SubPage()),
            ),
          );
        },
        child: const Text('TO sub page'),
      ),
    );
  }
}

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting Page'),
        leading: const CustomBackButton(),
      ),
      body: Text('setting page'),
    );
  }
}

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppRouter.of(context).canPop
        ? BackButton(
            onPressed: () {
              AppRouter.of(context).pop();
            },
          )
        : const SizedBox();
  }
}

class AppRouter extends InheritedWidget with _Router {
  final RouteSetting initial;
  AppRouter({super.key, required super.child, required this.initial}) {
    push(initial);
  }

  static AppRouter of(BuildContext context) => maybeOf(context) ?? _notFoundInheritedWidgetOfExactType();

  static AppRouter? maybeOf(BuildContext context) =>
      context.getElementForInheritedWidgetOfExactType<AppRouter>()?.widget as AppRouter?;

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
        'Out of scope, not found inherited widget '
            'a AppRouter of the exact type',
        'out_of_scope',
      );

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

mixin _Router on InheritedWidget {
  final ValueNotifier<RouteConfig> _currentConfig = ValueNotifier<RouteConfig>(RouteConfig());
  final ValueNotifier<String> _currentSegment = ValueNotifier<String>('');

  ValueListenable<RouteConfig> get currentConfig => _currentConfig;
  List<RouteSetting> get currentStack => _currentConfig.value[_currentSegment.value];
  ValueListenable<String> get currentSegment => _currentSegment;

  bool get canPop => _currentConfig.value[_currentSegment.value].length > 1;

  void push(RouteSetting route) {
    _currentSegment.value = route.uri.pathSegments.first;
    _currentConfig.value = _currentConfig.value.addRoute(route);
  }

  void pop() {
    _currentConfig.value = _currentConfig.value.removeLast(_currentSegment.value);
  }
}

class RouteConfig {
  final Map<String, List<RouteSetting>> _routes = {};

  List<RouteSetting> operator [](String key) => _routes[key] ?? [];

  RouteConfig addRoute(RouteSetting route) {
    final key = route.uri.pathSegments;
    if (_routes.containsKey(key.first)) {
      _routes[key.first]!.add(route);
    } else {
      _routes[key.first] = [route];
    }

    return this;
  }

  RouteConfig removeLast(String segment) {
    if (_routes.containsKey(segment)) {
      if (_routes[segment]!.length > 1) {
        _routes[segment]!.removeLast();
      }
    }

    return this;
  }

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => super.hashCode;
}

class RouteSetting<T, P extends Page<T>> {
  final String path;
  final P page;
  RouteSetting({required this.path, required this.page});

  Uri get uri => Uri.parse(path);
}

extension SegmentsToPages on List<RouteSetting> {
  List<Page> toPages() => map((e) => e.page).toList();
}
