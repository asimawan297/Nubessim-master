import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/modules/my_esim/models/all_esim_model.dart';
import 'package:nubesim/modules/my_esim/widgets/quick_install_tab.dart';
import 'package:nubesim/modules/my_esim/widgets/qr_code_tab.dart';
import 'package:nubesim/modules/my_esim/widgets/manual_tab.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import '../../../utils/heights_and_widths.dart';

class ViewInstructionsScreen extends StatelessWidget {
  const ViewInstructionsScreen({super.key, required this.selectedEsim});

  final EsimList selectedEsim;

  @override
  Widget build(BuildContext context) {
    return ViewInstructionsScreenView(selectedEsim: selectedEsim);
  }
}

class ViewInstructionsScreenView extends StatefulWidget {
  const ViewInstructionsScreenView({super.key, required this.selectedEsim});

  final EsimList selectedEsim;

  @override
  State<ViewInstructionsScreenView> createState() =>
      _ViewInstructionsScreenState();
}

class _ViewInstructionsScreenState extends State<ViewInstructionsScreenView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // print(widget.selectedEsim);
    // debugger();
    _tabController = TabController(length: 3, vsync: this);
  
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "eSIM Installation",
          style: context.textTheme.bodyMedium?.copyWith(
            fontSize: 19.0,
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
                children: [
                  // Tab Bar
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: const EdgeInsets.all(6.0),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerHeight: 0,
                      indicator: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xffFF668B).withOpacity(.7),
                            const Color(0xffCA2045),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: "Inter",
                      ),
                      tabs:  [
                              Tab(text: 'Quick Install'),
                              Tab(text: 'QR Code'),
                              Tab(text: 'Manual'),
                            ],
                    ),
                  ),
                  h1,
                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children:  [
                              SingleChildScrollView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                child: QuickInstallTab(
                                    selectedEsim: widget.selectedEsim),
                              ),
                              SingleChildScrollView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                child: QRCodeTab(
                                    selectedEsim: widget.selectedEsim),
                              ),
                              SingleChildScrollView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                child: ManualTab(
                                    selectedEsim: widget.selectedEsim),
                              ),                         
                            ],
                    ),
                  ),
                ],
              )
      ),
    );
  }
}
