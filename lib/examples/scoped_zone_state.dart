import 'package:flutter_rearch/flutter_rearch.dart';
import 'package:flutter/material.dart';
import 'package:rearch/rearch.dart';
import 'package:rearch_example/examples/common/types.dart';

// Feedback & Questions:
//
// 1. Could not follow the documentation since `use` is a `WidgetHandle`
//    but `CapsuleHandle` is expected.

// 2. Seems too much boilerplate code to create a scoped zone. Couldn't
//    this be generalized in a way that `RearchBootstrapper` is a zone widget
//    (maybe rename to `RearchZone` or `RearchScope`) that has a container
//    of capsules that can be loaded and used by any widget in the zone?
//    Then all `use` calls in the zone would be able to access that capsules in
//    this zone.

//    `app.dart`
//    RearchZone(
//      child: Column(
//        children:[
//          RearchZone(
//            capsules: [myCapsule],
//            child: Counter(), // This one will use the capsule in the inner `RearchZone`.
//          ),
//          Counter(), // This one will create a new capsule on the outer `RearchZone`
//        ],
//      )
//    ),

//    `Counter` is a RearchConsumer. If it `use` a capsule present in
//    `RearchZone` it will use that one, if a capsule is not present it will
//    create a new one and add it to the zone container.
//    Maybe `RearchZone.strict` could be used to throw an error if a capsule
//    is not found in the zone. Don't know if this is a good idea, since I don't
//    know how it could not throw on ephemeral state where is needed to create a
//    new capsule.
//
//    `Counter` build:
//
//    final (:count, :incrementCount) = use(myCapsule);
//    Text('${count()}'),
//    ElevatedButton(
//      onPressed: incrementCount,
//      child: const Text('Increment'),
//    ),

CountManager scopedZoneCountManager(CapsuleHandle use) {
  final (count, setCount) = use.data(0);
  return (
    count: count,
    incrementCount: () => setCount(count() + 1),
  );
}

class ScopedZoneStatePage extends RearchConsumer {
  const ScopedZoneStatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetHandle use) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scoped Zone Example')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ScopedCount(
            child: Builder(
              builder: (context) {
                final (:count, incrementCount: _) = ScopedCount.of(context);
                return Text('$count');
              },
            ),
          ),
          const Text('Unscoped zone'),
        ],
      ),
    );
  }
}

class ScopedCount extends RearchConsumer {
  const ScopedCount({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetHandle use) {
    return _ScopedCount(
      // How to fix `_TypeError (type '_WidgetHandleImpl' is not a subtype of
      // type 'CapsuleHandle' in type cast)` here, `use` is `WidgetHandle`
      // but `CapsuleHandle` is expected.
      // Placing a cast here for compilation
      scopedZoneCountManager(use as CapsuleHandle),
      child: child,
    );
  }

  static _ScopedCount? _maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ScopedCount>();

  static _ScopedCount _of(BuildContext context) {
    final widget = _maybeOf(context);
    assert(widget != null, 'No ScopedCount found in context');
    return widget!;
  }

  static CountManager? maybeOf(BuildContext context) =>
      _maybeOf(context)?._data;

  static CountManager of(BuildContext context) => _of(context)._data;
}

class _ScopedCount extends InheritedWidget {
  const _ScopedCount(this._data, {required super.child});
  final CountManager _data;
  @override
  bool updateShouldNotify(_ScopedCount oldWidget) => oldWidget._data != _data;
}
