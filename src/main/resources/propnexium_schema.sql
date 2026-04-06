CREATE DATABASE IF NOT EXISTS propnexium_db;
USE propnexium_db;

-- 1. users
CREATE TABLE IF NOT EXISTS users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(15),
    role ENUM('ADMIN','AGENT','USER') DEFAULT 'USER',
    profile_picture VARCHAR(300),
    is_active BOOLEAN DEFAULT TRUE,
    is_email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_role (role)
);

-- agent_profiles (needed for DataLoader)
CREATE TABLE IF NOT EXISTS agent_profiles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL UNIQUE,
    agency_name VARCHAR(100),
    license_number VARCHAR(50) UNIQUE,
    experience_years INT DEFAULT 0,
    bio TEXT,
    rating DECIMAL(3,1) DEFAULT 0.0,
    total_listings INT DEFAULT 0,
    total_sold INT DEFAULT 0,
    website VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 2. properties
CREATE TABLE IF NOT EXISTS properties (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    agent_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(15,2) NOT NULL,
    price_negotiable BOOLEAN DEFAULT FALSE,
    location VARCHAR(300),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    pincode VARCHAR(6),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    type ENUM('APARTMENT','HOUSE','VILLA','PLOT','COMMERCIAL','STUDIO','PENTHOUSE') NOT NULL,
    category ENUM('BUY','RENT') DEFAULT 'BUY',
    bedrooms INT DEFAULT 0,
    bathrooms INT DEFAULT 0,
    balconies INT DEFAULT 0,
    area_sqft DECIMAL(10,2),
    total_floors INT,
    floor_number INT,
    furnishing ENUM('UNFURNISHED','SEMI_FURNISHED','FULLY_FURNISHED') DEFAULT 'UNFURNISHED',
    parking ENUM('NONE','ONE','TWO','THREE_PLUS') DEFAULT 'NONE',
    facing ENUM('NORTH','SOUTH','EAST','WEST','NORTH_EAST','NORTH_WEST','SOUTH_EAST','SOUTH_WEST'),
    status ENUM('AVAILABLE','SOLD','RENTED','UNDER_REVIEW','REJECTED') DEFAULT 'UNDER_REVIEW',
    is_featured BOOLEAN DEFAULT FALSE,
    view_count INT DEFAULT 0,
    maintenance_charge DECIMAL(10,2),
    year_built INT,
    possession_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (agent_id) REFERENCES users(id),
    INDEX idx_city (city),
    INDEX idx_type (type),
    INDEX idx_category (category),
    INDEX idx_status (status),
    INDEX idx_price (price),
    FULLTEXT INDEX ft_title_desc (title, description)
);

-- 3. property_images
CREATE TABLE IF NOT EXISTS property_images (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    property_id BIGINT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    original_name VARCHAR(200),
    is_primary BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    INDEX idx_property_id (property_id)
);

-- 4. amenities
CREATE TABLE IF NOT EXISTS amenities (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    icon_class VARCHAR(50)
);

-- 5. property_amenities
CREATE TABLE IF NOT EXISTS property_amenities (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    property_id BIGINT NOT NULL UNIQUE,
    has_gym BOOLEAN DEFAULT FALSE,
    has_swimming_pool BOOLEAN DEFAULT FALSE,
    has_security BOOLEAN DEFAULT FALSE,
    has_lift BOOLEAN DEFAULT FALSE,
    has_power_backup BOOLEAN DEFAULT FALSE,
    has_club_house BOOLEAN DEFAULT FALSE,
    has_children_play_area BOOLEAN DEFAULT FALSE,
    has_garden BOOLEAN DEFAULT FALSE,
    has_intercom BOOLEAN DEFAULT FALSE,
    has_rainwater_harvesting BOOLEAN DEFAULT FALSE,
    has_waste_management BOOLEAN DEFAULT FALSE,
    has_visitor_parking BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE
);

-- 6. inquiries
CREATE TABLE IF NOT EXISTS inquiries (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    property_id BIGINT NOT NULL,
    user_id BIGINT,
    inquirer_name VARCHAR(100) NOT NULL,
    inquirer_email VARCHAR(100) NOT NULL,
    inquirer_phone VARCHAR(15),
    message TEXT NOT NULL,
    agent_reply TEXT,
    status ENUM('PENDING','REPLIED','CLOSED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    replied_at TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_property_id (property_id),
    INDEX idx_status (status)
);

-- 7. wishlists
CREATE TABLE IF NOT EXISTS wishlists (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    property_id BIGINT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_property (user_id, property_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE
);

-- reviews (needed)
CREATE TABLE IF NOT EXISTS reviews (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    agent_id BIGINT NOT NULL,
    reviewer_id BIGINT NOT NULL,
    property_id BIGINT,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_reviewer_agent (reviewer_id, agent_id),
    FOREIGN KEY (agent_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE SET NULL
);

-- 8. notifications
CREATE TABLE IF NOT EXISTS notifications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('INQUIRY','REPLY','WISHLIST','PROPERTY_STATUS','SYSTEM') DEFAULT 'SYSTEM',
    is_read BOOLEAN DEFAULT FALSE,
    link VARCHAR(300),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_read (user_id, is_read)
);

-- 9. password_reset_tokens
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL UNIQUE,
    token VARCHAR(255) NOT NULL UNIQUE,
    expiry_date TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 10. email_verifications
CREATE TABLE IF NOT EXISTS email_verifications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL UNIQUE,
    token VARCHAR(255) NOT NULL UNIQUE,
    expiry_date TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 11. price_history
CREATE TABLE IF NOT EXISTS price_history (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    property_id BIGINT NOT NULL,
    old_price DECIMAL(15,2) NOT NULL,
    new_price DECIMAL(15,2) NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE
);

-- 12. search_logs
CREATE TABLE IF NOT EXISTS search_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT,
    search_city VARCHAR(100),
    search_type VARCHAR(30),
    search_category VARCHAR(10),
    min_price DECIMAL(15,2),
    max_price DECIMAL(15,2),
    result_count INT,
    searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 13. saved_searches
CREATE TABLE IF NOT EXISTS saved_searches (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    search_query VARCHAR(500) NOT NULL,
    filters_json TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 14. subscribers
CREATE TABLE IF NOT EXISTS subscribers (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 15. property_reports
CREATE TABLE IF NOT EXISTS property_reports (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    property_id BIGINT NOT NULL,
    reporter_id BIGINT,
    reason VARCHAR(255) NOT NULL,
    details TEXT,
    status ENUM('PENDING','REVIEWED','RESOLVED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 16. property_bookings
CREATE TABLE IF NOT EXISTS property_bookings (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    property_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    visit_date DATE NOT NULL,
    time_slot VARCHAR(20) NOT NULL,
    visitor_name VARCHAR(100) NOT NULL,
    visitor_phone VARCHAR(15) NOT NULL,
    visitor_email VARCHAR(150) NOT NULL,
    notes TEXT,
    status VARCHAR(20) DEFAULT 'PENDING',
    agent_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_property_id (property_id),
    INDEX idx_user_id (user_id),
    INDEX idx_visit_date (visit_date),
    INDEX idx_status (status)
);

-- 17. blog_posts
CREATE TABLE IF NOT EXISTS blog_posts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    category VARCHAR(100),
    excerpt TEXT,
    content TEXT,
    cover_image VARCHAR(500),
    read_time_minutes INT DEFAULT 0,
    status ENUM('DRAFT','PUBLISHED','ARCHIVED') DEFAULT 'DRAFT',
    author_id BIGINT,
    view_count INT DEFAULT 0,
    published_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL
);
