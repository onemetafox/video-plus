<?php

namespace App\Http\Middleware;

use App\Models\User;
use Closure;
use Exception;
use Illuminate\Http\Request;
use Tymon\JWTAuth\Facades\JWTAuth;

class JwtMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next)
    {
        try {            
            $token = JWTAuth::getToken(); 
            if($token == ''){
                return response()->json([
                    'error' => true,
                    'status' => 'Authorization Token not found'
                ]);
            }
            $payload = JWTAuth::decode($token);
            $user_id = $payload->get('user_id');        
            $res = User::find($user_id);
            if(!empty($res)){
                if($res->api_token != $token){
                    return response()->json([
                        'error' => true,
                        'status' => 'Unauthorized access'
                    ]);
                } else {
                    if($res->status == 0){
                        return response()->json([
                            'error' => true,
                            'status' => 'your account has been deactive! please contact admin'
                        ]);
                    }
                }
            } else {
                return response()->json([
                    'error' => true,
                    'status' => 'Unauthorized access'
                ]);
            }

            $user = JWTAuth::parseToken()->authenticate();
        } catch (Exception $e) {
            if ($e instanceof \Tymon\JWTAuth\Exceptions\TokenInvalidException){
                return response()->json([
                    'error' => true,
                    'status' => 'Token is Invalid'
                ]);
            } else if ($e instanceof \Tymon\JWTAuth\Exceptions\TokenExpiredException){
                return response()->json([
                    'error' => true,
                    'status' => 'Token is Expired'
                ]);
            } else{
                return response()->json([
                    'error' => true,
                    'status' => 'Authorization Token not found'
                ]);
            }
        }
        return $next($request);
    }
}
