package com.example.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CategoryRequest {

    @NotBlank(message = "Tên danh mục không được để trống")
    @Size(min = 1, max = 100, message = "Tên danh mục phải từ 1 đến 100 ký tự")
    private String categoryName;

    @NotBlank(message = "Loại danh mục không được để trống")
    @Pattern(regexp = "^(INCOME|EXPENSE)$", message = "Loại danh mục phải là INCOME hoặc EXPENSE")
    private String categoryType;
}
