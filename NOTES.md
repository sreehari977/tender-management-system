# Project notes — read this before making changes

## What this is
Tender Management System — Java Servlets + JSP + JDBC + MySQL (no framework).
Built and running locally on Windows via Maven + standalone Tomcat.

## Environment paths (all on this machine, outside this project folder)
- **Tomcat home:** `C:\Users\sreeh\OneDrive\Desktop\JAVA PROJECT SETUP\tomcat\apache-tomcat-10.1.59`
- **Deployed WAR location:** `<tomcat home>\webapps\TenderManagementSystem.war`
- **App URL once running:** `http://localhost:8080/TenderManagementSystem/`
- **MySQL:** local instance, database name `tender_db`, user `root`
  (password lives only in `src/main/java/com/tms/util/DBUtil.java` — do not print/log it)

## Build, deploy, restart cycle
Run from the project root (where `pom.xml` lives):
```
mvn clean package
copy "target\TenderManagementSystem.war" "C:\Users\sreeh\OneDrive\Desktop\JAVA PROJECT SETUP\tomcat\apache-tomcat-10.1.59\webapps\"
```
Then restart Tomcat so it picks up the new WAR:
```
cd "C:\Users\sreeh\OneDrive\Desktop\JAVA PROJECT SETUP\tomcat\apache-tomcat-10.1.59\bin"
shutdown.bat
startup.bat
```
Wait ~10 seconds after `startup.bat` before testing in the browser.

## Demo logins (from database/seed.sql)
- Admin: `admin@tms.com` / `admin123`
- Vendor: `vendor1@tms.com` / `vendor123`
- Vendor: `vendor2@tms.com` / `vendor123`

## Stack specifics that matter (don't downgrade these)
- Tomcat 10.1.x = Jakarta EE 10. JSTL must be version **3.0.x**
  (`jakarta.servlet.jsp.jstl-api:3.0.0` + `org.glassfish.web:jakarta.servlet.jsp.jstl:3.0.1`).
  Earlier 2.0.0 jars caused `NoClassDefFoundError` / TLD resolution failures.
- `web.xml` must use the Jakarta EE 10 schema (`https://jakarta.ee/xml/ns/jakartaee`,
  `version="6.0"`) — the older javax/`xmlns.jcp.org` schema caused inconsistent
  taglib resolution on this Tomcat version.
- JSP taglib URI for JSTL core tags is `jakarta.tags.core` (not the old
  `http://java.sun.com/jsp/jstl/core`).
- MySQL connection URL needs `allowPublicKeyRetrieval=true` alongside `useSSL=false`,
  or login throws `Public Key Retrieval is not allowed`.
- `DBUtil.java` force-loads the driver with `Class.forName("com.mysql.cj.jdbc.Driver")`
  in a static block — needed because Tomcat's classloader doesn't always
  auto-register the JDBC driver from `WEB-INF/lib`.

## Existing code pattern — copy this for every new feature
Each feature is a three-file trio, no exceptions:
1. **DAO** (`src/main/java/com/tms/dao/XyzDao.java`) — one method per query, plain
   JDBC with `PreparedStatement`, returns model objects. See `UserDao.java`,
   `TenderDao.java`.
2. **Servlet** (`src/main/java/com/tms/servlet/XyzServlet.java`) — `@WebServlet`
   annotation for routing, reads request params/session, calls the DAO, forwards
   to a JSP via `RequestDispatcher`. See `LoginServlet.java`, `TenderListServlet.java`.
3. **JSP** (`src/main/webapp/WEB-INF/views/xyz.jsp`) — pure display, loops over
   `request` attributes with JSTL (`<c:forEach>`, `<c:if>`), no SQL or business
   logic. See `tenders.jsp`. Views live under `WEB-INF` so they can't be hit
   directly without going through a servlet first.

Models are plain POJOs with getters/setters only (`User.java`, `Tender.java`) —
add one per new entity (`Vendor.java`, `Bid.java`, `ContractAward.java`) as needed.

## Session / access control pattern
Logged-in user info lives in the HTTP session: `userId`, `userName`, `userRole`.
Every protected servlet should start with the same check `TenderListServlet` uses:
```java
HttpSession session = req.getSession(false);
if (session == null || session.getAttribute("userId") == null) {
    resp.sendRedirect("login.jsp");
    return;
}
```
Add a role check (`"ADMIN"` vs `"VENDOR"`) on top of that for admin-only or
vendor-only pages.

