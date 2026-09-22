# Tender Management System — Entity Relationship (ER) Specification

## 1. High-Level Entity Relationship Diagram

`mermaid
erDiagram
    USERS ||--o| VENDORS : extends (user_id)
    USERS ||--o{ TENDERS : creates (created_by)
    USERS ||--o{ CONTRACT_AWARDS : awards (awarded_by)
    USERS ||--o{ AUDIT_LOGS : acts (user_id)
    USERS ||--o{ NOTIFICATIONS : receives (user_id)

    VENDORS ||--o{ BIDS : submits (vendor_id)
    TENDERS ||--o{ BIDS : receives (tender_id)
    
    TENDERS ||--o| CONTRACT_AWARDS : finalized by (tender_id)
    BIDS ||--o| CONTRACT_AWARDS : winning bid (bid_id)

    USERS {
        int id PK
        string name
        string email UK
        string password
        enum role ADMIN, VENDOR
        enum status ACTIVE, INACTIVE
        timestamp created_at
    }

    VENDORS {
        int id PK
        int user_id FK,UK
        string company_name
        string registration_number UK
        string phone
        string address
        enum approval_status PENDING, APPROVED, REJECTED
    }

    TENDERS {
        int id PK
        string title
        text description
        string category
        decimal estimated_budget
        timestamp publish_date
        timestamp deadline
        enum status DRAFT, PUBLISHED, CLOSED, ARCHIVED
        int created_by FK
    }

    BIDS {
        int id PK
        int tender_id FK
        int vendor_id FK
        decimal amount
        text proposal_text
        timestamp submitted_at
        enum status SUBMITTED, UNDER_REVIEW, AWARDED, REJECTED
    }

    CONTRACT_AWARDS {
        int id PK
        int tender_id FK,UK
        int bid_id FK,UK
        timestamp awarded_at
        text notes
        int awarded_by FK
    }

    AUDIT_LOGS {
        int id PK
        int user_id FK
        string action
        string entity_type
        int entity_id
        timestamp timestamp
        text details
    }

    NOTIFICATIONS {
        int id PK
        int user_id FK
        string title
        text message
        string link
        boolean is_read
        timestamp created_at
    }
`

---

## 2. Table Data Dictionaries & Constraints

### 1. users
Master identity table holding user credentials and security clearance roles.
- id (INT, Primary Key, Auto Increment)
- 
ame (VARCHAR(150), Not Null): Full name of authorized individual.
- email (VARCHAR(150), Not Null, Unique): Login credential.
- password (VARCHAR(255), Not Null): Plain text password for demo, easily hashable for production.
- ole (ENUM('ADMIN', 'VENDOR'), Not Null): Access control tier.
- status (ENUM('ACTIVE', 'INACTIVE'), Default 'ACTIVE'): Account state.
- created_at (TIMESTAMP, Default CURRENT_TIMESTAMP)

### 2. endors
Commercial contractor entity profiles associated with user accounts.
- id (INT, Primary Key, Auto Increment)
- user_id (INT, Not Null, Unique, FK -> users.id ON DELETE CASCADE): 1-to-1 relationship.
- company_name (VARCHAR(200), Not Null): Registered legal corporate name.
- egistration_number (VARCHAR(100), Not Null, Unique): CIN, GST, or government registry identifier.
- phone (VARCHAR(30)): Official contact phone.
- ddress (VARCHAR(500)): Official physical/registered address.
- pproval_status (ENUM('PENDING', 'APPROVED', 'REJECTED'), Default 'PENDING'): Bidding gatekeeper flag. Only APPROVED vendors can lodge commercial bids.

### 3. 	enders
Procurement solicitations and Requests for Proposals (RFPs).
- id (INT, Primary Key, Auto Increment)
- 	itle (VARCHAR(200), Not Null): Title of the procurement scope.
- description (TEXT, Not Null): Detailed scope of work, requirements, deliverables.
- category (VARCHAR(100)): Industry sector (e.g. Infrastructure, IT, Telecommunications).
- estimated_budget (DECIMAL(15,2)): Sanctioned commercial allocation in INR.
- publish_date (TIMESTAMP, Nullable): Date when tender moved to PUBLISHED.
- deadline (TIMESTAMP, Not Null): Temporal cutoff point for bid lodging.
- status (ENUM('DRAFT', 'PUBLISHED', 'CLOSED', 'ARCHIVED'), Default 'DRAFT'): Lifecycle stage.
- created_by (INT, Not Null, FK -> users.id): Administrator who authored the tender.

### 4. ids
Sealed commercial bids and technical execution proposals lodged by vendors.
- id (INT, Primary Key, Auto Increment)
- 	ender_id (INT, Not Null, FK -> 	enders.id ON DELETE CASCADE)
- endor_id (INT, Not Null, FK -> endors.id ON DELETE CASCADE)
- mount (DECIMAL(15,2), Not Null): Commercial quote in INR.
- proposal_text (TEXT): Technical execution methodology, delivery schedules, compliance statements.
- submitted_at (TIMESTAMP, Default CURRENT_TIMESTAMP)
- status (ENUM('SUBMITTED', 'UNDER_REVIEW', 'AWARDED', 'REJECTED'), Default 'SUBMITTED')
- **Constraint**: UNIQUE (tender_id, vendor_id) — Enforces the strict **One-Bid Rule** per contractor per tender.

### 5. contract_awards
Legal contract awards finalized by the procurement evaluation committee.
- id (INT, Primary Key, Auto Increment)
- 	ender_id (INT, Not Null, Unique, FK -> 	enders.id): 1-to-1 relationship with tender.
- id_id (INT, Not Null, Unique, FK -> ids.id): 1-to-1 relationship with winning bid.
- warded_at (TIMESTAMP, Default CURRENT_TIMESTAMP): Timestamp of award finalization.
- 
otes (TEXT): Committee justification notes (often auto-generated by AI evaluation assistant).
- warded_by (INT, Not Null, FK -> users.id): Administrator who confirmed the award.

### 6. udit_logs
Statutory compliance trail recording mission-critical procurement events.
- id (INT, Primary Key, Auto Increment)
- user_id (INT, Nullable, FK -> users.id ON DELETE SET NULL): Actor user ID.
- ction (VARCHAR(100), Not Null): e.g. TENDER_PUBLISHED, VENDOR_APPROVED, BID_SUBMITTED, CONTRACT_AWARDED.
- entity_type (VARCHAR(50), Not Null): e.g. TENDER, VENDOR, BID, CONTRACT_AWARD.
- entity_id (INT, Not Null): Foreign ID of affected entity.
- 	imestamp (TIMESTAMP, Default CURRENT_TIMESTAMP): Immutable event record.
- details (TEXT): Contextual parameters or human-readable summary.

### 7. 
otifications
Real-time in-app notification alerts delivered to users.
- id (INT, Primary Key, Auto Increment)
- user_id (INT, Not Null, FK -> users.id ON DELETE CASCADE): Recipient account.
- 	itle (VARCHAR(200), Not Null): Short notification header.
- message (TEXT, Not Null): Detailed body text.
- link (VARCHAR(255)): Relative navigation URL (e.g. /tender?id=5, /my-bids).
- is_read (BOOLEAN, Default FALSE): Unread tracking flag.
- created_at (TIMESTAMP, Default CURRENT_TIMESTAMP)
