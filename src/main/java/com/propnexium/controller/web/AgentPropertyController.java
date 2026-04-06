package com.propnexium.controller.web;

import com.propnexium.dto.request.PropertyCreateDto;
import com.propnexium.entity.Property;
import com.propnexium.entity.PropertyImage;
import com.propnexium.entity.User;
import com.propnexium.entity.enums.*;
import com.propnexium.exception.ResourceNotFoundException;
import com.propnexium.exception.UnauthorizedAccessException;
import com.propnexium.repository.PropertyRepository;
import com.propnexium.service.PropertyImageService;
import com.propnexium.service.PropertyService;
import com.propnexium.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/agent/properties")
@PreAuthorize("hasAnyRole('AGENT','ADMIN')")
@RequiredArgsConstructor
public class AgentPropertyController {

    private final PropertyService propertyService;
    private final UserService userService;
    private final PropertyRepository propertyRepository;
    private final PropertyImageService propertyImageService;

    private static final List<String> CITIES = List.of(
            "Mumbai", "Delhi", "Bangalore", "Pune",
            "Hyderabad", "Chennai", "Kolkata", "Ahmedabad", "Jaipur", "Surat");

    @GetMapping
    public String myProperties(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(required = false) String status,
            Model model) {

        User agent = userService.getCurrentUser();
        Pageable pageable = PageRequest.of(page, 10, Sort.by("createdAt").descending());

        Page<Property> properties;
        if (status != null && !status.isBlank()) {
            try {
                PropertyStatus ps = PropertyStatus.valueOf(status);
                properties = propertyRepository.findByAgentIdAndStatus(agent.getId(), ps, pageable);
            } catch (IllegalArgumentException e) {
                properties = propertyRepository.findByAgentId(agent.getId(), pageable);
                status = null;
            }
        } else {
            properties = propertyRepository.findByAgentId(agent.getId(), pageable);
        }

        model.addAttribute("properties", properties);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", properties.getTotalPages());
        model.addAttribute("filterStatus", status);
        model.addAttribute("allStatuses", PropertyStatus.values());
        model.addAttribute("agent", agent);
        return "agent/my-properties";
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GET /agent/properties/add — show add form
    // ─────────────────────────────────────────────────────────────────────────
    @GetMapping("/add")
    public String showAddForm(Model model) {
        model.addAttribute("propertyDto", new PropertyCreateDto());
        populateFormModel(model);
        return "agent/add-property";
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST /agent/properties/add — submit new property
    // ─────────────────────────────────────────────────────────────────────────
    @PostMapping("/add")
    public String submitProperty(
            @ModelAttribute("propertyDto") @Valid PropertyCreateDto dto,
            BindingResult result,
            @RequestParam(value = "images", required = false) List<MultipartFile> images,
            RedirectAttributes redirectAttrs,
            Model model) {

        if (result.hasErrors()) {
            populateFormModel(model);
            return "agent/add-property";
        }

        try {
            User agent = userService.getCurrentUser();
            Property saved = propertyService.createPropertyFromDto(dto, agent.getId(), images);
            redirectAttrs.addFlashAttribute("successMessage",
                    "Property submitted for review! It will be listed after admin approval. (ID: " + saved.getId()
                            + ")");
            return "redirect:/agent/properties";
        } catch (Exception e) {
            model.addAttribute("errorMessage", "Failed to submit property: " + e.getMessage());
            populateFormModel(model);
            return "agent/add-property";
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GET /agent/properties/{id}/edit — show edit form pre-filled
    // ─────────────────────────────────────────────────────────────────────────
    @GetMapping("/{id}/edit")
    public String showEditForm(@PathVariable Long id, Model model) {
        User agent = userService.getCurrentUser();
        Property property = propertyService.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Property", "id", id));

        if (!property.getAgent().getId().equals(agent.getId())) {
            throw new UnauthorizedAccessException("You can only edit your own properties");
        }

        model.addAttribute("property", property);
        model.addAttribute("propertyDto", new PropertyCreateDto(property));
        populateFormModel(model);
        return "agent/edit-property";
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST /agent/properties/{id}/edit — save updated property
    // ─────────────────────────────────────────────────────────────────────────
    @PostMapping("/{id}/edit")
    public String updateProperty(
            @PathVariable Long id,
            @ModelAttribute("propertyDto") @Valid PropertyCreateDto dto,
            BindingResult result,
            @RequestParam(value = "images", required = false) List<MultipartFile> images,
            RedirectAttributes redirectAttrs,
            Model model) {

        if (result.hasErrors()) {
            populateFormModel(model);
            return "agent/edit-property";
        }

        try {
            User agent = userService.getCurrentUser();
            propertyService.updatePropertyFromDto(id, agent.getId(), dto, images);
            redirectAttrs.addFlashAttribute("successMessage", "Property updated successfully!");
        } catch (UnauthorizedAccessException e) {
            redirectAttrs.addFlashAttribute("errorMessage", e.getMessage());
        } catch (Exception e) {
            redirectAttrs.addFlashAttribute("errorMessage", "Update failed: " + e.getMessage());
        }
        return "redirect:/agent/properties";
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST /agent/properties/{id}/delete — soft-delete / unlist property
    // ─────────────────────────────────────────────────────────────────────────
    @PostMapping("/{id}/delete")
    public String deleteProperty(@PathVariable Long id, RedirectAttributes redirectAttrs) {
        try {
            User agent = userService.getCurrentUser();
            propertyService.softDeleteProperty(id, agent.getId());
            redirectAttrs.addFlashAttribute("successMessage", "Property removed from listings.");
        } catch (Exception e) {
            redirectAttrs.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/agent/properties";
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST /agent/properties/{id}/mark-sold — mark property as SOLD
    // ─────────────────────────────────────────────────────────────────────────
    @PostMapping("/{id}/mark-sold")
    public String markAsSold(@PathVariable Long id, RedirectAttributes redirectAttrs) {
        try {
            User agent = userService.getCurrentUser();
            Property property = propertyService.findById(id)
                    .orElseThrow(() -> new ResourceNotFoundException("Property", "id", id));

            if (!property.getAgent().getId().equals(agent.getId())) {
                throw new UnauthorizedAccessException("You can only update your own properties");
            }

            property.setStatus(PropertyStatus.SOLD);
            property.setUpdatedAt(java.time.LocalDateTime.now());
            propertyService.updateProperty(property);

            redirectAttrs.addFlashAttribute("successMessage",
                    "Property \"" + property.getTitle() + "\" marked as SOLD.");
        } catch (Exception e) {
            redirectAttrs.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/agent/properties";
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GET /agent/properties/{id}/images — manage images for a property
    // ─────────────────────────────────────────────────────────────────────────
    @GetMapping("/{id}/images")
    public String manageImages(@PathVariable Long id, Model model) {
        User agent = userService.getCurrentUser();
        Property property = propertyService.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Property", "id", id));

        if (!property.getAgent().getId().equals(agent.getId())) {
            throw new UnauthorizedAccessException("You can only manage images for your own properties");
        }

        model.addAttribute("property", property);
        model.addAttribute("images", propertyImageService.getImagesByProperty(id));
        return "agent/manage-images";
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helper: populate dropdown model attributes
    // ─────────────────────────────────────────────────────────────────────────
    private void populateFormModel(Model model) {
        model.addAttribute("propertyTypes", PropertyType.values());
        model.addAttribute("propertyCategories", PropertyCategory.values());
        model.addAttribute("furnishings", Furnishing.values());
        model.addAttribute("parkingOptions", Parking.values());
        model.addAttribute("facingOptions", Facing.values());
        model.addAttribute("cities", CITIES);
    }
}
