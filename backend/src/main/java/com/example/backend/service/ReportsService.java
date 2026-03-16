package com.example.backend.service;

import com.example.backend.dto.response.ApiResponse;
import com.example.backend.dto.response.CalendarReportDto;
import com.example.backend.dto.response.MonthlySummaryDto;
import org.springframework.security.core.Authentication;

public interface ReportsService {

    ApiResponse<MonthlySummaryDto> getMonthlySummary(Authentication auth, int month, int year);

    ApiResponse<CalendarReportDto> getCalendarReport(Authentication auth, int month, int year);
}
