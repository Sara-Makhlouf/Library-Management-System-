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
            $accessToken = $this->getAccessToken();

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

            if ($response->failed()) {
                Log::error('FCM Error: ' . $response->body());
                return false;
            }

            return true;
        } catch (\Exception $e) {
            Log::error('FCM Exception: ' . $e->getMessage());
            return false;
        }
    }

    private function getAccessToken(): string
    {
        $credentials = json_decode(file_get_contents($this->credentialsPath), true);

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
            'grant_type' => 'urn:ietf:params:oauth2:grant-type:jwt-bearer',
            'assertion'  => $jwt,
        ]);

        return $response->json('access_token');
    }

    private function generateJWT(array $payload, string $privateKey): string
    {
        $header = base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
        $body   = base64_encode(json_encode($payload));

        $data = "{$header}.{$body}";
        openssl_sign($data, $signature, $privateKey, 'SHA256');

        return "{$data}." . base64_encode($signature);
    }
}
