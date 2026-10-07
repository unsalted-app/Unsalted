// lib/src/ui/foods/sections/package_identity_section.dart
//
// Bildschirm 10, Abschnitt „Kennung“ (Teil 1.2): Name, Marke, Barcode.

import 'package:flutter/widgets.dart';
import 'package:unsalted_design/unsalted_design.dart';

/// Name, Marke und Barcode eines Lebensmittels.
class PackageIdentitySection extends StatelessWidget {
  /// Erzeugt den Abschnitt.
  const PackageIdentitySection({super.key, required this.name, required this.brand, required this.barcode});

  /// Name.
  final TextEditingController name;

  /// Marke.
  final TextEditingController brand;

  /// Barcode.
  final TextEditingController barcode;

  @override
  Widget build(BuildContext context) => AppSection(
        divider: false,
        children: [
          AppTextField(controller: name, label: 'Name'),
          AppTextField(controller: brand, label: 'Marke'),
          AppTextField(controller: barcode, label: 'Barcode'),
        ],
      );
}
