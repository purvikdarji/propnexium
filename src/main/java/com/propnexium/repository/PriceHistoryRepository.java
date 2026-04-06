package com.propnexium.repository;

import com.propnexium.entity.PriceHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PriceHistoryRepository extends JpaRepository<PriceHistory, Long> {

    List<PriceHistory> findByPropertyIdOrderByChangedAtAsc(Long propertyId);

    List<PriceHistory> findTop10ByPropertyIdOrderByChangedAtDesc(Long propertyId);
}
