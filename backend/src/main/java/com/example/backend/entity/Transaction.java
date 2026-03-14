package com.example.backend.entity;

import com.example.backend.entity.enums.TransactionType;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "transactions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "transaction_id")
    private Long transactionId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", referencedColumnName = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "account_id", referencedColumnName = "account_id", nullable = false)
    private Account account;

    /**
     * nullable = true: transaction may not belong to any category (e.g. TRANSFER/ALLOCATION).
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", referencedColumnName = "category_id", nullable = true)
    private Category category;

    @Column(name = "amount", precision = 19, scale = 4, nullable = false)
    private BigDecimal amount;

    @Enumerated(EnumType.STRING)
    @Column(name = "transaction_type", length = 15, nullable = false)
    private TransactionType transactionType;

    @Column(name = "transaction_date", nullable = false)
    private LocalDateTime transactionDate;

    @Column(name = "note", columnDefinition = "TEXT")
    private String note;

    /**
     * Only populated for TRANSFER and ALLOCATION transaction types.
     * nullable = true: most transactions have no receiver account.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "receiver_account_id", referencedColumnName = "account_id", nullable = true)
    private Account receiverAccount;

    @Column(name = "image_proof_url", columnDefinition = "TEXT")
    private String imageProofUrl;
}
