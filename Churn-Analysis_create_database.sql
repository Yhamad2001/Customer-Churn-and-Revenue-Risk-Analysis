-- ============================================================
-- PROJECT 2: Customer Churn & Revenue Risk Analysis
-- File: create_database.sql
-- Description: Creates and populates all tables.
--              Run this file first before anything else.
-- ============================================================

-- Uncomment these two lines before running:
-- CREATE DATABASE churn_analysis;
-- USE churn_analysis;

-- ============================================================
-- TABLE 1: customers
-- Core customer profile table
-- ============================================================
CREATE TABLE IF NOT EXISTS customers (
    customer_id       INT PRIMARY KEY,
    full_name         VARCHAR(100),
    email             VARCHAR(100),
    signup_date       DATE,
    region            VARCHAR(30),   -- North, South, East, West
    segment           VARCHAR(30),   -- Enterprise, Mid-Market, SMB
    account_manager   VARCHAR(60),
    industry          VARCHAR(40)
);

INSERT INTO customers VALUES
(1001, 'Apex Solutions',       'apex@apexsol.com',       '2021-03-15', 'East',  'Enterprise',  'Dana Reeves',   'Technology'),
(1002, 'BlueStar Retail',      'info@bluestar.com',      '2020-08-20', 'West',  'Mid-Market',  'Marcus Hill',   'Retail'),
(1003, 'CoreHealth Systems',   'core@corehealth.com',    '2022-01-10', 'North', 'Enterprise',  'Dana Reeves',   'Healthcare'),
(1004, 'Delta Logistics',      'ops@deltalog.com',       '2019-11-05', 'South', 'Mid-Market',  'Sarah Lane',    'Logistics'),
(1005, 'Echo Marketing',       'hello@echodmk.com',      '2023-02-28', 'East',  'SMB',         'Marcus Hill',   'Marketing'),
(1006, 'Frontier Finance',     'finance@frontier.com',   '2020-05-14', 'West',  'Enterprise',  'Sarah Lane',    'Finance'),
(1007, 'GreenLeaf Foods',      'ops@greenleaf.com',      '2021-09-03', 'North', 'SMB',         'Dana Reeves',   'Food & Bev'),
(1008, 'Harbor Insurance',     'info@harborins.com',     '2019-06-22', 'East',  'Enterprise',  'Marcus Hill',   'Insurance'),
(1009, 'IronBridge Mfg',       'ops@ironbridge.com',     '2022-07-18', 'South', 'Mid-Market',  'Sarah Lane',    'Manufacturing'),
(1010, 'JetStream Travel',     'ops@jetstream.com',      '2020-12-01', 'West',  'SMB',         'Dana Reeves',   'Travel'),
(1011, 'Keystone Partners',    'hello@keystone.com',     '2021-04-09', 'North', 'Mid-Market',  'Marcus Hill',   'Consulting'),
(1012, 'LightPath Energy',     'ops@lightpath.com',      '2023-05-20', 'East',  'Enterprise',  'Sarah Lane',    'Energy'),
(1013, 'Maple Street Media',   'info@maplestreet.com',   '2019-08-14', 'South', 'SMB',         'Dana Reeves',   'Media'),
(1014, 'Northgate Software',   'ops@northgate.com',      '2022-10-30', 'West',  'Mid-Market',  'Marcus Hill',   'Technology'),
(1015, 'Orion Pharma',         'info@orionpharma.com',   '2020-03-17', 'North', 'Enterprise',  'Sarah Lane',    'Healthcare'),
(1016, 'PineCrest Hotels',     'ops@pinecrest.com',      '2021-11-25', 'East',  'Mid-Market',  'Dana Reeves',   'Hospitality'),
(1017, 'QuickShip Couriers',   'ops@quickship.com',      '2023-01-08', 'South', 'SMB',         'Marcus Hill',   'Logistics'),
(1018, 'RedRock Construction', 'info@redrock.com',       '2019-04-30', 'West',  'Mid-Market',  'Sarah Lane',    'Construction'),
(1019, 'SilverBay Analytics',  'ops@silverbay.com',      '2022-06-12', 'North', 'Enterprise',  'Dana Reeves',   'Technology'),
(1020, 'TrueNorth Consulting', 'info@truenorth.com',     '2020-09-22', 'East',  'SMB',         'Marcus Hill',   'Consulting');

