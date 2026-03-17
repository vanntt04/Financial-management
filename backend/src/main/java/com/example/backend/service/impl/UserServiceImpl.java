package com.example.backend.service.impl;

import com.example.backend.dto.request.UpdateProfileRequest;
import com.example.backend.dto.response.ApiResponse;
import com.example.backend.dto.response.UserResponse;
import com.example.backend.entity.User;
import com.example.backend.exception.ApiException;
import com.example.backend.repository.UserRepository;
import com.example.backend.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;

    @Override
    public ApiResponse<UserResponse> getCurrentUser(Authentication auth) {
        User user = getCurrentUserEntity(auth);
        return ApiResponse.success("Thành công", toUserResponse(user));
    }

    @Override
    @Transactional
    public ApiResponse<UserResponse> updateProfile(Authentication auth, UpdateProfileRequest request) {
        User user = getCurrentUserEntity(auth);

        if (!user.getEmail().equalsIgnoreCase(request.getEmail())
                && userRepository.existsByEmail(request.getEmail())) {
            throw new ApiException("Email đã được sử dụng bởi tài khoản khác", HttpStatus.CONFLICT);
        }

        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());
        userRepository.save(user);

        return ApiResponse.success("Cập nhật hồ sơ thành công", toUserResponse(user));
    }

    private User getCurrentUserEntity(Authentication auth) {
        if (auth == null || auth.getPrincipal() == null) {
            throw new ApiException("Chưa đăng nhập", HttpStatus.UNAUTHORIZED);
        }
        Integer userId = Integer.parseInt(auth.getPrincipal().toString());
        return userRepository.findById(userId)
                .orElseThrow(() -> new ApiException("Không tìm thấy người dùng", HttpStatus.NOT_FOUND));
    }

    private static UserResponse toUserResponse(User user) {
        return UserResponse.builder()
                .userId(user.getUserId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .build();
    }
}
