import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/modules/my_esim/models/all_allocated_esim_input.dart';
import 'package:nubesim/modules/my_esim/widgets/active_esim_tab.dart';
import 'package:nubesim/modules/my_esim/widgets/inactive_esim_tab.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import '../../../utils/heights_and_widths.dart';
import '../cubits/all_esims_cubit/all_esims_cubit.dart';
import '../cubits/all_esims_cubit/all_esims_state.dart';

class MyESimScreen extends StatelessWidget {
  const MyESimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyESimScreenView();
  }
}

class MyESimScreenView extends StatefulWidget {
  const MyESimScreenView({super.key});

  @override
  State<MyESimScreenView> createState() => _MyESimScreenState();
}

class _MyESimScreenState extends State<MyESimScreenView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          "eSIM",
          style: context.textTheme.bodyMedium?.copyWith(
              fontSize: 19.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
        child: BlocBuilder<EsimCubit, EsimState>(
          builder: (context, state) {
            if (state.status == EsimStatus.loading) {
              return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 80,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  });
            } else if (state.status == EsimStatus.error) {
              return Center(
                child: Text(state.message),
              );
            } else if (state.status == EsimStatus.success) {
              return Column(
                children: [
                  Container(
                    width: 70.w,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: EdgeInsets.all(6.0),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerHeight: 0,
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xfaEF5576).withOpacity(0.7), // pink
                            Color(0xfaCA2045).withOpacity(1), // dark red
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
                      tabs: const [
                        Tab(text: 'Active eSim'),
                        Tab(text: 'Inactive eSim'),
                      ],
                    ),
                  ),
                  // h1,
                  // Text("Cancelled Esims -> ${state.cancelledEsims.length}"),
                  h3,

                  Expanded(
                      child: TabBarView(
                    controller: _tabController,
                    children: [
                      RefreshIndicator(
                        onRefresh: () async {
                          context.read<EsimCubit>().fetchEsims(
                              input: AllAllocatedEsimInput.initial());
                        },
                        child: ActiveEsimTab(list: state.activeEsims!),
                      ),
                      RefreshIndicator(
                        onRefresh: () async {
                          context.read<EsimCubit>().fetchEsims(
                              input: AllAllocatedEsimInput.initial());
                        },
                        child: InactiveEsimTab(list: state.cancelledEsims!),
                      )
                    ],
                  )),
                ],
              );
            } else {
              return SizedBox();
            }
          },
        ),
      ),
    );
  }
}
