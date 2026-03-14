package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Table(name = "Categories")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "category_id")
    private Long categoryId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", referencedColumnName = "user_id", nullable = true)
    private User user;

    @Column(name = "category_name", length = 100, nullable = false)
    private String categoryName;

    @Column(name = "category_type", length = 10, nullable = false)
    private String categoryType;

    @Column(name = "icon_tag", length = 50)
    private String iconTag;

    @Column(name = "is_default", nullable = false)
    @Builder.Default
    private boolean isDefault = false;

    // Relationships
    @OneToMany(mappedBy = "category", fetch = FetchType.LAZY)
    private List<Transaction> transactions;
}
