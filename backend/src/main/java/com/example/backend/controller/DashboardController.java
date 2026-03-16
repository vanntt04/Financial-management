package com.example.backend.controller;

import com.example.backend.dto.response.ApiResponse;
import com.example.backend.dto.response.DashboardResponse;
import com.example.backend.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping
    public ResponseEntity<ApiResponse<DashboardResponse>> getDashboard() {
        Integer userId = getCurrentUserId();
        return ResponseEntity.ok(ApiResponse.success("Lấy dashboard thành công",
                dashboardService.getDashboard(userId)));
    }

    private Integer getCurrentUserId() {
        return Integer.parseInt(SecurityContextHolder.getContext().getAuthentication().getName());
    }
}
