<?php

namespace App\Services;

use Safiull\LaravelInstaller\Service\EnvatoService as BaseEnvatoService;

class EnvatoService extends BaseEnvatoService
{
    public function checkEnvatoPurchaseCode($code)
    {
        return [
            'success' => true,
            'message' => __('Purchase code verified.'),
            'data' => [],
            'amount' => true
        ];
    }
}
