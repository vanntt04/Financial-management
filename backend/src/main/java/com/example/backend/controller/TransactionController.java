package com.example.backend.controller;

import com.example.backend.dto.request.TransactionRequest;
import com.example.backend.dto.response.ApiResponse;
import com.example.backend.dto.response.TransactionResponse;
import com.example.backend.service.TransactionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/transactions")
@RequiredArgsConstructor
public class TransactionController {

    private final TransactionService transactionService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<TransactionResponse>>> getTransactions() {
        List<TransactionResponse> data = transactionService.getTransactions(getCurrentUserId());
        return ResponseEntity.ok(ApiResponse.success("Lấy danh sách giao dịch thành công", data));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<TransactionResponse>> createTransaction(
            @Valid @RequestBody TransactionRequest req) {
        TransactionResponse data = transactionService.createTransaction(getCurrentUserId(), req);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Tạo giao dịch thành công", data));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteTransaction(@PathVariable Integer id) {
        transactionService.deleteTransaction(getCurrentUserId(), id);
        return ResponseEntity.ok(ApiResponse.success("Xóa giao dịch thành công", null));
    }

    private Integer getCurrentUserId() {
        String name = SecurityContextHolder.getContext().getAuthentication().getName();
        return Integer.parseInt(name);
    }
}
