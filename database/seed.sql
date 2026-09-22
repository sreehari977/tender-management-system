-- Run after schema.sql. Passwords are PLAIN TEXT here on purpose,
-- to keep the starter simple — see README "About password security".
USE tender_db;

INSERT INTO users (name, email, password, role, status) VALUES
('System Administrator', 'admin@tms.com',   'admin123',  'ADMIN',  'ACTIVE'),
('Rahul Menon',           'vendor1@tms.com', 'vendor123', 'VENDOR', 'ACTIVE'),
('Priya Nair',             'vendor2@tms.com', 'vendor123', 'VENDOR', 'ACTIVE');

INSERT INTO vendors (user_id, company_name, registration_number, phone, address, approval_status) VALUES
(2, 'Menon Infra Pvt Ltd', 'REG-TMS-1001', '+91-9876543210', 'Kochi, Kerala', 'APPROVED'),
(3, 'Nair Builders & Co',  'REG-TMS-1002', '+91-9876500000', 'Thiruvananthapuram, Kerala', 'APPROVED');

INSERT INTO tenders (title, description, category, estimated_budget, publish_date, deadline, status, created_by) VALUES
('Municipal Road Resurfacing — Ward 12',
 'Resurfacing of 3.2km stretch of municipal road including drainage repair.',
 'Civil Works', 2500000.00, NOW(), DATE_ADD(NOW(), INTERVAL 14 DAY), 'PUBLISHED', 1),
('Office IT Infrastructure Upgrade',
 'Supply and installation of networking equipment, 50 workstations, and server room cooling.',
 'IT Procurement', 1200000.00, NOW(), DATE_ADD(NOW(), INTERVAL 21 DAY), 'PUBLISHED', 1);
