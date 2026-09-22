# Antigravity prompts — run these in order

Paste one at a time. Wait for each to finish, verify in the browser yourself,
then move to the next. Don't skip ahead even if a prompt looks quick.

---

## 0. Orientation + sanity check (run this first, always)
```
Read NOTES.md in this project root before doing anything else. Then run a full
build/deploy/restart cycle (mvn clean package, copy the WAR to the Tomcat
webapps folder, restart Tomcat per the commands in NOTES.md), open
http://localhost:8080/TenderManagementSystem/ in the browser, and confirm the
login page loads and admin@tms.com / admin123 successfully shows the tender
list. Report back what you see — don't proceed to any new feature yet.
```

---

## 1. Vendor registration
```
Add vendor self-registration, following the exact DAO -> Servlet -> JSP pattern
already used for UserDao/TenderDao, LoginServlet/TenderListServlet, and
tenders.jsp (see NOTES.md for the pattern description).

Requirements:
- A public JSP form (like login.jsp, not behind login) at /register.jsp asking
  for: name, email, password, company name, registration number, phone, address.
- A RegisterServlet that inserts one row into `users` (role=VENDOR,
  status=ACTIVE) and one row into `vendors` (approval_status=PENDING) in the
  same transaction — roll back both if either insert fails.
- Validate server-side: all fields required, email not already in `users`,
  registration number not already in `vendors`.
- On success, redirect to login.jsp with a message that registration is
  pending admin approval. On validation failure, redisplay the form with an
  inline error message (same style as the login.jsp error banner).
- Add a "Register as a vendor" link on login.jsp pointing to /register.jsp.

After implementing, run the full build/deploy/restart cycle and verify by
registering a new vendor account in the browser, then confirm the new row
appears in both `users` and `vendors` tables with PENDING status.
```

---

## 2. Vendor approval queue (admin)
```
Add an admin-only page listing vendors with approval_status = PENDING, with
Approve/Reject buttons, following the existing DAO -> Servlet -> JSP pattern.

Requirements:
- VendorDao with methods: findByApprovalStatus(String status), and
  updateApprovalStatus(int vendorId, String newStatus).
- VendorApprovalServlet: GET shows the pending list (protected — redirect to
  login.jsp if not logged in, and show an access-denied page if userRole isn't
  ADMIN), POST handles the Approve/Reject action from a button per row.
- JSP at WEB-INF/views/vendor-approvals.jsp, styled like tenders.jsp
  (Bootstrap table, badges for status).
- On approve/reject, insert a row into `audit_logs` (action=VENDOR_APPROVED or
  VENDOR_REJECTED, entity_type=VENDOR, entity_id=vendor id, user_id=the admin's
  session userId).
- Add a nav link to this page for logged-in admins (put it in the tenders.jsp
  navbar, shown only when sessionScope.userRole == 'ADMIN').

After implementing, run the full build/deploy/restart cycle. Verify by
approving the vendor you registered in step 1, and confirm approval_status
updates in the `vendors` table and a row appears in `audit_logs`.
```

---

## 3. Tender create/edit (admin)
```
Add tender creation and editing for admins, following the existing pattern.

Requirements:
- Extend TenderDao with: insert(Tender t), update(Tender t), findById(int id).
- TenderFormServlet: GET with no id param shows a blank create form; GET with
  ?id=X pre-fills the form for editing; POST inserts or updates depending on
  whether an id was present. Admin-only (same access check as step 2).
- Form fields: title, description, category, estimated budget, deadline
  (datetime), status (dropdown: DRAFT, PUBLISHED, CLOSED, ARCHIVED).
- Validate: title/description/deadline required, deadline must be in the
  future for new tenders, estimated budget must be a positive number if given.
- JSP at WEB-INF/views/tender-form.jsp, Bootstrap form styling matching the
  rest of the app.
- Add a "Create tender" button on the admin's view of the tender list, and an
  "Edit" link per row when logged in as admin.
- Insert an audit_logs row (action=TENDER_PUBLISHED) specifically when status
  transitions to PUBLISHED.

After implementing, run the full build/deploy/restart cycle. Verify by
creating a new tender as admin, confirm it appears in tenders.jsp once
published, then edit it and confirm the change persists.
```

---

## 4. Tender detail page
```
Add a single-tender detail page, following the existing pattern.

Requirements:
- TenderDetailServlet at /tender?id=X, calls TenderDao.findById, forwards to
  WEB-INF/views/tender-detail.jsp.
- Shows full description, category, estimated budget, publish date, deadline,
  status.
- If logged in as an approved vendor and the tender is PUBLISHED and the
  deadline hasn't passed, show a "Submit bid" button linking to the bid
  submission page (build in step 5 — link it now, the target page doesn't
  need to exist yet).
- If logged in as admin, show a link to the edit form from step 3 and a link
  to the bid comparison screen (build in step 6 — same, link now).
- Update tenders.jsp so each row's title links to this detail page instead of
  being plain text.

After implementing, run the full build/deploy/restart cycle. Verify by
clicking a tender title from the list and confirming the detail page renders
correctly for both an admin and a vendor login.
```

---

