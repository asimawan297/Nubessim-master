import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/generated/assets.dart';
import 'package:nubesim/modules/shop/model/all_data_packages_model.dart';
import 'package:nubesim/modules/shop/widgets/info_Tool_tip.dart';

class AdditionalInfoCard extends StatefulWidget {
  final String description;
  final String speed;
  final double price;
  final String name;
  final int supportTopUpType;
  final String ipExport;
  final int dataType;
  final volumn;
  final String? fupPolicy;
  final List<LocationNetworkList> locationNetworkList;

  const AdditionalInfoCard(
      {super.key,
      required this.description,
      required this.volumn,
      required this.speed,
      required this.supportTopUpType,
      required this.ipExport,
      required this.price,
      required this.name,
      required this.dataType,
      this.fupPolicy,
      required this.locationNetworkList});

  @override
  State<AdditionalInfoCard> createState() => _AdditionalInfoCardState();
}

class _AdditionalInfoCardState extends State<AdditionalInfoCard> {
  int? expandedIndex; // Track which info icon is opened
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          locationTitle(
            index: 0,
            icon: Icons.signal_cellular_alt,
            title: "NETWORK",
            subtitle: widget.locationNetworkList,
          ),
          // _infoTile(
          //   index: 0,
          //   icon: Icons.signal_cellular_alt,
          //   title: "NETWORK",
          //   subtitle: widget.locationNetworkList,
          //   expandedText: "The Speed may vary depending on the location",
          // ),
          Divider(color: Color(0xfa00000033).withOpacity(.1)),
          _infoTile(
            index: 1,
            icon: Icons.description_outlined,
            imagePath: Assets.planTypeImg,
            title: "PLAN TYPE",
            subtitle: widget.dataType == 2 ? "Unlimited" : "Data Only",
            expandedText: widget.dataType == 2
                ? "This eSIM supports Unlimited data service"
                : "This eSIM supports only data service",
          ),
          if (widget.dataType == 2) ...[
            Divider(color: Color(0xfa00000033).withOpacity(.1)),
            _infoTile(
              index: 6,
              icon: Icons.info_outline,
              imagePath: Assets.planDataSpeedImg,
              title: "Data Speed",
              subtitle:
                  "High-speed data for the first ${widget.volumn} per day, then reduced to ${(widget.fupPolicy != null && widget.fupPolicy!.trim().isNotEmpty) ? widget.fupPolicy : '1 Mbps'} (reduced speed may vary depending on the country)",
              expandedText:
                  'Name: ${widget.name}\n${widget.description}\nPrice: ${widget.price}',
            ),
          ],
          Divider(color: Color(0xfa00000033).withOpacity(.1)),
          _infoTile(
            index: 2,
            icon: Icons.list_alt,
            imagePath: Assets.planValidityImg,
            title: "VALIDITY POLICY",
            subtitle:
                "The validity period starts when the eSIM connects to a mobile network in its coverage area. If you install the eSIM outside of the coverage area, you can connect to a network when you arrive.",
          ),
          Divider(color: Color(0xfa00000033).withOpacity(.1)),
          _infoTile(
            index: 3,
            icon: Icons.perm_identity,
            imagePath: Assets.identityVerificationImg,
            title: "IDENTIFICATION REQUIRES (eKYC)",
            subtitle: "Not Required",
          ),
          Divider(color: Color(0xfa00000033).withOpacity(.1)),
          _infoTile(
            index: 4,
            icon: Icons.upcoming,
            imagePath: Assets.topUpImg,
            title: "TOP-UP OPTION",
            subtitle:
                widget.supportTopUpType == 2 ? "Available" : "Not Available",
          ),
          Divider(color: Color(0xfa00000033).withOpacity(.1)),
          _infoTile(
            index: 5,
            icon: Icons.roundabout_right_rounded,
            title: "IP ROUTING",
            imagePath: Assets.iPRoutingImg,
            subtitle: widget.ipExport,
            expandedText:
                "Some eSIMs require alternative routing that may affect their IP addresses. This does not impact your ability to use data.",
          ),
          Divider(color: Color(0xfa00000033).withOpacity(.1)),
          _infoTile(
            index: 6,
            icon: Icons.info_outline,
            title: "OTHER INFO",
          ),
        ],
      ),
    );
  }

  /// Main info tile widget
  Widget _infoTile({
    required int index,
    required IconData icon,
    String? imagePath,
    required String title,
    String? subtitle,
    String? expandedText,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Title Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagePath != null) ...[
              Image.asset(imagePath, height: 20)
            ] else ...[
              Icon(icon, size: 20, color: Colors.black87)
            ],
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            if (expandedText != null) InfoTooltip(text: expandedText)
          ],
        ),
      ]),
    );
  }

  Widget locationTitle({
    required int index,
    required IconData icon,
    required String title,
    List<LocationNetworkList>? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: Colors.black87),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    if (subtitle != null)
                      SizedBox(
                        height: 80,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: subtitle.map((network) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 📶 Operator List
                                        ...network.operatorList.map((item) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  item["operatorName"] ?? "",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 2,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.grey,
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    item["networkType"] ?? "",
                                                    style: const TextStyle(
                                                      fontSize: 7,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      network.locationName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
