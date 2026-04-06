package com.propnexium.repository;

import com.propnexium.entity.PropertyAmenities;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PropertyAmenitiesRepository extends JpaRepository<PropertyAmenities, Long> {

    Optional<PropertyAmenities> findByPropertyId(Long propertyId);

    boolean existsByPropertyId(Long propertyId);

    void deleteByPropertyId(Long propertyId);
}
