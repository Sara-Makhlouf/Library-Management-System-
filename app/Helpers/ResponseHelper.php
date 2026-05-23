<?php

if (! function_exists('apiSuccess')) {
    function apiSuccess(string $message, mixed $data = null, int $status = 200)
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data'    => $data,
        ], $status);
    }
}

if (! function_exists('apiError')) {
    function apiError(string $message, int $status = 400, mixed $errors = null)
    {
        return response()->json([
            'success' => false,
            'message' => $message,
            'errors'  => $errors,
        ], $status);
    }
}
