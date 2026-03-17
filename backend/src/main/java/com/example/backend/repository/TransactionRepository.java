package com.example.backend.repository;

import com.example.backend.entity.Transaction;
import com.example.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Integer> {

    List<Transaction> findByUserAndIsDeletedFalseOrderByTransactionDateDesc(User user);

    Optional<Transaction> findByTransactionIdAndIsDeletedFalse(Integer transactionId);
}
