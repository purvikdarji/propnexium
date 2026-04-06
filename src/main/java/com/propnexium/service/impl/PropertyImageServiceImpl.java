package com.propnexium.service.impl;

import com.propnexium.entity.Property;
import com.propnexium.entity.PropertyImage;
import com.propnexium.exception.ResourceNotFoundException;
import com.propnexium.repository.PropertyImageRepository;
import com.propnexium.service.PropertyImageService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class PropertyImageServiceImpl implements PropertyImageService {

    private final PropertyImageRepository propertyImageRepository;

    @Value("${propnexium.upload.directory:uploads}")
    private String uploadDir;

    /* ──────────────────────────────────────────────────────────────────────── */
    /* Upload */
    /* ──────────────────────────────────────────────────────────────────────── */

    @Override
    public List<PropertyImage> uploadImages(Property property, List<MultipartFile> files) throws Exception {

        // Resolve to absolute path so transferTo() works on any OS / working-dir
        Path baseDir = Paths.get(uploadDir, "properties", String.valueOf(property.getId()))
                .toAbsolutePath();
        Files.createDirectories(baseDir);

        boolean isFirstImage = propertyImageRepository.countByPropertyId(property.getId()) == 0;

        List<PropertyImage> saved = new ArrayList<>();
        int order = (int) propertyImageRepository.countByPropertyId(property.getId());

        for (MultipartFile file : files) {
            if (file == null || file.isEmpty())
                continue;

            String ext = getExtension(file.getOriginalFilename());
            String filename = UUID.randomUUID() + ext;
            Path dest = baseDir.resolve(filename);

            // transferTo(Path) is reliable on Spring Boot + Windows
            file.transferTo(dest);

            boolean primary = isFirstImage && order == 0;

            PropertyImage image = PropertyImage.builder()
                    .property(property)
                    .imageUrl("/uploads/properties/" + property.getId() + "/" + filename)
                    .originalName(file.getOriginalFilename())
                    .isPrimary(primary)
                    .displayOrder(order++)
                    .build();

            saved.add(propertyImageRepository.save(image));
            isFirstImage = false;
        }

        return saved;
    }

    /* ──────────────────────────────────────────────────────────────────────── */
    /* Read */
    /* ──────────────────────────────────────────────────────────────────────── */

    @Override
    @Transactional(readOnly = true)
    public List<PropertyImage> getImagesByProperty(Long propertyId) {
        return propertyImageRepository.findByPropertyIdOrderByDisplayOrderAsc(propertyId);
    }

    /* ──────────────────────────────────────────────────────────────────────── */
    /* Delete */
    /* ──────────────────────────────────────────────────────────────────────── */

    @Override
    public void deleteImage(Long imageId, Long propertyId) {
        PropertyImage image = propertyImageRepository.findById(imageId)
                .orElseThrow(() -> new ResourceNotFoundException("PropertyImage", "id", imageId));

        if (!image.getProperty().getId().equals(propertyId)) {
            throw new IllegalArgumentException("Image does not belong to this property");
        }

        // Delete the physical file
        try {
            Path filePath = Paths.get(uploadDir, "properties",
                    String.valueOf(propertyId),
                    Paths.get(image.getImageUrl()).getFileName().toString()).toAbsolutePath();
            Files.deleteIfExists(filePath);
        } catch (IOException ignored) {
            // Physical file missing — still remove the DB record
        }

        boolean wasPrimary = Boolean.TRUE.equals(image.getIsPrimary());
        propertyImageRepository.delete(image);

        // If it was the primary, promote the first remaining image
        if (wasPrimary) {
            List<PropertyImage> remaining = propertyImageRepository.findByPropertyIdOrderByDisplayOrderAsc(propertyId);
            if (!remaining.isEmpty()) {
                remaining.get(0).setIsPrimary(true);
                propertyImageRepository.save(remaining.get(0));
            }
        }
    }

    /* ──────────────────────────────────────────────────────────────────────── */
    /* Set Primary */
    /* ──────────────────────────────────────────────────────────────────────── */

    @Override
    public void setPrimary(Long imageId, Long propertyId) {
        PropertyImage image = propertyImageRepository.findById(imageId)
                .orElseThrow(() -> new ResourceNotFoundException("PropertyImage", "id", imageId));

        if (!image.getProperty().getId().equals(propertyId)) {
            throw new IllegalArgumentException("Image does not belong to this property");
        }

        // Clear existing primary
        propertyImageRepository.clearPrimaryForProperty(propertyId);

        // Set new primary
        image.setIsPrimary(true);
        propertyImageRepository.save(image);
    }

    /* ──────────────────────────────────────────────────────────────────────── */
    /* Reorder */
    /* ──────────────────────────────────────────────────────────────────────── */

    @Override
    public void reorderImages(List<Map<String, Long>> orderData) {
        for (Map<String, Long> entry : orderData) {
            Long imageId = entry.get("imageId");
            Long displayOrder = entry.get("order");
            if (imageId == null || displayOrder == null)
                continue;

            propertyImageRepository.findById(imageId).ifPresent(img -> {
                img.setDisplayOrder(displayOrder.intValue());
                propertyImageRepository.save(img);
            });
        }
    }

    /* ──────────────────────────────────────────────────────────────────────── */
    /* Helpers */
    /* ──────────────────────────────────────────────────────────────────────── */

    private String getExtension(String filename) {
        if (filename == null || !filename.contains("."))
            return ".jpg";
        return filename.substring(filename.lastIndexOf('.'));
    }
}
