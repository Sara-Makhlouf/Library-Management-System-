const String baseUrl = 'http://192.168.1.15:8000/api/';
const String imageBaseUrl = 'http://192.168.1.15:8000/';
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
