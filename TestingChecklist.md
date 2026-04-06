# Final Testing Checklist

─── WEEK 12 NEW FEATURES ───

[ ] Book Site Visit button appears on property detail (visible to logged-in users only)
[ ] /properties/{id}/book page loads with property summary
[ ] Date dropdown shows next 14 days excluding Sundays
[ ] Selecting a date → AJAX loads available time slots
[ ] Booked slot disappears from available slots list
[ ] Selecting a slot → slot button turns blue
[ ] Submitting booking form → redirect to /user/bookings
[ ] Booking confirmation email received by user
[ ] New booking notification email received by agent
[ ] /agent/bookings shows pending bookings with Confirm button
[ ] Agent confirms booking → confirmed email sent to user
[ ] /user/bookings shows CONFIRMED status in green
[ ] Cancel booking → status changes to CANCELLED
[ ] Pending count badge shows on agent sidebar

[ ] /mortgage-calculator loads with two-column layout
[ ] Down payment slider updates loan amount in real time
[ ] Interest rate slider updates EMI card instantly
[ ] Tenure slider updates amortization table
[ ] Principal vs Interest doughnut chart renders
[ ] Amortization table shows all years correctly
[ ] Balance reduction line chart shows downward curve
[ ] Eligibility: income entered → eligible/not result shown
[ ] Scenario B comparison shows savings summary
[ ] From property detail page → price pre-filled in calculator

[ ] /blog listing page shows category filter pills
[ ] Category filter shows only posts of that category
[ ] Individual /blog/{slug} post page loads with content
[ ] Related posts section shows 3 relevant posts
[ ] View count increments on post page visit
[ ] Admin /admin/blog shows post list with status badges
[ ] Admin create new post → save as draft works
[ ] Admin publish post → status changes to PUBLISHED
[ ] Blog widget visible on homepage (3 latest posts)

[ ] /area-converter page loads with state dropdown
[ ] State filter shows only relevant units for that state
[ ] Swap button (⇄) exchanges from/to units
[ ] Bulk convert shows value in all filtered units
[ ] Quick reference table shows all 20 units
[ ] Property detail inline area widget converts correctly
[ ] "Full Area Converter →" link works from detail page

─── ALL PREVIOUS FEATURES (regression check) ───

[ ] Homepage loads correctly (hero, stats, cards, blog widget)
[ ] Search with FULLTEXT keyword returns results
[ ] Leaflet map renders on search and detail pages
[ ] PDF download works on property detail
[ ] Comparison bar persists across navigation
[ ] Admin analytics 6 charts render without errors
[ ] Notifications bell polls and updates badge
[ ] Bulk approve/reject works in admin
[ ] Email verification flow complete
[ ] Password reset flow complete
[ ] Newsletter subscribe/unsubscribe works
