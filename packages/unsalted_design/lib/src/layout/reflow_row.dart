// lib/src/layout/reflow_row.dart
//
// Layout (Teil 1.3, D13a): Inhalt und eine Aktion nebeneinander — oder, wenn
// dem Inhalt neben der Aktion weniger als [ReflowRow.mainMin] bliebe (große
// Schrift, schmale Fläche), die Aktion rechtsbündig darunter (28.10.11,
// „Nebeneinander wird untereinander“). Anders als ein `LayoutBuilder` kennt
// es die Breite der Aktion, weil es sie zuerst misst. Nicht exportiert.

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Inhalt mit Aktion daneben oder darunter.
class ReflowRow extends MultiChildRenderObjectWidget {
  /// Erzeugt die Zeile.
  ReflowRow({super.key, required Widget main, required Widget trailing, required this.gap, required this.mainMin})
      : super(children: [main, trailing]);

  /// Abstand zwischen Inhalt und Aktion (nebeneinander).
  final double gap;

  /// Mindestbreite des Inhalts neben der Aktion.
  final double mainMin;

  @override
  RenderReflowRow createRenderObject(BuildContext context) => RenderReflowRow(gap, mainMin);

  @override
  void updateRenderObject(BuildContext context, RenderReflowRow renderObject) {
    renderObject
      ..gap = gap
      ..mainMin = mainMin;
  }
}

/// Elterndaten von [RenderReflowRow].
class ReflowRowParentData extends ContainerBoxParentData<RenderBox> {}

/// Render-Objekt von [ReflowRow].
class RenderReflowRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ReflowRowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ReflowRowParentData> {
  /// Erzeugt das Render-Objekt mit Abstand und Mindestbreite des Inhalts.
  RenderReflowRow(this._gap, this._mainMin);

  double _gap;
  double _mainMin;

  /// Abstand zwischen Inhalt und Aktion.
  double get gap => _gap;
  set gap(double value) {
    if (value == _gap) return;
    _gap = value;
    markNeedsLayout();
  }

  /// Mindestbreite des Inhalts neben der Aktion.
  double get mainMin => _mainMin;
  set mainMin(double value) {
    if (value == _mainMin) return;
    _mainMin = value;
    markNeedsLayout();
  }

  RenderBox get _main => firstChild!;
  RenderBox get _trailing => lastChild!;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ReflowRowParentData) child.parentData = ReflowRowParentData();
  }

  /// `true`: Aktion unter dem Inhalt bei der Breite [width] und der
  /// Aktionsbreite [trailingWidth].
  bool _stacked(double width, double trailingWidth) => width - trailingWidth - gap < mainMin;

  Size _layout(BoxConstraints constraints, {required bool dry}) {
    assert(constraints.hasBoundedWidth, 'ReflowRow braucht eine begrenzte Breite');
    final width = constraints.maxWidth;
    Size measure(RenderBox child, BoxConstraints c) {
      if (dry) return child.getDryLayout(c);
      child.layout(c, parentUsesSize: true);
      return child.size;
    }

    final trailing = measure(_trailing, BoxConstraints(maxWidth: width));
    if (_stacked(width, trailing.width)) {
      final main = measure(_main, BoxConstraints(minWidth: width, maxWidth: width));
      if (!dry) {
        (_main.parentData! as ReflowRowParentData).offset = Offset.zero;
        (_trailing.parentData! as ReflowRowParentData).offset = Offset(width - trailing.width, main.height);
      }
      return constraints.constrain(Size(width, main.height + trailing.height));
    }
    final mainWidth = width - trailing.width - gap;
    final main = measure(_main, BoxConstraints(minWidth: mainWidth, maxWidth: mainWidth));
    if (!dry) {
      (_main.parentData! as ReflowRowParentData).offset = Offset.zero;
      (_trailing.parentData! as ReflowRowParentData).offset = Offset(width - trailing.width, 0);
    }
    return constraints.constrain(Size(width, math.max(main.height, trailing.height)));
  }

  @override
  void performLayout() => size = _layout(constraints, dry: false);

  @override
  Size computeDryLayout(BoxConstraints constraints) => _layout(constraints, dry: true);

  @override
  double computeMinIntrinsicWidth(double height) =>
      math.max(_main.getMinIntrinsicWidth(height), _trailing.getMinIntrinsicWidth(height));

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _main.getMaxIntrinsicWidth(height) + gap + _trailing.getMaxIntrinsicWidth(height);

  double _height(double width) {
    final trailingWidth = math.min(_trailing.getMaxIntrinsicWidth(double.infinity), width);
    final trailingHeight = _trailing.getMinIntrinsicHeight(trailingWidth);
    if (_stacked(width, trailingWidth)) return _main.getMinIntrinsicHeight(width) + trailingHeight;
    return math.max(_main.getMinIntrinsicHeight(width - trailingWidth - gap), trailingHeight);
  }

  @override
  double computeMinIntrinsicHeight(double width) => _height(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _height(width);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);
}
