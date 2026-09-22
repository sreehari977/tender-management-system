-- Run this whole file in MySQL Workbench (or `mysql -u root -p < schema.sql`)
-- Creates the database and all tables for the Tender Management System.

CREATE DATABASE IF NOT EXISTS tender_db;
USE tender_db;

CREATE TABLE users (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(150) NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    password        VARCHAR(255) NOT NULL,
    role            ENUM('ADMIN','VENDOR') NOT NULL,
    status          ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE vendors (
    id                    INT AUTO_INCREMENT PRIMARY KEY,
    user_id               INT NOT NULL UNIQUE,
    company_name          VARCHAR(200) NOT NULL,
    registration_number   VARCHAR(100) NOT NULL UNIQUE,
    phone                 VARCHAR(30),
    address               VARCHAR(500),
    approval_status       ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tenders (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    title               VARCHAR(200) NOT NULL,
    description         TEXT NOT NULL,
    category            VARCHAR(100),
    estimated_budget    DECIMAL(15,2),
    publish_date        TIMESTAMP NULL,
    deadline            TIMESTAMP NOT NULL,
    status              ENUM('DRAFT','PUBLISHED','CLOSED','ARCHIVED') NOT NULL DEFAULT 'DRAFT',
    created_by          INT NOT NULL,
    FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE bids (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    tender_id       INT NOT NULL,
    vendor_id       INT NOT NULL,
    amount          DECIMAL(15,2) NOT NULL,
    proposal_text   TEXT,
    submitted_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status          ENUM('SUBMITTED','UNDER_REVIEW','AWARDED','REJECTED') NOT NULL DEFAULT 'SUBMITTED',
    UNIQUE (tender_id, vendor_id),
    FOREIGN KEY (tender_id) REFERENCES tenders(id) ON DELETE CASCADE,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE contract_awards (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    tender_id       INT NOT NULL UNIQUE,
    bid_id          INT NOT NULL UNIQUE,
    awarded_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes           TEXT,
    awarded_by      INT NOT NULL,
    FOREIGN KEY (tender_id) REFERENCES tenders(id),
    FOREIGN KEY (bid_id) REFERENCES bids(id),
    FOREIGN KEY (awarded_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE audit_logs (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NULL,
    action          VARCHAR(100) NOT NULL,
    entity_type     VARCHAR(50) NOT NULL,
    entity_id       INT NOT NULL,
    timestamp       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    details         TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE notifications (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    title           VARCHAR(200) NOT NULL,
    message         TEXT NOT NULL,
    link            VARCHAR(255),
    is_read         BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
