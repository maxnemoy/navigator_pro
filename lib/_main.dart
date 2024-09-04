// import 'package:flutter/material.dart';

// void main() {
//   runApp(App());
// }

// class App extends StatelessWidget {
//   final RecipeRouteDelegate _recipeRouteDelegate = RecipeRouteDelegate();
//   final RecipeRouteInformationParser _informationParser = RecipeRouteInformationParser();

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       title: 'Nested Route',
//       routeInformationParser: _informationParser,
//       routerDelegate: _recipeRouteDelegate,
//     );
//   }
// }

// class RecipeRouteDelegate extends RouterDelegate<RecipeRoutePath>
//     with ChangeNotifier, PopNavigatorRouterDelegateMixin<RecipeRoutePath> {
//   final GlobalKey<NavigatorState> navigatorKey;

//   // get app state instance
//   CakeRecipeState appState = CakeRecipeState();

//   RecipeRouteDelegate() : navigatorKey = GlobalKey<NavigatorState>() {
//     appState.addListener(notifyListeners);
//   }

//   @override
//   Future<void> setNewRoutePath(RecipeRoutePath config) async {
//     if (config is RecipeListPath) {
//       // homeScreen
//       appState.selectedIndex = 0;
//       appState.selectedRecipe = null;
//     } else if (config is RecipeDetailsPath) {
//       // nested home/ details screen
//       appState.setSelectedRecipeById(config.id);
//     } else if (config is RecipeSettingPath) {
//       // setting screen
//       appState.selectedIndex = 1;
//     }
//   }

//   // @override
//   Widget build(BuildContext context) {
//     return Navigator(
//       key: navigatorKey,
//       onPopPage: (route, result) {
//         if (!route.didPop(result)) {
//           return false;
//         }
//         if (appState.selectedRecipe != null) {
//           appState.selectedRecipe = null;
//         }
//         notifyListeners();
//         return true;
//       },
//       pages: [
//         MaterialPage(
//           child: AppShell(appState: appState), // appShell
//         ),
//       ],
//     );
//   }

//   RecipeRoutePath get currentConfig {
//     if (appState.selectedIndex == 1) {
//       return RecipeSettingPath();
//     } else {
//       if (appState.selectedRecipe == null) {
//         return RecipeListPath();
//       } else {
//         return RecipeDetailsPath(appState.getSelectedRecipeById());
//       }
//     }
//   }
// }

// class RecipeRouteInformationParser extends RouteInformationParser<RecipeRoutePath> {
//   @override
//   Future<RecipeRoutePath> parseRouteInformation(RouteInformation routeInformation) async {
//     final uri = Uri.parse(routeInformation.location);

//     if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'settings') {
//       return RecipeSettingPath();
//     } else {
//       if (uri.pathSegments.length >= 2) {
//         if (uri.pathSegments[0] == 'recipe') {
//           return RecipeDetailsPath(int.tryParse(uri.pathSegments[1]) ?? 0);
//         }
//       }
//       return RecipeListPath();
//     }
//   }

//   @override
//   RouteInformation restoreRouteInformation(RecipeRoutePath config) {
//     if (config is RecipeListPath) {
//       return RouteInformation(location: '/home');
//     }
//     if (config is RecipeDetailsPath) {
//       return RouteInformation(location: '/recipe/${config.id}');
//     }
//     if (config is RecipeSettingPath) {
//       return RouteInformation(location: '/settings');
//     }
//     return RouteInformation(location: '/home');
//   }
// }

// class InnerRouteDelegate extends RouterDelegate<RecipeRoutePath>
//     with ChangeNotifier, PopNavigatorRouterDelegateMixin<RecipeRoutePath> {
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   CakeRecipeState _appState;

//   CakeRecipeState get appState => _appState;

//   set appState(CakeRecipeState newState) {
//     if (newState == _appState) {
//       return;
//     }
//     _appState = newState;
//     notifyListeners();
//   }

//   InnerRouteDelegate(this._appState);

//   @override
//   Widget build(BuildContext context) {
//     return Navigator(
//       key: this.navigatorKey,
//       pages: [
//         if (appState.selectedIndex == 0) ...[
//           FadeAnimationPage(
//             child: RecipeListScreen(
//               recipes: appState.recipes,
//               onTap: (recipe) {
//                 appState.selectedRecipe = recipe;
//                 notifyListeners();
//               },
//             ),
//           ),
//           if (appState.selectedRecipe != null)
//             MaterialPage(
//               key: ValueKey(appState.selectedRecipe),
//               child: RecipeDetailsScreen(
//                 recipe: appState.selectedRecipe!,
//                 key: ValueKey(appState),
//               ),
//             )
//         ] else
//           FadeAnimationPage(
//             child: SettingScreen(),
//             key: ValueKey('Setting'),
//           )
//       ],
//       onPopPage: (route, result) {
//         appState.selectedRecipe = null;
//         notifyListeners();
//         return route.didPop(result);
//       },
//     );
//   }

