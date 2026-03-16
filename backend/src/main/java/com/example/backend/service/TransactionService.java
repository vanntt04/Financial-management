package com.example.backend.service;

import com.example.backend.dto.request.TransactionRequest;
import com.example.backend.dto.response.TransactionResponse;

public interface TransactionService {
    TransactionResponse.ListResponse getTransactions(Integer userId, String filterType);
    TransactionResponse.Item createTransaction(Integer userId, TransactionRequest request);
    void deleteTransaction(Integer userId, Integer transactionId);
}
