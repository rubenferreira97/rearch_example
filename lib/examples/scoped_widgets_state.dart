import 'package:flutter/material.dart';
import 'package:flutter_rearch/flutter_rearch.dart';
import 'package:go_router/go_router.dart';
import 'package:rearch/rearch.dart';
import 'package:rearch_example/examples/common/types.dart';

// Feedback & Questions:
//
// 1. This capsule is not being disposed when `ShareMultipleStatePage` widget is
// removed from the widget tree. Is this a bug or by design? If by design, how
// can we autoDispose the capsule when the widget is removed from the widget tree?

CountManager scopedWidgetsCountManager(CapsuleHandle use) {
  final (count, setCount) = use.data(0);
  return (
    count: count,
    incrementCount: () => setCount(count() + 1),
  );
}

class ScopedWidgetsStatePage extends StatelessWidget {
  const ScopedWidgetsStatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoped Widgets Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('`countManager` should not in memory here.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/scoped-widgets/share-multiple'),
              child: const Text('Shared State'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/scoped-widgets/disposed'),
              child: const Text('Disposed State'),
            ),
          ],
        ),
      ),
    );
  }
}

class ShareMultipleStatePage extends RearchConsumer {
  const ShareMultipleStatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetHandle use) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shared State')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('`countManager` should have been created.'),
            const SizedBox(height: 16),
            const SharedState(),
            const SizedBox(height: 16),
            const SharedState(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.go('/scoped-widgets/share-multiple/share-nested'),
              child: const Text('Go to Shared Nested State'),
            ),
          ],
        ),
      ),
    );
  }
}

class SharedState extends RearchConsumer {
  const SharedState({super.key});

  @override
  Widget build(BuildContext context, WidgetHandle use) {
    final (:count, :incrementCount) = use(scopedWidgetsCountManager);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('You have pushed the button this many times:'),
        Text('${count()}'),
        ElevatedButton(
          onPressed: incrementCount,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}

class ShareInnerStatePage extends RearchConsumer {
  const ShareInnerStatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetHandle use) {
    final (:count, :incrementCount) = use(scopedWidgetsCountManager);
    return Scaffold(
      appBar: AppBar(title: const Text('Shared Nested State')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('`countManager` should have the same state.'),
            const SizedBox(height: 16),
            const Text('You have pushed the button this many times:'),
            Text('${count()}'),
            ElevatedButton(
              onPressed: incrementCount,
              child: const Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}

class ScopedWidgetsDisposedPage extends RearchConsumer {
  const ScopedWidgetsDisposedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetHandle use) {
    // This is a `RearchConsumer` because we could use a different capsule here
    // unrelated to `countManager`.
    return Scaffold(
      appBar: AppBar(title: const Text('Scoped State Disposed')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('`countManager` should not in memory here.'),
          ],
        ),
      ),
    );
  }
}
