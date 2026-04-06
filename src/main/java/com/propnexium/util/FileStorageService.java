package com.propnexium.util;

import com.propnexium.exception.InvalidFileException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.*;
import java.util.List;
import java.util.UUID;

/**
 * Service for validating and storing uploaded files to the local filesystem.
 */
@Service
public class FileStorageService {

    private static final List<String> ALLOWED_IMAGE_TYPES = List.of("image/jpeg", "image/png", "image/gif",
            "image/webp");
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024L; // 5 MB

    @Value("${propnexium.upload.directory:uploads}")
    private String uploadBaseDir;

    /**
     * Validate and store a file inside {@code <uploadBaseDir>/<subDir>/}.
     *
     * @param file   the uploaded file
     * @param subDir the subdirectory (e.g. "profile-pictures", "property-images")
     * @return the generated filename (UUID + original extension)
     * @throws InvalidFileException if the file is empty, too large, or has an
     *                              unsupported type
     */
    public String storeFile(MultipartFile file, String subDir) {
        if (file == null || file.isEmpty()) {
            throw new InvalidFileException("Please select a file to upload.");
        }
        if (file.getSize() > MAX_FILE_SIZE) {
            throw new InvalidFileException("File size must not exceed 5 MB.");
        }
        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_IMAGE_TYPES.contains(contentType)) {
            throw new InvalidFileException(
                    "Only JPEG, PNG, GIF, and WebP images are allowed.");
        }

        String originalFilename = file.getOriginalFilename();
        String ext = (originalFilename != null && originalFilename.contains("."))
                ? originalFilename.substring(originalFilename.lastIndexOf('.'))
                : ".jpg";
        String newFilename = UUID.randomUUID() + ext;

        try {
            Path targetDir = Paths.get(uploadBaseDir, subDir);
            Files.createDirectories(targetDir);
            Files.copy(file.getInputStream(), targetDir.resolve(newFilename),
                    StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            throw new InvalidFileException("Could not store file. Please try again.", e);
        }

        return newFilename;
    }

    /**
     * Delete a previously stored file. Silently ignores missing files.
     *
     * @param subDir   the subdirectory (e.g. "profile-pictures")
     * @param filename the filename to remove
     */
    public void deleteFile(String subDir, String filename) {
        try {
            Path target = Paths.get(uploadBaseDir, subDir, filename);
            Files.deleteIfExists(target);
        } catch (IOException ignored) {
            // best-effort delete
        }
    }
}
