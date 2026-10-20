import 'package:flutter/material.dart';
import 'package:nubesim/modules/shop/widgets/sim_types_widget.dart';

class SimTypesSelector extends StatelessWidget {
  final String selectedName;
  final ValueChanged<String> onChanged;

  const SimTypesSelector({
    super.key,
    required this.selectedName,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final simTypes = ["Popular", "Single", "Regional", "Global"];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        color: Colors.grey.shade200,
      ),
      padding: const EdgeInsets.all(6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: simTypes.map((type) {
          return SimTypesWidget(
            name: type,
            selectedName: selectedName,
            onSelect: (value) {
              onChanged(value);
            },
          );
        }).toList(),
      ),
    );
  }
}
