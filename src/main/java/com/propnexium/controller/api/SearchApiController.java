package com.propnexium.controller.api;

import com.propnexium.service.SearchService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * REST API controller for search-related endpoints.
 * - GET /api/search/autocomplete?prefix=... → title suggestions
 */
@RestController
@RequestMapping("/api/search")
@RequiredArgsConstructor
public class SearchApiController {

    private final SearchService searchService;

    /**
     * Returns up to 8 property title autocomplete suggestions matching the prefix.
     * Returns an empty list if prefix is shorter than 2 characters.
     */
    @GetMapping("/autocomplete")
    public ResponseEntity<Map<String, Object>> autocomplete(
            @RequestParam(defaultValue = "") String prefix) {

        List<String> suggestions = searchService.getAutocompleteSuggestions(prefix);
        return ResponseEntity.ok(Map.of("suggestions", suggestions));
    }
}
