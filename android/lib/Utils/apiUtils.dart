import '../LocalDataStore/AuthLocalDataStore.dart';

class ApiUtils {
  static Future<Map<String, String>> getHeaders() async {
    String jwtToken = AuthLocalDataSource.getJwtToken();
    return {"Authorization": 'Bearer $jwtToken'};
  }
}
