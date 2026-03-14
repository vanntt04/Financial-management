package com.example.backend.repository;

import com.example.backend.entity.Currency;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CurrencyRepository extends JpaRepository<Currency, Long> {

    boolean existsByCurrencyCode(String currencyCode);
}
