package com.propnexium.service;

import com.propnexium.dto.request.BookingRequestDto;
import com.propnexium.entity.PropertyBooking;

import java.time.LocalDate;
import java.util.List;

public interface BookingService {

    PropertyBooking createBooking(BookingRequestDto dto, Long userId);

    void confirmBooking(Long bookingId, Long agentId, String agentNotes);

    void rescheduleBooking(Long bookingId, Long agentId, LocalDate newDate, String newTimeSlot);

    void cancelBooking(Long bookingId, Long requesterId);

    void completeBooking(Long bookingId, Long agentId);

    List<PropertyBooking> getUserBookings(Long userId);

    List<PropertyBooking> getAgentBookings(Long agentId);

    List<String> getAvailableSlots(Long propertyId, LocalDate date);

    boolean hasUserBookedVisit(Long propertyId, Long userId);

    void deleteBooking(Long bookingId, Long userId);
}
