package com.example.backend.repository;

import com.example.backend.entity.Transaction;
import com.example.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Integer> {

    List<Transaction> findByUserAndIsDeletedFalseOrderByTransactionDateDesc(User user);

    Optional<Transaction> findByTransactionIdAndIsDeletedFalse(Integer transactionId);
    @Query("SELECT t FROM Transaction t WHERE t.user.userId = :userId AND t.transactionDate >= :start AND t.transactionDate < :end AND t.isDeleted = false")
    List<Transaction> findByUserIdAndDateBetween(
            @Param("userId") Integer userId,
            @Param("start") LocalDateTime start,
            @Param("end") LocalDateTime end);
}