-- ============================================================
-- TABLE 2: subscriptions
-- Monthly subscription records per customer
-- ============================================================
CREATE TABLE IF NOT EXISTS subscriptions (
    subscription_id   INT PRIMARY KEY AUTO_INCREMENT,
    customer_id       INT,
    plan_name         VARCHAR(40),   -- Basic, Professional, Enterprise
    monthly_revenue   DECIMAL(8,2),
    start_date        DATE,
    end_date          DATE,          -- NULL = still active
    status            VARCHAR(20),   -- Active, Churned, Paused
    contract_type     VARCHAR(20),   -- Monthly, Annual
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO subscriptions (customer_id, plan_name, monthly_revenue, start_date, end_date, status, contract_type) VALUES
(1001, 'Enterprise',    4500.00, '2021-03-15', NULL,         'Active',  'Annual'),
(1002, 'Professional',  1200.00, '2020-08-20', '2024-02-20', 'Churned', 'Monthly'),
(1003, 'Enterprise',    5200.00, '2022-01-10', NULL,         'Active',  'Annual'),
(1004, 'Professional',  980.00,  '2019-11-05', '2023-11-05', 'Churned', 'Monthly'),
(1005, 'Basic',         250.00,  '2023-02-28', NULL,         'Active',  'Monthly'),
(1006, 'Enterprise',    6100.00, '2020-05-14', NULL,         'Active',  'Annual'),
(1007, 'Basic',         180.00,  '2021-09-03', '2024-01-03', 'Churned', 'Monthly'),
(1008, 'Enterprise',    7200.00, '2019-06-22', NULL,         'Active',  'Annual'),
(1009, 'Professional',  1450.00, '2022-07-18', NULL,         'Active',  'Monthly'),
(1010, 'Basic',         220.00,  '2020-12-01', '2023-08-01', 'Churned', 'Monthly'),
(1011, 'Professional',  1100.00, '2021-04-09', NULL,         'Active',  'Annual'),
(1012, 'Enterprise',    4800.00, '2023-05-20', NULL,         'Active',  'Annual'),
(1013, 'Basic',         150.00,  '2019-08-14', '2023-05-14', 'Churned', 'Monthly'),
(1014, 'Professional',  1350.00, '2022-10-30', NULL,         'Active',  'Monthly'),
(1015, 'Enterprise',    5500.00, '2020-03-17', NULL,         'Active',  'Annual'),
(1016, 'Professional',  900.00,  '2021-11-25', '2024-03-25', 'Churned', 'Monthly'),
(1017, 'Basic',         200.00,  '2023-01-08', NULL,         'Active',  'Monthly'),
(1018, 'Professional',  1050.00, '2019-04-30', '2023-12-30', 'Churned', 'Monthly'),
(1019, 'Enterprise',    4200.00, '2022-06-12', NULL,         'Active',  'Annual'),
(1020, 'Basic',         175.00,  '2020-09-22', '2023-06-22', 'Churned', 'Monthly');

-- ============================================================
-- TABLE 3: support_tickets
-- Customer support interactions
-- ============================================================
CREATE TABLE IF NOT EXISTS support_tickets (
    ticket_id         INT PRIMARY KEY AUTO_INCREMENT,
    customer_id       INT,
    opened_date       DATE,
    closed_date       DATE,
    category          VARCHAR(40),   -- Billing, Technical, Account, Feature Request
    priority          VARCHAR(20),   -- Low, Medium, High, Critical
    satisfaction_score INT,          -- 1-5, NULL if not rated
    resolved          BOOLEAN,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO support_tickets (customer_id, opened_date, closed_date, category, priority, satisfaction_score, resolved) VALUES
(1001, '2024-01-05', '2024-01-07', 'Technical',       'Medium', 4, TRUE),
(1001, '2024-02-12', '2024-02-14', 'Feature Request', 'Low',    5, TRUE),
(1002, '2023-11-01', '2023-11-08', 'Billing',         'High',   2, TRUE),
(1002, '2024-01-15', '2024-01-20', 'Billing',         'High',   1, TRUE),
(1002, '2024-02-10', '2024-02-11', 'Account',         'Medium', 2, TRUE),
(1003, '2024-01-22', '2024-01-23', 'Technical',       'Low',    5, TRUE),
(1004, '2023-08-14', '2023-08-20', 'Billing',         'High',   2, TRUE),
(1004, '2023-10-05', '2023-10-12', 'Billing',         'Critical',1,TRUE),
(1004, '2023-11-18', '2023-11-25', 'Account',         'High',   2, TRUE),
(1005, '2024-01-30', '2024-02-01', 'Technical',       'Low',    4, TRUE),
(1006, '2024-02-08', '2024-02-09', 'Feature Request', 'Low',    5, TRUE),
(1007, '2023-10-10', '2023-10-18', 'Billing',         'High',   2, TRUE),
(1007, '2023-12-05', '2023-12-10', 'Account',         'Medium', 2, TRUE),
(1008, '2024-01-14', '2024-01-15', 'Technical',       'Medium', 4, TRUE),
(1009, '2024-02-20', '2024-02-22', 'Technical',       'Low',    4, TRUE),
(1010, '2023-05-10', '2023-05-18', 'Billing',         'High',   1, TRUE),
(1010, '2023-07-22', '2023-07-28', 'Account',         'High',   2, TRUE),
(1011, '2024-01-08', '2024-01-09', 'Feature Request', 'Low',    5, TRUE),
(1012, '2024-02-15', '2024-02-16', 'Technical',       'Medium', 4, TRUE),
(1013, '2023-02-20', '2023-02-28', 'Billing',         'Critical',1,TRUE),
(1013, '2023-04-05', '2023-04-10', 'Account',         'High',   2, TRUE),
(1014, '2024-01-25', '2024-01-27', 'Technical',       'Low',    4, TRUE),
(1015, '2024-02-18', '2024-02-19', 'Feature Request', 'Low',    5, TRUE),
(1016, '2024-01-10', '2024-01-18', 'Billing',         'High',   2, TRUE),
(1016, '2024-02-22', '2024-03-01', 'Billing',         'Critical',1,TRUE),
(1016, '2024-03-10', '2024-03-15', 'Account',         'High',   1, TRUE),
(1017, '2024-02-05', '2024-02-06', 'Technical',       'Low',    4, TRUE),
(1018, '2023-09-12', '2023-09-20', 'Billing',         'High',   2, TRUE),
(1018, '2023-11-08', '2023-11-14', 'Billing',         'Critical',1,TRUE),
(1019, '2024-01-20', '2024-01-21', 'Technical',       'Low',    5, TRUE),
(1020, '2023-03-15', '2023-03-22', 'Billing',         'High',   2, TRUE),
(1020, '2023-05-28', '2023-06-04', 'Account',         'Critical',1,TRUE);

-- ============================================================
-- TABLE 4: product_usage
-- Monthly product usage metrics per customer
-- Tracks engagement level over time
-- ============================================================
CREATE TABLE IF NOT EXISTS product_usage (
    usage_id          INT PRIMARY KEY AUTO_INCREMENT,
    customer_id       INT,
    usage_month       DATE,          -- First day of the month
    login_count       INT,
    features_used     INT,           -- Number of distinct features used
    reports_exported  INT,
    api_calls         INT,
    usage_score       DECIMAL(4,1),  -- Composite score 0-100
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO product_usage (customer_id, usage_month, login_count, features_used, reports_exported, api_calls, usage_score) VALUES
-- Active customers — high engagement
(1001, '2024-01-01', 45, 12, 8,  1200, 88.5),
(1001, '2024-02-01', 42, 11, 7,  1150, 85.0),
(1001, '2024-03-01', 48, 13, 9,  1300, 91.0),
(1003, '2024-01-01', 52, 14, 10, 1800, 94.0),
(1003, '2024-02-01', 49, 13, 9,  1750, 91.5),
(1003, '2024-03-01', 55, 15, 11, 1900, 96.0),
(1006, '2024-01-01', 60, 16, 12, 2200, 97.0),
(1006, '2024-02-01', 58, 15, 11, 2100, 95.5),
(1006, '2024-03-01', 62, 16, 13, 2300, 98.0),
(1008, '2024-01-01', 55, 15, 11, 2000, 96.0),
(1008, '2024-02-01', 53, 14, 10, 1950, 93.5),
(1008, '2024-03-01', 57, 15, 12, 2050, 95.0),
-- Churned customers — declining engagement before churn
(1002, '2023-11-01', 12, 4,  2,  200,  28.0),
(1002, '2023-12-01', 8,  3,  1,  120,  18.5),
(1002, '2024-01-01', 4,  2,  0,  50,   10.0),
(1004, '2023-08-01', 10, 4,  1,  180,  24.0),
(1004, '2023-09-01', 6,  2,  1,  90,   15.0),
(1004, '2023-10-01', 3,  1,  0,  30,   8.0),
(1007, '2023-10-01', 8,  3,  1,  100,  20.0),
(1007, '2023-11-01', 5,  2,  0,  60,   12.5),
(1007, '2023-12-01', 2,  1,  0,  20,   6.0),
(1010, '2023-05-01', 9,  3,  1,  140,  22.0),
(1010, '2023-06-01', 5,  2,  0,  80,   13.0),
(1010, '2023-07-01', 2,  1,  0,  25,   7.0),
(1013, '2023-02-01', 7,  3,  1,  110,  19.0),
(1013, '2023-03-01', 4,  2,  0,  55,   11.0),
(1013, '2023-04-01', 1,  1,  0,  15,   4.5),
(1016, '2024-01-01', 11, 4,  1,  160,  25.0),
(1016, '2024-02-01', 6,  2,  0,  80,   14.0),
(1016, '2024-03-01', 2,  1,  0,  20,   6.5),
(1018, '2023-09-01', 8,  3,  1,  120,  21.0),
(1018, '2023-10-01', 4,  2,  0,  60,   11.5),
(1018, '2023-11-01', 1,  1,  0,  10,   4.0),
(1020, '2023-03-01', 6,  3,  1,  90,   18.0),
(1020, '2023-04-01', 3,  1,  0,  40,   9.0),
(1020, '2023-05-01', 1,  1,  0,  10,   3.5),
-- Mid-range active customers
(1005, '2024-01-01', 18, 6,  3,  400,  52.0),
(1005, '2024-02-01', 20, 7,  4,  450,  55.5),
(1005, '2024-03-01', 22, 7,  4,  480,  57.0),
(1009, '2024-01-01', 35, 10, 6,  900,  75.0),
(1009, '2024-02-01', 33, 9,  6,  850,  72.5),
(1009, '2024-03-01', 38, 11, 7,  950,  78.0),
(1011, '2024-01-01', 28, 8,  5,  700,  68.0),
(1011, '2024-02-01', 30, 9,  5,  750,  70.5),
(1011, '2024-03-01', 32, 9,  6,  780,  72.0),
(1012, '2024-01-01', 40, 11, 7,  1100, 82.0),
(1012, '2024-02-01', 38, 10, 7,  1050, 80.0),
(1012, '2024-03-01', 42, 12, 8,  1150, 84.5),
(1014, '2024-01-01', 25, 8,  4,  600,  63.0),
(1014, '2024-02-01', 27, 8,  5,  650,  65.5),
(1014, '2024-03-01', 29, 9,  5,  700,  67.0),
(1015, '2024-01-01', 48, 13, 9,  1600, 90.0),
(1015, '2024-02-01', 46, 12, 8,  1550, 88.5),
(1015, '2024-03-01', 50, 14, 10, 1700, 92.0),
(1017, '2024-01-01', 15, 5,  2,  320,  44.0),
(1017, '2024-02-01', 17, 6,  3,  360,  47.5),
(1017, '2024-03-01', 19, 6,  3,  400,  50.0),
(1019, '2024-01-01', 44, 12, 8,  1400, 87.0),
(1019, '2024-02-01', 42, 11, 7,  1350, 85.0),
(1019, '2024-03-01', 46, 13, 9,  1500, 89.0);
