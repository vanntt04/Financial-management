package com.example.backend.service;

import com.example.backend.dto.request.TransactionRequest;
import com.example.backend.dto.response.TransactionResponse;

import java.util.List;

public interface TransactionService {

    List<TransactionResponse> getTransactions(Integer userId);

    TransactionResponse createTransaction(Integer userId, TransactionRequest req);

    void deleteTransaction(Integer userId, Integer transactionId);
}
