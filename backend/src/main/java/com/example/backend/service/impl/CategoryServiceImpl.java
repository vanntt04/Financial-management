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
    public List<CategoryResponse> getCategories(Long userId, String type) {
        List<Category> categories;
        if (type != null && !type.isBlank()) {
            categories = categoryRepository.findAllForUserByType(userId, type.toUpperCase());
        } else {
            categories = categoryRepository.findAllForUser(userId);
        }
        return categories.stream().map(this::toResponse).toList();
    }

    @Override
    @Transactional
    public CategoryResponse createCategory(Long userId, CategoryRequest request) {
        boolean exists = categoryRepository.existsByUserUserIdAndCategoryNameAndCategoryType(
                userId, request.getCategoryName(), request.getCategoryType().toUpperCase());
        if (exists) {
            throw new ApiException("Danh mục này đã tồn tại", HttpStatus.CONFLICT);
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        Category category = Category.builder()
                .user(user)
                .categoryName(request.getCategoryName())
                .categoryType(request.getCategoryType().toUpperCase())
                .iconTag(request.getIconTag())
                .isDefault(false)
                .build();

        Category saved = categoryRepository.save(category);
        return toResponse(saved);
    }

    @Override
    @Transactional
    public CategoryResponse updateCategory(Long userId, Long categoryId, CategoryRequest request) {
        Category category = categoryRepository.findById(categoryId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy danh mục"));

        if (category.isDefault()) {
            throw new ApiException("Không thể chỉnh sửa danh mục mặc định", HttpStatus.FORBIDDEN);
        }

        if (category.getUser() == null || !category.getUser().getUserId().equals(userId)) {
            throw new ApiException("Bạn không có quyền chỉnh sửa danh mục này", HttpStatus.FORBIDDEN);
        }

        // Check name conflict (exclude current category)
        boolean nameConflict = categoryRepository
                .existsByUserUserIdAndCategoryNameAndCategoryTypeAndCategoryIdNot(
                        userId, request.getCategoryName(), category.getCategoryType(), categoryId);
        if (nameConflict) {
            throw new ApiException("Tên danh mục đã tồn tại", HttpStatus.CONFLICT);
        }

        category.setCategoryName(request.getCategoryName());
        if (request.getIconTag() != null) {
            category.setIconTag(request.getIconTag());
        }

        Category updated = categoryRepository.save(category);
        return toResponse(updated);
    }

    @Override
    @Transactional
    public void deleteCategory(Long userId, Long categoryId) {
        Category category = categoryRepository.findById(categoryId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy danh mục"));

        if (category.isDefault()) {
            throw new ApiException("Không thể xóa danh mục mặc định", HttpStatus.FORBIDDEN);
        }

        if (category.getUser() == null || !category.getUser().getUserId().equals(userId)) {
            throw new ApiException("Bạn không có quyền xóa danh mục này", HttpStatus.FORBIDDEN);
        }

        categoryRepository.delete(category);
    }

    private CategoryResponse toResponse(Category category) {
        return CategoryResponse.builder()
                .categoryId(category.getCategoryId())
                .categoryName(category.getCategoryName())
                .categoryType(category.getCategoryType())
                .iconTag(category.getIconTag())
                .isDefault(category.isDefault())
                .build();
    }
}
