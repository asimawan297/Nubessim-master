import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/core/exceptions/api_error.dart';
import 'package:nubesim/modules/my_esim/models/all_allocated_esim_input.dart';
import 'package:nubesim/modules/my_esim/models/all_esim_model.dart';
import 'package:nubesim/modules/shop/model/all_data_packages_model.dart';
import 'package:nubesim/utils/helper_widgets.dart';
import '../../repo/my_esim_repo.dart';
import 'all_esims_state.dart';

class EsimCubit extends Cubit<EsimState> {
  final MyEsimRepository myEsimRepository;

  changeIsVoice(status) {
    emit(state.copyWith(isVoice: status));
  }

  EsimCubit({required this.myEsimRepository}) : super(EsimState.initial());

//   Future<void> fetchUsageQuery()async{
//     emit(state.copyWith(status: EsimStatus.loading));

//     // FirebaseFirestore.instance.collection()
//     final id = getUID();
//     // debugger();
//    final querySnapshot = await FirebaseFirestore.instance
//     .collection("order_data")
//     .where("UID", isEqualTo: id)
//     .get();

// List<String> orderNumbers = querySnapshot.docs
//     .map((doc) => doc['order_number'] as String)
//     .toList();

// print(orderNumbers);

//     debugger();
//     // final esimResponse =
//     //       await myEsimRepository.getUsageQuery(esimTranNoList: esimTranNoList);

//   }

  String? _resolveUid() {
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    if (authUid != null && authUid.isNotEmpty) return authUid;

    final storedUid = getUID();
    if (storedUid.isNotEmpty) return storedUid;

    return null;
  }

  Future<void> fetchEsims({required AllAllocatedEsimInput input}) async {
    emit(state.copyWith(status: EsimStatus.loading));

    try {
      final uid = _resolveUid();
      if (uid == null) {
        emit(state.copyWith(
          status: EsimStatus.success,
          activeEsims: [],
          cancelledEsims: [],
          totalEsims: 0,
        ));
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('order_data')
          .where('UID', isEqualTo: uid)
          .get();

      if (snapshot.docs.isEmpty) {
        emit(state.copyWith(
          status: EsimStatus.success,
          activeEsims: [],
          cancelledEsims: [],
          totalEsims: 0,
        ));
        return;
      }

      // 3️⃣ Safe non-null lists
      final List<EsimList> allActiveEsims = [];
      final List<EsimList> allCancelledEsims = [];
      int totalEsimsCount = 0;

      // 4️⃣ Loop through orders
      for (final data in snapshot.docs) {
        final doc = data.data();

        final String orderNumber = doc['order_number'] ?? '';
        if (orderNumber.isEmpty) continue;

        input.orderNo = orderNumber;

        // 5️⃣ Call API
        final esimResponse =
            await myEsimRepository.getAllAllocatedEsim(input: input);

        if (esimResponse?.obj?.esimList == null) continue;

        final esimList = esimResponse!.obj!.esimList!;

        // 6️⃣ Separate active & cancelled
        final activeEsims = esimList
            .where((esim) =>
                esim.esimStatus == "IN_USE" ||
                esim.esimStatus == "GOT_RESOURCE")
            .toList();

        final cancelledEsims = esimList
            .where((esim) =>
                esim.esimStatus != "IN_USE" &&
                esim.esimStatus != "GOT_RESOURCE")
            .toList();

        // 7️⃣ Attach coverage if available (supports both JSON string and list)
        if (doc["coverage"] != null && doc["coverage"].toString().isNotEmpty) {
          final dynamic coverageRaw = doc["coverage"];
          List<dynamic> coverageJson = [];

          if (coverageRaw is String) {
            coverageJson = (jsonDecode(coverageRaw) as List);
          } else if (coverageRaw is List) {
            coverageJson = coverageRaw;
          }

          final coverageList = coverageJson
              .whereType<Map>()
              .map((e) =>
                  LocationNetworkList.fromJson(Map<String, dynamic>.from(e)))
              .toList();

          for (final esim
              in activeEsims.where((e) => e.orderNo == orderNumber)) {
            esim.coverage = coverageList;
          }
        }

        // 8️⃣ Normalize statuses
        for (final esim in activeEsims) {
          if (esim.smdpStatus == "RELEASED" &&
              esim.esimStatus == "GOT_RESOURCE") {
            esim.esimStatus = "New";
          } else if (esim.smdpStatus == "ENABLED" &&
              esim.esimStatus == "GOT_RESOURCE") {
            esim.esimStatus = "Onboard";
          } else if (esim.smdpStatus == "ENABLED" &&
              esim.esimStatus == "IN_USE") {
            esim.esimStatus = "IN_USE";
          }
        }

        // 9️⃣ Add results
        allActiveEsims.addAll(activeEsims);
        allCancelledEsims.addAll(cancelledEsims);

        // ✅ Correct total count
        totalEsimsCount += esimList.length;
      }

      // 🔟 Emit final state
      emit(state.copyWith(
        status: EsimStatus.success,
        activeEsims: allActiveEsims.reversed.toList(),
        cancelledEsims: allCancelledEsims.reversed.toList(),
        totalEsims: totalEsimsCount,
      ));
    } on ApiError catch (e) {
      emit(state.copyWith(
        status: EsimStatus.error,
        message: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EsimStatus.error,
        message: e.toString(),
      ));
    }
  }
}
