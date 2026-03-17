package com.example.backend.service;

import com.example.backend.dto.request.UpdateProfileRequest;
import com.example.backend.dto.response.ApiResponse;
import com.example.backend.dto.response.UserResponse;
import org.springframework.security.core.Authentication;

public interface UserService {

    ApiResponse<UserResponse> getCurrentUser(Authentication auth);

    ApiResponse<UserResponse> updateProfile(Authentication auth, UpdateProfileRequest request);
}
