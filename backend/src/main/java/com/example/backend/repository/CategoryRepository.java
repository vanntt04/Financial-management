package com.example.backend.repository;

import com.example.backend.entity.Category;
import com.example.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Integer> {

    List<Category> findByUserAndIsDeletedFalse(User user);

    List<Category> findByUserAndCategoryTypeAndIsDeletedFalse(User user, String categoryType);

    Optional<Category> findByCategoryIdAndIsDeletedFalse(Integer categoryId);

    boolean existsByUserAndCategoryNameAndCategoryTypeAndIsDeletedFalse(
            User user, String categoryName, String categoryType);

    boolean existsByUserAndCategoryNameAndCategoryTypeAndIsDeletedFalseAndCategoryIdNot(
            User user, String categoryName, String categoryType, Integer categoryId);
}
