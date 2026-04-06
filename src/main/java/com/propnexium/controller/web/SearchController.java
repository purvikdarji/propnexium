package com.propnexium.controller.web;
import com.propnexium.dto.SearchPropertyViewModel;
import com.propnexium.dto.request.SearchCriteriaDto;
import com.propnexium.dto.response.ApiResponse;
import com.propnexium.dto.response.SearchResultDto;
import com.propnexium.entity.enums.Furnishing;
import com.propnexium.entity.enums.PropertyType;
import com.propnexium.service.PropertyService;
import com.propnexium.service.SearchService;
import com.propnexium.service.UserService;
import com.propnexium.service.WishlistService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/search")
@RequiredArgsConstructor
public class SearchController {

    private final SearchService searchService;
    private final WishlistService wishlistService;
    private final PropertyService propertyService;
    private final UserService userService;

    @GetMapping
    public String searchPage(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) Integer bedrooms,
            @RequestParam(required = false) String furnishing,
            @RequestParam(defaultValue = "0")  int page,
            @RequestParam(defaultValue = "9")  int size,
            Authentication authentication,
            Model model) {

        SearchCriteriaDto criteria = SearchCriteriaDto.builder()
                .keyword(trimToNull(keyword))
                .city(trimToNull(city))
                .type(trimToNull(type))
                .category(trimToNull(category))
                .minPrice(minPrice)
                .maxPrice(maxPrice)
                .bedrooms(bedrooms)
                .furnishing(trimToNull(furnishing))
                .page(page)
                .size(size)
                .build();

        SearchResultDto result = searchService.search(criteria);

        // Build mapViewModels for Leaflet search map
        List<SearchPropertyViewModel> mapViewModels = new ArrayList<>();
        if (result != null && result.getProperties() != null && !result.getProperties().isEmpty()) {
            mapViewModels = result.getProperties().stream()
                .map(p -> {
                    double[] c = propertyService.getEffectiveLatLng(p);
                    return new SearchPropertyViewModel(p, c[0], c[1]);
                }).collect(Collectors.toList());
        }
        model.addAttribute("mapViewModels", mapViewModels);

        boolean isLoggedIn = authentication != null
                && authentication.isAuthenticated()
                && !(authentication instanceof AnonymousAuthenticationToken);

        List<Long> savedPropertyIds = new ArrayList<>();
        if (isLoggedIn) {
            com.propnexium.entity.User currentUser = userService.getCurrentUser();
            if (currentUser != null) {
                savedPropertyIds = wishlistService.getUserWishlistPropertyIds(currentUser.getId());
            }
        }
        
        model.addAttribute("results",          result);
        model.addAttribute("result",           result);
        model.addAttribute("criteria",         criteria);
        model.addAttribute("activeFilters",   criteria.getActiveFilterLabels());
        model.addAttribute("cities",          propertyService.getDistinctCities());
        model.addAttribute("propertyTypes",   PropertyType.values());
        model.addAttribute("furnishingTypes", Furnishing.values());
        model.addAttribute("isLoggedIn",      isLoggedIn);
        model.addAttribute("savedPropertyIds", savedPropertyIds);

        return "search/index";
    }

    @GetMapping("/autocomplete")
    @ResponseBody
    public ResponseEntity<ApiResponse<List<String>>> autocomplete(
            @RequestParam(required = false, defaultValue = "") String q) {
        List<String> suggestions = searchService.getAutocompleteSuggestions(q);
        return ResponseEntity.ok(ApiResponse.success(suggestions, "OK"));
    }

    private String trimToNull(String str) {
        return (str == null || str.trim().isEmpty()) ? null : str.trim();
    }
}
