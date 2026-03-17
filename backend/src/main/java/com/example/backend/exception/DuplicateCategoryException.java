package com.example.backend.exception;

public class DuplicateCategoryException extends RuntimeException {
    public DuplicateCategoryException(String name, String type) {
        super("Danh mục '" + name + "' đã tồn tại trong loại "
                + ("INCOME".equals(type) ? "Thu nhập" : "Chi tiêu"));
    }
}
