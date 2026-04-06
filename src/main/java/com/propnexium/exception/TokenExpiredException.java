package com.propnexium.exception;

/**
 * Thrown when a password-reset token has passed its expiry time.
 */
public class TokenExpiredException extends RuntimeException {

    public TokenExpiredException(String message) {
        super(message);
    }
}
