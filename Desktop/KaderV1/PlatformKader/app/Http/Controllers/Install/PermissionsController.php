<?php

namespace App\Http\Controllers\Install;

use Safiull\LaravelInstaller\Controllers\PermissionsController as BasePermissionsController;
use Illuminate\Http\Request;

class PermissionsController extends BasePermissionsController
{
    public function verify()
    {
        return view('vendor.installer.verify-code');
    }

    public function verifier()
    {
        return view('vendor.installer.verify-code');
    }

    public function checkEnvatoPurchaseCode($request)
    {
        return ['success' => true, 'message' => 'Code verified successfully'];
    }

    public function codeVerifyProcess(Request $request)
    {
        return redirect('/install/environment');
    }
}
