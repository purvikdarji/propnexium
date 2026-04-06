package com.propnexium.service;

import com.propnexium.dto.request.SearchCriteriaDto;
import com.propnexium.dto.response.SearchResultDto;

import java.util.List;

/**
 * Search service: full-text property search with keyword preprocessing,
 * filter support, result pagination, and async search logging.
 */
public interface SearchService {

    /**
     * Performs a FULLTEXT search on properties using the given criteria.
     * Keywords are preprocessed into MySQL Boolean Mode tokens (+word*).
     * Results are ordered by relevance score then creation date DESC.
     */
    SearchResultDto search(SearchCriteriaDto criteria);

    /**
     * Returns up to 8 autocomplete title suggestions matching the given prefix.
     * Returns an empty list if the prefix is shorter than 2 characters.
     */
    List<String> getAutocompleteSuggestions(String prefix);
}
