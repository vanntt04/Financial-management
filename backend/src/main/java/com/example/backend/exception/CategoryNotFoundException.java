package com.example.backend.exception;

public class CategoryNotFoundException extends RuntimeException {
    public CategoryNotFoundException(Integer id) {
        super("Không tìm thấy danh mục với id: " + id);
    }
}
