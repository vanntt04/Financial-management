package com.example.backend.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
public class TransactionRequest {

    @NotNull(message = "Tài khoản không được để trống")
    private Integer accountId;

    @NotNull(message = "Danh mục không được để trống")
    private Integer categoryId;

    @NotNull(message = "Số tiền không được để trống")
    @DecimalMin(value = "0.01", message = "Số tiền phải lớn hơn 0")
    private BigDecimal amount;

    @NotBlank(message = "Loại giao dịch không được để trống")
    @Pattern(regexp = "^(INCOME|EXPENSE|TRANSFER)$",
             message = "Loại giao dịch phải là INCOME, EXPENSE hoặc TRANSFER")
    private String transactionType;

    private LocalDateTime transactionDate;

    private Integer receiverAccountId;
}
