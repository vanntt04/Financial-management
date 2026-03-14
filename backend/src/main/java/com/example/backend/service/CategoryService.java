package com.example.backend.service;

import com.example.backend.dto.request.CategoryRequest;
import com.example.backend.dto.response.CategoryResponse;

import java.util.List;

public interface CategoryService {

    List<CategoryResponse> getCategories(Long userId, String type);

    CategoryResponse createCategory(Long userId, CategoryRequest request);

    CategoryResponse updateCategory(Long userId, Long categoryId, CategoryRequest request);

    void deleteCategory(Long userId, Long categoryId);
}
