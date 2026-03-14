package com.example.backend.util;

import org.springframework.stereotype.Component;

import java.security.SecureRandom;

@Component
public class OtpUtil {

    private static final SecureRandom RANDOM = new SecureRandom();

    public String generate() {
        int code = RANDOM.nextInt(900000) + 100000; // 100000 - 999999
        return String.valueOf(code);
    }
}
