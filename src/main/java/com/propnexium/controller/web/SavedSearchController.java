package com.propnexium.controller.web;
import com.propnexium.dto.request.SearchCriteriaDto;
import com.propnexium.dto.response.ApiResponse;
import com.propnexium.entity.User;
import com.propnexium.service.SavedSearchService;
import com.propnexium.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/user/saved-searches")
@PreAuthorize("isAuthenticated()")
@RequiredArgsConstructor
public class SavedSearchController {

    private final SavedSearchService savedSearchService;
    private final UserService userService;

    @PostMapping
    @ResponseBody
    public ResponseEntity<ApiResponse<String>> saveSearch(
            @RequestParam String name,
            @ModelAttribute SearchCriteriaDto criteria,
            @AuthenticationPrincipal UserDetails userDetails) {

        User user = userService.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new IllegalStateException("Authenticated user not found"));
        savedSearchService.saveSearch(user.getId(), name, criteria);
        return ResponseEntity.ok(
                ApiResponse.success(null, "Search saved as \"" + name + "\""));
    }

    @DeleteMapping("/{id}")
    @ResponseBody
    public ResponseEntity<ApiResponse<String>> deleteSearch(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {

        User user = userService.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new IllegalStateException("Authenticated user not found"));
        savedSearchService.deleteSavedSearch(id, user.getId());
        return ResponseEntity.ok(
                ApiResponse.success(null, "Saved search deleted"));
    }
}
