-- =================================================================
-- PROP NEXIUM - IMAGE POPULATION SCRIPT
-- =================================================================

USE propnexium_db;

-- 1. POPULATE USERS (Profile Pictures)
UPDATE users SET profile_picture = 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=250&h=250&auto=format&fit=crop' WHERE id % 4 = 0;
UPDATE users SET profile_picture = 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=250&h=250&auto=format&fit=crop' WHERE id % 4 = 1;
UPDATE users SET profile_picture = 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=250&h=250&auto=format&fit=crop' WHERE id % 4 = 2;
UPDATE users SET profile_picture = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=250&h=250&auto=format&fit=crop' WHERE id % 4 = 3;

-- 2. POPULATE BLOG POSTS (Cover Images)
UPDATE blog_posts SET cover_image = '/uploads/blogs/real_estate_trends.png' WHERE id % 3 = 0;
UPDATE blog_posts SET cover_image = 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?q=80&w=800&auto=format&fit=crop' WHERE id % 3 = 1;
UPDATE blog_posts SET cover_image = 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=800&auto=format&fit=crop' WHERE id % 3 = 2;

-- 3. POPULATE PROPERTIES (Main & Gallery Images)
-- First, insert primary images for properties that have NONE
INSERT INTO property_images (property_id, image_url, is_primary, display_order)
SELECT id, '/uploads/properties/modern_apartment.png', TRUE, 0
FROM properties
WHERE id NOT IN (SELECT property_id FROM property_images);

-- Now spread all existing property image records across the generated high-quality images
UPDATE property_images SET image_url = '/uploads/properties/modern_apartment.png' WHERE id % 4 = 0;
UPDATE property_images SET image_url = '/uploads/properties/luxury_villa.png' WHERE id % 4 = 1;
UPDATE property_images SET image_url = '/uploads/properties/modern_penthouse.png' WHERE id % 4 = 2;
UPDATE property_images SET image_url = '/uploads/properties/suburban_house.png' WHERE id % 4 = 3;
