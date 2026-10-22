// lib/src/layout/reflow_row.dart
//
// Layout (Teil 1.3, D13a): Inhalt und eine Aktion nebeneinander — oder, wenn
// dem Inhalt neben der Aktion weniger als [ReflowRow.mainMin] bliebe (große
// Schrift, schmale Fläche), die Aktion rechtsbündig darunter (28.10.11,
// „Nebeneinander wird untereinander“). Anders als ein `LayoutBuilder` kennt
// es die Breite der Aktion, weil es sie zuerst misst. Nicht exportiert.
// Seit Teil 1.4 (T00a, `List/Item`): additiv [ReflowRow.stackedGap] und
// [ReflowRow.stackedEndGap] (Abstand über bzw. unter der Aktion, wenn sie
// darunter steht), [ReflowRow.centered] (nebeneinander senkrecht mittig statt
// oben bündig) und [ReflowRow.mainMinIntrinsic] (Mindestbreite zusätzlich aus
// der minimalen Eigenbreite des Inhalts, z. B. eines `ListTile`).

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Inhalt mit Aktion daneben oder darunter.
class ReflowRow extends MultiChildRenderObjectWidget {
  /// Erzeugt die Zeile.
  ReflowRow({
    super.key,
    required Widget main,
    required Widget trailing,
    required this.gap,
    required this.mainMin,
    this.stackedGap = 0,
    this.stackedEndGap = 0,
    this.centered = false,
    this.mainMinIntrinsic = false,
  }) : super(children: [main, trailing]);

  /// Abstand zwischen Inhalt und Aktion (nebeneinander).
  final double gap;

  /// Mindestbreite des Inhalts neben der Aktion.
  final double mainMin;

  /// Abstand über der Aktion, wenn sie unter dem Inhalt steht.
  final double stackedGap;

  /// Abstand unter der Aktion, wenn sie unter dem Inhalt steht.
  final double stackedEndGap;

  /// `true`: nebeneinander senkrecht mittig ausgerichtet.
  final bool centered;

  /// `true`: Mindestbreite mindestens die minimale Eigenbreite des Inhalts.
  final bool mainMinIntrinsic;

  @override
  RenderReflowRow createRenderObject(BuildContext context) =>
      RenderReflowRow(gap, mainMin, stackedGap, centered, stackedEndGap, mainMinIntrinsic);

  @override
  void updateRenderObject(BuildContext context, RenderReflowRow renderObject) {
    renderObject
      ..gap = gap
      ..mainMin = mainMin
      ..stackedGap = stackedGap
      ..stackedEndGap = stackedEndGap
      ..centered = centered
      ..mainMinIntrinsic = mainMinIntrinsic;
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
  RenderReflowRow(
    this._gap,
    this._mainMin, [
    this._stackedGap = 0,
    this._centered = false,
    this._stackedEndGap = 0,
    this._mainMinIntrinsic = false,
  ]);

  double _gap;
  double _mainMin;
  double _stackedGap;
  bool _centered;
  double _stackedEndGap;
  bool _mainMinIntrinsic;

  /// Abstand unter der Aktion, wenn sie unter dem Inhalt steht.
  double get stackedEndGap => _stackedEndGap;
  set stackedEndGap(double value) {
    if (value == _stackedEndGap) return;
    _stackedEndGap = value;
    markNeedsLayout();
  }

  /// `true`: Mindestbreite mindestens die minimale Eigenbreite des Inhalts.
  bool get mainMinIntrinsic => _mainMinIntrinsic;
  set mainMinIntrinsic(bool value) {
    if (value == _mainMinIntrinsic) return;
    _mainMinIntrinsic = value;
    markNeedsLayout();
  }

  /// Abstand über der Aktion, wenn sie unter dem Inhalt steht.
  double get stackedGap => _stackedGap;
  set stackedGap(double value) {
    if (value == _stackedGap) return;
    _stackedGap = value;
    markNeedsLayout();
  }

  /// `true`: nebeneinander senkrecht mittig ausgerichtet.
  bool get centered => _centered;
  set centered(bool value) {
    if (value == _centered) return;
    _centered = value;
    markNeedsLayout();
  }

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
  bool _stacked(double width, double trailingWidth) => width - trailingWidth - gap < _effectiveMainMin;

  double get _effectiveMainMin =>
      mainMinIntrinsic ? math.max(mainMin, _main.getMinIntrinsicWidth(double.infinity)) : mainMin;

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
        (_trailing.parentData! as ReflowRowParentData).offset =
            Offset(width - trailing.width, main.height + stackedGap);
      }
      return constraints.constrain(Size(width, main.height + stackedGap + trailing.height + stackedEndGap));
    }
    final mainWidth = width - trailing.width - gap;
    final main = measure(_main, BoxConstraints(minWidth: mainWidth, maxWidth: mainWidth));
    final height = math.max(main.height, trailing.height);
    if (!dry) {
      (_main.parentData! as ReflowRowParentData).offset =
          Offset(0, centered ? (height - main.height) / 2 : 0);
      (_trailing.parentData! as ReflowRowParentData).offset =
          Offset(width - trailing.width, centered ? (height - trailing.height) / 2 : 0);
    }
    return constraints.constrain(Size(width, height));
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
    if (_stacked(width, trailingWidth)) {
      return _main.getMinIntrinsicHeight(width) + stackedGap + trailingHeight + stackedEndGap;
    }
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
