package com.propnexium.repository;

import com.propnexium.entity.AgentProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface AgentProfileRepository extends JpaRepository<AgentProfile, Long> {

    Optional<AgentProfile> findByUserId(Long userId);

    boolean existsByUserId(Long userId);

    boolean existsByLicenseNumber(String licenseNumber);

    Optional<AgentProfile> findByLicenseNumber(String licenseNumber);
}
