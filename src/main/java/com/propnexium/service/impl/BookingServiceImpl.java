package com.propnexium.service.impl;

import com.propnexium.dto.request.BookingRequestDto;
import com.propnexium.entity.Property;
import com.propnexium.entity.PropertyBooking;
import com.propnexium.entity.User;
import com.propnexium.repository.BookingRepository;
import com.propnexium.repository.PropertyRepository;
import com.propnexium.repository.UserRepository;
import com.propnexium.service.BookingService;
import com.propnexium.service.EmailService;
import com.propnexium.service.NotificationService;
import com.propnexium.entity.enums.NotificationType;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class BookingServiceImpl implements BookingService {

    private final BookingRepository bookingRepository;
    private final PropertyRepository propertyRepository;
    private final UserRepository userRepository;
    private final EmailService emailService;
    private final NotificationService notificationService;

    // Based on user requirements
    private static final List<String> ALL_SLOTS = Arrays.asList(
            "10:00 AM", "11:00 AM", "12:00 PM",
            "02:00 PM", "03:00 PM", "04:00 PM", "05:00 PM"
    );

    @Override
    @Transactional
    public PropertyBooking createBooking(BookingRequestDto dto, Long userId) {
        if (dto.getVisitDate().isBefore(LocalDate.now().plusDays(1))) {
            throw new IllegalArgumentException("Bookings must be made at least one day in advance.");
        }
        

        boolean slotTaken = bookingRepository.existsByPropertyIdAndVisitDateAndTimeSlotAndStatusNot(
                dto.getPropertyId(),
                dto.getVisitDate(),
                dto.getTimeSlot(),
                PropertyBooking.BookingStatus.CANCELLED
        );
        
        if (slotTaken) {
            throw new IllegalArgumentException("This time slot is already taken. Please choose another one.");
        }

        Property property = propertyRepository.findById(dto.getPropertyId())
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        PropertyBooking booking = PropertyBooking.builder()
                .property(property)
                .user(user)
                .visitDate(dto.getVisitDate())
                .timeSlot(dto.getTimeSlot())
                .visitorName(dto.getVisitorName())
                .visitorPhone(dto.getVisitorPhone())
                .visitorEmail(dto.getVisitorEmail())
                .notes(dto.getNotes())
                .status(PropertyBooking.BookingStatus.PENDING)
                .build();

        booking = bookingRepository.saveAndFlush(booking);

        // Capture final booking ID for use in lambda (must be effectively final)
        final Long bookingId = booking.getId();
        final String propertyTitle = property.getTitle();
        final Long agentId = property.getAgent().getId();
        final String visitorName = dto.getVisitorName();
        final String visitDate = dto.getVisitDate().toString();

        // Fire emails AFTER the transaction commits so the async thread
        // can see the persisted booking in findByIdWithDetails().
        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
            @Override
            public void afterCommit() {
                emailService.sendBookingConfirmationEmail(bookingId);
                emailService.sendBookingAlertToAgent(bookingId);
            }
        });

        // In-app notification for agent
        notificationService.createNotification(
                agentId,
                "New Site Visit Request",
                "New visit request for '" + propertyTitle + "' from " + visitorName + " on " + visitDate,
                NotificationType.BOOKING,
                "/agent/bookings"
        );

        return booking;
    }

    @Override
    @Transactional
    public void confirmBooking(Long bookingId, Long agentId, String agentNotes) {
        PropertyBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));
                
        if (!booking.getProperty().getAgent().getId().equals(agentId)) {
            throw new SecurityException("You do not have permission to manage this booking.");
        }
        
        booking.setStatus(PropertyBooking.BookingStatus.CONFIRMED);
        if (agentNotes != null && !agentNotes.trim().isEmpty()) {
            booking.setAgentNotes(agentNotes);
        }
        bookingRepository.saveAndFlush(booking);
        
        final Long bId = booking.getId();
        
        // Notify user AFTER transaction commits
        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
            @Override
            public void afterCommit() {
                emailService.sendBookingStatusEmailToUser(bId, "Confirmed");
            }
        });

        // In-app notification for user
        notificationService.createNotification(
                booking.getUser().getId(),
                "Site Visit Confirmed",
                "Your visit request for '" + booking.getProperty().getTitle() + "' has been confirmed by the agent.",
                NotificationType.BOOKING,
                "/user/bookings"
        );
    }

    @Override
    @Transactional
    public void rescheduleBooking(Long bookingId, Long agentId, LocalDate newDate, String newTimeSlot) {
        PropertyBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));
                
        if (!booking.getProperty().getAgent().getId().equals(agentId)) {
            throw new SecurityException("You do not have permission to manage this booking.");
        }
        
        booking.setVisitDate(newDate);
        booking.setTimeSlot(newTimeSlot);
        booking.setStatus(PropertyBooking.BookingStatus.RESCHEDULED);
        bookingRepository.saveAndFlush(booking);
    }

    @Override
    @Transactional
    public void cancelBooking(Long bookingId, Long requesterId) {
        PropertyBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));
                
        // Both user and agent can cancel a booking
        if (!booking.getUser().getId().equals(requesterId) && 
            !booking.getProperty().getAgent().getId().equals(requesterId)) {
            throw new SecurityException("You do not have permission to cancel this booking.");
        }
        
        booking.setStatus(PropertyBooking.BookingStatus.CANCELLED);
        bookingRepository.saveAndFlush(booking);

        final Long bId = booking.getId();

        // If the agent is the one cancelling, notify the user
        if (booking.getProperty().getAgent().getId().equals(requesterId)) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    emailService.sendBookingStatusEmailToUser(bId, "Declined / Cancelled by Agent");
                }
            });

            // In-app notification for user
            notificationService.createNotification(
                    booking.getUser().getId(),
                    "Site Visit Cancelled",
                    "Your visit request for '" + booking.getProperty().getTitle() + "' has been cancelled by the agent.",
                    NotificationType.BOOKING,
                    "/user/bookings"
            );
        } else {
            // User is the one cancelling, notify the agent
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    emailService.sendBookingCancellationAlertToAgent(bId);
                }
            });
            
            notificationService.createNotification(
                    booking.getProperty().getAgent().getId(),
                    "Site Visit Cancelled by Visitor",
                    "The visit for '" + booking.getProperty().getTitle() + "' has been cancelled by the visitor.",
                    NotificationType.BOOKING,
                    "/agent/bookings"
            );
        }
    }

    @Override
    @Transactional
    public void deleteBooking(Long bookingId, Long userId) {
        PropertyBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));
                
        if (!booking.getUser().getId().equals(userId)) {
            throw new SecurityException("You do not have permission to delete this record.");
        }
        
        // Only allow deletion from user view if it's already cancelled
        if (booking.getStatus() != PropertyBooking.BookingStatus.CANCELLED) {
            throw new IllegalStateException("Only cancelled bookings can be deleted from your view.");
        }
        
        bookingRepository.delete(booking);
    }

    @Override
    @Transactional
    public void completeBooking(Long bookingId, Long agentId) {
        PropertyBooking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));
                
        if (!booking.getProperty().getAgent().getId().equals(agentId)) {
            throw new SecurityException("You do not have permission to manage this booking.");
        }
        
        booking.setStatus(PropertyBooking.BookingStatus.COMPLETED);
        bookingRepository.save(booking);
    }

    @Override
    public List<PropertyBooking> getUserBookings(Long userId) {
        return bookingRepository.findByUserIdOrderByVisitDateDesc(userId);
    }

    @Override
    public List<PropertyBooking> getAgentBookings(Long agentId) {
        return bookingRepository.findByPropertyAgentIdOrderByCreatedAtDesc(agentId);
    }

    @Override
    public List<String> getAvailableSlots(Long propertyId, LocalDate date) {
        if (date.isBefore(LocalDate.now().plusDays(1))) {
            return new ArrayList<>(); // Empty list for unavailable days
        }
        
        // Find existing non-cancelled bookings for this specific property and date
        List<PropertyBooking> existingBookings = bookingRepository.findByPropertyIdAndVisitDateAndStatusNot(
                propertyId, date, PropertyBooking.BookingStatus.CANCELLED);
                
        List<String> takenSlots = existingBookings.stream()
                .map(PropertyBooking::getTimeSlot)
                .collect(Collectors.toList());
                
        return ALL_SLOTS.stream()
                .filter(slot -> !takenSlots.contains(slot))
                .collect(Collectors.toList());
    }

    @Override
    public boolean hasUserBookedVisit(Long propertyId, Long userId) {
        // Users can re-book if their previous visits were COMPLETED or CANCELLED
        return bookingRepository.existsByPropertyIdAndUserIdAndStatusIn(
                propertyId, userId, Arrays.asList(PropertyBooking.BookingStatus.PENDING, PropertyBooking.BookingStatus.CONFIRMED));
    }
}
