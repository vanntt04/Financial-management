package com.example.backend.controller;

import com.example.backend.dto.request.CategoryRequest;
import com.example.backend.dto.response.CategoryResponse;
import com.example.backend.service.CategoryService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(CategoryController.class)
class CategoryControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private CategoryService categoryService;

    @Test
    @WithMockUser(username = "1")
    void getCategories_returnsOk() throws Exception {
        CategoryResponse cat = new CategoryResponse();
        cat.setCategoryId(1);
        cat.setCategoryName("Ăn uống");
        cat.setCategoryType("EXPENSE");

        when(categoryService.getCategories(1, null)).thenReturn(List.of(cat));

        mockMvc.perform(get("/api/categories"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data[0].categoryName").value("Ăn uống"));

        verify(categoryService).getCategories(1, null);
    }

    @Test
    @WithMockUser(username = "1")
    void createCategory_returnsCreated() throws Exception {
        CategoryRequest request = new CategoryRequest();
        request.setCategoryName("Lương");
        request.setCategoryType("INCOME");

        CategoryResponse response = new CategoryResponse();
        response.setCategoryId(1);
        response.setCategoryName("Lương");
        response.setCategoryType("INCOME");

        when(categoryService.createCategory(eq(1), any(CategoryRequest.class))).thenReturn(response);

        mockMvc.perform(post("/api/categories")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.categoryName").value("Lương"));

        verify(categoryService).createCategory(eq(1), any(CategoryRequest.class));
    }

    @Test
    @WithMockUser(username = "1")
    void deleteCategory_returnsOk() throws Exception {
        doNothing().when(categoryService).deleteCategory(1, 5);

        mockMvc.perform(delete("/api/categories/5").with(csrf()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        verify(categoryService).deleteCategory(1, 5);
    }
}
