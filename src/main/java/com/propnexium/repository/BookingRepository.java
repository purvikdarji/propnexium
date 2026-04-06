package com.propnexium.repository;

import com.propnexium.entity.PropertyBooking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface BookingRepository extends JpaRepository<PropertyBooking, Long> {

    @Query("SELECT b FROM PropertyBooking b WHERE b.user.id = :userId ORDER BY b.visitDate DESC")
    List<PropertyBooking> findByUserIdOrderByVisitDateDesc(@Param("userId") Long userId);

    @Query("SELECT b FROM PropertyBooking b WHERE b.property.agent.id = :agentId ORDER BY b.createdAt DESC")
    List<PropertyBooking> findByPropertyAgentIdOrderByCreatedAtDesc(@Param("agentId") Long agentId);

    @Query("SELECT b FROM PropertyBooking b WHERE b.property.id = :propertyId ORDER BY b.visitDate ASC")
    List<PropertyBooking> findByPropertyIdOrderByVisitDateAsc(@Param("propertyId") Long propertyId);
    
    List<PropertyBooking> findByPropertyIdAndVisitDateAndStatusNot(
            Long propertyId, LocalDate visitDate, PropertyBooking.BookingStatus status);

    @Query("SELECT COUNT(b) > 0 FROM PropertyBooking b WHERE b.property.id = :propertyId " +
           "AND b.visitDate = :date AND b.timeSlot = :timeSlot AND b.status <> :status")
    boolean existsByPropertyIdAndVisitDateAndTimeSlotAndStatusNot(
            @Param("propertyId") Long propertyId, 
            @Param("date") LocalDate date, 
            @Param("timeSlot") String timeSlot, 
            @Param("status") PropertyBooking.BookingStatus status);

    @Query("SELECT COUNT(b) > 0 FROM PropertyBooking b WHERE b.property.id = :propertyId " +
           "AND b.user.id = :userId AND b.status <> :status")
    boolean existsByPropertyIdAndUserIdAndStatusNot(
            @Param("propertyId") Long propertyId, 
            @Param("userId") Long userId, 
            @Param("status") PropertyBooking.BookingStatus status);

    boolean existsByPropertyIdAndUserIdAndStatusIn(
            Long propertyId, Long userId, List<PropertyBooking.BookingStatus> statuses);

    // Count for admin overview
    long countByStatus(PropertyBooking.BookingStatus status);

    @Query("SELECT b FROM PropertyBooking b WHERE " +
           "b.property.agent.id = :agentId AND " +
           "b.status = :status ORDER BY b.visitDate ASC")
    List<PropertyBooking> findByAgentIdAndStatus(
            @Param("agentId") Long agentId,
            @Param("status") PropertyBooking.BookingStatus status);

    @Query("SELECT b FROM PropertyBooking b " +
           "JOIN FETCH b.property p " +
           "JOIN FETCH p.agent a " +
           "JOIN FETCH b.user u " +
           "WHERE b.id = :id")
    java.util.Optional<PropertyBooking> findByIdWithDetails(@Param("id") Long id);
}
