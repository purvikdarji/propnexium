<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Inquiry Detail – PropNexium</title>
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
                    rel="stylesheet">
                <style>
                    * {
                        box-sizing: border-box;
                        margin: 0;
                        padding: 0
                    }

                    body {
                        font-family: 'Inter', sans-serif;
                        background: #f8fafc;
                        color: #1e293b
                    }

                    a {
                        text-decoration: none
                    }

                    .wrap {
                        display: flex;
                        min-height: 100vh
                    }

                    .main {
                        flex: 1;
                        display: flex;
                        flex-direction: column
                    }

                    .topbar {
                        background: white;
                        padding: 14px 28px;
                        border-bottom: 1px solid #e2e8f0;
                        display: flex;
                        align-items: center;
                        gap: 12px
                    }

                    .topbar .breadcrumb {
                        font-size: 13px;
                        color: #64748b
                    }

                    .topbar .breadcrumb a {
                        color: #1a73e8
                    }

                    .topbar h1 {
                        font-size: 18px;
                        font-weight: 700
                    }

                    .content {
                        padding: 24px 28px
                    }

                    .layout {
                        display: grid;
                        grid-template-columns: 3fr 2fr;
                        gap: 20px;
                        align-items: start
                    }

                    /* Cards */
                    .card {
                        background: white;
                        border-radius: 12px;
                        padding: 22px;
                        box-shadow: 0 1px 8px rgba(0, 0, 0, .07);
                        margin-bottom: 16px
                    }

                    .card h3 {
                        font-size: 15px;
                        font-weight: 700;
                        color: #1e293b;
                        margin-bottom: 16px;
                        padding-bottom: 10px;
                        border-bottom: 1.5px solid #f1f5f9
                    }

                    /* Flash */
                    .flash-ok {
                        background: #dcfce7;
                        color: #166534;
                        border-radius: 8px;
                        padding: 12px 18px;
                        margin-bottom: 16px;
                        font-size: 14px
                    }

                    .flash-err {
                        background: #fee2e2;
                        color: #dc2626;
                        border-radius: 8px;
                        padding: 12px 18px;
                        margin-bottom: 16px;
                        font-size: 14px
                    }

                    /* Inquirer info grid */
                    .info-grid {
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 10px
                    }

                    .info-item label {
                        font-size: 11px;
                        font-weight: 700;
                        text-transform: uppercase;
                        letter-spacing: .5px;
                        color: #94a3b8;
                        display: block;
                        margin-bottom: 3px
                    }

                    .info-item span {
                        font-size: 14px;
                        color: #1e293b
                    }

                    /* Message block */
                    .msg-block {
                        background: #f8fafc;
                        border-left: 4px solid #3b82f6;
                        padding: 15px 18px;
                        border-radius: 0 8px 8px 0;
                        font-size: 14px;
                        line-height: 1.7;
                        color: #374151;
                        word-break: break-word
                    }

                    /* Reply block */
                    .reply-block {
                        background: #f0fdf4;
                        border-left: 4px solid #22c55e;
                        padding: 15px 18px;
                        border-radius: 0 8px 8px 0;
                        font-size: 14px;
                        line-height: 1.7;
                        color: #374151
                    }

                    .reply-header {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        margin-bottom: 10px
                    }

                    .reply-header span {
                        font-weight: 700;
                        color: #16a34a;
                        font-size: 13px
                    }

                    .reply-header .reply-date {
                        font-size: 12px;
                        color: #64748b;
                        font-weight: 400
                    }

                    /* Reply form */
                    .reply-form textarea {
                        width: 100%;
                        padding: 12px 14px;
                        border: 1.5px solid #d1d5db;
                        border-radius: 8px;
                        font-size: 14px;
                        font-family: inherit;
                        resize: vertical;
                        min-height: 110px;
                        outline: none;
                        transition: border-color .18s;
                        line-height: 1.6
                    }

                    .reply-form textarea:focus {
                        border-color: #3b82f6
                    }

                    .form-actions {
                        display: flex;
                        align-items: center;
                        gap: 12px;
                        margin-top: 12px;
                        justify-content: space-between
                    }

                    .btn-reply {
                        padding: 11px 26px;
                        background: linear-gradient(135deg, #1a73e8, #1557b0);
                        color: white;
                        border: none;
                        border-radius: 7px;
                        font-size: 14px;
                        font-weight: 700;
                        cursor: pointer;
                        font-family: inherit
                    }

                    .btn-close {
                        padding: 10px 18px;
                        background: #fee2e2;
                        color: #dc2626;
                        border: none;
                        border-radius: 7px;
                        font-size: 13px;
                        font-weight: 600;
                        cursor: pointer;
                        font-family: inherit
                    }

                    /* Badge */
                    .badge {
                        display: inline-block;
                        padding: 4px 12px;
                        border-radius: 12px;
                        font-size: 12px;
                        font-weight: 700
                    }

                    .badge-PENDING {
                        background: #fef3c7;
                        color: #d97706
                    }

                    .badge-REPLIED {
                        background: #dcfce7;
                        color: #16a34a
                    }

                    .badge-CLOSED {
                        background: #f3f4f6;
                        color: #6b7280
                    }

                    /* Property card */
                    .prop-detail {
                        font-size: 13px;
                        color: #64748b;
                        margin-bottom: 6px;
                        display: flex;
                        align-items: center;
                        gap: 6px
                    }

                    .prop-price {
                        font-size: 20px;
                        font-weight: 800;
                        color: #1a73e8;
                        margin-bottom: 12px
                    }

                    .btn-view-prop {
                        display: block;
                        width: 100%;
                        padding: 10px;
                        background: #1a73e8;
                        color: white;
                        border-radius: 7px;
                        text-align: center;
                        font-size: 14px;
                        font-weight: 600
                    }

                    /* Timeline */
                    .timeline {
                        display: flex;
                        flex-direction: column;
                        gap: 0
                    }

                    .tl-item {
                        display: flex;
                        align-items: flex-start;
                        gap: 14px;
                        padding: 10px 0;
                        position: relative
                    }

                    .tl-item:not(:last-child)::after {
                        content: '';
                        position: absolute;
                        left: 10px;
                        top: 32px;
                        width: 2px;
                        bottom: -10px;
                        background: #e2e8f0
                    }

                    .tl-dot {
                        width: 22px;
                        height: 22px;
                        border-radius: 50%;
                        flex-shrink: 0;
                        margin-top: 2px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 11px;
                        font-weight: 700
                    }

                    .tl-dot.done {
                        background: #dcfce7;
                        color: #16a34a
                    }

                    .tl-dot.pending {
                        background: #fef3c7;
                        color: #d97706
                    }

                    .tl-dot.grey {
                        background: #f1f5f9;
                        color: #94a3b8
                    }

                    .tl-content .tl-label {
                        font-size: 13px;
                        font-weight: 600;
                        color: #1e293b
                    }

                    .tl-content .tl-date {
                        font-size: 11px;
                        color: #94a3b8;
                        margin-top: 2px
                    }
                </style>
            </head>

            <body>
                <div class="wrap">
                    <%@ include file="/WEB-INF/views/agent/sidebar.jsp" %>

                        <div class="main">
                            <!-- Topbar -->
                            <div class="topbar">
                                <div>
                                    <div class="breadcrumb">
                                        <a href="/agent/inquiries">Inquiries</a> &rsaquo; ${inquiry.inquirerName}
                                    </div>
                                    <h1>Inquiry from ${inquiry.inquirerName}</h1>
                                </div>
                                <span class="badge badge-${inquiry.status}"
                                    style="margin-left:auto">${inquiry.status}</span>
                            </div>

                            <div class="content">
                                <c:if test="${not empty successMessage}">
                                    <div class="flash-ok">&#10003; ${successMessage}</div>
                                </c:if>
                                <c:if test="${not empty errorMessage}">
                                    <div class="flash-err">&#9888; ${errorMessage}</div>
                                </c:if>

                                <div class="layout">
                                    <!-- LEFT COLUMN -->
                                    <div>
                                        <!-- Inquirer Info -->
                                        <div class="card">
                                            <h3>&#128100; Inquirer Information</h3>
                                            <div class="info-grid">
                                                <div class="info-item">
                                                    <label>Full Name</label>
                                                    <span>${inquiry.inquirerName}</span>
                                                </div>
                                                <div class="info-item">
                                                    <label>Email</label>
                                                    <span><a href="mailto:${inquiry.inquirerEmail}"
                                                            style="color:#1a73e8">${inquiry.inquirerEmail}</a></span>
                                                </div>
                                                <div class="info-item">
                                                    <label>Phone</label>
                                                    <span>${not empty inquiry.inquirerPhone ? inquiry.inquirerPhone :
                                                        '—'}</span>
                                                </div>
                                                <div class="info-item">
                                                    <label>Submitted</label>
                                                    <span>${inquiry.createdAt.dayOfMonth}/${inquiry.createdAt.monthValue}/${inquiry.createdAt.year}</span>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Original Message -->
                                        <div class="card">
                                            <h3>&#128172; Original Message</h3>
                                            <div class="msg-block">${inquiry.message}</div>
                                        </div>

                                        <!-- Agent Reply (if exists) -->
                                        <c:if test="${not empty inquiry.agentReply}">
                                            <div class="card">
                                                <h3>&#10084; Your Reply</h3>
                                                <div class="reply-block">
                                                    <div class="reply-header">
                                                        <span>&#10003; Agent Reply</span>
                                                        <span class="reply-date">
                                                            Sent on
                                                            ${inquiry.repliedAt.dayOfMonth}/${inquiry.repliedAt.monthValue}/${inquiry.repliedAt.year}
                                                        </span>
                                                    </div>
                                                    ${inquiry.agentReply}
                                                </div>
                                            </div>
                                        </c:if>

                                        <!-- Reply Form (not shown if CLOSED) -->
                                        <c:if test="${inquiry.status != 'CLOSED'}">
                                            <div class="card">
                                                <h3>${not empty inquiry.agentReply ? '&#9998; Update Reply' : '&#128394;
                                                    Write Reply'}</h3>
                                                <form action="/agent/inquiries/${inquiry.id}/reply" method="POST"
                                                    class="reply-form">
                                                    <input type="hidden" name="${_csrf.parameterName}"
                                                        value="${_csrf.token}" />
                                                    <textarea name="replyText" id="replyText"
                                                        placeholder="Type your reply to ${inquiry.inquirerName}…&#10;The inquirer will be notified by email.">${not empty inquiry.agentReply ? inquiry.agentReply : ''}</textarea>
                                                    <div class="form-actions">
                                                        <c:if test="${inquiry.status != 'CLOSED'}">
                                                            <form action="/agent/inquiries/${inquiry.id}/close"
                                                                method="POST" style="margin:0">
                                                                <input type="hidden" name="${_csrf.parameterName}"
                                                                    value="${_csrf.token}" />
                                                                <button type="submit" class="btn-close"
                                                                    onclick="return confirm('Mark this inquiry as Closed?')">
                                                                    &#128274; Close Inquiry
                                                                </button>
                                                            </form>
                                                        </c:if>
                                                        <button type="submit" class="btn-reply">
                                                            &#9993; Send Reply
                                                        </button>
                                                    </div>
                                                </form>
                                            </div>
                                        </c:if>

                                        <c:if test="${inquiry.status == 'CLOSED'}">
                                            <div
                                                style="background:#f3f4f6;border-radius:10px;padding:16px 20px;text-align:center;color:#6b7280;font-size:14px;">
                                                &#128274; This inquiry is closed. No further replies can be sent.
                                            </div>
                                        </c:if>
                                    </div>

                                    <!-- RIGHT COLUMN -->
                                    <div>
                                        <!-- Property Card -->
                                        <div class="card">
                                            <h3>&#127968; Property</h3>
                                            <div style="font-size:15px;font-weight:700;color:#1e293b;margin-bottom:8px">
                                                ${property.title}</div>
                                            <div class="prop-price">&#8377;
                                                <fmt:formatNumber value="${property.price}" type="number"
                                                    maxFractionDigits="0" />
                                            </div>
                                            <div class="prop-detail">&#128205; ${property.city}<c:if
                                                    test="${not empty property.state}">, ${property.state}</c:if>
                                            </div>
                                            <div class="prop-detail">&#127968; ${property.type} &bull;
                                                ${property.category}</div>
                                            <c:if test="${not empty property.areaSqft}">
                                                <div class="prop-detail">&#128222; ${property.areaSqft} sqft</div>
                                            </c:if>
                                            <div style="margin-top:14px">
                                                <a href="/properties/${property.id}" class="btn-view-prop"
                                                    target="_blank">
                                                    View Property &#8599;
                                                </a>
                                            </div>
                                        </div>

                                        <!-- Status Timeline -->
                                        <div class="card">
                                            <h3>&#128336; Timeline</h3>
                                            <div class="timeline">
                                                <!-- Inquiry Received -->
                                                <div class="tl-item">
                                                    <div class="tl-dot done">&#10003;</div>
                                                    <div class="tl-content">
                                                        <div class="tl-label">Inquiry Received</div>
                                                        <div class="tl-date">
                                                            ${inquiry.createdAt.dayOfMonth}/${inquiry.createdAt.monthValue}/${inquiry.createdAt.year}
                                                            at ${inquiry.createdAt.hour}:${String.format("%02d",
                                                            inquiry.createdAt.minute)}</div>
                                                    </div>
                                                </div>

                                                <!-- Reply Sent -->
                                                <div class="tl-item">
                                                    <c:choose>
                                                        <c:when test="${not empty inquiry.repliedAt}">
                                                            <div class="tl-dot done">&#10003;</div>
                                                            <div class="tl-content">
                                                                <div class="tl-label">Reply Sent</div>
                                                                <div class="tl-date">
                                                                    ${inquiry.repliedAt.dayOfMonth}/${inquiry.repliedAt.monthValue}/${inquiry.repliedAt.year}
                                                                </div>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="tl-dot pending">&#8230;</div>
                                                            <div class="tl-content">
                                                                <div class="tl-label" style="color:#94a3b8">Reply
                                                                    Pending</div>
                                                                <div class="tl-date">Not replied yet</div>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>

                                                <!-- Closed -->
                                                <div class="tl-item">
                                                    <c:choose>
                                                        <c:when test="${inquiry.status == 'CLOSED'}">
                                                            <div class="tl-dot done">&#128274;</div>
                                                            <div class="tl-content">
                                                                <div class="tl-label">Inquiry Closed</div>
                                                                <div class="tl-date">Closed by agent</div>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="tl-dot grey">&#9711;</div>
                                                            <div class="tl-content">
                                                                <div class="tl-label" style="color:#94a3b8">Not Closed
                                                                </div>
                                                                <div class="tl-date">Still open</div>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Quick actions -->
                                        <div style="display:flex;gap:10px">
                                            <a href="mailto:${inquiry.inquirerEmail}" style="flex:1;display:block;padding:10px;background:white;border-radius:8px;
                      text-align:center;font-size:13px;font-weight:600;color:#1a73e8;
                      box-shadow:0 1px 6px rgba(0,0,0,0.07)">
                                                &#128231; Send Email
                                            </a>
                                            <c:if test="${not empty inquiry.inquirerPhone}">
                                                <a href="tel:${inquiry.inquirerPhone}" style="flex:1;display:block;padding:10px;background:white;border-radius:8px;
                        text-align:center;font-size:13px;font-weight:600;color:#16a34a;
                        box-shadow:0 1px 6px rgba(0,0,0,0.07)">
                                                    &#128241; Call
                                                </a>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                </div>
            </body>

            </html>