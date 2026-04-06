package com.propnexium.service.impl;

import com.propnexium.dto.request.SearchCriteriaDto;
import com.propnexium.dto.response.SearchResultDto;
import com.propnexium.repository.PropertyRepository;
import com.propnexium.service.SearchService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Implementation of {@link SearchService}.
 *
 * <p>Keyword preprocessing:
 * Each whitespace-delimited word with length >= 2 is transformed into
 * {@code +word*}, enabling prefix matching in MySQL FULLTEXT Boolean Mode.
 * E.g. "sea view flat" → "+sea* +view* +flat*"
 *
 * <p>Search logging is delegated to {@link SearchLogAsyncWriter} — a separate
 * Spring bean — to avoid the transactional rollback-only conflict that occurs
 * when an @Async write-method is called within a @Transactional(readOnly=true) class.
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SearchServiceImpl implements SearchService {

    private final PropertyRepository propertyRepository;
    private final SearchLogAsyncWriter logAsyncWriter;

    // ─── Search ──────────────────────────────────────────────────────────────

    @Override
    public SearchResultDto search(SearchCriteriaDto criteria) {
        long startTime = System.currentTimeMillis();

        // Preprocess keyword into MySQL Boolean Mode tokens
        String processedKeyword = preprocessKeyword(criteria.getKeyword());

        int offset = criteria.getPage() * criteria.getSize();

        var properties = propertyRepository.fullTextSearch(
                processedKeyword,
                criteria.getCity(),
                criteria.getType(),
                criteria.getCategory(),
                criteria.getMinPrice(),
                criteria.getMaxPrice(),
                criteria.getBedrooms(),
                criteria.getFurnishing(),
                criteria.getSize(),
                offset
        );

        // Force initialization of images to avoid LazyInitializationException/empty UI
        properties.forEach(p -> {
            if (p.getImages() != null) p.getImages().size();
        });

        long totalCount = propertyRepository.fullTextSearchCount(
                processedKeyword,
                criteria.getCity(),
                criteria.getType(),
                criteria.getCategory(),
                criteria.getMinPrice(),
                criteria.getMaxPrice(),
                criteria.getBedrooms(),
                criteria.getFurnishing()
        );

        long searchTimeMs = System.currentTimeMillis() - startTime;
        int totalPages = (int) Math.ceil((double) totalCount / criteria.getSize());

        log.debug("Search completed: {} results in {}ms (keyword='{}')",
                totalCount, searchTimeMs, criteria.getKeyword());

        // Delegate async logging to a separate bean (avoids read-only TX conflict)
        logAsyncWriter.log(criteria, (int) totalCount, searchTimeMs);

        return SearchResultDto.builder()
                .properties(properties)
                .totalCount(totalCount)
                .totalPages(totalPages)
                .currentPage(criteria.getPage())
                .searchTimeMs(searchTimeMs)
                .criteria(criteria)
                .build();
    }

    // ─── Autocomplete ─────────────────────────────────────────────────────────

    @Override
    public List<String> getAutocompleteSuggestions(String prefix) {
        if (prefix == null || prefix.trim().length() < 2) {
            return List.of();
        }
        return propertyRepository.findAutocompleteSuggestions("%" + prefix.trim() + "%");
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────

    /**
     * Converts a raw keyword string into MySQL Boolean Mode search terms.
     * Each word >= 2 chars becomes "+word*".
     * Returns null if keyword is blank (so MATCH clause is omitted).
     */
    private String preprocessKeyword(String raw) {
        if (raw == null || raw.trim().isEmpty()) {
            return null;
        }
        String processed = Arrays.stream(raw.trim().split("\\s+"))
                .filter(w -> w.length() >= 2)
                .map(w -> "+" + w + "*")
                .collect(Collectors.joining(" "));
        return processed.isEmpty() ? null : processed;
    }
}
