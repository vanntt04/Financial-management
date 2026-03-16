package com.example.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class TransactionResponse {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Item {
        private Integer transactionId;
        private BigDecimal amount;
        private String transactionType;
        private LocalDateTime transactionDate;
        private String categoryName;
        private String categoryType;
        private Integer categoryId;
        private String accountName;
        private Integer accountId;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ListResponse {
        private List<Item> transactions;
        private int totalCount;
        private String filterType;
    }
}
