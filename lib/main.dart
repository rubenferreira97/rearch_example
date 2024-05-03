import 'package:flutter/material.dart';
import 'package:flutter_rearch/flutter_rearch.dart';
import 'package:go_router/go_router.dart';
import 'package:rearch_example/examples/local_state.dart';
import 'package:rearch_example/examples/scoped_widgets_state.dart';
import 'package:rearch_example/examples/scoped_zone_state.dart';
import 'package:rearch_example/examples/app_state.dart';

// As a flutter developer, I normally want the following scenarios solved by a
// state management library:

// a) Create local state for each new widget instance (Ephemeral/Local state).
//    State should be created and bounded to each new widget instance.
//    State should be disposed when the bounded widget is removed from the widget tree.
//    State should not be shared across multiple widgets in the widget tree. Each
//    widget should have its own state, even if they are of the same type. E.g. a
//    widget instance named `FooWidget` should have its own state that is not
//    shared with another `FooWidget` instance in the widget tree.
//    Changes to this state should trigger a rebuild of the bounded widget.
//    E.g. a `Counter` page that resets when it's popped and pushed again.
//    I could only solve this scenario with a workaround. Creating inline
//    capsules in the widget. This is not ideal since it couples
//    the state to the widget tree and makes it harder to reuse.
//    I would hope we could use something like a capsule factory to create
//    different capsules for each widget instance. Maybe I am missing something.
//    Check `local_state.dart`.

// b) Share state globally across multiple widgets in the widget tree (App/Global State).
//    State should be created once and shared across multiple widgets in the widget tree.
//    State should not be disposed when the dependent widgets are removed from the widget tree.
//    State should be shared across multiple widgets in the widget tree. E.g. a
//    widget named `FooWidget` should have its state shared with another
//    `BarWidget` instance in the widget tree.
//    Changes to this state should trigger a rebuild to the app (or if optimized, only to the dependent widgets).
//    E.g. Theme, User, Locale, Database connection, etc.
//    Rearch seems to solve this scenario by creating a capsule at the app root
//    and caching its value with any widget that uses it. But how can I eagerly
//    initialize the capsule? Does a `use` at the app root create the capsule?
//    Check `app_state.dart`.

// c) Share state scoped to a "zone"
//    State should be created once by a zone widget.
//    State should be disposed when the zone is removed from the widget tree.
//    State can be shared across any widget present in the zone.
//    Changes to this state should trigger a rebuild to the zone (or if optimized, only to the dependent widgets).
//    Seems related to https://rearch.gsconrad.com/flutter/scoping-state.
//    Check `scoped_zone_state.dart`.

// d) Share state scoped to a specific set of widgets in the widget tree.
//    State should be created once by the first widget in the scope.
//    State should be disposed when all widgets in the scope are removed from the
//    widget tree.
//    State should be shared across multiple widgets in the scope. E.g. a widget
//    named `FooWidget` could have this state shared with another `BarWidget` instance.
//    Changes to this state should trigger a rebuild of the dependent widgets.
//    E.g two widgets on different pages that share the same state.
//    Rearch can solve this scenario by sharing a capsule between widgets,
//    however, it does not seem to dispose the capsule when all listeners are
//    removed from the widget tree. Check `scoped_widgets_state.dart`.
//    Check `scoped_widgets_state.dart`.

// In all the above scenarios, state should persist across widget lifecycle
// changes like rebuilds.

/////// Understanding Rearch architecture by asking (dumb?) questions: ///////

// 1. How are capsules created on Flutter? On the first `use` in a `RearchConsumer`?

// 2. If a `RearchConsumer` is removed from the widget tree and added again, is
//    the capsule disposed and recreated (if is the only `use`ing it)? Or is the
//    capsule cached and reused?

// 3. If multiple `RearchConsumer` use the same capsule, are they sharing the
//    same instance or is a new instance created for each widget?

// 4. Would be reasonable to have a `RearchZone`/`RearchScope` widget that
//    replaces the `RearchBootstrapper`? Check `scoped_zone_state.dart`.

void main() => runApp(const RearchExampleApp());

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const RearchExamplesPage(),
      routes: [
        GoRoute(
          path: 'local',
          builder: (context, state) => const LocalStatePage(),
        ),
        GoRoute(
          path: 'app-state',
          builder: (context, state) => const AppStatePage(),
        ),
        GoRoute(
          path: 'scoped-widgets',
          builder: (context, state) => const ScopedWidgetsStatePage(),
          routes: [
            GoRoute(
              path: 'share-multiple',
              builder: (context, state) => const ShareMultipleStatePage(),
              routes: [
                GoRoute(
                  path: 'share-nested',
                  builder: (context, state) => const ShareInnerStatePage(),
                ),
              ],
            ),
            GoRoute(
              path: 'disposed',
              builder: (context, state) => const ScopedWidgetsDisposedPage(),
            ),
          ],
        ),
        GoRoute(
          path: 'scoped-zone',
          builder: (context, state) => const ScopedZoneStatePage(),
        ),
      ],
    ),
  ],
);

class RearchExampleApp extends StatelessWidget {
  const RearchExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RearchBootstrapper(
      child: MaterialApp.router(
        routerConfig: _router,
      ),
    );
  }
}

class RearchExamplesPage extends StatelessWidget {
  const RearchExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rearch Examples'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/local'),
              child: const Text('Local/Ephemeral State'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/app-state'),
              child: const Text('App/Global State'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/scoped-zone'),
              child: const Text('Scoped Zone State'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/scoped-widgets'),
              child: const Text('Scoped Widgets State'),
            ),
          ],
        ),
      ),
    );
  }
}
