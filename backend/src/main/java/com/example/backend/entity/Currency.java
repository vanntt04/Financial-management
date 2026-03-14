package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "currencies")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Currency {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "currency_id")
    private Long currencyId;

    @Column(name = "currency_code", length = 3, nullable = false, unique = true)
    private String currencyCode;

    @Column(name = "currency_name", length = 50, nullable = false)
    private String currencyName;

    @Column(name = "symbol", length = 5, nullable = false)
    private String symbol;

    @Column(name = "exchange_rate_to_base", precision = 19, scale = 6, nullable = false)
    private BigDecimal exchangeRateToBase;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // Relationships
    @OneToMany(mappedBy = "baseCurrency", fetch = FetchType.LAZY)
    private List<User> users;

    @OneToMany(mappedBy = "currency", fetch = FetchType.LAZY)
    private List<Account> accounts;
}
