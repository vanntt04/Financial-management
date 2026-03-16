package com.example.backend.service.impl;

import com.example.backend.dto.request.*;
import com.example.backend.dto.response.ApiResponse;
import com.example.backend.dto.response.AuthResponse;
import com.example.backend.dto.response.UserResponse;
import com.example.backend.entity.Currency;
import com.example.backend.entity.OtpVerification;
import com.example.backend.entity.User;
import com.example.backend.exception.*;
import com.example.backend.repository.CurrencyRepository;
import com.example.backend.repository.OtpRepository;
import com.example.backend.repository.UserRepository;
import com.example.backend.service.AuthService;
import com.example.backend.service.CategoryService;
import com.example.backend.service.EmailService;
import com.example.backend.util.JwtUtil;
import com.example.backend.util.OtpUtil;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final OtpRepository otpRepository;
    private final CurrencyRepository currencyRepository;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final OtpUtil otpUtil;
    private final CategoryService categoryService;

    @Value("${otp.expiration-minutes:5}")
    private int otpExpirationMinutes;

    @Value("${otp.resend-cooldown-seconds:60}")
    private int resendCooldownSeconds;

    private static final String OTP_TYPE_REGISTER = "REGISTER";
    private static final String OTP_TYPE_FORGOT   = "FORGOT_PASSWORD";
    private static final int    MAX_ATTEMPT        = 5;

    // ─────────────────────────────────────────────────────────
    // REGISTER
    // ─────────────────────────────────────────────────────────
    @Override
    @Transactional
    public ApiResponse<Void> register(RegisterRequest request) {

        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new ApiException("Mật khẩu xác nhận không khớp", HttpStatus.BAD_REQUEST);
        }

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new EmailAlreadyExistsException("Email đã được sử dụng");
        }

        Currency vnd = currencyRepository.findByCurrencyCode("VND")
                .orElseThrow(() -> new ApiException("Không tìm thấy tiền tệ VND", HttpStatus.INTERNAL_SERVER_ERROR));

        User user = User.builder()
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .fullName(request.getFullName())
                .baseCurrency(vnd)
                .build();

        userRepository.save(user);

        String otpCode = otpUtil.generate();
        LocalDateTime now = LocalDateTime.now();

        OtpVerification otp = OtpVerification.builder()
                .target(request.getEmail())
                .otpCode(otpCode)
                .otpType(OTP_TYPE_REGISTER)
                .expiresAt(now.plusMinutes(otpExpirationMinutes))
                .lastSentAt(now)
                .isUsed(false)
                .attemptCount(0)
                .build();

        otpRepository.save(otp);
        emailService.sendRegisterOtpEmail(request.getEmail(), request.getFullName(), otpCode);

        return ApiResponse.success("Mã OTP đã gửi tới email. Vui lòng kiểm tra hộp thư.", null);
    }

    // ─────────────────────────────────────────────────────────
    // VERIFY OTP (đăng ký)
    // ─────────────────────────────────────────────────────────
    @Override
    @Transactional
    public ApiResponse<AuthResponse> verifyOtp(VerifyOtpRequest request) {

        OtpVerification otp = otpRepository
                .findTopByTargetAndOtpTypeAndIsUsedFalseOrderByCreatedAtDesc(
                        request.getEmail(), OTP_TYPE_REGISTER)
                .orElseThrow(() -> new ApiException("Không tìm thấy yêu cầu xác thực", HttpStatus.BAD_REQUEST));

        if (otp.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new ApiException("Mã OTP đã hết hạn, vui lòng gửi lại", HttpStatus.BAD_REQUEST);
        }

        if (otp.getAttemptCount() >= MAX_ATTEMPT) {
            throw new ApiException("Đã nhập sai quá nhiều lần, yêu cầu OTP mới", HttpStatus.BAD_REQUEST);
        }

        if (!otp.getOtpCode().equals(request.getOtpCode())) {
            otp.setAttemptCount(otp.getAttemptCount() + 1);
            otpRepository.save(otp);
            int remaining = MAX_ATTEMPT - otp.getAttemptCount();
            throw new ApiException("Mã OTP không đúng. Còn " + remaining + " lần thử", HttpStatus.BAD_REQUEST);
        }

        otp.setUsed(true);
        otpRepository.save(otp);

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        // Tạo category mặc định cho user mới
        categoryService.createDefaultCategories(user);

        String accessToken  = jwtUtil.generateAccessToken(user.getUserId());
        String refreshToken = jwtUtil.generateRefreshToken(user.getUserId());

        return ApiResponse.success("Xác thực thành công", buildAuthResponse(user, accessToken, refreshToken));
    }

    // ─────────────────────────────────────────────────────────
    // RESEND OTP
    // ─────────────────────────────────────────────────────────
    @Override
    @Transactional
    public ApiResponse<Void> resendOtp(ResendOtpRequest request) {

        otpRepository
                .findTopByTargetAndOtpTypeAndIsUsedFalseOrderByCreatedAtDesc(
                        request.getEmail(), OTP_TYPE_REGISTER)
                .ifPresent(prev -> {
                    if (prev.getLastSentAt() != null &&
                            prev.getLastSentAt().plusSeconds(resendCooldownSeconds).isAfter(LocalDateTime.now())) {
                        throw new TooManyRequestsException("Vui lòng chờ trước khi gửi lại OTP");
                    }
                    prev.setUsed(true);
                    otpRepository.save(prev);
                });

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        String otpCode = otpUtil.generate();
        LocalDateTime now = LocalDateTime.now();

        OtpVerification otp = OtpVerification.builder()
                .target(request.getEmail())
                .otpCode(otpCode)
                .otpType(OTP_TYPE_REGISTER)
                .expiresAt(now.plusMinutes(otpExpirationMinutes))
                .lastSentAt(now)
                .isUsed(false)
                .attemptCount(0)
                .build();

        otpRepository.save(otp);
        emailService.sendRegisterOtpEmail(request.getEmail(), user.getFullName(), otpCode);

        return ApiResponse.success("Đã gửi lại mã OTP. Vui lòng kiểm tra hộp thư.", null);
    }

    // ─────────────────────────────────────────────────────────
    // LOGIN
    // ─────────────────────────────────────────────────────────
    @Override
    public ApiResponse<AuthResponse> login(LoginRequest request) {

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ApiException("Email hoặc mật khẩu không đúng", HttpStatus.UNAUTHORIZED));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new ApiException("Email hoặc mật khẩu không đúng", HttpStatus.UNAUTHORIZED);
        }

        String accessToken  = jwtUtil.generateAccessToken(user.getUserId());
        String refreshToken = jwtUtil.generateRefreshToken(user.getUserId());

        return ApiResponse.success("Đăng nhập thành công", buildAuthResponse(user, accessToken, refreshToken));
    }

    // ─────────────────────────────────────────────────────────
    // REFRESH TOKEN
    // ─────────────────────────────────────────────────────────
    @Override
    public ApiResponse<AuthResponse> refreshToken(String refreshToken) {

        if (!jwtUtil.validateToken(refreshToken)) {
            throw new ApiException("Refresh token không hợp lệ hoặc đã hết hạn", HttpStatus.UNAUTHORIZED);
        }

        Integer userId = jwtUtil.extractUserId(refreshToken);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        String newAccessToken  = jwtUtil.generateAccessToken(userId);
        String newRefreshToken = jwtUtil.generateRefreshToken(userId);

        return ApiResponse.success("Làm mới token thành công", buildAuthResponse(user, newAccessToken, newRefreshToken));
    }

    // ─────────────────────────────────────────────────────────
    // LOGOUT
    // ─────────────────────────────────────────────────────────
    @Override
    public ApiResponse<Void> logout(String refreshToken) {
        if (refreshToken != null && jwtUtil.validateToken(refreshToken)) {
            jwtUtil.blacklistToken(refreshToken);
        }
        return ApiResponse.success("Đăng xuất thành công", null);
    }

    // ─────────────────────────────────────────────────────────
    // FORGOT PASSWORD
    // ─────────────────────────────────────────────────────────
    @Override
    @Transactional
    public ApiResponse<Void> forgotPassword(ForgotPasswordRequest request) {

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy tài khoản với email này"));

        otpRepository
                .findTopByTargetAndOtpTypeAndIsUsedFalseOrderByCreatedAtDesc(
                        request.getEmail(), OTP_TYPE_FORGOT)
                .ifPresent(prev -> {
                    if (prev.getLastSentAt() != null &&
                            prev.getLastSentAt().plusSeconds(resendCooldownSeconds).isAfter(LocalDateTime.now())) {
                        throw new TooManyRequestsException("Vui lòng chờ trước khi gửi lại OTP");
                    }
                    prev.setUsed(true);
                    otpRepository.save(prev);
                });

        String otpCode = otpUtil.generate();
        LocalDateTime now = LocalDateTime.now();

        OtpVerification otp = OtpVerification.builder()
                .target(request.getEmail())
                .otpCode(otpCode)
                .otpType(OTP_TYPE_FORGOT)
                .expiresAt(now.plusMinutes(otpExpirationMinutes))
                .lastSentAt(now)
                .isUsed(false)
                .attemptCount(0)
                .build();

        otpRepository.save(otp);
        emailService.sendForgotPasswordOtpEmail(request.getEmail(), user.getFullName(), otpCode);

        return ApiResponse.success("Mã OTP đặt lại mật khẩu đã được gửi tới email.", null);
    }

    // ─────────────────────────────────────────────────────────
    // RESET PASSWORD
    // ─────────────────────────────────────────────────────────
    @Override
    @Transactional
    public ApiResponse<Void> resetPassword(ResetPasswordRequest request) {

        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new ApiException("Mật khẩu xác nhận không khớp", HttpStatus.BAD_REQUEST);
        }

        OtpVerification otp = otpRepository
                .findTopByTargetAndOtpTypeAndIsUsedFalseOrderByCreatedAtDesc(
                        request.getEmail(), OTP_TYPE_FORGOT)
                .orElseThrow(() -> new ApiException("Không tìm thấy yêu cầu đặt lại mật khẩu", HttpStatus.BAD_REQUEST));

        if (otp.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new ApiException("Mã OTP đã hết hạn, vui lòng gửi lại", HttpStatus.BAD_REQUEST);
        }

        if (otp.getAttemptCount() >= MAX_ATTEMPT) {
            throw new ApiException("Đã nhập sai quá nhiều lần, yêu cầu OTP mới", HttpStatus.BAD_REQUEST);
        }

        if (!otp.getOtpCode().equals(request.getOtpCode())) {
            otp.setAttemptCount(otp.getAttemptCount() + 1);
            otpRepository.save(otp);
            int remaining = MAX_ATTEMPT - otp.getAttemptCount();
            throw new ApiException("Mã OTP không đúng. Còn " + remaining + " lần thử", HttpStatus.BAD_REQUEST);
        }

        otp.setUsed(true);
        otpRepository.save(otp);

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        return ApiResponse.success("Đặt lại mật khẩu thành công", null);
    }

    // ─────────────────────────────────────────────────────────
    // HELPER
    // ─────────────────────────────────────────────────────────
    private AuthResponse buildAuthResponse(User user, String accessToken, String refreshToken) {

        UserResponse userResponse = UserResponse.builder()
                .userId(user.getUserId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .build();

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(86400)
                .user(userResponse)
                .build();
    }
}
