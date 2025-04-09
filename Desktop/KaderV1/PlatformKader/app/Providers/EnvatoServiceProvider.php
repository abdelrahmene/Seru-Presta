<?php

namespace App\Providers;

use App\Services\EnvatoService;
use Illuminate\Support\ServiceProvider;

class EnvatoServiceProvider extends ServiceProvider
{
    public function register()
    {
        $this->app->singleton('Safiull\LaravelInstaller\Service\EnvatoService', function ($app) {
            return new EnvatoService();
        });
    }
}
