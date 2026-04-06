package com.propnexium.config;
import com.propnexium.entity.AgentProfile;
import com.propnexium.entity.Property;
import com.propnexium.entity.PropertyAmenities;
import com.propnexium.entity.User;
import com.propnexium.entity.enums.*;
import com.propnexium.repository.AgentProfileRepository;
import com.propnexium.repository.PropertyAmenitiesRepository;
import com.propnexium.repository.PropertyRepository;
import com.propnexium.repository.UserRepository;
import com.propnexium.repository.BlogRepository;
import com.propnexium.entity.BlogPost;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Random;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataLoader implements CommandLineRunner {

    private final UserRepository              userRepository;
    private final AgentProfileRepository      agentProfileRepository;
    private final PropertyRepository          propertyRepository;
    private final PropertyAmenitiesRepository propertyAmenitiesRepository;
    private final BlogRepository              blogRepository;
    private final PasswordEncoder             passwordEncoder;
    private static final Random RNG = new Random();

    @Override
    @Transactional
    public void run(String... args) {

        log.info("DataLoader: Starting database seed...");

        if (propertyRepository.count() == 0) {
            seedPropertiesAndUsers();
        } else {
            log.info("DataLoader: Properties already exist — skipping property seed.");
        }

        seedBlogPosts();
    }


    private void seedPropertiesAndUsers() {
        User admin = createUser("PropNexium Admin", "admin@propnexium.com",
                "9000000000", UserRole.ADMIN, true);

        User agent1 = createUser("Rajesh Sharma", "agent1@propnexium.com",
                "9111111111", UserRole.AGENT, true);
        User agent2 = createUser("Priya Patel", "agent2@propnexium.com",
                "9222222222", UserRole.AGENT, true);
        User agent3 = createUser("Arjun Mehta", "agent3@propnexium.com",
                "9333333333", UserRole.AGENT, true);

        createAgentProfile(agent1, "Sharma Realty", "MH-2024-001",
                "Mumbai luxury property specialist with 8+ years of experience. " +
                "Expert in sea-facing apartments and premium residential projects.",
                8, new BigDecimal("4.7"), 35, 18);

        createAgentProfile(agent2, "Patel Properties", "DL-2024-002",
                "Delhi NCR expert focusing on residential and commercial projects. " +
                "Strong network in South Delhi and Noida IT corridor.",
                6, new BigDecimal("4.5"), 28, 14);

        createAgentProfile(agent3, "Mehta Estates", "BG-2024-003",
                "Bangalore tech-hub properties and premium villa specialist. " +
                "Deep knowledge of Whitefield, Koramangala, and Indiranagar micro-markets.",
                10, new BigDecimal("4.8"), 42, 27);

        // ── 2 Regular Users ───────────────────────────────────────────────────
        User user1 = createUser("Ananya Singh", "user1@propnexium.com",
                "9444444441", UserRole.USER, true);
        User user2 = createUser("Rohit Kumar", "user2@propnexium.com",
                "9444444442", UserRole.USER, true);

        // ── 15 Properties across 6 cities ─────────────────────────────────────

        // ═══ MUMBAI — 3 properties ═══════════════════════════════════════════

        Property p1 = buildAndSaveProperty(
                "Luxury 3BHK Sea-View Apartment – Bandra West",
                "Stunning sea-facing apartment in Bandra West with panoramic ocean views, " +
                "premium Italian marble flooring, modular kitchen, and 2 covered parking spots. " +
                "Part of a gated complex with 24/7 security, gymnasium, and rooftop pool. " +
                "Just 5 minutes from Bandra station. Ready to move in.",
                new BigDecimal("18500000"),
                "Mumbai", "Maharashtra", "400050",
                PropertyType.APARTMENT, PropertyCategory.BUY,
                3, 3, 2,
                new BigDecimal("1850"),
                Furnishing.FULLY_FURNISHED, Parking.TWO,
                PropertyStatus.AVAILABLE, true,
                agent1, 187, 75
        );
        saveAmenities(p1, true, true, true, true, true, true, false, true, false, false, false, true);

        Property p2 = buildAndSaveProperty(
                "Cozy 1BHK Flat for Rent – Andheri East",
                "Well-maintained 1BHK available for rent, minutes from Andheri Metro station. " +
                "Perfect for working professionals. Society has backup power, lift, and security. " +
                "Grocery stores and cafes in the immediate vicinity.",
                new BigDecimal("25000"),
                "Mumbai", "Maharashtra", "400069",
                PropertyType.APARTMENT, PropertyCategory.RENT,
                1, 1, 1,
                new BigDecimal("620"),
                Furnishing.SEMI_FURNISHED, Parking.ONE,
                PropertyStatus.AVAILABLE, false,
                agent1, 94, 82
        );
        saveAmenities(p2, false, false, true, true, true, false, false, false, false, false, false, false);

        Property p3 = buildAndSaveProperty(
                "Commercial Shop Space – Andheri West High Street",
                "Prime commercial unit on a busy high-street in Andheri West. " +
                "Ground floor with heavy footfall, ideal for retail, F&B, or clinic. " +
                "24/7 power backup and CCTV installed. Clear title with immediate possession.",
                new BigDecimal("12000000"),
                "Mumbai", "Maharashtra", "400058",
                PropertyType.COMMERCIAL, PropertyCategory.BUY,
                0, 1, 0,
                new BigDecimal("800"),
                Furnishing.UNFURNISHED, Parking.ONE,
                PropertyStatus.AVAILABLE, false,
                agent2, 56, 88
        );
        saveAmenities(p3, false, false, true, false, true, false, false, false, false, false, true, true);

        // ═══ DELHI — 2 properties ════════════════════════════════════════════

        Property p4 = buildAndSaveProperty(
                "Spacious 4BHK Independent House – Vasant Kunj",
                "Beautiful independent house with a private garden and modular kitchen " +
                "in one of Delhi's most serene localities. 4 bedrooms, all with attached baths. " +
                "Ample parking for 2 cars. Close to Vasant Kunj Mall and DPS School.",
                new BigDecimal("32000000"),
                "Delhi", "Delhi", "110070",
                PropertyType.HOUSE, PropertyCategory.BUY,
                4, 4, 1,
                new BigDecimal("2800"),
                Furnishing.SEMI_FURNISHED, Parking.TWO,
                PropertyStatus.AVAILABLE, true,
                agent2, 143, 65
        );
        saveAmenities(p4, true, false, true, false, true, false, true, true, true, false, false, true);

        Property p5 = buildAndSaveProperty(
                "Premium Studio Apartment for Rent – Connaught Place",
                "Fully furnished studio in the heart of New Delhi, walking distance from " +
                "Rajiv Chowk metro. Ideal for young professionals or short-term corporate stay. " +
                "Building has lift, intercom, and 24/7 security.",
                new BigDecimal("35000"),
                "Delhi", "Delhi", "110001",
                PropertyType.STUDIO, PropertyCategory.RENT,
                0, 1, 0,
                new BigDecimal("450"),
                Furnishing.FULLY_FURNISHED, Parking.NONE,
                PropertyStatus.AVAILABLE, false,
                agent2, 67, 72
        );
        saveAmenities(p5, false, false, true, true, true, false, false, false, true, false, false, false);

        // ═══ BANGALORE — 3 properties ════════════════════════════════════════

        Property p6 = buildAndSaveProperty(
                "Modern 3BHK Villa – Whitefield Bangalore",
                "Contemporary villa in a gated community near ITPL Tech Park. " +
                "Features a private pool, clubhouse access, landscaped garden, and 24/7 security. " +
                "10 minutes from major IT companies. Fully furnished with premium fittings.",
                new BigDecimal("22000000"),
                "Bangalore", "Karnataka", "560066",
                PropertyType.VILLA, PropertyCategory.BUY,
                3, 4, 2,
                new BigDecimal("2200"),
                Furnishing.FULLY_FURNISHED, Parking.TWO,
                PropertyStatus.AVAILABLE, true,
                agent3, 221, 55
        );
        saveAmenities(p6, true, true, true, true, true, true, true, true, true, true, true, true);

        Property p7 = buildAndSaveProperty(
                "2BHK Apartment for Rent – Koramangala 6th Block",
                "Spacious 2BHK in the heart of Bangalore's startup hub, Koramangala 6th Block. " +
                "Walking distance from restaurants, cafes, and offices. " +
                "Society amenities include gym, power backup, and covered parking.",
                new BigDecimal("35000"),
                "Bangalore", "Karnataka", "560034",
                PropertyType.APARTMENT, PropertyCategory.RENT,
                2, 2, 1,
                new BigDecimal("1100"),
                Furnishing.SEMI_FURNISHED, Parking.ONE,
                PropertyStatus.AVAILABLE, false,
                agent3, 108, 60
        );
        saveAmenities(p7, true, false, true, true, true, false, false, false, false, false, false, true);

        Property p8 = buildAndSaveProperty(
                "Penthouse with Sky Deck – Indiranagar",
                "Exclusive 4BHK penthouse with a private rooftop sky deck offering 360° city views. " +
                "Smart home automation, home theatre, jacuzzi, and premium fittings throughout. " +
                "Rare opportunity in Bangalore's most coveted address.",
                new BigDecimal("55000000"),
                "Bangalore", "Karnataka", "560038",
                PropertyType.PENTHOUSE, PropertyCategory.BUY,
                4, 5, 3,
                new BigDecimal("3500"),
                Furnishing.FULLY_FURNISHED, Parking.THREE_PLUS,
                PropertyStatus.AVAILABLE, true,
                agent3, 194, 45
        );
        saveAmenities(p8, true, true, true, true, true, true, false, true, true, false, false, true);

        // ═══ AHMEDABAD — 3 properties ════════════════════════════════════════

        Property p9 = buildAndSaveProperty(
                "3BHK Premium Flat – Prahlad Nagar",
                "Well-appointed 3BHK in Prahlad Nagar, Ahmedabad's prime residential belt. " +
                "Complex features a clubhouse, swimming pool, gym, and multi-level parking. " +
                "Close to premium schools, hospitals, and SG Highway.",
                new BigDecimal("7200000"),
                "Ahmedabad", "Gujarat", "380015",
                PropertyType.APARTMENT, PropertyCategory.BUY,
                3, 2, 2,
                new BigDecimal("1380"),
                Furnishing.SEMI_FURNISHED, Parking.ONE,
                PropertyStatus.AVAILABLE, true,
                agent1, 162, 58
        );
        saveAmenities(p9, true, true, true, true, true, true, true, false, false, false, false, true);

        Property p10 = buildAndSaveProperty(
                "2BHK Apartment for Rent – Near SG Highway",
                "Affordable 2BHK with modern interiors, excellent connectivity on SG Highway. " +
                "Perfect for families or working couples. Society has CCTV, lift, and visitor parking. " +
                "Grocery stores and metro access within 10 minutes.",
                new BigDecimal("22000"),
                "Ahmedabad", "Gujarat", "380054",
                PropertyType.APARTMENT, PropertyCategory.RENT,
                2, 2, 1,
                new BigDecimal("1050"),
                Furnishing.SEMI_FURNISHED, Parking.ONE,
                PropertyStatus.AVAILABLE, false,
                agent2, 83, 68
        );
        saveAmenities(p10, false, false, true, true, true, false, false, false, true, false, false, true);

        Property p11 = buildAndSaveProperty(
                "Row House in Bopal – Gated Society",
                "Charming 3BHK row house in Bopal's fastest-growing residential area. " +
                "Private terrace, front lawn, and 2 car garage. Society has kids' play area and garden. " +
                "Excellent schools and hospitals nearby. Ready to move.",
                new BigDecimal("9500000"),
                "Ahmedabad", "Gujarat", "380058",
                PropertyType.HOUSE, PropertyCategory.BUY,
                3, 3, 1,
                new BigDecimal("1800"),
                Furnishing.SEMI_FURNISHED, Parking.TWO,
                PropertyStatus.AVAILABLE, false,
                agent2, 77, 85
        );
        saveAmenities(p11, true, false, true, true, true, false, true, true, true, false, false, false);

        // ═══ PUNE — 2 properties ═════════════════════════════════════════════

        Property p12 = buildAndSaveProperty(
                "Penthouse in Baner with Private Terrace",
                "Luxurious 4BHK penthouse in Baner with a massive private terrace and city views. " +
                "Tastefully designed with Italian marble, modular kitchen, and 3-car parking. " +
                "Premium gated society with gym, pool, and concierge service.",
                new BigDecimal("15000000"),
                "Pune", "Maharashtra", "411045",
                PropertyType.APARTMENT, PropertyCategory.BUY,
                4, 3, 3,
                new BigDecimal("2800"),
                Furnishing.FULLY_FURNISHED, Parking.THREE_PLUS,
                PropertyStatus.AVAILABLE, true,
                agent3, 194, 42
        );
        saveAmenities(p12, true, true, true, true, true, true, false, true, true, true, true, true);

        Property p13 = buildAndSaveProperty(
                "1BHK Flat for Rent – Hinjewadi IT Park Area",
                "Budget-friendly 1BHK steps from Hinjewadi IT Park Phase 1. " +
                "Ideal for IT professionals. Society amenities include lift, power backup, and security. " +
                "Multiple food courts and transport hubs nearby.",
                new BigDecimal("15000"),
                "Pune", "Maharashtra", "411057",
                PropertyType.APARTMENT, PropertyCategory.RENT,
                1, 1, 1,
                new BigDecimal("550"),
                Furnishing.SEMI_FURNISHED, Parking.ONE,
                PropertyStatus.AVAILABLE, false,
                agent1, 112, 70
        );
        saveAmenities(p13, false, false, true, true, true, false, false, false, false, false, false, false);

        // ═══ CHENNAI — 1 property ════════════════════════════════════════════

        Property p14 = buildAndSaveProperty(
                "Luxury Sea-View Villa – ECR Road Chennai",
                "Majestic 4BHK luxury villa on the iconic East Coast Road with direct beach access. " +
                "Private pool, landscaped garden, home automation system, and premium fixtures. " +
                "Peaceful retreat with excellent connectivity to the city.",
                new BigDecimal("22000000"),
                "Chennai", "Tamil Nadu", "600041",
                PropertyType.VILLA, PropertyCategory.BUY,
                4, 4, 2,
                new BigDecimal("4500"),
                Furnishing.FULLY_FURNISHED, Parking.THREE_PLUS,
                PropertyStatus.AVAILABLE, true,
                agent2, 98, 50
        );
        saveAmenities(p14, true, true, true, true, true, true, true, true, true, true, true, true);

        // ═══ HYDERABAD — 1 property ══════════════════════════════════════════

        Property p15 = buildAndSaveProperty(
                "2BHK in Gachibowli Tech Hub – Premium Society",
                "Spacious 2BHK in Gachibowli, surrounded by leading IT campuses (Google, Microsoft, TCS). " +
                "Society features gym, swimming pool, children's play area, and 24/7 security. " +
                "Metro connectivity under development nearby.",
                new BigDecimal("28000"),
                "Hyderabad", "Telangana", "500032",
                PropertyType.APARTMENT, PropertyCategory.RENT,
                2, 2, 1,
                new BigDecimal("1200"),
                Furnishing.SEMI_FURNISHED, Parking.ONE,
                PropertyStatus.AVAILABLE, false,
                agent3, 134, 55
        );
        saveAmenities(p15, true, true, true, true, true, false, true, false, false, false, false, true);

        // ── Summary log ──────────────────────────────────────────────────────
        log.info("DataLoader: ✅ Seeding complete.");
        log.info("  ✓ 1 Admin   — admin@propnexium.com     / Admin@123");
        log.info("  ✓ 3 Agents  — agent1/2/3@propnexium.com / Agent@123");
        log.info("  ✓ 2 Users   — user1/2@propnexium.com    / User@123");
        log.info("  ✓ 3 AgentProfiles seeded");
        log.info("  ✓ 15 Properties across Mumbai, Delhi, Bangalore, Ahmedabad, Pune, Chennai, Hyderabad");
    }

    private void seedBlogPosts() {
        if (blogRepository.count() > 0) {
            log.info("DataLoader: Blog posts already exist — skipping blog seed.");
            return;
        }

        User admin = userRepository.findByEmail("admin@propnexium.com").orElseGet(() ->
            createUser("PropNexium Admin", "admin@propnexium.com", "9000000000", UserRole.ADMIN, true)
        );

        createBlogPost(
                "5 Tips for First-Time Home Buyers",
                "5-tips-first-time-home-buyers",
                "Buying Tips",
                "Essential advice for navigating the real estate market for the first time.",
                5, BlogPost.PostStatus.PUBLISHED, admin,
                "https://images.unsplash.com/photo-1560518884-ce58822b07b4?w=800",
                "<h2>1. Know your budget</h2><p>Always check your finances...</p>"
        );

        createBlogPost(
                "How to Negotiate Rent in India",
                "how-to-negotiate-rent-india",
                "Renting Guide",
                "Proven strategies to get the best deal on your next rental property.",
                4, BlogPost.PostStatus.PUBLISHED, admin,
                "https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800",
                "<h2>Research the Market</h2><p>Before negotiating, understand local rates...</p>"
        );

        createBlogPost(
                "Understanding Bigha, Cent and Guntha",
                "understanding-bigha-cent-guntha",
                "Legal & Finance",
                "A comprehensive guide to traditional Indian area units and their conversions.",
                6, BlogPost.PostStatus.PUBLISHED, admin,
                "https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=800",
                "<h2>What is a Bigha?</h2><p>Bigha is a traditional unit of measurement...</p>"
        );
        
        log.info("  ✓ 3 Sample Blog Posts seeded");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helper: create & save a User
    // ─────────────────────────────────────────────────────────────────────────
    private User createUser(String name, String email, String phone,
                            UserRole role, boolean emailVerified) {
        return userRepository.save(User.builder()
                .name(name)
                .email(email)
                .password(passwordEncoder.encode(
                        role == UserRole.ADMIN ? "Admin@123"
                        : role == UserRole.AGENT ? "Agent@123"
                        : "User@123"))
                .phone(phone)
                .role(role)
                .isActive(true)
                .isEmailVerified(emailVerified)
                .build());
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helper: create & save an AgentProfile
    // ─────────────────────────────────────────────────────────────────────────
    private void createAgentProfile(User agent, String agencyName,
                                    String licenseNumber, String bio,
                                    int experienceYears, BigDecimal rating,
                                    int totalListings, int totalSold) {
        agentProfileRepository.save(AgentProfile.builder()
                .user(agent)
                .agencyName(agencyName)
                .licenseNumber(licenseNumber)
                .bio(bio)
                .experienceYears(experienceYears)
                .rating(rating)
                .totalListings(totalListings)
                .totalSold(totalSold)
                .build());
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helper: build, persist & return a Property.
    // createdAt is staggered randomly over the past `maxAgeDays` days so that
    // the monthly analytics chart shows activity across multiple months.
    // ─────────────────────────────────────────────────────────────────────────
    private Property buildAndSaveProperty(
            String title, String description,
            BigDecimal price,
            String city, String state, String pincode,
            PropertyType type, PropertyCategory category,
            int bedrooms, int bathrooms, int balconies,
            BigDecimal areaSqft,
            Furnishing furnishing, Parking parking,
            PropertyStatus status, boolean isFeatured,
            User agent, int viewCount, int maxAgeDays) {

        // Stagger createdAt across the past maxAgeDays days for realistic charts
        LocalDateTime createdAt = LocalDateTime.now()
                .minusDays(RNG.nextInt(maxAgeDays) + 1)
                .minusHours(RNG.nextInt(24))
                .minusMinutes(RNG.nextInt(60));

        Property property = Property.builder()
                .title(title)
                .description(description)
                .price(price)
                .city(city)
                .state(state)
                .pincode(pincode)
                .location(city + ", " + state)
                .type(type)
                .category(category)
                .bedrooms(bedrooms)
                .bathrooms(bathrooms)
                .balconies(balconies)
                .areaSqft(areaSqft)
                .furnishing(furnishing)
                .parking(parking)
                .status(status)
                .isFeatured(isFeatured)
                .viewCount(viewCount)
                .agent(agent)
                .build();

        Property saved = propertyRepository.save(property);

        // Manually back-date createdAt using a native update
        // (Hibernate @CreationTimestamp cannot be overridden at save-time)
        propertyRepository.updateCreatedAt(saved.getId(), createdAt);

        return saved;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helper: create & save a PropertyAmenities record
    // Parameter order matches the PropertyAmenities boolean columns:
    //   hasGym, hasSwimmingPool, hasSecurity, hasLift, hasPowerBackup,
    //   hasClubHouse, hasChildrenPlayArea, hasGarden, hasIntercom,
    //   hasRainwaterHarvesting, hasWasteManagement, hasVisitorParking
    // ─────────────────────────────────────────────────────────────────────────
    private void saveAmenities(Property property,
                               boolean gym, boolean pool, boolean security,
                               boolean lift, boolean powerBackup, boolean clubHouse,
                               boolean childrenPlayArea, boolean garden,
                               boolean intercom, boolean rainwater, boolean waste,
                               boolean visitorParking) {
        propertyAmenitiesRepository.save(PropertyAmenities.builder()
                .property(property)
                .hasGym(gym)
                .hasSwimmingPool(pool)
                .hasSecurity(security)
                .hasLift(lift)
                .hasPowerBackup(powerBackup)
                .hasClubHouse(clubHouse)
                .hasChildrenPlayArea(childrenPlayArea)
                .hasGarden(garden)
                .hasIntercom(intercom)
                .hasRainwaterHarvesting(rainwater)
                .hasWasteManagement(waste)
                .hasVisitorParking(visitorParking)
                .build());
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helper: create & save a BlogPost
    // ─────────────────────────────────────────────────────────────────────────
    private void createBlogPost(String title, String slug, String category,
                                String excerpt, int readTime, BlogPost.PostStatus status, User author,
                                String coverImage, String content) {
        blogRepository.save(BlogPost.builder()
                .title(title)
                .slug(slug)
                .category(category)
                .excerpt(excerpt)
                .readTimeMinutes(readTime)
                .status(status)
                .author(author)
                .coverImage(coverImage)
                .content(content)
                .publishedAt(LocalDateTime.now().minusDays(RNG.nextInt(30)))
                .viewCount(RNG.nextInt(500))
                .build());
    }
}
