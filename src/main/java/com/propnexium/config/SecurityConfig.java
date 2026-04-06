package com.propnexium.config;

import com.propnexium.repository.UserRepository;
import com.propnexium.security.CustomUserDetailsService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

import java.time.LocalDateTime;

/**
 * Full PropNexium Security Configuration.
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

        private final CustomUserDetailsService userDetailsService;
        private final UserRepository userRepository;

        @Bean
        public BCryptPasswordEncoder passwordEncoder() {
                return new BCryptPasswordEncoder(12);
        }

        @Bean
        public DaoAuthenticationProvider authenticationProvider() {
                DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
                provider.setUserDetailsService(userDetailsService);
                provider.setPasswordEncoder(passwordEncoder());
                return provider;
        }

        @Bean
        public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
                http
                                .authenticationProvider(authenticationProvider())

                                // ── URL Authorization ──────────────────────────────────────────
                                .authorizeHttpRequests(auth -> auth
                                                // Admin only
                                                .requestMatchers(new AntPathRequestMatcher("/admin/**"))
                                                .hasRole("ADMIN")
                                                // Agent and Admin
                                                .requestMatchers(new AntPathRequestMatcher("/agent/**"))
                                                .hasAnyRole("AGENT", "ADMIN")
                                                // User dashboard
                                                .requestMatchers(new AntPathRequestMatcher("/user/**")).authenticated()
                                                // Authenticated REST APIs
                                                .requestMatchers(
                                                                new AntPathRequestMatcher("/api/v1/user/**"),
                                                                new AntPathRequestMatcher("/api/v1/inquiries/**"),
                                                                new AntPathRequestMatcher("/api/v1/wishlist/**"),
                                                                new AntPathRequestMatcher("/api/v1/reviews/**"))
                                                .authenticated()
                                                // Everything else is public (home page, properties, auth pages, static
                                                // resources, etc.)
                                                .anyRequest().permitAll())

                                // ── Form Login ─────────────────────────────────────────────────
                                .formLogin(form -> form
                                                .loginPage("/auth/login")
                                                .loginProcessingUrl("/auth/do-login")
                                                .usernameParameter("email")
                                                .passwordParameter("password")
                                                .successHandler(roleBasedRedirectHandler())
                                                .failureUrl("/auth/login?error=true"))

                                // ── Logout ─────────────────────────────────────────────────────
                                .logout(logout -> logout
                                                .logoutRequestMatcher(new AntPathRequestMatcher("/auth/logout"))
                                                .logoutSuccessUrl("/auth/login?logout=true")
                                                .invalidateHttpSession(true)
                                                .deleteCookies("JSESSIONID", "remember-me"))

                                // ── Remember Me ────────────────────────────────────────────────
                                .rememberMe(rm -> rm
                                                .key("propnexium-rmb-key-2024")
                                                .tokenValiditySeconds(7 * 24 * 3600)
                                                .userDetailsService(userDetailsService))

                                // ── Exception Handling ─────────────────────────────────────────
                                .exceptionHandling(ex -> ex
                                                .accessDeniedPage("/error/403"))

                                // ── CSRF ──────────────────────────────────────────────────────
                                .csrf(csrf -> csrf
                                                .ignoringRequestMatchers(new AntPathRequestMatcher("/api/**"),
                                                                new AntPathRequestMatcher("/contact")));

                return http.build();
        }

        /**
         * Redirect users to their role-specific dashboard after successful login.
         * Also updates lastLogin timestamp on every successful authentication.
         */
        @Bean
        public AuthenticationSuccessHandler roleBasedRedirectHandler() {
                return (request, response, authentication) -> {
                        // Update lastLogin timestamp
                        try {
                                userRepository.findByEmail(authentication.getName()).ifPresent(user -> {
                                        user.setLastLogin(LocalDateTime.now());
                                        userRepository.save(user);
                                });
                        } catch (Exception ignored) { /* non-critical, don't block redirect */ }

                        boolean isAdmin = authentication.getAuthorities().stream()
                                        .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
                        boolean isAgent = authentication.getAuthorities().stream()
                                        .anyMatch(a -> a.getAuthority().equals("ROLE_AGENT"));

                        if (isAdmin) {
                                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                        } else if (isAgent) {
                                response.sendRedirect(request.getContextPath() + "/agent/dashboard");
                        } else {
                                response.sendRedirect(request.getContextPath() + "/user/dashboard");
                        }
                };
        }
}
