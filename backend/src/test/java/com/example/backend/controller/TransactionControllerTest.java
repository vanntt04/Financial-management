package com.example.backend.controller;

import com.example.backend.dto.request.TransactionRequest;
import com.example.backend.dto.response.TransactionResponse;
import com.example.backend.service.TransactionService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(TransactionController.class)
class TransactionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    private ObjectMapper objectMapper;

    @MockBean
    private TransactionService transactionService;

    @BeforeEach
    void setUp() {
        objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
    }

    @Test
    @WithMockUser(username = "1")
    void getTransactions_returnsOk() throws Exception {
        TransactionResponse tr = TransactionResponse.builder()
                .transactionId(1)
                .accountName("Ví")
                .categoryName("Lương")
                .amount(BigDecimal.valueOf(1000000))
                .transactionType("INCOME")
                .transactionDate(LocalDateTime.now())
                .build();

        when(transactionService.getTransactions(1)).thenReturn(List.of(tr));

        mockMvc.perform(get("/api/transactions"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data[0].transactionId").value(1))
                .andExpect(jsonPath("$.data[0].transactionType").value("INCOME"));

        verify(transactionService).getTransactions(1);
    }

    @Test
    @WithMockUser(username = "1")
    void createTransaction_returnsCreated() throws Exception {
        TransactionRequest req = new TransactionRequest();
        req.setAccountId(1);
        req.setCategoryId(1);
        req.setAmount(BigDecimal.valueOf(50000));
        req.setTransactionType("EXPENSE");

        TransactionResponse created = TransactionResponse.builder()
                .transactionId(1)
                .accountName("Ví")
                .categoryName("Ăn uống")
                .amount(BigDecimal.valueOf(50000))
                .transactionType("EXPENSE")
                .transactionDate(LocalDateTime.now())
                .build();

        when(transactionService.createTransaction(eq(1), any(TransactionRequest.class))).thenReturn(created);

        mockMvc.perform(post("/api/transactions")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.transactionId").value(1))
                .andExpect(jsonPath("$.data.transactionType").value("EXPENSE"));

        verify(transactionService).createTransaction(eq(1), any(TransactionRequest.class));
    }

    @Test
    @WithMockUser(username = "1")
    void deleteTransaction_returnsOk() throws Exception {
        doNothing().when(transactionService).deleteTransaction(1, 10);

        mockMvc.perform(delete("/api/transactions/10").with(csrf()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        verify(transactionService).deleteTransaction(1, 10);
    }
}
