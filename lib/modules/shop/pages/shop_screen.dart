import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/config/routes/nav_router.dart';
import 'package:nubesim/modules/shop/widgets/data_tab.dart';
import 'package:nubesim/modules/shop/widgets/voice_tab.dart';
import 'package:nubesim/utils/extensions/padding_extension.dart';
import 'package:sizer/sizer.dart';

import '../../my_esim/cubits/all_esims_cubit/all_esims_cubit.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          // actions: [
          //   TextButton(
          //     onPressed: () {
          //       // Shop tab uses a nested Navigator (PersistentNavigator) that does not
          //       // expose MaterialApp routes — use the root navigator from NavRouter.
          //       NavRouter.navigationKey.currentState
          //           ?.pushNamed('/stripe-test-payment');
          //       // NavRouter.pushFromRoot(
          //       //   context,
          //       //   CompleteOrderScreen(
          //       //       name: 'Test',
          //       //       package: PackageList(
          //       //           packageCode: 'sasas',
          //       //           name: 'Test',
          //       //           price: 1200,
          //       //           slug: '1200',
          //       //           currencyCode: 'US',
          //       //           volume: 1,
          //       //           dataType: 1,
          //       //           unusedValidTime: 1200,
          //       //           supportTopUpType: 1200,
          //       //           ipExport: 'assas',
          //       //           duration: 7,
          //       //           durationUnit: 'Day',
          //       //           location: 'Japan',
          //       //           description: 'Test',
          //       //           activeType: 1,
          //       //           favorite: false,
          //       //           retailPrice: 1200,
          //       //           speed: '100 Mbps',
          //       //           locationNetworkList: []),
          //       //       orderNumber: '1234567890'),
          //       // );
          //     },
          //     child: const Text(
          //       'Test payment',
          //       style: TextStyle(
          //         fontSize: 12,
          //         fontWeight: FontWeight.w600,
          //         fontFamily: 'Inter',
          //       ),
          //     ),
          //   ),
          // ],
          title: Container(
            width: 70.w,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(100),
            ),
            padding: EdgeInsets.all(6.0),
            child: TabBar(
              onTap: (index) {
                if (index == 0) {
                  context.read<EsimCubit>().changeIsVoice(false);
                } else if (index == 1) {
                  context.read<EsimCubit>().changeIsVoice(true);
                }
              },
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              controller: _tabController,
              indicator: BoxDecoration(
                color: Color(0xffD0284D),
                borderRadius: BorderRadius.circular(30),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: "Inter",
              ),
              tabs: const [Tab(text: 'Data'), Tab(text: 'Voice')],
            ),
          ).paddingTop(8.0).paddingBottom(8.0),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [DataTab(), VoiceTab()],
          // VoiceTab
        ),
      ),
    );
  }
}
