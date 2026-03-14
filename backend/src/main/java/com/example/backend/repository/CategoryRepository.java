package com.example.backend.repository;

import com.example.backend.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {

    @Query("SELECT c FROM Category c WHERE (c.user IS NULL AND c.isDefault = true) OR (c.user.userId = :userId) ORDER BY c.isDefault DESC, c.categoryName ASC")
    List<Category> findAllForUser(@Param("userId") Long userId);

    @Query("SELECT c FROM Category c WHERE ((c.user IS NULL AND c.isDefault = true) OR (c.user.userId = :userId)) AND c.categoryType = :type ORDER BY c.isDefault DESC, c.categoryName ASC")
    List<Category> findAllForUserByType(@Param("userId") Long userId, @Param("type") String type);

    boolean existsByUserUserIdAndCategoryNameAndCategoryType(Long userId, String categoryName, String categoryType);

    boolean existsByUserUserIdAndCategoryNameAndCategoryTypeAndCategoryIdNot(
            Long userId, String categoryName, String categoryType, Long categoryId);

    Optional<Category> findByCategoryIdAndUserUserId(Long categoryId, Long userId);

    long countByUserIsNull();

    long countByIsDefaultTrue();
}
