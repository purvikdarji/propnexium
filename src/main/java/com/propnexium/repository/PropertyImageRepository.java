package com.propnexium.repository;

import com.propnexium.entity.PropertyImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PropertyImageRepository extends JpaRepository<PropertyImage, Long> {

    List<PropertyImage> findByPropertyIdOrderByDisplayOrderAsc(Long propertyId);

    Optional<PropertyImage> findByPropertyIdAndIsPrimaryTrue(Long propertyId);

    @Modifying
    @Query("UPDATE PropertyImage pi SET pi.isPrimary = false WHERE pi.property.id = :propertyId")
    void clearPrimaryForProperty(Long propertyId);

    long countByPropertyId(Long propertyId);
}
