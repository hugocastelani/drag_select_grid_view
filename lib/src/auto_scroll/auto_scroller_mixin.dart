import 'package:flutter/widgets.dart';

import 'auto_scroll.dart';
import 'auto_scroller.dart';

/// Mixin that collects UI information and gives them to UI-agnostic classes
/// that handle auto-scrolling.
mixin AutoScrollerMixin<T extends StatefulWidget> on State<T> {
  /// Information about the direction and duration of the scroll.
  @visibleForTesting
  AutoScroll autoScroll = AutoScroll.stopped();

  double _widgetHeight;
  double _widgetWidth;

  /// The height of the auto-scroll hotspot.
  ///
  /// Used to check whether an offset is in hotspot's bounds.
  double get autoScrollHotspotHeight;

  /// The controller of the grid's scroll-view.
  ///
  /// Used to perform the auto-scroll.
  ScrollController get controller;

  /// Stores the size of the widget.
  ///
  /// Such information is used to check whether an offset is in hotspot's bounds.
  ///
  /// By doing this once, we are assuming the widget will never change it's size
  /// without calling this method again.
  @override
  @mustCallSuper
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final widgetSize = context.size;
        _widgetHeight = widgetSize.height;
        _widgetWidth = widgetSize.width;
      },
    );
  }

  /// Triggers the auto-scroll.
  ///
  /// This method is going to get called right after calling
  /// [startAutoScrollingForward] or [startAutoScrollingBackward], so it'll take
  /// the updated [autoScroll] and, depending on the information it holds, start
  /// or stop auto-scrolling.
  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    final scroller = AutoScroller(autoScroll, controller);
    if (scroller.mustScroll) scroller.scroll();
    return null;
  }

  /// Returns whether the [localPosition] is in upper-hotspot's bounds.
  bool isInsideUpperAutoScrollHotspot(Offset localPosition) =>
      _isInsideWidget(localPosition) &&
      localPosition.dy <= autoScrollHotspotHeight;

  /// Returns whether the [localPosition] is in lower-hotspot's bounds.
  bool isInsideLowerAutoScrollHotspot(Offset localPosition) =>
      _isInsideWidget(localPosition) &&
      localPosition.dy > (_widgetHeight - autoScrollHotspotHeight);

  /// Scrolls forward indefinitely.
  ///
  /// Nothing is done if forward auto-scroll is already being performed.
  void startAutoScrollingForward() {
    _updateAutoScrollIfDifferent(
      AutoScroll(
        direction: AutoScrollDirection.forward,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Scrolls backward indefinitely.
  ///
  /// Nothing is done if backward auto-scroll is already being performed.
  void startAutoScrollingBackward() {
    _updateAutoScrollIfDifferent(
      AutoScroll(
        direction: AutoScrollDirection.backward,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Stops scrolling smoothly.
  ///
  /// Nothing is done if no auto-scroll is being performed.
  void stopScrolling() {
    if (autoScroll.isScrolling) {
      _updateAutoScrollIfDifferent(
        AutoScroll.stopped(direction: autoScroll.direction),
      );
    }
  }

  bool _isInsideWidget(Offset localPosition) =>
      (localPosition.dy >= 0) &&
      (_widgetHeight - localPosition.dy >= 0) &&
      (localPosition.dx >= 0) &&
      (_widgetWidth - localPosition.dx >= 0);

  void _updateAutoScrollIfDifferent(AutoScroll newAutoScroll) {
    if (newAutoScroll != autoScroll) {
      setState(() => autoScroll = newAutoScroll);
    }
  }
}