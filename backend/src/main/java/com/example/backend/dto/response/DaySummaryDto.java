package com.example.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DaySummaryDto {
    private int day;
    private double totalIncome;
    private double totalExpense;
    private boolean hasTransaction;
}
