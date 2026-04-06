package com.propnexium.service.impl;

import com.propnexium.dto.request.UserRegistrationDto;
import com.propnexium.dto.request.UserUpdateDto;
import com.propnexium.entity.AgentProfile;
import com.propnexium.entity.User;
import com.propnexium.entity.enums.UserRole;
import com.propnexium.exception.BusinessException;
import com.propnexium.exception.DuplicateResourceException;
import com.propnexium.exception.ResourceNotFoundException;
import com.propnexium.repository.AgentProfileRepository;
import com.propnexium.repository.UserRepository;
import com.propnexium.service.EmailService;
import com.propnexium.service.EmailVerificationService;
import com.propnexium.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AgentProfileRepository agentProfileRepository;
    private final EmailService emailService;
    @Lazy
    private final EmailVerificationService emailVerificationService;

    @Override
    public User registerUser(UserRegistrationDto dto) throws DuplicateResourceException {

        // 1. Duplicate email check
        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new DuplicateResourceException(
                    "An account with email " + dto.getEmail() + " already exists");
        }

        // 2. Cross-field password match (belt-and-suspenders; controller also checks)
        if (!dto.isPasswordMatching()) {
            throw new BusinessException("Passwords do not match");
        }

        // 3. Determine role
        UserRole role = "AGENT".equalsIgnoreCase(dto.getRole())
                ? UserRole.AGENT
                : UserRole.USER;

        // 4. Build and persist User
        User user = User.builder()
                .name(dto.getName())
                .email(dto.getEmail())
                .password(passwordEncoder.encode(dto.getPassword()))
                .phone(dto.getPhone())
                .role(role)
                .isActive(true)
                .build();

        User saved = userRepository.save(user);

        // 5. If AGENT, create a starter AgentProfile
        if (role == UserRole.AGENT) {
            AgentProfile profile = AgentProfile.builder()
                    .user(saved)
                    .rating(BigDecimal.ZERO)
                    .experienceYears(0)
                    .totalListings(0)
                    .build();
            agentProfileRepository.save(profile);
        }

        // 6. Send welcome email asynchronously (non-blocking)
        emailService.sendWelcomeEmail(saved);

        // 7. Send email verification link asynchronously
        emailVerificationService.sendVerificationEmail(saved);

        return saved;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Queries
    // ─────────────────────────────────────────────────────────────────────────

    @Override
    @Transactional(readOnly = true)
    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    @Override
    @Transactional(readOnly = true)
    public long countByRole(UserRole role) {
        return userRepository.countByRole(role);
    }

    @Override
    @Transactional(readOnly = true)
    public long countAll() {
        return userRepository.count();
    }

    @Override
    @Transactional(readOnly = true)
    public List<User> findByRole(UserRole role) {
        return userRepository.findByRole(role);
    }

    @Override
    @Transactional(readOnly = true)
    public List<User> getRecentUsers(int limit) {
        return userRepository.findRecentUsers(PageRequest.of(0, limit));
    }

    @Override
    @Transactional(readOnly = true)
    public Page<User> findAllPaginated(String role, String search, int page, int size) {
        UserRole userRole = null;
        if (role != null && !role.isBlank()) {
            try {
                userRole = UserRole.valueOf(role.toUpperCase());
            } catch (IllegalArgumentException ignored) {
            }
        }
        String searchTerm = (search != null && search.isBlank()) ? null : search;
        return userRepository.findForAdmin(
                userRole, searchTerm,
                PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt")));
    }

    @Override
    public boolean toggleActiveStatus(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        user.setIsActive(!user.getIsActive());
        userRepository.save(user);
        return user.getIsActive();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Profile updates
    // ─────────────────────────────────────────────────────────────────────────

    @Override
    public User updateProfile(Long userId, UserUpdateDto dto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        user.setName(dto.getName());
        user.setPhone(dto.getPhone());
        return userRepository.save(user);
    }

    @Override
    public void changePassword(Long userId, String oldPassword, String newPassword) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new BusinessException("Current password is incorrect");
        }
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }

    @Override
    public void updateProfilePicture(Long userId, String imageUrl) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        user.setProfilePicture(imageUrl);
        userRepository.save(user);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // SecurityContext integration
    // ─────────────────────────────────────────────────────────────────────────

    @Override
    @Transactional(readOnly = true)
    public User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()
                || auth instanceof AnonymousAuthenticationToken) {
            return null;
        }
        String email = auth.getName();
        return userRepository.findByEmail(email).orElse(null);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Legacy helpers
    // ─────────────────────────────────────────────────────────────────────────

    @Override
    public User updateUser(User user) {
        return userRepository.save(user);
    }

    @Override
    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }

    @Override
    public void activateUser(Long id) {
        userRepository.findById(id).ifPresent(u -> {
            u.setIsActive(true);
            userRepository.save(u);
        });
    }

    @Override
    public void deactivateUser(Long id) {
        userRepository.findById(id).ifPresent(u -> {
            u.setIsActive(false);
            userRepository.save(u);
        });
    }

    @Override
    public void verifyEmail(Long id) {
        userRepository.findById(id).ifPresent(u -> {
            u.setIsEmailVerified(true);
            userRepository.save(u);
        });
    }
}
