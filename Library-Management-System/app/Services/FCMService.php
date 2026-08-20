<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FCMService
{
    protected string $projectId;
    protected string $credentialsPath;

    public function __construct()
    {
        $this->projectId       = config('firebase.project_id');
        $this->credentialsPath = config('firebase.credentials.file');
    }

    public function sendToDevice(string $fcmToken, string $title, string $body, array $data = []): bool
    {
        try {
            if (empty($fcmToken)) {
                Log::warning('FCM: Empty token provided, skipping send.');
                return false;
            }

            $accessToken = $this->getAccessToken();

            if ($accessToken === null) {
                Log::error('FCM: Failed to obtain access token, aborting send.');
                return false;
            }

            $response = Http::withToken($accessToken)
                ->post("https://fcm.googleapis.com/v1/projects/{$this->projectId}/messages:send", [
                    'message' => [
                        'token'        => $fcmToken,
                        'notification' => [
                            'title' => $title,
                            'body'  => $body,
                        ],
                        'data'    => array_map('strval', $data),
                        'android' => [
                            'priority' => 'high',
                        ],
                        'apns' => [
                            'headers' => ['apns-priority' => '10'],
                        ],
                    ],
                ]);

            // نطبع الـ response كامل دايماً (نجح أو فشل) لنتأكد من التفاصيل
            Log::info('FCM Send Response Status: ' . $response->status());
            Log::info('FCM Send Response Body: ' . $response->body());
            Log::info('FCM: Token used (full): ' . $fcmToken);

            if ($response->failed()) {
                Log::error('FCM Send Error: ' . $response->body());
                return false;
            }

            Log::info('FCM: Notification sent successfully to token ending in ' . substr($fcmToken, -10));
            return true;
        } catch (\Throwable $e) {
            // \Throwable يغطي كل من Exception و Error (متل TypeError)
            Log::error('FCM Exception: ' . $e->getMessage());
            return false;
        }
    }

    private function getAccessToken(): ?string
    {
        try {
            if (empty($this->credentialsPath)) {
                Log::error('FCM: credentials path is empty in config/firebase.php');
                return null;
            }

            if (!file_exists($this->credentialsPath)) {
                Log::error('FCM: Credentials file not found at path: ' . $this->credentialsPath);
                return null;
            }

            $rawContent = file_get_contents($this->credentialsPath);
            $credentials = json_decode($rawContent, true);

            if (json_last_error() !== JSON_ERROR_NONE) {
                Log::error('FCM: Credentials file is not valid JSON. Error: ' . json_last_error_msg());
                return null;
            }

            if (!isset($credentials['client_email'], $credentials['private_key'])) {
                Log::error('FCM: Credentials file is missing client_email or private_key.');
                return null;
            }

            if (empty($this->projectId)) {
                Log::error('FCM: project_id is empty in config/firebase.php');
                return null;
            }

            $now     = time();
            $payload = [
                'iss'   => $credentials['client_email'],
                'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
                'aud'   => 'https://oauth2.googleapis.com/token',
                'iat'   => $now,
                'exp'   => $now + 3600,
            ];

            $jwt = $this->generateJWT($payload, $credentials['private_key']);

            $response = Http::asForm()->post('https://oauth2.googleapis.com/token', [
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion'  => $jwt,
            ]);

            // 🟢 تسجيل تفصيلي لمعرفة سبب الفشل الحقيقي من Google
            Log::info('FCM OAuth Response Status: ' . $response->status());
            Log::info('FCM OAuth Response Body: ' . $response->body());

            if ($response->failed()) {
                return null;
            }

            $accessToken = $response->json('access_token');

            if (empty($accessToken)) {
                Log::error('FCM: OAuth response did not contain access_token. Full body: ' . $response->body());
                return null;
            }

            return $accessToken;
        } catch (\Throwable $e) {
            Log::error('FCM getAccessToken Exception: ' . $e->getMessage());
            return null;
        }
    }

    private function generateJWT(array $payload, string $privateKey): string
    {
        $header = rtrim(strtr(base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT'])), '+/', '-_'), '=');
        $body   = rtrim(strtr(base64_encode(json_encode($payload)), '+/', '-_'), '=');

        $data = "{$header}.{$body}";
        openssl_sign($data, $signature, $privateKey, 'SHA256');

        return "{$data}." . rtrim(strtr(base64_encode($signature), '+/', '-_'), '=');
    }
}
