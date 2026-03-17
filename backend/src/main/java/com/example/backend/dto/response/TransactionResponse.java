package com.example.backend.dto.response;

import com.example.backend.entity.Transaction;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionResponse {

    private Integer transactionId;
    private String accountName;
    private String categoryName;
    private String categoryType;
    private BigDecimal amount;
    private String transactionType;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime transactionDate;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime updatedAt;

    public static TransactionResponse from(Transaction t) {
        return TransactionResponse.builder()
                .transactionId(t.getTransactionId())
                .accountName(t.getAccount().getAccountName())
                .categoryName(t.getCategory().getCategoryName())
                .categoryType(t.getCategory().getCategoryType())
                .amount(t.getAmount())
                .transactionType(t.getTransactionType())
                .transactionDate(t.getTransactionDate())
                .updatedAt(t.getUpdatedAt())
                .build();
    }
}
