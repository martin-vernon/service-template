<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],

    'resend' => [
        'key' => env('RESEND_KEY'),
    ],

    'ses' => [
        'key'    => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel'              => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    'auth' => [
        'url' => env('AUTH_SERVICE_URL', 'http://auth-nginx'),
        'timeout' => env('AUTH_TIMEOUT', 10),
        'retries' => env('AUTH_RETRIES', 2),
        'retry_delay' => env('AUTH_RETRY_DELAY', 100), // milliseconds
    ],

    'rbac' => [
        'url' => env('RBAC_SERVICE_URL', 'http://rbac-nginx'),
        'timeout' => env('RBAC_TIMEOUT', 10),
        'retries' => env('RBAC_RETRIES', 2),
        'retry_delay' => env('RBAC_RETRY_DELAY', 100), // milliseconds
    ],

    'security' => [
        'url' => env('SECURITY_SERVICE_URL', 'http://security-nginx'),
        'timeout' => env('SECURITY_TIMEOUT', 10),
        'retries' => env('SECURITY_RETRIES', 2),
        'retry_delay' => env('SECURITY_RETRY_DELAY', 100), // milliseconds
    ],

];