## 5. Bid submission (vendor)
```
Add bid submission for vendors, following the existing pattern.

Requirements:
- BidDao with methods: insert(Bid b), findByTenderAndVendor(int tenderId,
  int vendorId), findByVendor(int vendorId).
- BidServlet: GET ?tenderId=X shows the bid form (vendor-only, redirect
  non-vendors); POST inserts the bid.
- Server-side enforce, with clear error messages back on the form if violated:
  - vendor's approval_status must be APPROVED
  - tender must be PUBLISHED and deadline must not have passed
  - vendor must not already have a bid on this tender (check before insert;
    also rely on the DB's UNIQUE(tender_id, vendor_id) constraint as a
    backstop — catch that SQL exception and show a friendly error too)
- Form fields: bid amount, proposal text. New bid status defaults to
  SUBMITTED.
- JSP at WEB-INF/views/bid-form.jsp, Bootstrap styling.
- Insert an audit_logs row (action=BID_SUBMITTED) on success.

After implementing, run the full build/deploy/restart cycle. Verify by
submitting a bid as an approved vendor, confirm it appears in the `bids`
table, then try submitting a second bid on the same tender as the same vendor
and confirm it's rejected with a clear message.
```

---

## 6. My bids / bid history (vendor)
```
Add a page for vendors to see their own bid history, following the existing
pattern.

Requirements:
- Extend BidDao if needed (findByVendor should already exist from step 5).
- MyBidsServlet (vendor-only), forwards to WEB-INF/views/my-bids.jsp.
- Table: tender title, bid amount, submitted date, status (badge-colored:
  SUBMITTED=blue, UNDER_REVIEW=amber, AWARDED=green, REJECTED=red).
- Add a nav link "My bids" shown only when sessionScope.userRole == 'VENDOR'.

After implementing, run the full build/deploy/restart cycle. Verify by
logging in as the vendor from step 5 and confirming the submitted bid shows
up with the correct status.
```

---

## 7. Bid comparison + award screen (admin)
```
Add the admin screen to compare bids on a tender and award the winner,
following the existing pattern.

Requirements:
- Extend BidDao: findByTender(int tenderId), updateStatus(int bidId, String
  status).
- Add ContractAwardDao: insert(ContractAward a).
- BidComparisonServlet at /bids?tenderId=X (admin-only): GET lists all bids
  for that tender sortable by amount/date (simple: just support
  ?sort=amount|date via query param, default to amount ascending), each row
  has a "Select winner" button. POST handles the award action: insert into
  contract_awards, set the winning bid's status to AWARDED, set every other
  bid on that tender to REJECTED, and set the tender's status to CLOSED — all
  in one transaction.
- JSP at WEB-INF/views/bid-comparison.jsp, Bootstrap table with sort links in
  the column headers.
- Insert an audit_logs row (action=CONTRACT_AWARDED) on successful award.
- Prevent awarding twice — if contract_awards already has a row for this
  tender_id, show the existing award info instead of the selection UI.

After implementing, run the full build/deploy/restart cycle. Verify by
awarding the bid submitted in step 5, then confirm: contract_awards has a new
row, the bid's status is AWARDED, the tender's status is CLOSED, and the
vendor's "My bids" page (step 6) now shows AWARDED.
```

---

## 8. Admin dashboard
```
Add an admin dashboard summarizing system activity, following the existing
pattern.

Requirements:
- DashboardServlet (admin-only) at /dashboard, aggregates counts via simple
  COUNT(*) queries (add these as new DAO methods, or a small DashboardDao):
  total vendors, pending vendor approvals, total tenders, published tenders,
  total bids, total contract awards.
- JSP at WEB-INF/views/dashboard.jsp: Bootstrap card grid showing each count,
  plus a small table of the 5 most recently published tenders.
- Make this the default landing page after admin login (update LoginServlet's
  redirect: admins go to /dashboard, vendors go to /tenders).

After implementing, run the full build/deploy/restart cycle. Verify the counts
match what's actually in the database (cross-check one or two numbers
manually in Workbench).
```

---

## 9. Error pages + empty states
```
Add proper error handling and empty-state messaging across the app.

Requirements:
- Custom error pages: WEB-INF/views/error-404.jsp, error-500.jsp,
  access-denied.jsp — Bootstrap-styled, on-brand with the rest of the app, not
  Tomcat's default stack-trace page. Wire these up in web.xml with
  <error-page> entries for 404, 500, and java.lang.Exception.
- Every access-denied redirect currently pointing at login.jsp for a
  wrong-role user should instead forward to access-denied.jsp with a clear
  message, not silently redirect to login.
- Add empty-state messaging (already partially done in tenders.jsp — extend
  the same "No X found" pattern) to: vendor-approvals.jsp (no pending
  vendors), my-bids.jsp (no bids yet), bid-comparison.jsp (no bids on this
  tender yet).

After implementing, run the full build/deploy/restart cycle. Verify by
triggering a 404 (visit a bad URL), and by logging in as a vendor and trying
to visit an admin-only URL directly.
```

---

## 10. Styling consistency pass
```
Do a final visual consistency pass across every JSP in this project.

Requirements:
- Every page shares the same navbar (logo/title, role-appropriate nav links,
  logout) — factor this into a single JSP fragment (e.g.
  WEB-INF/includes/navbar.jsp) and <jsp:include> it everywhere instead of
  duplicating the navbar markup per page.
- Consistent Bootstrap badge colors for every status field across the app
  (tender status, bid status, vendor approval status) — define the mapping
  once in a comment at the top of navbar.jsp or a shared CSS file, and apply
  it consistently.
- Consistent button styles: primary action = btn-primary, destructive
  (reject/delete) = btn-outline-danger, secondary = btn-outline-secondary.
- Add a small custom.css (linked from every page) for anything Bootstrap
  doesn't cover (e.g. reduced badge font size, table row spacing).

After implementing, run the full build/deploy/restart cycle and click through
every page in the app (as both admin and vendor) to confirm nothing looks
inconsistent or broken.
```

---

## After all of the above
Update the checklist in NOTES.md to check off everything completed, and ask
Antigravity to do a final review pass: search the codebase for any remaining
`System.out.println` debug statements, hard-coded test values, or TODO
comments left behind, and clean them up.
