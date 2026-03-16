package com.example.backend.repository;

import com.example.backend.entity.Account;
import com.example.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface AccountRepository extends JpaRepository<Account, Integer> {

    List<Account> findByUserAndIsDeletedFalse(User user);

    @Query("SELECT COALESCE(SUM(a.balance), 0) FROM Account a " +
            "WHERE a.user = :user AND a.isDeleted = false")
    BigDecimal sumBalanceByUser(@Param("user") User user);
}
