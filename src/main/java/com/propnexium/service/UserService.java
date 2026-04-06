package com.propnexium.service;

import com.propnexium.dto.request.UserRegistrationDto;
import com.propnexium.dto.request.UserUpdateDto;
import com.propnexium.entity.User;
import com.propnexium.entity.enums.UserRole;
import com.propnexium.exception.DuplicateResourceException;
import org.springframework.data.domain.Page;

import java.util.List;
import java.util.Optional;

/**
 * Service interface for User operations.
 */
public interface UserService {

    /**
     * Register a new user from the registration DTO. Creates AgentProfile if role
     * is AGENT.
     */
    User registerUser(UserRegistrationDto dto) throws DuplicateResourceException;

    Optional<User> findByEmail(String email);

    Optional<User> findById(Long id);

    /** Update editable profile fields (name, phone). */
    User updateProfile(Long userId, UserUpdateDto dto);

    /** Change password after verifying the old one. */
    void changePassword(Long userId, String oldPassword, String newPassword);

    /** Update just the profile picture URL. */
    void updateProfilePicture(Long userId, String imageUrl);

    boolean existsByEmail(String email);

    long countByRole(UserRole role);

    /** Total number of registered users. */
    long countAll();

    List<User> findByRole(UserRole role);

    /**
     * Return the currently authenticated user from the SecurityContext, or null if
     * anonymous.
     */
    User getCurrentUser();

    /** N most recently registered users. */
    List<User> getRecentUsers(int limit);

    /**
     * Paginated + filterable list of all users (admin user management).
     * role and search are optional filters.
     */
    Page<User> findAllPaginated(String role, String search, int page, int size);

    /** Toggle a user's active/inactive status and return the new value. */
    boolean toggleActiveStatus(Long userId);

    // ---- legacy helpers (kept for backward compatibility) ----
    User updateUser(User user);

    void deleteUser(Long id);

    void activateUser(Long id);

    void deactivateUser(Long id);

    void verifyEmail(Long id);
}
