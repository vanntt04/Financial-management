package com.example.backend.service;

import com.example.backend.dto.request.AccountRequest;
import com.example.backend.dto.response.AccountResponse;

import java.util.List;

public interface AccountService {
    List<AccountResponse> getAccounts(Integer userId);
    AccountResponse createAccount(Integer userId, AccountRequest request);
    AccountResponse updateAccount(Integer userId, Integer accountId, AccountRequest request);
    void deleteAccount(Integer userId, Integer accountId);
}
