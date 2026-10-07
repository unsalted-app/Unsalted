// lib/catalog/sample.dart
//
// Hilfen für Anwendungsfälle: Inhalt mit Innenabstand, scrollbar.

import 'package:flutter/material.dart';
import 'package:unsalted_design/unsalted_design.dart';
import 'package:widgetbook/widgetbook.dart';

/// Anwendungsfall, dessen Inhalt mit Abstand auf einer Seite steht.
WidgetbookUseCase useCase(String name, WidgetBuilder builder) => WidgetbookUseCase(
      name: name,
      builder: (context) => Scaffold(
        body: SingleChildScrollView(child: AppPadding.all(AppSpace.l, child: builder(context))),
      ),
    );

/// Anwendungsfall, der selbst eine ganze Seite ist (Templates, AppPage).
WidgetbookUseCase pageUseCase(String name, WidgetBuilder builder) => WidgetbookUseCase(name: name, builder: builder);

/// Komponente mit Anwendungsfällen.
WidgetbookComponent component(String name, List<WidgetbookUseCase> useCases) =>
    WidgetbookComponent(name: name, useCases: useCases);

/// Leere Aktion für Beispiele.
void noop() {}
