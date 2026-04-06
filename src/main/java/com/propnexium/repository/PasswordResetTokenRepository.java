package com.propnexium.repository;

import com.propnexium.entity.PasswordResetToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Optional;

public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, Long> {

    /** Find an active (not used) token by its value. */
    Optional<PasswordResetToken> findByToken(String token);

    /** Find a token that has not yet been consumed. */
    Optional<PasswordResetToken> findByTokenAndUsedFalse(String token);

    /**
     * Remove every reset token that belongs to the given user.
     * Called before issuing a new reset link.
     */
    @Modifying
    @Query("DELETE FROM PasswordResetToken t WHERE t.user.id = :userId")
    void deleteAllByUserId(@Param("userId") Long userId);

    /** Housekeeping: remove tokens whose expiry has already passed. */
    @Modifying
    @Query("DELETE FROM PasswordResetToken t WHERE t.expiryAt < :now")
    void deleteAllExpired(@Param("now") LocalDateTime now);
}
