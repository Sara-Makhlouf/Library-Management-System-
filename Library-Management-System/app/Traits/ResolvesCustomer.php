<?php

namespace App\Traits;

use App\Models\Customer;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

trait ResolvesCustomer
{
    protected function resolveCustomer(): Customer|JsonResponse
    {
        $customer = Auth::user()->customer;

        if (!$customer) {
            return response()->json([
                'status'  => 'error',
                'message' => 'عذراً، هذا الحساب غير مرتبط بملف زبون.',
            ], 403);
        }

        return $customer;
    }

    protected function customerOrFail(): Customer|JsonResponse
    {
        return $this->resolveCustomer();
    }
}
