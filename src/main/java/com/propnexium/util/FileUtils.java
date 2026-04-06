package com.propnexium.util;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

/**
 * Utility methods for handling file uploads.
 */
public final class FileUtils {

    private static final List<String> ALLOWED_IMAGE_TYPES = Arrays.asList("image/jpeg", "image/jpg", "image/png",
            "image/webp");
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5 MB

    private FileUtils() {
        /* utility class */ }

    public static boolean isValidImageType(String contentType) {
        return contentType != null && ALLOWED_IMAGE_TYPES.contains(contentType.toLowerCase());
    }

    public static boolean isValidFileSize(long sizeBytes) {
        return sizeBytes <= MAX_FILE_SIZE;
    }

    public static String generateUniqueFileName(String originalName) {
        String extension = getExtension(originalName);
        return UUID.randomUUID() + (extension.isEmpty() ? "" : "." + extension);
    }

    public static String getExtension(String filename) {
        if (filename == null || !filename.contains("."))
            return "";
        return filename.substring(filename.lastIndexOf('.') + 1).toLowerCase();
    }

    public static Path resolveUploadPath(String uploadDir, String subDir) {
        return Paths.get(uploadDir, subDir).toAbsolutePath();
    }
}
