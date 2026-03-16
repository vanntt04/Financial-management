package com.example.backend.service;

import com.example.backend.dto.response.DashboardResponse;

public interface DashboardService {
    DashboardResponse getDashboard(Integer userId);
}
