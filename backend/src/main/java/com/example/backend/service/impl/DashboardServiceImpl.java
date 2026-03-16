package com.example.backend.service.impl;

import com.example.backend.dto.response.AccountResponse;
import com.example.backend.dto.response.DashboardResponse;
import com.example.backend.dto.response.TransactionResponse;
import com.example.backend.entity.User;
import com.example.backend.exception.ResourceNotFoundException;
import com.example.backend.repository.AccountRepository;
import com.example.backend.repository.TransactionRepository;
import com.example.backend.repository.UserRepository;
import com.example.backend.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DashboardServiceImpl implements DashboardService {

    private final AccountRepository accountRepository;
    private final TransactionRepository transactionRepository;
    private final UserRepository userRepository;

    @Override
    public DashboardResponse getDashboard(Integer userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        LocalDateTime startOfMonth = LocalDateTime.now()
                .withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime endOfMonth = LocalDateTime.now()
                .withDayOfMonth(LocalDateTime.now().toLocalDate().lengthOfMonth())
                .withHour(23).withMinute(59).withSecond(59);

        BigDecimal totalBalance   = accountRepository.sumBalanceByUser(user);
        BigDecimal monthlyIncome  = transactionRepository.sumIncome(user, startOfMonth, endOfMonth);
        BigDecimal monthlyExpense = transactionRepository.sumExpense(user, startOfMonth, endOfMonth);
        BigDecimal monthlySaving  = monthlyIncome.subtract(monthlyExpense);

        List<AccountResponse> accounts = accountRepository.findByUserAndIsDeletedFalse(user)
                .stream()
                .map(a -> AccountResponse.builder()
                        .accountId(a.getAccountId())
                        .accountName(a.getAccountName())
                        .balance(a.getBalance())
                        .allocationPercentage(a.getAllocationPercentage())
                        .isGoalActive(a.isGoalActive())
                        .targetAmount(a.getTargetAmount())
                        .build())
                .toList();

        List<TransactionResponse.Item> recent = transactionRepository
                .findRecent(user, PageRequest.of(0, 5))
                .stream()
                .map(t -> TransactionResponse.Item.builder()
                        .transactionId(t.getTransactionId())
                        .amount(t.getAmount())
                        .transactionType(t.getTransactionType())
                        .transactionDate(t.getTransactionDate())
                        .accountId(t.getAccount() != null ? t.getAccount().getAccountId() : null)
                        .accountName(t.getAccount() != null ? t.getAccount().getAccountName() : null)
                        .categoryId(t.getCategory() != null ? t.getCategory().getCategoryId() : null)
                        .categoryName(t.getCategory() != null ? t.getCategory().getCategoryName() : null)
                        .categoryType(t.getCategory() != null ? t.getCategory().getCategoryType() : null)
                        .build())
                .toList();

        return DashboardResponse.builder()
                .totalBalance(totalBalance)
                .monthlyIncome(monthlyIncome)
                .monthlyExpense(monthlyExpense)
                .monthlySaving(monthlySaving)
                .accounts(accounts)
                .recentTransactions(recent)
                .build();
    }
}
