package com.example.backend.repository;

import com.example.backend.entity.Account;
import com.example.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface AccountRepository extends JpaRepository<Account, Integer> {

    Optional<Account> findByAccountIdAndUserAndIsDeletedFalse(Integer accountId, User user);
}
