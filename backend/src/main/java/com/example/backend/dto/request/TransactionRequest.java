package com.example.backend.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class TransactionRequest {

    @NotNull(message = "Vui lòng nhập số tiền")
    @DecimalMin(value = "1", message = "Số tiền phải lớn hơn 0")
    private BigDecimal amount;

    @NotNull(message = "Vui lòng chọn tài khoản")
    private Integer accountId;

    @NotNull(message = "Vui lòng chọn danh mục")
    private Integer categoryId;

    @NotNull(message = "Vui lòng chọn loại giao dịch")
    private String transactionType; // INCOME | EXPENSE

    private LocalDateTime transactionDate;
}
