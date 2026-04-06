package com.propnexium.service;

import com.propnexium.entity.Property;
import com.propnexium.entity.PropertyImage;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

public interface PropertyImageService {

    /** Upload one or more images for the given property. */
    List<PropertyImage> uploadImages(Property property, List<MultipartFile> files) throws Exception;

    /** Return all images for a property, ordered by displayOrder ASC. */
    List<PropertyImage> getImagesByProperty(Long propertyId);

    /** Delete a single image (verifies it belongs to propertyId). */
    void deleteImage(Long imageId, Long propertyId);

    /** Mark one image as primary (clears previous primary). */
    void setPrimary(Long imageId, Long propertyId);

    /** Bulk-update display order. Each entry: {imageId: X, order: Y} */
    void reorderImages(List<Map<String, Long>> orderData);
}
