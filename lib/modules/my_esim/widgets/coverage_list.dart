import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/modules/shop/model/all_data_packages_model.dart';

class CoverageList extends StatelessWidget {
  final List<LocationNetworkList>? networkList;

  const CoverageList({super.key, required this.networkList});

  @override
  Widget build(BuildContext context) {
    return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: networkList!.map((network) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
           
              // 📶 Operator List
              ...network.operatorList.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item["operatorName"] ?? "",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade500, width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item["networkType"] ?? "",
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          SizedBox(width: 10,),
           // 🌐 Network Name (like “USA” or “Europe”)
          Text(
            network.locationName ?? "",
            style: const TextStyle(
              fontSize: 10,
              
              color: AppColors.textGrey,
            ),
          ),
          

        ],
      ),
    );
  }).toList(),
);

  }
}
