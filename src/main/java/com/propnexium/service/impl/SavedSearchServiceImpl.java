package com.propnexium.service.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.propnexium.dto.request.SearchCriteriaDto;
import com.propnexium.entity.SavedSearch;
import com.propnexium.entity.User;
import com.propnexium.repository.SavedSearchRepository;
import com.propnexium.repository.UserRepository;
import com.propnexium.service.SavedSearchService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SavedSearchServiceImpl implements SavedSearchService {

    private static final Logger log = LoggerFactory.getLogger(SavedSearchServiceImpl.class);

    private final SavedSearchRepository savedSearchRepository;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper;

    @Override
    @Transactional
    public void saveSearch(Long userId, String name, SearchCriteriaDto criteria) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));

        String filtersJson;
        try {
            filtersJson = objectMapper.writeValueAsString(criteria);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to serialise search criteria", e);
        }

        SavedSearch savedSearch = SavedSearch.builder()
                .user(user)
                .name(name)
                .filtersJson(filtersJson)
                .createdAt(LocalDateTime.now())
                .build();

        savedSearchRepository.save(savedSearch);
        log.info("Saved search '{}' for user {}", name, userId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SavedSearch> getUserSavedSearches(Long userId) {
        return savedSearchRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    @Override
    @Transactional
    public void deleteSavedSearch(Long id, Long userId) {
        savedSearchRepository.deleteByIdAndUserId(id, userId);
        log.info("Deleted saved search {} for user {}", id, userId);
    }

    @Override
    public String buildSearchUrl(SavedSearch savedSearch) {
        try {
            SearchCriteriaDto criteria = objectMapper.readValue(
                    savedSearch.getFiltersJson(), SearchCriteriaDto.class);
            String queryString = criteria.toQueryString();
            // toQueryString() prepends '&' on each param; strip leading '&'
            if (queryString.startsWith("&")) {
                queryString = queryString.substring(1);
            }
            return "/search?" + queryString;
        } catch (JsonProcessingException e) {
            log.warn("Failed to parse filtersJson for saved search {}: {}", savedSearch.getId(), e.getMessage());
            return "/search";
        }
    }
}