//   @override
//   Future<void> setNewRoutePath(RecipeRoutePath config) async {
//     assert(true);
//   }
// }

// abstract class RecipeRoutePath {}

// class RecipeDetailsPath extends RecipeRoutePath {
//   final int id;

//   RecipeDetailsPath(this.id);
// }

// class RecipeListPath extends RecipeRoutePath {}

// class RecipeSettingPath extends RecipeRoutePath {}

// class FadeAnimationPage extends Page {
//   final Widget child;

//   const FadeAnimationPage({super.key, required this.child});

//   @override
//   Route createRoute(BuildContext context) {
//     return PageRouteBuilder(
//         settings: this,
//         pageBuilder: (_, anime1, anime2) {
//           var curveTween = CurveTween(curve: Curves.easeIn);
//           return FadeTransition(
//             opacity: anime1.drive(curveTween),
//             child: this.child,
//           );
//         });
//   }
// }

// class RecipeDetailsScreen extends StatelessWidget {
//   final ValueKey key;
//   final Recipe recipe;

//   const RecipeDetailsScreen({required this.key, required this.recipe});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(recipe.name, style: Theme.of(context).textTheme.headlineMedium),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(recipe.category, style: Theme.of(context).textTheme.titleLarge),
//                 Text(recipe.chef, style: Theme.of(context).textTheme.labelSmall),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class RecipeListScreen extends StatelessWidget {
//   final List<Recipe> recipes;
//   final ValueChanged<Recipe> onTap;

//   const RecipeListScreen({
//     required this.recipes,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Recipes'),
//       ),
//       body: ListView(
//         children: [
//           for (var recipe in this.recipes)
//             ListTile(
//               title: Text(recipe.name),
//               subtitle: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(recipe.category),
//                   Text(recipe.chef),
//                 ],
//               ),
//               onTap: () => onTap(recipe),
//             )
//         ],
//       ),
//     );
//   }
// }

// class SettingScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Settings'),
//       ),
//       body: Column(
//         children: [
//           Text('Settings'),
//           ElevatedButton(onPressed: (){Navigator.of(context).}, child: child)
//         ],
//       ),
//     );
//   }
// }

// class Recipe {
//   final String name;
//   final String category;
//   final String chef;

//   Recipe({required this.category, required this.chef, required this.name});
// }

// class CakeRecipeState extends ChangeNotifier {
//   int _selectedIndex;
//   Recipe? _selectedRecipe;

//   final List<Recipe> recipes = [
//     Recipe(name: 'Pumpkin Cake', category: 'Squash recipes', chef: 'Sue Case'),
//     Recipe(name: "Grandma's Chocolate Texas Sheet Cake", category: 'Sheet cake', chef: 'Bakah Miller'),
//     Recipe(name: 'Apple Upside-Down cake', category: 'Apple desserts', chef: 'Amber'),
//     Recipe(name: 'Maple Buttercream Frosting', category: 'Buttercream frosting', chef: 'Sarah'),
//   ];

//   CakeRecipeState() : _selectedIndex = 0;

//   int get selectedIndex => _selectedIndex;

//   set selectedIndex(int v) {
//     _selectedIndex = v;
//     if (_selectedIndex == 1) {
//       _selectedRecipe = null;
//     }
//     notifyListeners();
//   }

//   set selectedRecipe(Recipe? value) {
//     _selectedRecipe = value;
//     notifyListeners();
//   }

//   Recipe? get selectedRecipe => _selectedRecipe;

//   int getSelectedRecipeById() {
//     if (_selectedRecipe == null) return 0;
//     if (!recipes.contains(_selectedRecipe)) return 0;
//     return recipes.indexOf(_selectedRecipe!);
//   }

//   void setSelectedRecipeById(int id) {
//     if (id < 0 || id > recipes.length - 1) {
//       return;
//     }
//     _selectedRecipe = recipes[id];
//     notifyListeners();
//   }
// }

// class AppShell extends StatefulWidget {
//   CakeRecipeState appState;

//   AppShell({required this.appState});

//   @override
//   _AppState createState() => _AppState();
// }

// class _AppState extends State<AppShell> {
//   InnerRouteDelegate? _innerRouteDelegate;
//   ChildBackButtonDispatcher? _backButtonDispatcher;

//   @override
//   void initState() {
//     super.initState();
//     _innerRouteDelegate = InnerRouteDelegate(widget.appState);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _backButtonDispatcher = Router.of(context).backButtonDispatcher?.createChildBackButtonDispatcher();
//   }

//   @override
//   void didUpdateWidget(covariant AppShell oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     _innerRouteDelegate?.appState = widget.appState;
//   }

//   @override
//   Widget build(BuildContext context) {
//     var appState = widget.appState;
//     return Scaffold(
//       body: Router(
//         routerDelegate: _innerRouteDelegate!,
//         backButtonDispatcher: _backButtonDispatcher,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'Settings',
//           ),
//         ],
//         currentIndex: appState.selectedIndex,
//         onTap: (inx) {
//           appState.selectedIndex = inx;
//         },
//       ),
//     );
//   }
// }
