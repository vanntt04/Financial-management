package com.example.backend.service.impl;

import com.example.backend.dto.response.*;
import com.example.backend.entity.Account;
import com.example.backend.entity.Transaction;
import com.example.backend.exception.ApiException;
import com.example.backend.repository.AccountRepository;
import com.example.backend.repository.TransactionRepository;
import com.example.backend.repository.UserRepository;
import com.example.backend.service.ReportsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReportsServiceImpl implements ReportsService {

    private static final String TYPE_INCOME = "INCOME";
    private static final String TYPE_EXPENSE = "EXPENSE";

    private final TransactionRepository transactionRepository;
    private final AccountRepository accountRepository;
    private final UserRepository userRepository;

    @Override
    public ApiResponse<MonthlySummaryDto> getMonthlySummary(Authentication auth, int month, int year) {
        Integer userId = getUserId(auth);
        LocalDateTime start = YearMonth.of(year, month).atDay(1).atStartOfDay();
        LocalDateTime end = YearMonth.of(year, month).atEndOfMonth().plusDays(1).atStartOfDay();

        List<Transaction> list = transactionRepository.findByUserIdAndDateBetween(userId, start, end);

        double totalIncome = list.stream()
                .filter(t -> TYPE_INCOME.equals(t.getTransactionType()))
                .mapToDouble(t -> t.getAmount().doubleValue())
                .sum();
        double totalExpense = list.stream()
                .filter(t -> TYPE_EXPENSE.equals(t.getTransactionType()))
                .mapToDouble(t -> t.getAmount().doubleValue())
                .sum();

        Map<Integer, Double> spentByAccount = list.stream()
                .filter(t -> TYPE_EXPENSE.equals(t.getTransactionType()))
                .collect(Collectors.groupingBy(
                        t -> t.getAccount().getAccountId(),
                        Collectors.summingDouble(t -> t.getAmount().doubleValue())
                ));

        List<Account> accounts = accountRepository.findByUserUserIdAndIsDeletedFalse(userId);
        List<JarUsageDto> jars = new ArrayList<>();
        for (Account acc : accounts) {
            double spent = spentByAccount.getOrDefault(acc.getAccountId(), 0.0);
            double budget = 0.0;
            if (acc.getAllocationPercentage() != null && totalIncome > 0) {
                budget = totalIncome * acc.getAllocationPercentage().doubleValue() / 100.0;
            }
            jars.add(JarUsageDto.builder()
                    .name(acc.getAccountName())
                    .spent(spent)
                    .budget(budget)
                    .build());
        }

        MonthlySummaryDto dto = MonthlySummaryDto.builder()
                .month(month)
                .year(year)
                .totalExpense(totalExpense)
                .totalIncome(totalIncome)
                .jars(jars)
                .build();
        return ApiResponse.success("Thành công", dto);
    }

    @Override
    public ApiResponse<CalendarReportDto> getCalendarReport(Authentication auth, int month, int year) {
        Integer userId = getUserId(auth);
        LocalDateTime start = YearMonth.of(year, month).atDay(1).atStartOfDay();
        LocalDateTime end = YearMonth.of(year, month).atEndOfMonth().plusDays(1).atStartOfDay();

        List<Transaction> list = transactionRepository.findByUserIdAndDateBetween(userId, start, end);

        int daysInMonth = YearMonth.of(year, month).lengthOfMonth();
        Map<Integer, DaySummaryDto> byDay = new HashMap<>();
        for (int d = 1; d <= daysInMonth; d++) {
            byDay.put(d, DaySummaryDto.builder()
                    .day(d)
                    .totalIncome(0.0)
                    .totalExpense(0.0)
                    .hasTransaction(false)
                    .build());
        }

        for (Transaction t : list) {
            LocalDate date = t.getTransactionDate().toLocalDate();
            if (date.getYear() != year || date.getMonthValue() != month) continue;
            int day = date.getDayOfMonth();
            DaySummaryDto existing = byDay.get(day);
            double income = TYPE_INCOME.equals(t.getTransactionType()) ? t.getAmount().doubleValue() : 0;
            double expense = TYPE_EXPENSE.equals(t.getTransactionType()) ? t.getAmount().doubleValue() : 0;
            byDay.put(day, DaySummaryDto.builder()
                    .day(day)
                    .totalIncome(existing.getTotalIncome() + income)
                    .totalExpense(existing.getTotalExpense() + expense)
                    .hasTransaction(true)
                    .build());
        }

        List<DaySummaryDto> days = new ArrayList<>();
        for (int d = 1; d <= daysInMonth; d++) {
            days.add(byDay.get(d));
        }

        CalendarReportDto dto = CalendarReportDto.builder()
                .month(month)
                .year(year)
                .days(days)
                .build();
        return ApiResponse.success("Thành công", dto);
    }

    private Integer getUserId(Authentication auth) {
        if (auth == null || auth.getPrincipal() == null) {
            throw new ApiException("Chưa đăng nhập", HttpStatus.UNAUTHORIZED);
        }
        return Integer.parseInt(auth.getPrincipal().toString());
    }
}