## Database
Full schema in `database/schema.sql`, demo data in `database/seed.sql`. Seven
tables: `users`, `vendors`, `tenders`, `bids`, `contract_awards`, `audit_logs`, `notifications`.
Key constraints already enforced at the DB level: one bid per vendor per tender,
one award per tender/per bid. See `ER_DIAGRAM.md` in this same folder for the
full table/column reference.

## Implemented Features (100% Completed & Verified)
- [x] Database connectivity & connection management (`DBUtil.java`)
- [x] Database schema & seed data (`users`, `vendors`, `tenders`, `bids`, `contract_awards`, `audit_logs`, `notifications`)
- [x] User authentication & session management (`LoginServlet.java`, `UserDao.java`, `User.java`, `login.jsp`)
- [x] User logout (`LogoutServlet.java`)
- [x] Vendor registration & modern signup portal (`signup.jsp`, `RegisterServlet.java`, `VendorDao.java`, `Vendor.java`, password match feedback)
- [x] Legacy registration compatibility (`register.jsp` forwarding to `signup.jsp`)
- [x] Vendor approval queue (`VendorApprovalServlet.java`, `VendorDao.java`, `vendor-approvals.jsp`, `AuditLogDao.java`, `AuditLog.java`)
- [x] Tender create/edit form (`TenderFormServlet.java`, `TenderDao.java`, `Tender.java`, `tender-form.jsp`, `tenders.jsp`)
- [x] Tender detail page (`TenderDetailServlet.java`, `VendorDao.java`, `TenderDao.java`, `tender-detail.jsp`, `tenders.jsp`)
- [x] Bid submission form (`BidServlet.java`, `BidDao.java`, `Bid.java`, `bid-form.jsp`, `AuditLogDao.java`)
- [x] My bids / bid history page (`MyBidsServlet.java`, `BidDao.java`, `Bid.java`, `my-bids.jsp`)
- [x] Bid comparison + award screen (`BidComparisonServlet.java`, `ContractAwardDao.java`, `ContractAward.java`, `BidDao.java`, `TenderDao.java`, `bid-comparison.jsp`)
- [x] Admin executive dashboard (`DashboardServlet.java`, `DashboardDao.java`, `dashboard.jsp`)
- [x] Custom error pages (403 `access-denied.jsp`, 404 `error-404.jsp`, 500 `error-500.jsp`, `web.xml`)
- [x] Global UI theme & responsiveness (`custom.css`, `navbar.jsp`, Bootstrap 5.3.3)
- [x] Option 1: File & Document Attachments (`FileUploadUtil.java`, `FileDownloadServlet.java`, MIME validation, 10MB limit, path traversal defense, RBAC download guards)
- [x] Option 2: Search, Category Filtering, Budget Bounds & Pagination (`TenderDao.java`, `TenderListServlet.java`, `tenders.jsp`)
- [x] Option 3: Official Printable Legal Contract Award Certificate (`AwardCertificateServlet.java`, `award-certificate.jsp`, `@media print` CSS)
- [x] Option 4: Real-time In-App Notifications & Audit Trail (`NotificationDao.java`, `NotificationServlet.java`, `notifications.jsp`, `navbar.jsp`, `AuditLogServlet.java`, `audit-logs.jsp`)
- [x] Step 16: Modern AI Copilot & Procurement Intelligence (`AiProcurementService.java`, `AiAssistantServlet.java`, `ai-copilot.jsp`, RFP Summarizer, AI Proposal Drafter, Live 5-Dimension Strength Meter, Commercial Anomaly & Outlier Risk Detector)
- [x] Step 17: Dedicated Vendor Registration & Public Signup Portal (`signup.jsp`, `RegisterServlet.java`, client-side real-time match verification, server-side duplicate & required checks, guest AI assistant integration)

## Remaining feature checklist
- None. All baseline steps, all 4 advanced options, modern AI procurement tools, and public signup portal are 100% complete and verified.

