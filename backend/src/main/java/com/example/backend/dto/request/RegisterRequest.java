package com.example.backend.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class RegisterRequest {

    @NotBlank(message = "Họ tên không được để trống")
    @Size(min = 2, max = 50, message = "Họ tên phải từ 2 đến 50 ký tự")
    private String fullName;

    @NotBlank(message = "Email không được để trống")
    @Email(message = "Email không hợp lệ")
    private String email;

    @NotBlank(message = "Mật khẩu không được để trống")
    @Size(min = 8, message = "Mật khẩu phải có ít nhất 8 ký tự, gồm chữ hoa, thường và số")
    @Pattern(
        regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).+$",
        message = "Mật khẩu phải có ít nhất 8 ký tự, gồm chữ hoa, thường và số"
    )
    private String password;

    @NotBlank(message = "Xác nhận mật khẩu không được để trống")
    private String confirmPassword;

    @Pattern(
        regexp = "^(0[3|5|7|8|9])+([0-9]{8})$",
        message = "Số điện thoại không hợp lệ"
    )
    private String phoneNumber;
}
