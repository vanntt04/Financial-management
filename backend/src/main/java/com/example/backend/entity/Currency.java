package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

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
    private Integer currencyId;

    @Column(name = "currency_code", length = 3, nullable = false, unique = true)
    private String currencyCode;

    @Column(name = "currency_name", length = 50, nullable = false)
    private String currencyName;

    @Column(length = 5, nullable = false)
    private String symbol;

    @Column(name = "exchange_rate_to_base", nullable = false)
    private BigDecimal exchangeRateToBase;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
