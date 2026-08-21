import 'package:library_mobile_app/core/network.dart';
import 'package:library_mobile_app/feature/History/data/HistoryModel.dart';

class HistoryRepository {
  Future<List<HistoryModel>> getOrderHistory() async {
    final dio = await NetworkService.getInstance();
    final response = await dio.get('/transactions/my-history');
    return (response.data as List)
        .map((e) => HistoryModel.fromJson(e))
        .toList();
  }
}
