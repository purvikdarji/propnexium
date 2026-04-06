package com.propnexium.controller.web;

import com.propnexium.entity.Property;
import com.propnexium.repository.PropertyRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/compare")
public class CompareController {

    private final PropertyRepository propertyRepository;

    public CompareController(PropertyRepository propertyRepository) {
        this.propertyRepository = propertyRepository;
    }

    @GetMapping
    public String comparePage(
            @RequestParam String ids,
            Model model,
            org.springframework.web.servlet.mvc.support.RedirectAttributes redirectAttributes) {

        // Parse up to 3 IDs
        List<Long> idList = Arrays.stream(ids.split(","))
                .limit(3)
                .map(String::trim)
                .filter(s -> s.matches("\\d+"))
                .map(Long::parseLong)
                .collect(Collectors.toList());

        if (idList.size() < 2) {
            redirectAttributes.addFlashAttribute("errorMessage", "Please select at least 2 properties to compare.");
            return "redirect:/properties";
        }

        List<Property> properties = idList.stream()
                .map(id -> propertyRepository.findById(id).orElse(null))
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        if (properties.size() < 2) {
            redirectAttributes.addFlashAttribute("errorMessage", "One or more properties selected for comparison were not found.");
            return "redirect:/properties";
        }

        // Calculate best values for highlighting
        BigDecimal minPrice = properties.stream()
                .map(Property::getPrice)
                .min(BigDecimal::compareTo).orElse(null);

        BigDecimal maxArea = properties.stream()
                .map(Property::getAreaSqft)
                .filter(Objects::nonNull)
                .max(BigDecimal::compareTo).orElse(null);

        Integer maxBedrooms = properties.stream()
                .map(Property::getBedrooms)
                .filter(Objects::nonNull)
                .max(Integer::compareTo).orElse(null);

        model.addAttribute("properties", properties);
        model.addAttribute("minPrice", minPrice);
        model.addAttribute("maxArea", maxArea);
        model.addAttribute("maxBedrooms", maxBedrooms);

        return "compare/index";
    }
}
