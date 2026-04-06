package com.propnexium.service.impl;

import com.propnexium.dto.request.SearchCriteriaDto;
import com.propnexium.entity.SearchLog;
import com.propnexium.repository.SearchLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Slf4j
@Component
@RequiredArgsConstructor
public class SearchLogAsyncWriter {

    private final SearchLogRepository searchLogRepository;

    @Async
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void log(SearchCriteriaDto criteria, int resultCount, long searchTimeMs) {
        try {
            SearchLog entry = SearchLog.builder()
                    .keyword(criteria.getKeyword())
                    .searchCity(criteria.getCity())
                    .searchType(criteria.getType())
                    .searchCategory(criteria.getCategory())
                    .resultCount(resultCount)
                    .searchTimeMs(searchTimeMs)
                    .searchedAt(LocalDateTime.now())
                    .build();
            searchLogRepository.save(entry);
        } catch (Exception ex) {
            log.warn("Search log write failed (non-fatal): {}", ex.getMessage());
        }
    }
}
