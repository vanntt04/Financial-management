package com.example.backend.controller;

import com.example.backend.dto.response.ApiResponse;
import com.example.backend.dto.response.CalendarReportDto;
import com.example.backend.dto.response.MonthlySummaryDto;
import com.example.backend.service.ReportsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/reports")
@RequiredArgsConstructor
public class ReportsController {

    private final ReportsService reportsService;

    @GetMapping("/monthly-summary")
    public ResponseEntity<ApiResponse<MonthlySummaryDto>> getMonthlySummary(
            Authentication auth,
            @RequestParam int month,
            @RequestParam int year) {
        return ResponseEntity.ok(reportsService.getMonthlySummary(auth, month, year));
    }

    @GetMapping("/calendar")
    public ResponseEntity<ApiResponse<CalendarReportDto>> getCalendarReport(
            Authentication auth,
            @RequestParam int month,
            @RequestParam int year) {
        return ResponseEntity.ok(reportsService.getCalendarReport(auth, month, year));
    }
}
