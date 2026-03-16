package com.example.backend.seeder;

import com.example.backend.entity.Currency;
import com.example.backend.repository.CurrencyRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataSeeder implements ApplicationRunner {

    private final CurrencyRepository currencyRepository;

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        seedCurrencies();
    }

    private void seedCurrencies() {
        if (currencyRepository.count() > 0) {
            log.info("Currencies already seeded, skipping.");
            return;
        }

        List<Currency> currencies = List.of(
                Currency.builder()
                        .currencyCode("VND")
                        .currencyName("Việt Nam Đồng")
                        .symbol("₫")
                        .exchangeRateToBase(BigDecimal.ONE)
                        .build(),
                Currency.builder()
                        .currencyCode("USD")
                        .currencyName("US Dollar")
                        .symbol("$")
                        .exchangeRateToBase(new BigDecimal("0.000041"))
                        .build()
        );

        currencyRepository.saveAll(currencies);
        log.info("Seeded {} currencies.", currencies.size());
    }
}
