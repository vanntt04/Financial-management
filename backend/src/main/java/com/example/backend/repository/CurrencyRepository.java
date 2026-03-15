package com.example.backend.repository;

import com.example.backend.entity.Currency;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CurrencyRepository extends JpaRepository<Currency, Integer> {

    boolean existsByCurrencyCode(String currencyCode);

    Optional<Currency> findByCurrencyCode(String currencyCode);
}
