package com.example.backend.repository;

import com.example.backend.entity.Transaction;
import com.example.backend.entity.User;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Integer> {

    List<Transaction> findByUserAndIsDeletedFalseOrderByTransactionDateDesc(User user);

    List<Transaction> findByUserAndTransactionTypeAndIsDeletedFalseOrderByTransactionDateDesc(
            User user, String transactionType);

    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t " +
            "WHERE t.user = :user AND t.transactionType = 'INCOME' " +
            "AND t.isDeleted = false " +
            "AND t.transactionDate BETWEEN :start AND :end")
    BigDecimal sumIncome(@Param("user") User user,
                         @Param("start") LocalDateTime start,
                         @Param("end") LocalDateTime end);

    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t " +
            "WHERE t.user = :user AND t.transactionType = 'EXPENSE' " +
            "AND t.isDeleted = false " +
            "AND t.transactionDate BETWEEN :start AND :end")
    BigDecimal sumExpense(@Param("user") User user,
                          @Param("start") LocalDateTime start,
                          @Param("end") LocalDateTime end);

    @Query("SELECT t FROM Transaction t WHERE t.user = :user " +
            "AND t.isDeleted = false ORDER BY t.transactionDate DESC")
    List<Transaction> findRecent(@Param("user") User user, Pageable pageable);

    Optional<Transaction> findByTransactionIdAndIsDeletedFalse(Integer transactionId);
}
