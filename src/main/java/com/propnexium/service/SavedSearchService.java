package com.propnexium.service;

import com.propnexium.dto.request.SearchCriteriaDto;
import com.propnexium.entity.SavedSearch;

import java.util.List;

public interface SavedSearchService {

    /** Serialise criteria to JSON and persist a named SavedSearch for the given user. */
    void saveSearch(Long userId, String name, SearchCriteriaDto criteria);

    /** Return all saved searches for a user, newest first. */
    List<SavedSearch> getUserSavedSearches(Long userId);

    /** Delete a saved search only if it belongs to the given user (safe delete). */
    void deleteSavedSearch(Long id, Long userId);

    /** Reconstruct the /search?... URL from a saved search's stored JSON. */
    String buildSearchUrl(SavedSearch savedSearch);
}
