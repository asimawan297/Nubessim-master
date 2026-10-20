import 'package:flutter/material.dart';
import 'package:nubesim/modules/shop/widgets/country_items.dart';
import 'package:nubesim/modules/shop/widgets/package_items.dart';
import 'package:nubesim/modules/shop/widgets/section_header.dart';

class EsimResultsList extends StatelessWidget {
  final List<dynamic> allResults;

  const EsimResultsList({
    super.key,
    required this.allResults,
  });

  @override
  Widget build(BuildContext context) {
    // print(allResults);
    // debugger();
    final singleEsimResults = allResults
        .where((result) => result['esimType'] == 'single')
        .toList();
    final regionalEsimResults = allResults
        .where((result) => result['esimType'] == 'regional')
        .toList();
    final globalEsimResults = allResults
        .where((result) => result['esimType'] == 'global')
        .toList();
// debugger();
    List<Widget> widgets = [];

    if (singleEsimResults.isNotEmpty) {
      // widgets.add(SectionHeader(
      //   title: "Single eSIM",
      //   count: singleEsimResults.length,
      // ));
      widgets.add(const SizedBox(height: 8));
      widgets.addAll(singleEsimResults.map((result) {
        final isCountry = result['type'] == 'country';
        final data = result['data'];
        final esimType = result['esimType'];

        if (isCountry) {
          return CountryItem(
            country: data,
            esimType: esimType,
          );
        } else {
          return PackageItem(
            package: data,
            esimType: esimType,
            context: context,
          );
        }
      }).toList());
      widgets.add(const SizedBox(height: 24));
    }

    if (regionalEsimResults.isNotEmpty) {
      widgets.add(SectionHeader(
        title: "Regional eSIM",
        count: regionalEsimResults.length,
      ));
      widgets.add(const SizedBox(height: 8));
      widgets.addAll(regionalEsimResults.map((result) {
        final data = result['data'];
        final esimType = result['esimType'];
        return PackageItem(
          package: data,
          esimType: esimType,
          context: context,
        );
      }).toList());
      widgets.add(const SizedBox(height: 24));
    }

    if (globalEsimResults.isNotEmpty) {
      widgets.add(SectionHeader(
        title: "Global eSIM",
        count: globalEsimResults.length,
      ));
      widgets.add(const SizedBox(height: 8));
      widgets.addAll(globalEsimResults.map((result) {
        final data = result['data'];
        final esimType = result['esimType'];
        return PackageItem(
          package: data,
          esimType: esimType,
          context: context,
        );
      }).toList());
    }
// debugger();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
