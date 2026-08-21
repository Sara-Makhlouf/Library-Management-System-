import 'package:dio/dio.dart';
import 'package:library_mobile_app/core/network.dart';
import 'package:library_mobile_app/feature/Bill/data/BillModel.dart';

class BillsRepository {
  Future<List<BillModel>> getAllBills() async {
    try {
      final Dio dio = await NetworkService.getInstance();
      final response = await dio.get('/my-bills');

      if (response.statusCode == 200) {
        final paginationData = response.data['data'];
        final List<dynamic> billsList = paginationData['data'] ?? [];

        return billsList.map((json) => BillModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load bills: $e');
    }
  }

  Future<BillModel> getBillDetails(int id) async {
    try {
      final Dio dio = await NetworkService.getInstance();
      final response = await dio.get('/my-bills/$id');

      if (response.statusCode == 200) {
        return BillModel.fromJson(response.data['data'] ?? response.data);
      }
      throw Exception('Bill not found');
    } catch (e) {
      throw Exception('Failed to load bill details: $e');
    }
  }
}
