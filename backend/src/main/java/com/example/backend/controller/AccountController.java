package com.example.backend.controller;

import com.example.backend.dto.request.AccountRequest;
import com.example.backend.dto.response.AccountResponse;
import com.example.backend.dto.response.ApiResponse;
import com.example.backend.service.AccountService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/accounts")
@RequiredArgsConstructor
public class AccountController {

    private final AccountService accountService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<AccountResponse>>> getAccounts() {
        Integer userId = getCurrentUserId();
        return ResponseEntity.ok(
            ApiResponse.success("Lấy danh sách hũ thành công",
                accountService.getAccounts(userId)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<AccountResponse>> createAccount(
            @Valid @RequestBody AccountRequest request) {
        Integer userId = getCurrentUserId();
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success("Tạo hũ thành công",
                accountService.createAccount(userId, request)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<AccountResponse>> updateAccount(
            @PathVariable Integer id,
            @Valid @RequestBody AccountRequest request) {
        Integer userId = getCurrentUserId();
        return ResponseEntity.ok(ApiResponse.success("Cập nhật hũ thành công",
            accountService.updateAccount(userId, id, request)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Map<String, String>>> deleteAccount(
            @PathVariable Integer id) {
        Integer userId = getCurrentUserId();
        accountService.deleteAccount(userId, id);
        return ResponseEntity.ok(ApiResponse.success("Xóa hũ thành công",
            Map.of("message", "Xóa hũ thành công")));
    }

    private Integer getCurrentUserId() {
        return Integer.parseInt(
            SecurityContextHolder.getContext().getAuthentication().getName());
    }
}
