const String ip = '10.39.219.158';
const String baseUrl = 'http://$ip:8000/api';
const String imageBaseUrl = 'http://$ip:8000/';
const String tokenKey = 'auth_token';
const String fcmTokenKey = 'fcm_token';
const String userKey = 'user_data';
void printNetworkConfig() {
  print('🌐 Network config:');
  print('  baseUrl: $baseUrl');
  print('  tokenKey: $tokenKey');
  print('  fcmTokenKey: $fcmTokenKey');
  print('  userKey: $userKey');
}
