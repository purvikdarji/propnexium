<%@ page pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
      <nav style="background:#1a73e8; padding:0 30px; display:flex;
            justify-content:space-between; align-items:center; height:60px;
            position:sticky; top:0; z-index:999; box-shadow:0 2px 8px rgba(0,0,0,0.15);">

        <!-- Brand -->
        <a href="/" style="color:white; text-decoration:none; font-size:20px; font-weight:700;
                     letter-spacing:-0.5px;">
          🏠 PropNexium
        </a>

        <!-- Links -->
        <div style="display:flex; align-items:center; gap:20px;">
          <a href="/properties" style="color:rgba(255,255,255,0.9); text-decoration:none;
                                  font-size:14px;">Properties</a>
          <a href="/news" style="color:rgba(255,255,255,0.9); text-decoration:none;
                                  font-size:14px;">📰 News</a>
          <a href="/blog"
             style="color:rgba(255,255,255,0.9);text-decoration:none;font-size:14px;">
            📝 Blog
          </a>
          <a href="/search" style="color:rgba(255,255,255,0.9); text-decoration:none;
                                  font-size:14px;">🔍 Search</a>
          <a href="/calculator" style="color:rgba(255,255,255,0.9); text-decoration:none;
                                  font-size:14px;">🏦 Calculator</a>
          <a href="/tools/area-converter" style="color:rgba(255,255,255,0.9); text-decoration:none;
                                  font-size:14px;">📏 Area Converter</a>

          <sec:authorize access="isAuthenticated()">

            <!-- Role-specific links -->
            <sec:authorize access="hasRole('AGENT')">
              <a href="/agent/dashboard" style="color:rgba(255,255,255,0.9); text-decoration:none;
                                          font-size:14px;">Agent Panel</a>
              <a href="/agent/bookings" style="color:rgba(255,255,255,0.9); text-decoration:none;
                                          font-size:14px;">Manage Visits</a>
            </sec:authorize>
            <sec:authorize access="hasRole('ADMIN')">
              <a href="/admin/dashboard" style="color:rgba(255,255,255,0.9); text-decoration:none;
                                          font-size:14px;">Admin Panel</a>
            </sec:authorize>

            <!-- Notification Bell (real-time polling) -->
            <div style="position:relative;display:inline-block;" id="notifWrapper">
              <button id="notificationBell"
                onclick="toggleNotificationDropdown(event)"
                style="background:transparent;border:none;cursor:pointer;padding:6px 4px;
                       position:relative;line-height:1;font-size:22px;display:flex;
                       align-items:center;">
                🔔
                <span id="notificationBadge"
                  style="display:none;position:absolute;top:0px;right:0px;
                         background:#dc2626;color:white;font-size:10px;
                         font-weight:700;border-radius:50%;width:18px;height:18px;
                         align-items:center;justify-content:center;min-width:18px;">
                  0
                </span>
              </button>

              <!-- Dropdown -->
              <div id="notificationDropdown"
                style="display:none;position:absolute;right:-80px;top:calc(100% + 10px);
                       width:320px;background:white;border:1px solid #e5e7eb;
                       border-radius:10px;box-shadow:0 8px 30px rgba(0,0,0,0.15);
                       z-index:9999;">
                <!-- Header -->
                <div style="display:flex;justify-content:space-between;align-items:center;
                            padding:14px 16px;border-bottom:1px solid #f1f5f9;">
                  <span style="font-weight:700;font-size:14px;color:#1e293b;">Notifications</span>
                  <button onclick="markAllRead()"
                    style="background:transparent;border:none;color:#1a73e8;font-size:12px;
                           cursor:pointer;font-weight:600;">
                    Mark all read
                  </button>
                </div>
                <!-- List -->
                <div id="notificationList" style="max-height:280px;overflow-y:auto;"></div>
                <!-- Footer -->
                <div style="padding:10px 16px;border-top:1px solid #f1f5f9;text-align:center;">
                  <a href="/user/notifications"
                     style="color:#1a73e8;font-size:13px;text-decoration:none;font-weight:600;">
                    View All Notifications
                  </a>
                </div>
              </div>
            </div>


            <!-- User Dropdown -->
            <div style="position:relative;" id="userMenuWrapper">
              <button onclick="toggleUserMenu()" style="background:rgba(255,255,255,0.2); border:1px solid rgba(255,255,255,0.35);
                 color:white; padding:7px 15px; border-radius:20px; cursor:pointer;
                 font-size:14px; display:flex; align-items:center; gap:6px;">
                <span style="font-size:16px;">👤</span>
                <sec:authentication property="principal.fullName" />
                <span>▾</span>
              </button>
              <div id="userMenu" style="display:none; position:absolute; right:0; top:48px; background:white;
                    border-radius:10px; padding:8px 0; min-width:190px;
                    box-shadow:0 8px 25px rgba(0,0,0,0.15); z-index:1000;">
                <a href="/user/dashboard" style="display:flex; align-items:center; gap:10px; padding:11px 18px;
                    color:#333; text-decoration:none; font-size:14px;
                    transition:background 0.15s;" onmouseover="this.style.background='#f5f7ff'"
                  onmouseout="this.style.background='transparent'">
                  📊 Dashboard
                </a>
                <a href="/user/profile" style="display:flex; align-items:center; gap:10px; padding:11px 18px;
                    color:#333; text-decoration:none; font-size:14px;" onmouseover="this.style.background='#f5f7ff'"
                  onmouseout="this.style.background='transparent'">
                  👤 My Profile
                </a>
                <a href="/user/wishlist" style="display:flex; align-items:center; gap:10px; padding:11px 18px;
                    color:#333; text-decoration:none; font-size:14px;" onmouseover="this.style.background='#f5f7ff'"
                  onmouseout="this.style.background='transparent'">
                  ❤️ Wishlist
                </a>
                <a href="/user/inquiries" style="display:flex; align-items:center; gap:10px; padding:11px 18px;
                    color:#333; text-decoration:none; font-size:14px;" onmouseover="this.style.background='#f5f7ff'"
                  onmouseout="this.style.background='transparent'">
                  📬 My Inquiries
                </a>
                <a href="/user/bookings" style="display:flex; align-items:center; gap:10px; padding:11px 18px;
                    color:#333; text-decoration:none; font-size:14px;" onmouseover="this.style.background='#f5f7ff'"
                  onmouseout="this.style.background='transparent'">
                  📅 Scheduled Visits
                </a>
                <hr style="margin:6px 0; border:none; border-top:1px solid #eee;">
                <a href="/auth/logout" style="display:flex; align-items:center; gap:10px; padding:11px 18px;
                    color:#e53935; text-decoration:none; font-size:14px;" onmouseover="this.style.background='#fff5f5'"
                  onmouseout="this.style.background='transparent'">
                  🚪 Sign Out
                </a>
              </div>
            </div>

          </sec:authorize>

          <sec:authorize access="!isAuthenticated()">
            <a href="/auth/login" style="color:white; text-decoration:none; border:1px solid rgba(255,255,255,0.6);
                padding:7px 18px; border-radius:20px; font-size:14px;">
              Sign In
            </a>
            <a href="/auth/register" style="background:white; color:#1a73e8; text-decoration:none;
                padding:7px 18px; border-radius:20px; font-weight:600; font-size:14px;">
              Register
            </a>
          </sec:authorize>
        </div>
      </nav>

      <%@ include file="/WEB-INF/views/common/comparison-bar.jsp" %>

        <script>
          function toggleUserMenu() {
            const menu = document.getElementById('userMenu');
            menu.style.display = (menu.style.display === 'none' || menu.style.display === '')
              ? 'block' : 'none';
          }
          document.addEventListener('click', function (e) {
            const wrapper = document.getElementById('userMenuWrapper');
            if (wrapper && !wrapper.contains(e.target)) {
              document.getElementById('userMenu').style.display = 'none';
            }
          });
        </script>

        <!-- ═══════════════ NOTIFICATION POLLING JS ═══════════════ -->
        <script>
        (function() {
          // ── Helpers ──────────────────────────────────────────────
          function getCsrf() {
            const m = document.querySelector('meta[name="_csrf"]');
            return m ? m.getAttribute('content') : '';
          }

          function updateBadge(count) {
            const badge = document.getElementById('notificationBadge');
            if (!badge) return;
            if (count > 0) {
              badge.style.display = 'flex';
              badge.textContent = count > 99 ? '99+' : count;
            } else {
              badge.style.display = 'none';
            }
          }

          // ── Poll unread count ─────────────────────────────────────
          function pollUnreadCount() {
            fetch('/api/v1/notifications/unread-count', { credentials: 'same-origin' })
              .then(function(r) { return r.ok ? r.json() : null; })
              .then(function(data) { if (data) updateBadge(data.count); })
              .catch(function() {});
          }

          // ── Toggle dropdown ───────────────────────────────────────
          window.toggleNotificationDropdown = function(e) {
            if (e) e.stopPropagation();
            const dd = document.getElementById('notificationDropdown');
            if (!dd) return;
            const visible = dd.style.display === 'block';
            dd.style.display = visible ? 'none' : 'block';
            if (!visible) loadRecentNotifications();
          };

          // ── Load recent ───────────────────────────────────────────
          function loadRecentNotifications() {
            fetch('/api/v1/notifications/recent', { credentials: 'same-origin' })
              .then(function(r) { return r.json(); })
              .then(function(data) {
                const list = document.getElementById('notificationList');
                if (!list) return;
                if (!data.data || !data.data.length) {
                  list.innerHTML = '<div style="padding:24px;text-align:center;color:#94a3b8;font-size:13px;">🔔 No notifications yet</div>';
                  return;
                }
                list.innerHTML = data.data.map(function(n) {
                  return '<div id="notif_' + n.id + '" ' +
                    'style="padding:12px 16px;border-bottom:1px solid #f1f5f9;cursor:pointer;' +
                    'background:' + (n.read ? 'white' : '#eff6ff') + ';" ' +
                    'onclick="markNotifRead(' + n.id + ',\'' + (n.linkUrl || '#') + '\')">' +
                    '<div style="font-size:13px;font-weight:' + (n.read ? '400' : '600') +
                    ';color:#1e293b;margin-bottom:3px;">' + (n.title || '') + '</div>' +
                    '<div style="font-size:12px;color:#94a3b8;">' + (n.message || '') + '</div>' +
                    '</div>';
                }).join('');
              })
              .catch(function() {});
          }

          // ── Mark single as read ───────────────────────────────────
          window.markNotifRead = function(id, url) {
            fetch('/api/v1/notifications/' + id + '/read', {
              method: 'POST', credentials: 'same-origin',
              headers: { 'X-CSRF-TOKEN': getCsrf(), 'Content-Type': 'application/json' }
            }).then(function() {
              const el = document.getElementById('notif_' + id);
              if (el) el.style.background = 'white';
              pollUnreadCount();
              if (url && url !== '#') window.location = url;
            }).catch(function() {});
          };

          // ── Mark all as read ──────────────────────────────────────
          window.markAllRead = function() {
            fetch('/api/v1/notifications/mark-all-read', {
              method: 'POST', credentials: 'same-origin',
              headers: { 'X-CSRF-TOKEN': getCsrf(), 'Content-Type': 'application/json' }
            }).then(function() {
              updateBadge(0);
              loadRecentNotifications();
              const dd = document.getElementById('notificationDropdown');
              if (dd) dd.style.display = 'none';
            }).catch(function() {});
          };

          // ── Close on outside click ────────────────────────────────
          document.addEventListener('click', function(e) {
            const wrapper = document.getElementById('notifWrapper');
            const dd = document.getElementById('notificationDropdown');
            if (wrapper && dd && !wrapper.contains(e.target)) {
              dd.style.display = 'none';
            }
          });

          // ── Start polling ─────────────────────────────────────────
          pollUnreadCount();
          setInterval(pollUnreadCount, 30000);
        })();
        </script>