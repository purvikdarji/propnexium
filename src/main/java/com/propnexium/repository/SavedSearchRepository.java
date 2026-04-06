package com.propnexium.repository;

import com.propnexium.entity.SavedSearch;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
public interface SavedSearchRepository extends JpaRepository<SavedSearch, Long> {

    List<SavedSearch> findByUserIdOrderByCreatedAtDesc(Long userId);

    @Transactional
    void deleteByIdAndUserId(Long id, Long userId);
}
