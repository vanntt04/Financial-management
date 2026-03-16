package com.example.backend.service.impl;

import com.example.backend.dto.request.AccountRequest;
import com.example.backend.dto.response.AccountResponse;
import com.example.backend.entity.Account;
import com.example.backend.entity.User;
import com.example.backend.exception.ApiException;
import com.example.backend.exception.ResourceNotFoundException;
import com.example.backend.repository.AccountRepository;
import com.example.backend.repository.CurrencyRepository;
import com.example.backend.repository.UserRepository;
import com.example.backend.service.AccountService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AccountServiceImpl implements AccountService {

    private final AccountRepository accountRepository;
    private final UserRepository userRepository;
    private final CurrencyRepository currencyRepository;

    @Override
    public List<AccountResponse> getAccounts(Integer userId) {
        User user = getUser(userId);
        return accountRepository.findByUserAndIsDeletedFalse(user)
                .stream().map(this::toResponse).toList();
    }

    @Override
    @Transactional
    public AccountResponse createAccount(Integer userId, AccountRequest request) {
        User user = getUser(userId);

        // Dùng currency VND mặc định
        var currency = currencyRepository.findByCurrencyCode("VND")
                .orElseThrow(() -> new ApiException("Không tìm thấy VND", HttpStatus.INTERNAL_SERVER_ERROR));

        Account account = Account.builder()
                .user(user)
                .accountName(request.getAccountName())
                .currency(currency)
                .allocationPercentage(request.getAllocationPercentage())
                .isGoalActive(Boolean.TRUE.equals(request.getIsGoalActive()))
                .targetAmount(request.getTargetAmount())
                .targetDate(request.getTargetDate())
                .isDeleted(false)
                .build();

        return toResponse(accountRepository.save(account));
    }

    @Override
    @Transactional
    public AccountResponse updateAccount(Integer userId, Integer accountId, AccountRequest request) {
        Account account = accountRepository.findById(accountId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy hũ"));

        if (!account.getUser().getUserId().equals(userId)) {
            throw new ApiException("Bạn không có quyền sửa hũ này", HttpStatus.FORBIDDEN);
        }
        if (account.isDeleted()) {
            throw new ResourceNotFoundException("Không tìm thấy hũ");
        }

        account.setAccountName(request.getAccountName());
        account.setAllocationPercentage(request.getAllocationPercentage());
        account.setGoalActive(Boolean.TRUE.equals(request.getIsGoalActive()));
        account.setTargetAmount(request.getTargetAmount());
        account.setTargetDate(request.getTargetDate());

        return toResponse(accountRepository.save(account));
    }

    @Override
    @Transactional
    public void deleteAccount(Integer userId, Integer accountId) {
        Account account = accountRepository.findById(accountId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy hũ"));

        if (!account.getUser().getUserId().equals(userId)) {
            throw new ApiException("Bạn không có quyền xóa hũ này", HttpStatus.FORBIDDEN);
        }

        account.setDeleted(true);
        accountRepository.save(account);
    }

    // ── Helper ─────────────────────────────────────────────
    private User getUser(Integer userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));
    }

    private AccountResponse toResponse(Account a) {
        return AccountResponse.builder()
                .accountId(a.getAccountId())
                .accountName(a.getAccountName())
                .balance(a.getBalance())
                .allocationPercentage(a.getAllocationPercentage())
                .isGoalActive(a.isGoalActive())
                .targetAmount(a.getTargetAmount())
                .build();
    }
}
