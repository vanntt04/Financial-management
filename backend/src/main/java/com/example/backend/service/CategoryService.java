package com.example.backend.service;

import com.example.backend.dto.request.CategoryRequest;
import com.example.backend.dto.response.CategoryResponse;
import com.example.backend.entity.User;

import java.util.List;

public interface CategoryService {

    List<CategoryResponse> getCategories(Integer userId, String type);

    CategoryResponse createCategory(Integer userId, CategoryRequest request);

    CategoryResponse updateCategory(Integer userId, Integer categoryId, CategoryRequest request);

    void deleteCategory(Integer userId, Integer categoryId);
    void createDefaultCategories(User user);
}
