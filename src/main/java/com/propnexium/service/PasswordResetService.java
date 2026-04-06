package com.propnexium.service;

/**
 * Manages the password-reset lifecycle:
 * issue a token → validate → apply new password.
 */
public interface PasswordResetService {

    /**
     * Generate a reset token and send an email to the given address.
     *
     * @throws com.propnexium.exception.ResourceNotFoundException if no user
     *         exists with {@code email}.
     */
    void initiatePasswordReset(String email);

    /**
     * Apply {@code newPassword} to the user that owns the valid reset token.
     *
     * @throws com.propnexium.exception.ResourceNotFoundException if the token
     *         is not found or has already been used.
     * @throws com.propnexium.exception.TokenExpiredException     if the token
     *         is past its expiry time.
     */
    void resetPassword(String token, String newPassword);

    /**
     * @return {@code true} if the token exists, has not been used, and has not
     *         expired.
     */
    boolean validateToken(String token);
}
