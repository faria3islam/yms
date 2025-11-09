SET search_path = public;
CREATE SCHEMA IF NOT EXISTS public;

CREATE TABLE IF NOT EXISTS city (
    city_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    province VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS category (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS users (
    users_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    whatsapp VARCHAR(50),
    role VARCHAR(50) CHECK (role IN ('ADMIN', 'TREASURER')),
    password_hash TEXT NOT NULL,
    city_id INT REFERENCES city(city_id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT TRUE,
    invited_at TIMESTAMP,
    last_login TIMESTAMP
);

CREATE TABLE IF NOT EXISTS budget_request (
    request_id SERIAL PRIMARY KEY,
    city_id INT REFERENCES city(city_id) ON DELETE RESTRICT,
    requester_id INT REFERENCES users(users_id) ON DELETE SET NULL,
    recipient_id INT REFERENCES users(users_id) ON DELETE SET NULL,
    month VARCHAR(20) NOT NULL,
    description TEXT,
    status VARCHAR(10) CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS requested_event (
    req_event_id SERIAL PRIMARY KEY,
    request_id INT REFERENCES budget_request(request_id),
    name VARCHAR(100),
    event_date DATE,
    total_amount NUMERIC(10, 2),
    notes TEXT
);

CREATE TABLE IF NOT EXISTS requested_break_down_line (
    line_id SERIAL PRIMARY KEY,
    req_event_id INT REFERENCES requested_event(req_event_id),
    category_id INT REFERENCES category(category_id),
    description TEXT,
    amount NUMERIC(10, 2)
);

CREATE TABLE IF NOT EXISTS approval (
    approval_id SERIAL PRIMARY KEY,
    request_id INT REFERENCES budget_request(request_id),
    approver_id INT REFERENCES users(users_id),
    decision VARCHAR(20) CHECK (decision IN ('YES', 'NO-PLEASE RESEND')),
    note TEXT,
    decided_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS event (
    event_id SERIAL PRIMARY KEY,
    city_id INT REFERENCES city(city_id),
    name VARCHAR(50),
    event_date DATE,
    attendees_count INT NOT NULL,
    prepared_by INT REFERENCES users(users_id)
);

-- Fixed: define event_id and category_id columns before referencing them
CREATE TABLE IF NOT EXISTS expense (
    expense_id SERIAL PRIMARY KEY,
    event_id INT REFERENCES event(event_id) ON DELETE SET NULL,
    category_id INT REFERENCES category(category_id) ON DELETE SET NULL,
    vendor VARCHAR(100) NOT NULL,
    item_desc VARCHAR(100) NOT NULL,
    amount_before_tax NUMERIC(10, 2) NOT NULL,
    hst NUMERIC(10, 2) NOT NULL,
    round_off NUMERIC(10, 2),
    total_amount NUMERIC(10, 2) NOT NULL,
    receipt_number INTEGER,
    spent_at TIMESTAMP NOT NULL,
    volunteer_name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS receipt(
    receipt_id SERIAL PRIMARY KEY,
    expense_id INT REFERENCES expense(expense_id) ON DELETE CASCADE,
    file_path VARCHAR(255),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS petty_cash_statement(
    pcs_id SERIAL PRIMARY KEY,
    city_id INT REFERENCES city(city_id),
    month VARCHAR(20) NOT NULL,
    opening_balance NUMERIC(10, 2) NOT NULL,
    total_spent NUMERIC(10, 2) NOT NULL,
    closing_balance NUMERIC(10, 2) NOT NULL,
    carried_forward NUMERIC(10, 2) NOT NULL,
    cash_in_hand NUMERIC(10, 2) NOT NULL,
    prepared_by INT REFERENCES users(users_id),
    approved_by INT REFERENCES users(users_id)
);

CREATE TABLE IF NOT EXISTS petty_cash_expense(
    pcx_id SERIAL PRIMARY KEY,
    pcs_id INT REFERENCES petty_cash_statement(pcs_id),
    event VARCHAR(100) NOT NULL,
    nature_of_expense VARCHAR(100) NOT NULL,
    vendor VARCHAR(100) NOT NULL,
    amount_before_tax NUMERIC(10, 2) NOT NULL,
    hst NUMERIC(10, 2) NOT NULL,
    round_off NUMERIC(10, 2),
    total_amount NUMERIC(10, 2) NOT NULL,
    receipt_number INTEGER,
    spent_at TIMESTAMP NOT NULL,
    volunteer_name VARCHAR(100) NOT NULL,
    balance_on_hand_after NUMERIC(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS cash_collection(
    collection_id SERIAL PRIMARY KEY,
    city_id INT REFERENCES city(city_id),
    event VARCHAR(100) NOT NULL,
    amount_collected NUMERIC(10, 2) NOT NULL,
    collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    notes VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS deposit(
   deposit_id SERIAL PRIMARY KEY,
   collection_id INT REFERENCES cash_collection(collection_id),
   bank_ref VARCHAR(100) NOT NULL,
   deposited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
   slip_path VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS disbursement(
   disb_id SERIAL PRIMARY KEY,
   city_id INT REFERENCES city(city_id),
   amount NUMERIC(10, 2) NOT NULL,
   method VARCHAR(100) NOT NULL,
   sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
   ref_no INTEGER,
   reason VARCHAR(100),
   request_id INT REFERENCES budget_request(request_id)
);
