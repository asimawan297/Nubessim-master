import 'package:flutter/material.dart';
import 'package:nubesim/modules/my_esim/models/all_esim_model.dart';
import 'package:nubesim/modules/shop/widgets/eSIM_package_tile.dart';
import 'package:nubesim/utils/time_utils.dart';

class PackageInfoSheet extends StatelessWidget {
  final String? esimTranNo;
  final String? createTime;
  final String? activateTime;

  final String? basicPlan;
  final String? basicPlanSpeedTxt;
  final String? basicPlanCreated;

  final List<AllAllocatedEsimPackageList>? topupPlan;

  const PackageInfoSheet({
    super.key,
    required this.esimTranNo,
    required this.createTime,
    required this.activateTime,
    required this.basicPlan,
    required this.basicPlanSpeedTxt,
    required this.basicPlanCreated,
    required this.topupPlan,
  });

  @override
  Widget build(BuildContext context) {
    // print(createTime);
    TextStyle titleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    TextStyle labelStyle = TextStyle(
      fontSize: 14,
      color: Colors.black54,
    );

    TextStyle valueStyle = TextStyle(
      fontSize: 14,
      color: Colors.black87,
    );

    Widget buildRow(String label, String value, {isDate = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label.toString(), style: labelStyle),
            Text(
                isDate && value != ""
                    ? dateTimeAccordingZone(value)
                    : value.toString(),
                style: valueStyle),
          ],
        ),
      );
    }

    Widget buildSectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 10),
        child: Text(title, style: titleStyle),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Package Information", style: titleStyle),
            const SizedBox(height: 16),

            // General Info
            buildRow("eSIM Tran No", esimTranNo!),
            buildRow("Create time", createTime!, isDate: true),
            if (activateTime != null)
              buildRow("Activate time", activateTime!, isDate: true),

            // Basic Plan Details
            if (topupPlan!.isEmpty) ...[
              buildSectionTitle("Basic Plan Details"),
              buildRow(
                  "Basic Plan",
                  basicPlan == "Unlimited"
                      ? basicPlanSpeedTxt ?? ""
                      : basicPlan!),
              buildRow("Created", basicPlanCreated!, isDate: true),
            ],
            // Topup Details
            if (basicPlan == "Unlimited" || topupPlan!.isEmpty)
              ...[]
            else ...[
              buildSectionTitle("Topup Details"),
              Column(
                children: topupPlan!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final plan = entry.value;

                  return Column(
                    children: [
                      buildRow("Top up Plan ${index + 1}",
                          extractCountry(plan.packageName)),
                      buildRow("eSIM Tran No", plan.esimTranNo ?? ""),
                      buildRow("Created", plan.createTime ?? "", isDate: true),
                    ],
                  );
                }).toList(),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
