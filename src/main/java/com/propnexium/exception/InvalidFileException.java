package com.propnexium.exception;

/**
 * Thrown when a file upload is invalid (wrong type, too large, etc.).
 */
public class InvalidFileException extends RuntimeException {

    public InvalidFileException(String message) {
        super(message);
    }

    public InvalidFileException(String message, Throwable cause) {
        super(message, cause);
    }
}
