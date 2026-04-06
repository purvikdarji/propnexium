package com.propnexium.controller.web;

import com.propnexium.dto.request.BookingRequestDto;
import com.propnexium.dto.response.ApiResponse;
import com.propnexium.entity.Property;
import com.propnexium.entity.PropertyBooking;
import com.propnexium.entity.User;
import com.propnexium.service.BookingService;
import com.propnexium.service.PropertyService;
import com.propnexium.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Controller
@RequiredArgsConstructor
public class BookingController {

    private final BookingService bookingService;
    private final PropertyService propertyService;
    private final UserService userService;

    // GET /properties/{id}/book -> booking form page
    @GetMapping("/properties/{id}/book")
    public String bookingForm(@PathVariable Long id, Model model, @AuthenticationPrincipal UserDetails userDetails) {
        Property property = propertyService.findById(id).orElse(null);
        
        BookingRequestDto dto = new BookingRequestDto();
        if (userDetails != null) {
            User user = userService.findByEmail(userDetails.getUsername()).orElse(null);
            if (user != null) {
                dto.setVisitorName(user.getName());
                dto.setVisitorEmail(user.getEmail());
                dto.setVisitorPhone(user.getPhone() != null ? user.getPhone() : "");
            }
        }
        
        model.addAttribute("property", property);
        model.addAttribute("booking", dto);
        model.addAttribute("minDate", LocalDate.now().plusDays(1).toString());
        return "booking/form"; // mapping to webapp/WEB-INF/views/booking/form.jsp
    }

    // POST /properties/{id}/book -> submit booking
    @PostMapping("/properties/{id}/book")
    public String submitBooking(
            @PathVariable Long id,
            @Valid @ModelAttribute("booking") BookingRequestDto dto,
            BindingResult result,
            @AuthenticationPrincipal UserDetails userDetails,
            RedirectAttributes redirectAttrs,
            Model model) {
            
        if (result.hasErrors()) {
            model.addAttribute("property", propertyService.findById(id).orElse(null));
            model.addAttribute("minDate", LocalDate.now().plusDays(1).toString());
            return "booking/form";
        }
        
        dto.setPropertyId(id);
        
        if (userDetails == null) {
            return "redirect:/auth/login";
        }
        
        User user = userService.findByEmail(userDetails.getUsername()).orElseThrow(() -> new RuntimeException("User not found"));
        
        try {
            PropertyBooking booking = bookingService.createBooking(dto, user.getId());
            redirectAttrs.addFlashAttribute("successMessage",
                    "Site visit booked for " + dto.getVisitDate() + " at " + dto.getTimeSlot() +
                    ". Confirmation sent to your email.");
            return "redirect:/user/bookings";
        } catch (Exception e) {
            redirectAttrs.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/properties/" + id + "/book";
        }
    }

    // GET /api/v1/bookings/slots?propertyId=X&date=YYYY-MM-DD
    @GetMapping("/api/v1/bookings/slots")
    @ResponseBody
    public ResponseEntity<ApiResponse<List<String>>> getSlots(
            @RequestParam Long propertyId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        List<String> slots = bookingService.getAvailableSlots(propertyId, date);
        return ResponseEntity.ok(ApiResponse.success(slots, "OK"));
    }

    // POST /agent/bookings/{id}/confirm
    @PostMapping("/agent/bookings/{id}/confirm")
    public String confirmBooking(
            @PathVariable Long id,
            @RequestParam(required = false) String agentNotes,
            @AuthenticationPrincipal UserDetails userDetails,
            RedirectAttributes redirectAttrs) {
        User agent = userService.findByEmail(userDetails.getUsername()).orElseThrow(() -> new RuntimeException("Agent not found"));
        bookingService.confirmBooking(id, agent.getId(), agentNotes);
        redirectAttrs.addFlashAttribute("successMessage", "Booking confirmed. User has been notified.");
        return "redirect:/agent/bookings";
    }

    // POST /agent/bookings/{id}/cancel
    @PostMapping("/agent/bookings/{id}/cancel")
    public String cancelBookingAgent(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails,
            RedirectAttributes redirectAttrs) {
        User agent = userService.findByEmail(userDetails.getUsername()).orElseThrow(() -> new RuntimeException("Agent not found"));
        bookingService.cancelBooking(id, agent.getId());
        redirectAttrs.addFlashAttribute("successMessage", "Booking cancelled.");
        return "redirect:/agent/bookings";
    }
    
    // POST /agent/bookings/{id}/complete
    @PostMapping("/agent/bookings/{id}/complete")
    public String completeBooking(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails,
            RedirectAttributes redirectAttrs) {
        User agent = userService.findByEmail(userDetails.getUsername()).orElseThrow(() -> new RuntimeException("Agent not found"));
        bookingService.completeBooking(id, agent.getId());
        redirectAttrs.addFlashAttribute("successMessage", "Booking marked as completed.");
        return "redirect:/agent/bookings";
    }

    // POST /user/bookings/{id}/cancel
    @PostMapping("/user/bookings/{id}/cancel")
    public String cancelBookingUser(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails,
            RedirectAttributes redirectAttrs) {
        User user = userService.findByEmail(userDetails.getUsername()).orElseThrow(() -> new RuntimeException("User not found"));
        bookingService.cancelBooking(id, user.getId());
        redirectAttrs.addFlashAttribute("successMessage", "Booking cancelled successfully.");
        return "redirect:/user/bookings";
    }

    // POST /user/bookings/{id}/delete
    @PostMapping("/user/bookings/{id}/delete")
    public String deleteBookingUser(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails,
            RedirectAttributes redirectAttrs) {
        User user = userService.findByEmail(userDetails.getUsername()).orElseThrow(() -> new RuntimeException("User not found"));
        try {
            bookingService.deleteBooking(id, user.getId());
            redirectAttrs.addFlashAttribute("successMessage", "Booking record deleted successfully.");
        } catch (Exception e) {
            redirectAttrs.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/user/bookings";
    }

    // GET /user/bookings -> user bookings dashboard section
    @GetMapping("/user/bookings")
    public String userBookings(
            @AuthenticationPrincipal UserDetails userDetails,
            Model model) {
        User user = userService.findByEmail(userDetails.getUsername()).orElseThrow(() -> new RuntimeException("User not found"));
        model.addAttribute("bookings", bookingService.getUserBookings(user.getId()));
        return "user/bookings";
    }

    // GET /agent/bookings -> agent bookings management
    @GetMapping("/agent/bookings")
    public String agentBookings(
            @AuthenticationPrincipal UserDetails userDetails,
            Model model) {
        User agent = userService.findByEmail(userDetails.getUsername()).orElseThrow(() -> new RuntimeException("Agent not found"));
        List<PropertyBooking> allAgentBookings = bookingService.getAgentBookings(agent.getId());
        
        model.addAttribute("pendingBookings", allAgentBookings.stream()
                .filter(b -> b.getStatus() == PropertyBooking.BookingStatus.PENDING)
                .collect(Collectors.toList()));
                
        model.addAttribute("confirmedBookings", allAgentBookings.stream()
                .filter(b -> b.getStatus() == PropertyBooking.BookingStatus.CONFIRMED)
                .collect(Collectors.toList()));
                
        return "agent/bookings";
    }
}
