import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/core/exceptions/api_error.dart';
import 'package:nubesim/modules/my_esim/cubits/esim_details_cubit/esim_detail_state.dart';
import 'package:nubesim/modules/my_esim/models/esim_details_input.dart';
import '../../repo/my_esim_repo.dart';

class EsimDetailCubit extends Cubit<EsimDetailState> {
  final MyEsimRepository myEsimRepository;

  EsimDetailCubit({required this.myEsimRepository})
      : super(EsimDetailState.initial());

  Future<void> fetchEsimDetails({required EsimDetailsInput input}) async {
    emit(state.copyWith(status: EsimDetailStatus.loading));

    try {
      // Fetching all eSIMs data
      final esimResponse =
          await myEsimRepository.getEsimDetails(input: input);

      emit(state.copyWith(
        status: EsimDetailStatus.success,
        success: esimResponse.success,
        errorCode: esimResponse.errorCode,
        errorMsg: esimResponse.errorMsg,
        esimList: esimResponse.obj!.esimList,
        pager: esimResponse.obj!.pager,
      ));
    } on ApiError catch (e) {
      emit(state.copyWith(
        status: EsimDetailStatus.error,
        message: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EsimDetailStatus.error,
        message: e.toString(),
      ));
    }
  }
}
