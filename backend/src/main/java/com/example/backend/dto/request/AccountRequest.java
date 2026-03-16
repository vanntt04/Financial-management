package com.example.backend.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class AccountRequest {

    @NotBlank(message = "Tên hũ không được để trống")
    @Size(max = 100, message = "Tên hũ tối đa 100 ký tự")
    private String accountName;

    @DecimalMin(value = "0", message = "Phần trăm phân bổ không được âm")
    @DecimalMax(value = "100", message = "Phần trăm phân bổ tối đa 100%")
    private BigDecimal allocationPercentage;

    private Boolean isGoalActive = false;

    @DecimalMin(value = "0", message = "Số tiền mục tiêu không được âm")
    private BigDecimal targetAmount;

    private LocalDate targetDate;
}