## Verification Status
- **Last Verified:** 2026-09-05 09:56 IST
- **Tomcat Target:** Apache Tomcat 10.1.59 (Standalone, port 8080)
- **Database:** MySQL `tender_db` running locally
- **Step 0 Verified:** Full build/package/deploy cycle, `admin@tms.com` login, and active tenders list rendering.
- **Step 1 Verified:** Vendor self-registration UI (`/register.jsp`), duplicate validations, and transactional persistence in `users` (`VENDOR`) + `vendors` (`PENDING`).
- **Step 2 Verified:**
-   Role-based security on `/vendor-approvals`: redirects unauthenticated requests to `login.jsp`; returns HTTP 403 Forbidden for non-admin users (`vendor1@tms.com`).
-   Admin view (`admin@tms.com`) rendered pending vendor application for `Sharma Constructions Ltd` (`REG-TMS-2005`).
-   Submitted approval via POST; updated `vendors` status to `APPROVED`.
-   Verified audit trail inserted into `audit_logs` (`action = 'VENDOR_APPROVED'`, `entity_type = 'VENDOR'`, `entity_id = 3`, `user_id = 1`).
- **Step 3 Verified:**
-   Role-based security on `/tender-form`: unauthenticated users redirect to `login.jsp`; non-admin users (`vendor1@tms.com`) receive HTTP 403 Forbidden.
-   Server-side validations: verified required fields and future deadline requirement (rejected past date).
-   Created published tender `Solar Panel Installation — Central Hospital` (`id = 3`); verified `audit_logs` record (`action = 'TENDER_PUBLISHED'`).
-   Verified tender pre-filling upon edit (`GET /tender-form?id=3`).
-   Updated tender to `Solar Photovoltaic Grid Installation — Central Hospital` with budget `₹ 4200000.00`; verified persistence in database and live rendering in `/tenders`.
-   Added "+ Create Tender" button and per-row "Edit" buttons in `tenders.jsp` for admins.
- **Step 4 Verified:**
-   `TenderDetailServlet` at `/tender?id=X`: redirects unauthenticated requests to `login.jsp`.
-   Admin login (`admin@tms.com`) at `/tender?id=1`: renders complete tender specifications, status badge, scope of work, and admin action links ("Edit Tender" $\rightarrow$ `tender-form?id=1`, "Compare Bids" $\rightarrow$ `bids?tenderId=1`).
-   Approved vendor login (`vendor1@tms.com`) at `/tender?id=1`: renders "Submit Bid" button linking to `bid?tenderId=1`.
-   Draft/Closed tender check (`/tender?id=4`): displays disabled button `<button disabled>Bidding Not Open</button>` for vendors.
-   Rejected/Pending vendor check (`fraud@example.com`): displays disabled button `<button disabled title="Account awaiting admin approval">Submit Bid (Approval Required)</button>`.
-   Input validation: missing ID, non-integer ID (`invalid_text`), or non-existent ID (`9999`) safely redirects to `tenders`.
-   Converted table row titles in `tenders.jsp` into clickable links.
- **Step 5 Verified:**
-   `BidServlet` at `/bid`: unauthenticated requests redirect to `login.jsp`; admin login receives HTTP 403 Forbidden.
-   Approved vendor (`vendor1@tms.com`) loaded `/bid?tenderId=1`: displays tender summary card, budget variance benchmark, structured proposal template button, and live character counter.
-   Input validation: verified negative amount (`amount = -500`) rejected with *"Bid amount must be a positive number."* and preserved user input.
-   Submitted valid bid: recorded `amount = 2400000.00`, `status = 'SUBMITTED'` in `bids` table.
-   Verified audit trail inserted into `audit_logs` (`action = 'BID_SUBMITTED'`, `entity_type = 'BID'`, `user_id = 2`).
-   Duplicate bid guard: second submission attempt on Tender #1 was rejected with *"You have already submitted a bid for this tender."*.
-   Updated `/tender?id=1` for `vendor1`: renders celebratory flash banner, displays *"Bid On File"* info box, and replaces CTA with disabled button `✓ Bid Already Submitted`.
- **Step 6 Verified:**
-   `MyBidsServlet` at `/my-bids`: redirects unauthenticated requests to `login.jsp`; returns HTTP 403 Forbidden for admin users.
-   Extended `Bid.java` and `BidDao.findByVendor(vendorId)` with tender status and enriched joined columns.
-   Implemented `my-bids.jsp` featuring:
-     Dynamic KPI summary bar: Total Bids, Submitted, Under Review, Awarded Contracts.
-     Status-coded badges (`SUBMITTED`=blue, `UNDER_REVIEW`=amber, `AWARDED`=green, `REJECTED`=red).
-     Tender status badges with links directly to tender detail view.
-     Formatted Indian Rupee currency (`₹ X,XXX.XX`) and formatted datetime stamps (`dd MMM yyyy, hh:mm a`).
-     Modal popup viewing vendor's full proposal text.
-     Zero-state / empty-state card for vendors with no submissions (`vendor2@tms.com`) with CTA to browse active tenders.
-   Navbar updated across `tenders.jsp`, `tender-detail.jsp`, `bid-form.jsp`, and `my-bids.jsp` to display "My Bids" only when `sessionScope.userRole == 'VENDOR'`.
-   Live verification with `vendor1@tms.com` confirmed row for Tender #1 (₹ 2,400,000.00, SUBMITTED badge, proposal modal).
-   Live verification with `vendor2@tms.com` confirmed clean empty state rendering.
- **Step 7 Verified:**
-   `BidComparisonServlet` at `/bids?tenderId=X`: unauthenticated requests redirect to `login.jsp`; non-admin users (`vendor1@tms.com`) receive HTTP 403 Forbidden with branded `access-denied.jsp`.
-   Invalid parameters (`/bids`, `/bids?tenderId=-1`, `/bids?tenderId=abc`, `/bids?tenderId=9999`) safely redirect to `tenders`.
-   Admin view (`admin@tms.com`) rendered bids list with:
-     Procurement rank badges: `L1 (Lowest Bidder)` in green pill badge.
-     Dynamic budget variance calculation (`4.0% below budget` in green).
-     Sorting by price (`?sort=amount`, default) and submission date (`?sort=date`).
-     "View Proposal" modal popup showing technical proposal details.
-     "Select Winner" button opening an award confirmation modal with optional administrative justification notes.
-   Empty state verified: `/bids?tenderId=2` cleanly rendered "No Bids Submitted Yet" zero-state card.
-   Executed contract award POST:
-     Atomic transaction: inserted row into `contract_awards` (tender_id=1, bid_id=1, notes, awarded_by=1), updated winning bid to `AWARDED`, marked competing bids `REJECTED`, updated tender status to `CLOSED`, and recorded immutable audit log (`action = 'CONTRACT_AWARDED'`, `entity_type = 'CONTRACT_AWARD'`).
-     Post/Redirect/Get pattern: redirected to `/bids?tenderId=1&awarded=1`.
-   Locked state & Double-award prevention:
-     `/bids?tenderId=1` displays the official **Contract Award Summary Certificate** with trophy icon, awarded vendor name (`Menon Infra Pvt Ltd`), reg number (`REG-TMS-1001`), final contract amount (`₹ 2,400,000.00`), awarding admin, timestamp, and justification notes.
-     "Select Winner" action buttons are completely removed; bids table is in read-only audit mode.
-     Second POST attempt on `/bids` safely rejected with `alreadyAwarded=1`.
-   Vendor Synchronization verified:
-     `vendor1@tms.com` visited `/my-bids`: Tender #1 status updated to green `AWARDED` badge, and KPI card shows `Awarded Contracts: 1`.
-     Tender #1 status on `/tenders` is now `CLOSED` and filtered out from active bidding.
- **Step 8 Verified:**
-   `DashboardDao` created querying real-time procurement statistics: Total Tenders (4), Published (2), Closed (1), Total Bids (1), Total Awards (1), Total Awarded Value (₹ 2,400,000.00), Total Registered Vendors (4), Pending Approvals (0), and Recently Published Tenders.
-   `DashboardServlet` at `/dashboard`: restricts access strictly to `ADMIN` role; unauthenticated requests redirect to `login.jsp`; vendor requests receive HTTP 403 Forbidden with branded `access-denied.jsp`.
-   `LoginServlet` updated: Admin logins (`admin@tms.com`) auto-redirect to `/dashboard`; Vendor logins (`vendor1@tms.com`) auto-redirect to `/tenders`.
-   `dashboard.jsp` implemented:
-     6 Executive Metric Cards with icons, micro-copy, and dynamic count badges.
-     Quick Actions Toolbar: "+ Create Tender" button and "Review Approvals (X)" button with dynamic badge alerts.
-     Recently Published Tenders Table with formatted Indian Rupee currencies, deadlines, status badges, and action buttons (`View`, `Bids`, `Edit`).
-     Zero-state handling for published tenders table if none published.
-   Live HTTP test: Admin GET `/dashboard` returned HTTP 200 with accurate live data.
- **Step 9 Verified (Custom Error Pages & Resilience):**
-   Upgraded `web.xml` to Jakarta EE 10 (`version="6.0"`).
-   Mapped `<error-page>` elements for 403, 404, 500, and `java.lang.Exception`.
-   `access-denied.jsp` (HTTP 403): Custom shield icon, explanatory reason parameter, current user session info, and navigation links.
-   `error-404.jsp` (HTTP 404): Magnifying glass icon, clean message, return to active tenders CTA.
-   `error-500.jsp` (HTTP 500): Server error page with support contact, avoiding raw stack traces.
-   Live tests:
-     Vendor access to `/dashboard` returned HTTP 403 with `access-denied.jsp`.
-     Non-existent URL `/thispagedoesnotexist` returned HTTP 404 with `error-404.jsp`.
- **Step 10 Verified (Unified Layout, CSS & Navigation):**
-   Created reusable component `WEB-INF/includes/navbar.jsp`:
-     Role-aware brand link: Admins link to `/dashboard`, Vendors and guests link to `/tenders`.
-     Role-aware menu links: Admins see Dashboard, Active Tenders, Vendor Approvals; Vendors see Active Tenders, My Bids.
-     Active menu indicator: Dynamic `active` parameter highlighting current page in navigation.
-     Session indicator: Displays user name, colored role badge (`ADMIN`=blue, `VENDOR`=info), and logout button.
-     Guest links: "Sign In" and "Register as Vendor" buttons when unauthenticated.
-   Created `src/main/webapp/css/custom.css` (HTTP 200 OK verified):
-     Status badge color system (`badge-status-published`, `badge-status-draft`, `badge-status-closed`, `badge-status-submitted`, `badge-status-under-review`, `badge-status-awarded`, `badge-status-rejected`, `badge-status-pending`).
-     Consistent typography, hover transitions, and card elevations (`metric-card:hover`).
-     Award certificate styling (`award-banner`).
-     L1 bidder row highlighting (`table-l1`).
-   Refactored all 12 JSP pages across the application to include `custom.css` and `navbar.jsp`.
-   Root landing page (`/index.jsp`) enhanced to route authenticated Admins to `/dashboard`, authenticated Vendors to `/tenders`, and unauthenticated visitors to `login.jsp`.
- **Edge Case & Resilience Testing Verified:**
-   **Transaction Rollback:** Verified that if a vendor row fails insertion (e.g. duplicate key), the newly created `users` row is rolled back with zero orphaned rows.
-   **Rejection Flow:** Tested vendor rejection (`action=REJECT`); verified `approval_status = 'REJECTED'` and `audit_logs` entry with `action = 'VENDOR_REJECTED'`.
-   **Concurrency & Idempotency Guard:** `updateApprovalStatus` requires `approval_status = 'PENDING'`; duplicate approval/rejection attempts cannot overwrite or generate duplicate audit records.
-   **Dual-Tier Duplicate Bid Defense (Step 5):** Application check via `bidDao.hasVendorBid` combined with database backstop catching MySQL Error 1062 / SQLState 23000 to prevent race-condition double-bids.
-   **Temporal Submission Guard (Step 5):** Re-checks tender deadline on the server at `doPost` time to block late submissions.
-   **Draft Privacy Protection (Step 4):** Direct URL access to `DRAFT` tenders (`/tender?id=4`) by non-admins/vendors is strictly blocked with a redirect to `/tenders`.
-   **ID Boundary & Range Hardening (Step 4 & 7):** Negative, zero (`id=0`, `id=-5`), non-integer (`invalid_text`), and non-existent (`9999`) IDs are sanitized and gracefully redirected.
-   **Date/Time Precision & Relative Countdown (Step 4, 5, 6, 7):** Replaced raw SQL timestamps with formatted dates (`dd MMM yyyy, hh:mm a`) and contextual time-remaining badges.
-   **XSS Immunity:** Dynamic content across all forms and views fully escaped with JSTL `<c:out>`.
-   **Budget Benchmark Analysis (Step 5 & 7):** Real-time client-side and server-side calculation of percentage variance against tender estimated budget.
- **Step 11 Verified (Advanced Option 1: File Uploads & Secure Downloads):**
-   Added `attachment_filename` and `attachment_path` columns to both `tenders` and `bids` tables.
-   Implemented `FileUploadUtil.java` enforcing UUID-prefixed file naming, extension whitelist (`pdf`, `doc`, `docx`, `zip`, `xlsx`, `csv`), 10MB file limit, canonical path resolution, and path-traversal prevention.
-   Updated `TenderFormServlet` with `@MultipartConfig` to accept RFP specification documents during tender creation/editing.
-   Updated `BidServlet` with `@MultipartConfig` to accept technical/commercial proposal attachments during vendor bid submission.
-   Implemented `FileDownloadServlet` at `/download?type=tender|bid&id=X`:
-     Admins have download privileges across all tender specs and bid proposals.
-     Vendors can download all published tender specs.
-     Draft tender specs are restricted to Admins (returns HTTP 403 `access-denied.jsp`).
-     Bid proposal attachments are restricted to the submitting Vendor and Admins; competitor downloads are blocked with HTTP 403 `access-denied.jsp`.
-     Negative or non-integer IDs return HTTP 400 Bad Request; missing files return HTTP 404 Not Found.
- **Step 12 Verified (Advanced Option 2: Search, Category Filtering, Budget Range & Pagination):**
-   Extended `TenderDao` with dynamic SQL query builder: `searchAndFilter(...)`, `countFiltered(...)`, and `getCategories()`.
-   Updated `TenderListServlet` at `/tenders` to parse `q`, `category`, `minBudget`, `maxBudget`, `sort` (`deadline_asc`, `deadline_desc`, `budget_asc`, `budget_desc`, `newest`), and `page`.
-   Updated `tenders.jsp` with responsive collapsible filter card, active filter badges, attachment document icons, and dynamic pagination controls with clean empty-state fallback.
- **Step 13 Verified (Advanced Option 3: Official Printable Legal Contract Award Certificate):**
-   Implemented `AwardCertificateServlet` at `/award-certificate?tenderId=X`.
-   Access strictly restricted to Admins and the winning Vendor. Competing vendors attempting access receive HTTP 403 `access-denied.jsp`.
-   Implemented `WEB-INF/views/award-certificate.jsp`:
-     Formal legal procurement layout with official double border, government emblem styling, procurement reference headers, and watermark.
-     Full procurement metadata (Tender ID, Title, Category, Budget, Winning Bid Amount, Vendor Name, Reg Number, Awarding Officer, Date & Timestamp, Justification Notes).
-     Dual signatory blocks (Procurement Officer and Authorized Contractor Signatory).
-     Integrated `@media print` CSS rules hiding navigation, bell dropdown, and action buttons for print/PDF export.
- **Step 14 Verified (Advanced Option 4: In-App Notifications & Audit Trail):**
-   Created `notifications` database table with foreign key to `users(id)`, title, message, link, read status, and timestamp.
-   Implemented `Notification.java` and `NotificationDao.java` supporting asynchronous user notifications, unread counts, and batch "mark all as read".
-   Implemented `NotificationServlet` at `/notifications` supporting both full JSP list and real-time JSON endpoint (`?format=json`).
-   Integrated live notification broadcast events:
-     Publishing a tender broadcasts instant notification to all approved vendors with direct link to tender.
-     Vendor approval/rejection sends direct notification to the vendor user account.
-     Contract award generates winning notification with certificate link to the winner, and closing notification to competing bidders.
-   Updated `WEB-INF/includes/navbar.jsp` with real-time notification bell dropdown, unread count badge, and automated polling.
-   Implemented `AuditLogServlet` at `/audit-logs` and `audit-logs.jsp` for compliance audit feed with action filtering (`CONTRACT_AWARDED`, `VENDOR_APPROVED`, `TENDER_PUBLISHED`, `BID_SUBMITTED`) and pagination.
- **Step 15 Verified (Codebase Hygiene & Final Review Pass):**
-   Scanned entire codebase with zero `System.out.println` or `System.err.println` occurrences.
-   Zero `printStackTrace()` calls; all exceptions wrapped in `ServletException` or handled gracefully.
-   Zero hardcoded test values or `TODO` comments.
-   Automated 12-test role authorization and edge-case security matrix passed with 100% success rate.
- **Step 16 Verified (Minor Modern AI Tools & Standout Procurement Features):**
-   Implemented `AiProcurementService.java` providing embedded, local NLP heuristics with zero external API dependencies.
-   Created `AiAssistantServlet.java` (`@WebServlet("/api/ai")`) serving JSON for page tours, chat queries, RFP summarization, proposal drafting, strength scoring, and bid risk analytics.
-   Implemented global floating AI Copilot launcher button (`✨ AI Copilot`) in `navbar.jsp` and interactive offcanvas drawer (`ai-copilot.jsp`) present across all pages:
-     Provides automatic contextual page familiarization (Title, Overview, Key Capabilities, Pro Tips, Quick Question pills).
-     Conversational Natural Language Q&A assistant addressing procurement rules, L1 evaluation, submission deadlines, and platform mechanics.
-   Implemented AI RFP Executive Summary & Deliverables Extractor on `tender-detail.jsp`:
-     Synthesizes multi-page RFP scope into an executive summary, extracts 4–5 concrete technical deliverables, assesses project risk level (`LOW`, `MEDIUM`, `HIGH`), and outlines mandatory vendor credentials.
-   Implemented AI Proposal Assistant on `bid-form.jsp`:
-     One-click `✨ AI Auto-Draft Proposal` button generating tailored, comprehensive commercial/technical proposals based on tender title, scope, budget, and contractor name.
-     Live interactive `✨ AI Proposal Quality & Compliance Meter` evaluating proposals in real time across 5 dimensions (Scope Depth, Quality/ISO Standards, Milestones & Timeline, Warranty/DLP, and Budget Realism) with a 0–100% score, grade badge, and actionable improvement feedback.
-   Implemented AI Commercial Evaluation & Anomaly Detector on `bid-comparison.jsp`:
-     Analyzes commercial quotes across bidders, detects abnormally low bids (> 30% below budget, flagging potential execution risk), identifies L1 leader, and provides a one-click auto-fill award justification note.
-   Automated 16-test suite passed with 100% success rate.
- **Step 17 Verified (Vendor Registration & Public Signup Portal):**
-   Designed and implemented dedicated, modern responsive 2-column onboarding portal: `signup.jsp`.
-   Left column showcases platform value propositions (Certified Solicitations, Transparent L1 Evaluation, AI Proposal Assistant, Official Award Certificates) and compliance guidelines.
-   Right column provides structured 2-section registration form:
-     Authorized Representative credentials (Full Name, Corporate Email, Password with real-time dynamic match feedback, and Confirm Password).
-     Enterprise Information (Registered Legal Entity Name, CIN/GST Registration Number, Phone, Registered Address, and Anti-collusion Code of Conduct compliance checkbox).
-   Updated `RegisterServlet.java`:
-     Multi-mapped to both `@WebServlet({"/register", "/signup"})`.
-     Added server-side password confirmation validation (`Passwords do not match.`).
-     Validates all mandatory fields, trims inputs, and preserves form fields on validation errors.
-     Safely inserts user (`users` role `VENDOR`) and vendor profile (`vendors` status `PENDING`).
-     Redirects upon completion to `login.jsp?registered=pending` with confirmation banner.
-   Integrated backward-compatible forward from `register.jsp` to `signup.jsp`.
-   Updated `login.jsp` and `WEB-INF/includes/navbar.jsp` guest links to point directly to `signup.jsp`.
-   Configured public guest access for `AiAssistantServlet.java` (`page_guide` and `chat`), including dedicated signup page guide and onboarding prompts in `AiProcurementService.java`.
-   Embedded `ai-copilot.jsp` on `signup.jsp` for instant guest procurement onboarding and assistance.
-   Automated 9-test signup suite and 16-test full regression suite passed with 100% success rate.
- **Step 18 Verified (High-End Enterprise Design System & Live Interactivity Engine):**
-   Designed and integrated a modern enterprise typography system importing Google Fonts `Plus Jakarta Sans` (for bold, crisp headers, stat values, and badges) and `Inter` (for refined data presentation and body typography).
-   Implemented a glassmorphic top navigation bar with backdrop blur (`backdrop-filter: blur(16px)`), subtle translucent slate borders, and an authoritative shield emblem (`🛡️`).
-   Implemented seamless page transition animations (`tmsPageFade`) delivering zero-flash view switches and smooth micro-elevations on all dashboard and tender cards.
-   Engineered a standalone, zero-dependency client-side interactivity engine (`js/tms-live.js`) providing:
-     `TMS.toast(type, message, title)`: Smooth floating toast alert notifications replacing intrusive alert dialogues.
-     `TMS.copy(text, label)`: 1-click clipboard copy utility with automatic feedback toast and fallback support.
-     `TMS.initScrollProgress()`: Real-time top progress bar tracking reading completion across long RFP tenders and tables.
-     `TMS.initNumberCounters()`: Fluid cubic-bezier count-up animation for all KPI summary metrics on page load.
-     `TMS.initCountdowns()`: Live, real-time ticking deadline countdown clocks (Days, Hours, Minutes, Seconds) updating every second with automatic urgency color pulses.
-     `TMS.initLiveTableFilter()`: Instant debounced live table search across all rows with match badge counter (`Found X of Y entries`) and zero delay.
-     `TMS.initCopyButtons()`: Dynamic binding to all `[data-copy]` elements for instant copy chips (Tender reference IDs, CIN registration numbers, GST codes).
-   Enhanced all UI views:
-     `dashboard.jsp`: Animated KPI counters, live instant search filter for recent tenders with match badge counter, copyable reference chips, live deadline countdown tickers.
-     `tenders.jsp`: Quick Category pills (`All`, `Solar & Renewable`, `Infrastructure`, `IT & Software`), instant live search bar, dynamic countdown tickers, and copy chips.
-     `tender-detail.jsp`: Copy chips for Tender ID and procurement reference, live ticking countdown widget, 1-click scope copy button.
-     `bid-form.jsp`: Live proposal word count and reading time ticker, submit button loading spinner animation.
-     `vendor-approvals.jsp`: Live instant filter for pending/approved vendor rows, copyable registration numbers.
-     `my-bids.jsp`: Animated KPI counters, live instant filter for submitted bids, copyable reference chips.
-     `audit-logs.jsp`: Instant search filter across audit events and timestamps.
-     `login.jsp`: Shield emblem header, one-click demo filler buttons (`Admin Demo` & `Vendor Demo`) for instant testing without manual typing.
-     `signup.jsp`: Live password match feedback, clean 2-column layout, instant field validation.
-   Automated 16-test security regression suite and 15-test UI interaction suite passed with 100% success rate (31 total passing tests).
- **Step 19 Verified (Cloud Deployment Readiness & Docker Containerization):**
-   Updated `DBUtil.java` with environment variable / system property dynamic fallbacks (`DB_URL`, `DB_USER`, `DB_PASSWORD`) with default fallbacks to local MySQL.
-   Updated `FileUploadUtil.java` with portable dynamic storage path fallbacks (`TMS_UPLOAD_DIR` or `~/tms-uploads`).
-   Created multi-stage production `Dockerfile` (Maven 3.9 + Eclipse Temurin JDK 17 builder, deploying to Apache Tomcat 10.1 as `ROOT.war`).
-   Created `.dockerignore` for minimal, high-speed container packaging.
-   Created `render.yaml` Infrastructure-as-Code blueprint for 1-click cloud deployment on Render.com or Railway.app.
-   Verified clean `mvn clean package` build in 6.9 seconds and automated endpoint verification (15/15 passed).
- **System Status:** All core features (Steps 0–10), all 4 advanced options (Steps 11–14), AI Procurement features (Step 16), Vendor Signup Portal (Step 17), High-End Live Frontend Interactivity Engine (Step 18), and Cloud Deployment Containerization (Step 19) are 100% complete, fully tested, and running live on Apache Tomcat 10.1.59.

> [!NOTE]
> Do NOT use `mvn tomcat7:run`. It starts an embedded Tomcat 7 instance using the deprecated `javax.servlet` API, causing 404s and class loading incompatibilities with Jakarta EE 10. Always use the standalone Tomcat 10.1.59 in `tomcat/apache-tomcat-10.1.59`.

After finishing any item above, always run the full build/deploy/restart cycle
and verify in the browser before considering it done.



