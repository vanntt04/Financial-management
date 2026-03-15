package com.example.backend.service.impl;

import com.example.backend.dto.request.CategoryRequest;
import com.example.backend.dto.response.CategoryResponse;
import com.example.backend.entity.Category;
import com.example.backend.entity.User;
import com.example.backend.exception.ApiException;
import com.example.backend.exception.ResourceNotFoundException;
import com.example.backend.repository.CategoryRepository;
import com.example.backend.repository.UserRepository;
import com.example.backend.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {

    private final CategoryRepository categoryRepository;
    private final UserRepository userRepository;

    @Override
    public List<CategoryResponse> getCategories(Integer userId, String type) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        List<Category> categories;
        if (type != null && !type.isBlank()) {
            categories = categoryRepository.findByUserAndCategoryTypeAndIsDeletedFalse(user, type.toUpperCase());
        } else {
            categories = categoryRepository.findByUserAndIsDeletedFalse(user);
        }
        return categories.stream().map(this::toResponse).toList();
    }

    @Override
    @Transactional
    public CategoryResponse createCategory(Integer userId, CategoryRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        boolean exists = categoryRepository.existsByUserAndCategoryNameAndCategoryTypeAndIsDeletedFalse(
                user, request.getCategoryName(), request.getCategoryType().toUpperCase());
        if (exists) {
            throw new ApiException("Danh mục này đã tồn tại", HttpStatus.CONFLICT);
        }

        Category category = Category.builder()
                .user(user)
                .categoryName(request.getCategoryName())
                .categoryType(request.getCategoryType().toUpperCase())
                .isDeleted(false)
                .build();

        return toResponse(categoryRepository.save(category));
    }

    @Override
    @Transactional
    public CategoryResponse updateCategory(Integer userId, Integer categoryId, CategoryRequest request) {
        Category category = categoryRepository.findByCategoryIdAndIsDeletedFalse(categoryId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy danh mục"));

        if (!category.getUser().getUserId().equals(userId)) {
            throw new ApiException("Bạn không có quyền chỉnh sửa danh mục này", HttpStatus.FORBIDDEN);
        }

        boolean nameConflict = categoryRepository
                .existsByUserAndCategoryNameAndCategoryTypeAndIsDeletedFalseAndCategoryIdNot(
                        category.getUser(), request.getCategoryName(), category.getCategoryType(), categoryId);
        if (nameConflict) {
            throw new ApiException("Tên danh mục đã tồn tại", HttpStatus.CONFLICT);
        }

        category.setCategoryName(request.getCategoryName());

        return toResponse(categoryRepository.save(category));
    }

    @Override
    @Transactional
    public void deleteCategory(Integer userId, Integer categoryId) {
        Category category = categoryRepository.findByCategoryIdAndIsDeletedFalse(categoryId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy danh mục"));

        if (!category.getUser().getUserId().equals(userId)) {
            throw new ApiException("Bạn không có quyền xóa danh mục này", HttpStatus.FORBIDDEN);
        }

        category.setDeleted(true);
        categoryRepository.save(category);
    }

    private CategoryResponse toResponse(Category category) {
        return CategoryResponse.builder()
                .categoryId(category.getCategoryId())
                .categoryName(category.getCategoryName())
                .categoryType(category.getCategoryType())
                .updatedAt(category.getUpdatedAt())
                .build();
    }
}
