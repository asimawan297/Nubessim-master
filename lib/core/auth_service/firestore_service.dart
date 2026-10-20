import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../model/countries_data_model.dart';
import '../model/order_history_model.dart'; // Import the OrderHistoryModel

class FireStoreService {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Method to fetch countries
  Future<List<CountriesData>> fetchCountries() async {
    try {
      final String response =
          await rootBundle.loadString('assets/countries.json');
      final List<dynamic> data = json.decode(response);
      return data.map((item) => CountriesData.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> validatePromoCode(String code) async {
    try {
      final query = await _fireStore
          .collection('promo_codes')
          .where('code', isEqualTo: code)
          .get();

      // debugger();
      if (query.docs.isEmpty) return null;

      final data = query.docs.first.data();
      final docId = query.docs.first.id;

      final expiryDate = (data['expiryDate'] as Timestamp).toDate();

      if (DateTime.now().isAfter(expiryDate)) return null;
      // if (usageLimit == 0) return null;
      return {
        'data': data,
        'docId': docId,
      };
    } catch (e) {
      return null;
    }
  }

  // Method to store order history in Firestore
  Future<void> storeOrderHistory(OrderHistoryModel orderHistory) async {
    try {
      var orderData = orderHistory.toJson();
      final coverageRaw = orderData['coverage'];
      if (coverageRaw is List || coverageRaw is Map) {
        // Website format stores coverage as JSON string in Firestore.
        orderData['coverage'] = jsonEncode(coverageRaw);
      } else if (coverageRaw == null) {
        orderData['coverage'] = '[]';
      } else if (coverageRaw is! String) {
        orderData['coverage'] = coverageRaw.toString();
      }
      if (orderData.isEmpty) {
        return; 
      }

      final docId =
          (orderHistory.trxId != null && orderHistory.trxId!.isNotEmpty)
              ? orderHistory.trxId!
              : orderData['trx_id']?.toString() ?? '';

      if (docId.isEmpty) {
        return;
      }

      await _fireStore.collection('order_data').doc(docId).set(orderData);
    } catch (e, stackTrace) {
      //
    }
  }

  Future<List<OrderHistoryModel>> fetchOrderHistoryListByUID(String uid) async {
    try {
      final querySnapshot = await _fireStore
          .collection('order_data')
          .where('UID', isEqualTo: uid) // ✅ FIXED: match your model field
          .get();
      // debugger();
      return querySnapshot.docs
          .map((doc) => OrderHistoryModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
