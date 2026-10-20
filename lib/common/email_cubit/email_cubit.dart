import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/common/email_repository/email_repository.dart';
import 'package:nubesim/core/exceptions/api_error.dart';
import '../model/send_email_input.dart';
import 'email_state.dart';

class EmailCubit extends Cubit<EmailState> {
  final EmailRepository emailRepository;

  EmailCubit({required this.emailRepository}) : super(EmailState.initial());

  Future<void> sendEmail(SendEmailInput input) async {
    emit(state.copyWith(status: EmailStatus.loading));

    try {
      final response = await emailRepository.sendEmail(input: input);
      emit(state.copyWith(
        status: EmailStatus.success,
        response: response,
      ));
    } on ApiError {
      emit(state.copyWith(
        status: EmailStatus.error,
        message: "Something went wrong, please try again after some time."
      ));
    }
  }
}
