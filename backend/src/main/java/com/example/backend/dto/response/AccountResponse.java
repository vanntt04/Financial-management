package com.example.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AccountResponse {
    private Integer accountId;
    private String accountName;
    private BigDecimal balance;
    private BigDecimal allocationPercentage;
    private Boolean isGoalActive;
    private BigDecimal targetAmount;
}
