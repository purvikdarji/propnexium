# PropNexium 🏠
> Full-stack Real Estate Platform — Java Spring Boot Internship Project

![Java 17](https://img.shields.io/badge/Java-17-orange)
![Spring Boot 3](https://img.shields.io/badge/Spring%20Boot-3.4-brightgreen)
![MySQL 8](https://img.shields.io/badge/MySQL-8.0-blue)
![Docker](https://img.shields.io/badge/Docker-Multi--Stage-blueviolet)

## Features

**For Buyers / Users:**
- Advanced property search with FULLTEXT and filters
- Interactive Leaflet map with location pins
- EMI & Mortgage Eligibility Calculator
- Indian Area Unit Converter (20 units)
- Book Site Visits with slot management
- PDF downloads for property brochures
- Wishlists and Saved Searches

**For Agents:**
- Agent Dashboard with analytics
- Property listing management
- Site visit booking management (Confirm/Cancel)
- Inquiry handling

**For Admins:**
- Analytics Dashboard with 6 charts
- User & Agent management
- Bulk approve/reject properties
- Real Estate Blog content management (CRUD)

**Platform:**
- Multi-role authentication (Admin, Agent, User)
- Email verification & Password reset
- Newsletter subscriptions
- Responsive UI (JSP + Bootstrap/Tailwind)

## Tech Stack
| Tier | Technology |
|---|---|
| Language | Java 17 |
| Framework | Spring Boot 3.2 |
| Security | Spring Security |
| Database | MySQL 8.0 |
| ORM | Spring Data JPA / Hibernate |
| View Templates | JSP (JavaServer Pages) |
| Containerization| Docker & Docker Compose|
| Maps | Leaflet.js |
| Charts | Chart.js |
| Email | Spring Boot Mail |
| Build Tool | Maven |

## Default Accounts
| Role  | Email                | Password  |
|-------|----------------------|-----------|
| Admin | admin@propnexium.com | Admin@123 |
| Agent | rahul@propnexium.com | Agent@123 |
| Agent | priya@propnexium.com | Agent@123 |
| User  | amit@gmail.com       | User@123  |

## Setup

**1. Using Docker Compose (Recommended)**
```bash
docker-compose up -d --build
```
Access at `http://localhost:8080`.

**2. Local Maven setup**
```bash
mvn clean install
java -jar target/propnexium-final-1.0.0.jar
```
Ensure you set up `application-local.properties` or environment variables for DB access.

## Package Structure
- `com.propnexium.controller` - MVC Controllers
- `com.propnexium.entity` - JPA Entities
- `com.propnexium.repository` - Spring Data Repositories
- `com.propnexium.service` - Business Logic
- `com.propnexium.config` - Security & App Config
- `com.propnexium.dto` - Data Transfer Objects

## Database Schema
1. users
2. properties
3. property_images
4. amenities / property_amenities
5. inquiries
6. wishlists
7. notifications
8. password_reset_tokens
9. email_verifications
10. price_history
11. search_logs
12. saved_searches
13. subscribers
14. property_reports
15. property_bookings
16. blog_posts
17. agent_profiles & reviews

## License
MIT License
