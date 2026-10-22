// lib/catalog/surfaces.dart
//
// Komponenten: Text, Symbole, Karten, Flächen, Trennlinien.

import 'package:flutter/material.dart';
import 'package:unsalted_design/unsalted_design.dart';
import 'package:widgetbook/widgetbook.dart';

import 'sample.dart';

/// Ordner „Basis“ (text, icons, cards, surfaces).
final surfacesFolder = WidgetbookFolder(name: 'text, icons, cards, surfaces', children: [
  component('AppSelectableArea', [
    useCase('Input/Text Selection', (_) => const AppSelectableArea(
          child: AppStack(gap: AppSpace.s, children: [
            AppText('Lange drücken markiert ein Wort; die Griffe erweitern die Auswahl.'),
            AppText.caption('Kopieren über das Menü der Plattform.'),
          ]),
        )),
  ]),
  component('AppText', [
    useCase('Rollen', (_) => const AppStack(gap: AppSpace.s, children: [
          AppText('Text/Body — Fließtext'),
          AppText.strong('Text/Strong — Überschrift eines Abschnitts'),
          AppText.title('Text/Title — Titel'),
          AppText.caption('Text/Caption — Kleingedrucktes'),
          AppText.display('type/display'),
          AppText.titlePage('type/title-page'),
          AppText.heading('type/heading'),
          AppText.bodySmall('type/body-small'),
          AppText.labelSmall('type/label-small'),
          AppText.data('type/data 1.234,5'),
          AppText.dataStrong('type/data-strong 343'),
          AppText.code('type/code {"a": 1}'),
        ])),
    useCase('Töne', (_) => const AppStack(gap: AppSpace.s, children: [
          AppText('normal'),
          AppText('muted', tone: AppTone.muted),
          AppText('primary', tone: AppTone.primary),
          AppText('error', tone: AppTone.error),
        ])),
  ]),
  component('AppIcon', [
    useCase('Icon', (_) => const AppStack(direction: Axis.horizontal, gap: AppSpace.m, children: [
          AppIcon(AppIcons.star),
          AppIcon(AppIcons.star, tone: AppTone.primary),
          AppIcon(AppIcons.book, size: AppIconSize.s),
        ])),
    useCase('AppIcons', (_) => Wrap(spacing: 16, runSpacing: 16, children: [
          for (final MapEntry(key: name, value: icon) in AppIcons.byFigmaName.entries)
            SizedBox(width: 140, child: AppStack(gap: AppSpace.xs, children: [AppIcon(icon), AppText.caption(name)])),
        ])),
  ]),
  component('AppCard', [
    useCase('Card', (_) => const AppCard(onTap: noop, child: AppText('Antippbare Karte'))),
  ]),
  component('AppSurface', [
    useCase('Surface/low, medium, high', (_) => const AppStack(gap: AppSpace.s, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AppSurface(tone: AppSurfaceTone.low, child: Text('low')),
          AppSurface(child: Text('medium')),
          AppSurface(tone: AppSurfaceTone.high, fullWidth: true, child: Text('high, volle Breite')),
        ])),
    useCase('Surface/info, warning, error', (_) => const AppStack(gap: AppSpace.s, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AppSurface(tone: AppSurfaceTone.info, child: Text('Eingefroren — als Entwurf kopieren?')),
          AppSurface(tone: AppSurfaceTone.warning, padding: AppSpace.s, child: Text('Wert ungewöhnlich hoch.')),
          AppSurface(tone: AppSurfaceTone.error, padding: AppSpace.s, child: Text('Eingabe ungültig.')),
        ])),
  ]),
  component('AppDivider', [
    useCase('Divider', (_) => const AppStack(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Standard'),
          AppDivider(),
          Text('space/xxl'),
          AppDivider(space: AppSpace.xxl),
          Text('bündig'),
          AppDivider.flush(),
          IntrinsicHeight(
            child: Row(children: [Expanded(child: Text('links')), AppDivider.vertical(), Expanded(child: Text('rechts'))]),
          ),
        ])),
  ]),
]);
