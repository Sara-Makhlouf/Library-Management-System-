abstract class PaymentState {}

class PaymentInitial extends PaymentState {
  final String selectedPayment;
  final bool wantsDelivery;

  PaymentInitial({this.selectedPayment = 'cash', this.wantsDelivery = true});
}

class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final Map<String, dynamic> responseData;
  late final String orderId;
  late final String date;

  PaymentSuccess(this.responseData) {
    orderId = responseData['bill_id']?.toString() ?? 'N/A';
    date = DateTime.now().toString().substring(0, 10);
  }
}

class PaymentFailure extends PaymentState {
  final String error;
  PaymentFailure(this.error);
}
