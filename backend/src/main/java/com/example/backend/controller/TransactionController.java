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
import java.util.Map;

@RestController
@RequestMapping("/api/transactions")
@RequiredArgsConstructor
public class TransactionController {

    private final TransactionService transactionService;

    /**
     * GET /api/transactions?type=ALL|INCOME|EXPENSE
     */
    @GetMapping
    public ResponseEntity<ApiResponse<TransactionResponse.ListResponse>> getTransactions(
            @RequestParam(defaultValue = "ALL") String type) {
        Integer userId = getCurrentUserId();
        return ResponseEntity.ok(
                ApiResponse.success("Lấy danh sách giao dịch thành công",
                        transactionService.getTransactions(userId, type)));
    }

    /**
     * POST /api/transactions
     */
    @PostMapping
    public ResponseEntity<ApiResponse<TransactionResponse.Item>> createTransaction(
            @Valid @RequestBody TransactionRequest request) {
        Integer userId = getCurrentUserId();
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Tạo giao dịch thành công",
                        transactionService.createTransaction(userId, request)));
    }

    /**
     * DELETE /api/transactions/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Map<String, String>>> deleteTransaction(
            @PathVariable Integer id) {
        Integer userId = getCurrentUserId();
        transactionService.deleteTransaction(userId, id);
        return ResponseEntity.ok(ApiResponse.success("Xóa giao dịch thành công",
                Map.of("message", "Đã xóa giao dịch thành công")));
    }

    private Integer getCurrentUserId() {
        return Integer.parseInt(SecurityContextHolder.getContext().getAuthentication().getName());
    }
}
