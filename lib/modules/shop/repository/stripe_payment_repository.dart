import 'package:dio/dio.dart';
import 'package:nubesim/modules/shop/model/create_customer_input_model.dart';
import 'package:nubesim/modules/shop/model/payment_card_input.dart';
import 'package:nubesim/modules/shop/model/stripe_input.dart';
import 'package:nubesim/modules/shop/model/stripe_response.dart';
import '../../../core/exceptions/api_error.dart';
import '../../../core/network/stripe_dio_client.dart';
import '../../../utils/logger/logger.dart';

class StripePaymentRepository {
  final StripeDioClient _dioClient = StripeDioClient();

  final _log = logger(StripePaymentRepository);

  Future createPaymentIntent(StripeInput input) async {
    try {
      final response = await _dioClient.post(
        "https://createpaymentintent-to3676ta5a-uc.a.run.app",
        data: input.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );
// debugger();
      if (response.statusCode == 200) {
        // print("!!!!!!!!!!!!!clientSecret: ${response.data["clientSecret"]}");
        return response.data["clientSecret"];
      } else {
        throw ApiError(
            message: 'Failed to create payment intent',
            code: response.statusCode);
      }
    } on DioException catch (e, stackTrace) {
      _log.e(e, stackTrace: stackTrace);
      throw ApiError.fromDioException(e);
    } on TypeError catch (e) {
      _log.e(e.stackTrace);
      throw ApiError(message: '$e', code: 0);
    } on ApiError catch (e) {
      _log.e(e);
      throw ApiError(message: e.message, code: 0);
    }
  }

  // Future<String> createCustomer(CreateCustomerInput input) async {
  //   try {
  //     var response =
  //         await _dioClient.post(Endpoints.createCustomer, data: input.toJson());
  //     if (response.statusCode == 200) {
  //       return response.data['id'];
  //     } else {
  //       throw ApiError(
  //           message: 'Failed to create customer', code: response.statusCode);
  //     }
  //   } on DioException catch (e, stackTrace) {
  //     _log.e(e, stackTrace: stackTrace);
  //     throw ApiError.fromDioException(e);
  //   } on TypeError catch (e) {
  //     _log.e(e.stackTrace);
  //     throw ApiError(message: '$e', code: 0);
  //   } catch (e) {
  //     _log.e(e);
  //     throw ApiError(message: 'try fail : $e', code: 0);
  //   }
  // }

  // Future<List<SaveCardModel>> fetchSavedCards(String customerId) async {
  //   try {
  //     var response = await _dioClient.get(
  //       '${Endpoints.fetchSaveCards}?customer=$customerId&type=card',
  //     );
  //     if (response.statusCode == 200) {
  //       final jsonList = response.data['data'] as List<dynamic>;
  //       return jsonList.map((json) => SaveCardModel.fromJson(json)).toList();
  //     } else {
  //       throw ApiError(
  //           message: 'Failed to fetch saved cards', code: response.statusCode);
  //     }
  //   } on DioException catch (e, stackTrace) {
  //     _log.e(e, stackTrace: stackTrace);
  //     throw ApiError.fromDioException(e);
  //   } on TypeError catch (e) {
  //     _log.e(e.stackTrace);
  //     throw ApiError(message: '$e', code: 0);
  //   } catch (e) {
  //     _log.e(e);
  //     throw ApiError(message: 'try fail : $e', code: 0);
  //   }
  // }
}

// Add a repository used by the cubit that calls Stripe directly per provided cURL
class PaymentWithCardRepository {
  final Dio _dio;

  PaymentWithCardRepository({Dio? dio}) : _dio = dio ?? Dio();

  // Creates a PaymentIntent using Stripe's API directly
  Future<StripePaymentResponse> makePaymentWithCard(
      PaymentWithCardInput input) async {
    try {
      final response = await _dio.post(
        'https://api.stripe.com/v1/payment_intents',
        data: {
          'amount': input.amount,
          'currency': input.currency,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: const {
            'Authorization':
                'Basic c2tfdGVzdF81MVJjdzVxTERkTVp3VUR2Q09GS1ZmUnlmU1hQTFEwZk9KdmVLcDZqUmlxVlBVM2hMbTdJSGRMcFFuSnh0Nkg3NDc5c2tnV2IwUXZYbjJYVThxbFJGY1lZNDAwT3dPazFhNng6',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );
      if (response.statusCode == 200) {
        return StripePaymentResponse.fromJson(response.data);
      } else {
        throw ApiError(
            message: 'Failed to create payment intent',
            code: response.statusCode ?? 0);
      }
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    } catch (e) {
      throw ApiError(message: e.toString(), code: 0);
    }
  }

  // Optional: create a Customer directly in Stripe
  Future<String> createCustomer(CreateCustomerInput input) async {
    try {
      final response = await _dio.post(
        'https://api.stripe.com/v1/customers',
        data: {
          'name': input.name,
          'email': input.email,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: const {
            'Authorization':
                'Basic c2tfdGVzdF81MVJjdzVxTERkTVp3VUR2Q09GS1ZmUnlmU1hQTFEwZk9KdmVLcDZqUmlxVlBVM2hMbTdJSGRMcFFuSnh0Nkg3NDc5c2tnV2IwUXZYbjJYVThxbFJGY1lZNDAwT3dPazFhNng6',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );
      if (response.statusCode == 200) {
        final id = response.data['id'] as String?;
        if (id == null || id.isEmpty) {
          throw ApiError(message: 'Missing customer id in response', code: 0);
        }
        return id;
      } else {
        throw ApiError(
            message: 'Failed to create customer',
            code: response.statusCode ?? 0);
      }
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    } catch (e) {
      throw ApiError(message: e.toString(), code: 0);
    }
  }
}
