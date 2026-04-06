package com.propnexium.repository;

import com.propnexium.entity.Wishlist;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface WishlistRepository extends JpaRepository<Wishlist, Long> {

    @Query("SELECT w.property.id FROM Wishlist w WHERE w.user.id = :userId")
    List<Long> findPropertyIdsByUserId(@Param("userId") Long userId);

    @EntityGraph(attributePaths = {"property.images"})
    List<Wishlist> findByUserId(Long userId);

    @EntityGraph(attributePaths = {"property.images"})
    Page<Wishlist> findByUserId(Long userId, Pageable pageable);

    Optional<Wishlist> findByUserIdAndPropertyId(Long userId, Long propertyId);

    boolean existsByUserIdAndPropertyId(Long userId, Long propertyId);

    long countByUserId(Long userId);

    void deleteByUserIdAndPropertyId(Long userId, Long propertyId);

    long countByPropertyId(Long propertyId);
}
