package com.example.backend.seeder;

import com.example.backend.entity.Category;
import com.example.backend.entity.Currency;
import com.example.backend.repository.CategoryRepository;
import com.example.backend.repository.CurrencyRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataSeeder implements ApplicationRunner {

    private final CurrencyRepository currencyRepository;
    private final CategoryRepository categoryRepository;

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        seedCurrencies();
        seedDefaultCategories();
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
                        .updatedAt(LocalDateTime.now())
                        .build(),
                Currency.builder()
                        .currencyCode("USD")
                        .currencyName("US Dollar")
                        .symbol("$")
                        .exchangeRateToBase(new BigDecimal("0.00004100"))
                        .updatedAt(LocalDateTime.now())
                        .build(),
                Currency.builder()
                        .currencyCode("EUR")
                        .currencyName("Euro")
                        .symbol("€")
                        .exchangeRateToBase(new BigDecimal("0.00003800"))
                        .updatedAt(LocalDateTime.now())
                        .build()
        );

        currencyRepository.saveAll(currencies);
        log.info("Seeded {} currencies.", currencies.size());
    }

    private void seedDefaultCategories() {
        if (categoryRepository.countByIsDefaultTrue() > 0) {
            log.info("Default categories already seeded, skipping.");
            return;
        }

        List<Category> expenseCategories = List.of(
                buildDefault("Ăn uống", "EXPENSE", "restaurant"),
                buildDefault("Di chuyển", "EXPENSE", "directions_car"),
                buildDefault("Mua sắm", "EXPENSE", "shopping_bag"),
                buildDefault("Hóa đơn & Tiện ích", "EXPENSE", "receipt"),
                buildDefault("Giải trí", "EXPENSE", "sports_esports"),
                buildDefault("Sức khỏe", "EXPENSE", "favorite"),
                buildDefault("Giáo dục", "EXPENSE", "school"),
                buildDefault("Nhà ở", "EXPENSE", "home"),
                buildDefault("Khác", "EXPENSE", "more_horiz")
        );

        List<Category> incomeCategories = List.of(
                buildDefault("Lương", "INCOME", "account_balance_wallet"),
                buildDefault("Thưởng", "INCOME", "card_giftcard"),
                buildDefault("Đầu tư", "INCOME", "trending_up"),
                buildDefault("Kinh doanh", "INCOME", "store"),
                buildDefault("Quà tặng", "INCOME", "redeem"),
                buildDefault("Khác", "INCOME", "more_horiz")
        );

        categoryRepository.saveAll(expenseCategories);
        categoryRepository.saveAll(incomeCategories);
        log.info("Seeded {} default categories.", expenseCategories.size() + incomeCategories.size());
    }

    private Category buildDefault(String name, String type, String iconTag) {
        return Category.builder()
                .user(null)
                .categoryName(name)
                .categoryType(type)
                .iconTag(iconTag)
                .isDefault(true)
                .build();
    }
}
