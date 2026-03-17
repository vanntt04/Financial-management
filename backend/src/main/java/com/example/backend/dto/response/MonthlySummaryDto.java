package com.example.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MonthlySummaryDto {
    private int month;
    private int year;
    private double totalExpense;
    private double totalIncome;
    private List<JarUsageDto> jars;
}
