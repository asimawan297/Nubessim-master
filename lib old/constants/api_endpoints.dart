class Endpoints {
  static const String getAllDataPackages = '/api/v1/open/package/list';
  static const String getAllTopUpPackages = '/api/v1/open/esim/topup';
  static const String getAllPlansForCuntry = '/api/v1/open/package/list';
  static const String orderNewEsim = '/api/v1/open/esim/order';
  static const String getAccountBalance = '/api/v1/open/balance/query';
  static const String getAllAllocatedEsims = '/api/v1/open/esim/query';
  static const String getUsageQuery = '/api/v1/open/esim/usage/query';

  // OTP related endpoints
  static const String sendOtp = '/api/v1/auth/send-otp';
  static const String verifyOtp = '/api/v1/auth/verify-otp';
  static const String resendOtp = '/api/v1/auth/resend-otp';

  //Stripe Payment
  static const String createPaymentIntent = '/payment_intents';
  static const String createPaymentWithSaveCard = '/payment_intents';
  static const String createCustomer = '/customers';
  static const String fetchSaveCards = '/payment_methods';

  static const String sendEmail = "https://api.brevo.com/v3/smtp/email";
}
