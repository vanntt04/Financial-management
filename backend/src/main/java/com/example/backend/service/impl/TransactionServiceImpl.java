package com.example.backend.service.impl;

import com.example.backend.dto.request.TransactionRequest;
import com.example.backend.dto.response.TransactionResponse;
import com.example.backend.entity.Account;
import com.example.backend.entity.Category;
import com.example.backend.entity.Transaction;
import com.example.backend.entity.User;
import com.example.backend.exception.ApiException;
import com.example.backend.exception.ResourceNotFoundException;
import com.example.backend.repository.AccountRepository;
import com.example.backend.repository.CategoryRepository;
import com.example.backend.repository.TransactionRepository;
import com.example.backend.repository.UserRepository;
import com.example.backend.service.TransactionService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TransactionServiceImpl implements TransactionService {

    private final TransactionRepository transactionRepository;
    private final AccountRepository accountRepository;
    private final CategoryRepository categoryRepository;
    private final UserRepository userRepository;

    @Override
    public TransactionResponse.ListResponse getTransactions(Integer userId, String filterType) {
        User user = getUser(userId);

        List<Transaction> list;
        if (filterType == null || filterType.equalsIgnoreCase("ALL")) {
            list = transactionRepository.findByUserAndIsDeletedFalseOrderByTransactionDateDesc(user);
        } else {
            list = transactionRepository
                    .findByUserAndTransactionTypeAndIsDeletedFalseOrderByTransactionDateDesc(
                            user, filterType.toUpperCase());
        }

        List<TransactionResponse.Item> items = list.stream().map(this::toItem).toList();
        return TransactionResponse.ListResponse.builder()
                .transactions(items)
                .totalCount(items.size())
                .filterType(filterType == null ? "ALL" : filterType.toUpperCase())
                .build();
    }

    @Override
    @Transactional
    public TransactionResponse.Item createTransaction(Integer userId, TransactionRequest req) {
        User user = getUser(userId);

        Account account = accountRepository.findById(req.getAccountId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy tài khoản"));

        if (!account.getUser().getUserId().equals(userId)) {
            throw new ApiException("Tài khoản không thuộc người dùng này", HttpStatus.FORBIDDEN);
        }

        Category category = categoryRepository.findByCategoryIdAndIsDeletedFalse(req.getCategoryId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy danh mục"));

        Transaction t = Transaction.builder()
                .user(user)
                .account(account)
                .category(category)
                .amount(req.getAmount())
                .transactionType(req.getTransactionType().toUpperCase())
                .transactionDate(req.getTransactionDate() != null
                        ? req.getTransactionDate() : LocalDateTime.now())
                .isDeleted(false)
                .build();

        // Cập nhật số dư tài khoản
        if (req.getTransactionType().equalsIgnoreCase("INCOME")) {
            account.setBalance(account.getBalance().add(req.getAmount()));
        } else {
            account.setBalance(account.getBalance().subtract(req.getAmount()));
        }
        accountRepository.save(account);

        return toItem(transactionRepository.save(t));
    }

    @Override
    @Transactional
    public void deleteTransaction(Integer userId, Integer transactionId) {
        Transaction t = transactionRepository.findByTransactionIdAndIsDeletedFalse(transactionId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy giao dịch"));

        if (!t.getUser().getUserId().equals(userId)) {
            throw new ApiException("Giao dịch không thuộc người dùng này", HttpStatus.FORBIDDEN);
        }

        // Hoàn lại số dư
        Account account = t.getAccount();
        if (account != null) {
            if (t.getTransactionType().equals("INCOME")) {
                account.setBalance(account.getBalance().subtract(t.getAmount()));
            } else {
                account.setBalance(account.getBalance().add(t.getAmount()));
            }
            accountRepository.save(account);
        }

        t.setDeleted(true);
        transactionRepository.save(t);
    }

    // ── Helper ─────────────────────────────────────────────

    private User getUser(Integer userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));
    }

    private TransactionResponse.Item toItem(Transaction t) {
        return TransactionResponse.Item.builder()
                .transactionId(t.getTransactionId())
                .amount(t.getAmount())
                .transactionType(t.getTransactionType())
                .transactionDate(t.getTransactionDate())
                .accountId(t.getAccount() != null ? t.getAccount().getAccountId() : null)
                .accountName(t.getAccount() != null ? t.getAccount().getAccountName() : null)
                .categoryId(t.getCategory() != null ? t.getCategory().getCategoryId() : null)
                .categoryName(t.getCategory() != null ? t.getCategory().getCategoryName() : null)
                .categoryType(t.getCategory() != null ? t.getCategory().getCategoryType() : null)
                .build();
    }
}
