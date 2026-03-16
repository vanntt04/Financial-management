package com.example.backend.service;

import com.example.backend.dto.request.*;
import com.example.backend.dto.response.ApiResponse;
import com.example.backend.dto.response.AuthResponse;

public interface AuthService {

    ApiResponse<Void> register(RegisterRequest request);

    ApiResponse<AuthResponse> verifyOtp(VerifyOtpRequest request);

    ApiResponse<Void> resendOtp(ResendOtpRequest request);

    ApiResponse<AuthResponse> login(LoginRequest request);

    ApiResponse<AuthResponse> refreshToken(String refreshToken);

    ApiResponse<Void> logout(String refreshToken);

    ApiResponse<Void> forgotPassword(ForgotPasswordRequest request);

    ApiResponse<Void> resetPassword(ResetPasswordRequest request);
}
