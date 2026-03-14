package com.example.backend.repository;

import com.example.backend.entity.OtpVerification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OtpRepository extends JpaRepository<OtpVerification, Long> {

    Optional<OtpVerification> findTopByTargetAndOtpTypeAndIsUsedFalseOrderByCreatedAtDesc(
            String target, String otpType);

    Optional<OtpVerification> findTopByTargetAndOtpTypeOrderByCreatedAtDesc(
            String target, String otpType);

    @Modifying
    @Query("UPDATE OtpVerification o SET o.isUsed = true WHERE o.target = :target AND o.otpType = :otpType AND o.isUsed = false")
    void markAllAsUsed(@Param("target") String target, @Param("otpType") String otpType);
}
