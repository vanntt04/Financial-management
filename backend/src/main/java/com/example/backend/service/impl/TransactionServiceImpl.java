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
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TransactionServiceImpl implements TransactionService {

    private final TransactionRepository transactionRepository;
    private final AccountRepository accountRepository;
    private final CategoryRepository categoryRepository;
    private final UserRepository userRepository;

    private User loadUser(Integer userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));
    }

    private Account loadAccount(Integer accountId, User user) {
        return accountRepository.findByAccountIdAndUserAndIsDeletedFalse(accountId, user)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy tài khoản với id: " + accountId));
    }

    private Category loadCategory(Integer categoryId, User user) {
        return categoryRepository.findByCategoryIdAndIsDeletedFalse(categoryId)
                .filter(c -> c.getUser().getUserId().equals(user.getUserId()))
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy danh mục với id: " + categoryId));
    }

    @Override
    public List<TransactionResponse> getTransactions(Integer userId) {
        User user = loadUser(userId);
        return transactionRepository
                .findByUserAndIsDeletedFalseOrderByTransactionDateDesc(user)
                .stream()
                .map(TransactionResponse::from)
                .toList();
    }

    @Override
    @Transactional
    public TransactionResponse createTransaction(Integer userId, TransactionRequest req) {
        User user = loadUser(userId);
        Account account = loadAccount(req.getAccountId(), user);
        Category category = loadCategory(req.getCategoryId(), user);

        String type = req.getTransactionType().toUpperCase();

        switch (type) {
            case "INCOME" -> {
                account.setBalance(account.getBalance().add(req.getAmount()));
                accountRepository.save(account);
            }
            case "EXPENSE" -> {
                if (account.getBalance().compareTo(req.getAmount()) < 0) {
                    throw new ApiException("Số dư không đủ để thực hiện giao dịch", HttpStatus.BAD_REQUEST);
                }
                account.setBalance(account.getBalance().subtract(req.getAmount()));
                accountRepository.save(account);
            }
            case "TRANSFER" -> {
                if (req.getReceiverAccountId() == null) {
                    throw new ApiException("Tài khoản nhận không được để trống khi chuyển tiền",
                            HttpStatus.BAD_REQUEST);
                }
                if (req.getReceiverAccountId().equals(req.getAccountId())) {
                    throw new ApiException("Tài khoản nguồn và tài khoản nhận không được trùng nhau",
                            HttpStatus.BAD_REQUEST);
                }
                if (account.getBalance().compareTo(req.getAmount()) < 0) {
                    throw new ApiException("Số dư không đủ để thực hiện chuyển tiền", HttpStatus.BAD_REQUEST);
                }
                Account receiverAccount = loadAccount(req.getReceiverAccountId(), user);
                account.setBalance(account.getBalance().subtract(req.getAmount()));
                receiverAccount.setBalance(receiverAccount.getBalance().add(req.getAmount()));
                accountRepository.save(account);
                accountRepository.save(receiverAccount);
            }
            default -> throw new ApiException("Loại giao dịch không hợp lệ: " + type, HttpStatus.BAD_REQUEST);
        }

        Account receiverAccountRef = (type.equals("TRANSFER") && req.getReceiverAccountId() != null)
                ? loadAccount(req.getReceiverAccountId(), user) : null;

        Transaction transaction = Transaction.builder()
                .user(user)
                .account(account)
                .category(category)
                .amount(req.getAmount())
                .transactionType(type)
                .transactionDate(req.getTransactionDate() != null
                        ? req.getTransactionDate() : LocalDateTime.now())
                .receiverAccount(receiverAccountRef)
                .isDeleted(false)
                .build();

        return TransactionResponse.from(transactionRepository.save(transaction));
    }

    @Override
    @Transactional
    public void deleteTransaction(Integer userId, Integer transactionId) {
        Transaction transaction = transactionRepository
                .findByTransactionIdAndIsDeletedFalse(transactionId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Không tìm thấy giao dịch với id: " + transactionId));

        if (!transaction.getUser().getUserId().equals(userId)) {
            throw new ApiException("Bạn không có quyền xóa giao dịch này", HttpStatus.FORBIDDEN);
        }

        // Hoàn tiền ngược lại
        String type = transaction.getTransactionType();
        Account account = transaction.getAccount();

        switch (type) {
            case "INCOME" -> {
                account.setBalance(account.getBalance().subtract(transaction.getAmount()));
                accountRepository.save(account);
            }
            case "EXPENSE" -> {
                account.setBalance(account.getBalance().add(transaction.getAmount()));
                accountRepository.save(account);
            }
            case "TRANSFER" -> {
                account.setBalance(account.getBalance().add(transaction.getAmount()));
                accountRepository.save(account);
                Account receiverAccount = transaction.getReceiverAccount();
                if (receiverAccount != null) {
                    receiverAccount.setBalance(receiverAccount.getBalance().subtract(transaction.getAmount()));
                    accountRepository.save(receiverAccount);
                }
            }
        }

        transaction.setDeleted(true);
        transactionRepository.save(transaction);
    }
}
