CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  full_name VARCHAR(140) NOT NULL,
  email VARCHAR(160) UNIQUE NOT NULL,
  phone VARCHAR(40) NOT NULL DEFAULT '',
  password_hash TEXT NOT NULL,
  role VARCHAR(60) NOT NULL DEFAULT 'Admin',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS otp_verifications (
  id SERIAL PRIMARY KEY,
  email VARCHAR(160) NOT NULL,
  otp_code VARCHAR(10) NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  verified BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_otp_email_created ON otp_verifications (email, created_at DESC);

CREATE TABLE IF NOT EXISTS skus (
  id SERIAL PRIMARY KEY,
  sku_code VARCHAR(40) UNIQUE NOT NULL,
  title VARCHAR(160) NOT NULL,
  specs_summary VARCHAR(200) NOT NULL,
  stock_label VARCHAR(60) NOT NULL DEFAULT '0 rolls',
  brand VARCHAR(100) NOT NULL,
  material_type VARCHAR(100) NOT NULL,
  grade VARCHAR(50) NOT NULL,
  length VARCHAR(50) NOT NULL DEFAULT '12m',
  quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  low_stock_threshold INTEGER NOT NULL DEFAULT 10,
  supplier VARCHAR(140) NOT NULL DEFAULT '',
  storage_location VARCHAR(120) NOT NULL DEFAULT '',
  buying_price NUMERIC(12, 2) NOT NULL DEFAULT 0,
  weight_prefix VARCHAR(80) NOT NULL DEFAULT '',
  notes TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS stock_movements (
  id SERIAL PRIMARY KEY,
  sku_id INTEGER NOT NULL REFERENCES skus(id) ON DELETE CASCADE,
  adjustment_type VARCHAR(80) NOT NULL,
  unit VARCHAR(40) NOT NULL DEFAULT 'rolls',
  quantity_delta INTEGER NOT NULL,
  supplier VARCHAR(140) NOT NULL DEFAULT '',
  storage_location VARCHAR(120) NOT NULL DEFAULT '',
  buying_price NUMERIC(12, 2),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  order_code VARCHAR(40) NOT NULL,
  customer_name VARCHAR(140) NOT NULL,
  company_name VARCHAR(160) NOT NULL,
  phone VARCHAR(40) NOT NULL DEFAULT '',
  reference_code VARCHAR(80) NOT NULL DEFAULT '',
  items_summary VARCHAR(200) NOT NULL,
  status VARCHAR(40) NOT NULL DEFAULT 'Pending',
  billing_status VARCHAR(40) NOT NULL DEFAULT 'Unbilled',
  total_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
  payment_mode VARCHAR(30) NOT NULL DEFAULT 'Cash',
  time_ago_label VARCHAR(50) NOT NULL DEFAULT 'Just now',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_name_and_category VARCHAR(180) NOT NULL,
  estimated_label VARCHAR(60) NOT NULL,
  estimated_qty INTEGER NOT NULL DEFAULT 12,
  exact_weight_kg VARCHAR(40) NOT NULL DEFAULT '',
  notes TEXT NOT NULL DEFAULT ''
);

CREATE TABLE IF NOT EXISTS daybook_entries (
  id SERIAL PRIMARY KEY,
  order_id INTEGER REFERENCES orders(id) ON DELETE SET NULL,
  company_name VARCHAR(160) NOT NULL,
  order_code VARCHAR(40) NOT NULL,
  status_label VARCHAR(40) NOT NULL DEFAULT 'Paid/Billed',
  customer_name VARCHAR(140) NOT NULL,
  phone VARCHAR(40) NOT NULL DEFAULT '',
  reference_code VARCHAR(80) NOT NULL DEFAULT '',
  amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
  payment_mode VARCHAR(30) NOT NULL DEFAULT 'Cash',
  items_count INTEGER NOT NULL DEFAULT 0,
  tonnage NUMERIC(10, 2) NOT NULL DEFAULT 0,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  timestamp_label VARCHAR(80) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO skus (
  sku_code, title, specs_summary, stock_label, brand, material_type,
  grade, length, quantity, low_stock_threshold, supplier, storage_location, buying_price
)
VALUES
  ('SKU-101', 'TMT Bar 12mm FE500D', 'Specs : Dia 12, FE500D, L 12m', '120 rolls', 'Tata Tiscon', 'TMT Bar', 'FE500D', '12m', 120, 25, 'Tata Steel Dealer', 'Bay A-1', 54000),
  ('SKU-102', 'TMT Bar 12mm FE500D', 'Specs : Dia 12, FE500D, L 12m', '120 rolls', 'JSW Steel', 'TMT Bar', 'FE500D', '12m', 120, 25, 'JSW Distribution', 'Bay A-2', 53500),
  ('SKU-103', 'TMT Bar 12mm FE500D', 'Specs : Dia 12, FE500D, L 12m', '120 rolls', 'SAIL', 'TMT Bar', 'FE500D', '12m', 120, 25, 'SAIL Yard', 'Bay B-1', 52800)
ON CONFLICT (sku_code) DO NOTHING;

INSERT INTO orders (
  order_code, customer_name, company_name, phone, reference_code,
  items_summary, status, billing_status, total_amount, payment_mode, time_ago_label
)
VALUES
  ('#SS1033', 'Ram Kishor Sharma', 'Vijay metals', '+91 7223945264', '1232481698147', 'TMT Bars X 250 Bundles', 'In Progress', 'Paid/Billed', 1259.55, 'Cash', '12 mins ago'),
  ('#SS1032', 'Ganesh Raj', 'Ganesh metal Co.', '+91 9835011223', '1232481698188', 'TMT Bars X 250 Bundles', 'Pending', 'Unbilled', 4820.00, 'Online', '12 mins ago')
ON CONFLICT DO NOTHING;

INSERT INTO order_items (order_id, product_name_and_category, estimated_label, estimated_qty)
SELECT o.id, 'TMT Bars X 250 Bundles', '2400Kg', 12
FROM orders o
WHERE NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.order_id = o.id)
LIMIT 5;

INSERT INTO daybook_entries (
  company_name, order_code, status_label, customer_name, phone,
  reference_code, amount, payment_mode, items_count, tonnage, entry_date, timestamp_label
)
VALUES
  ('Vijay Metals', '#S51030', 'Paid/Billed', 'Vijay Raj', '+91 7223945264', '1232481698147', 1259.55, 'Cash', 36, 12.5, CURRENT_DATE, 'September 21,2026 | 12:34'),
  ('Vijay Metals', '#S51030', 'Paid/Billed', 'Vijay Raj', '+91 7223945264', '1232481698147', 1259.55, 'Cash', 36, 12.5, CURRENT_DATE, 'September 21,2026 | 12:34'),
  ('Vijay Metals', '#S51030', 'Paid/Billed', 'Vijay Raj', '+91 7223945264', '1232481698147', 1259.55, 'Cash', 36, 12.5, CURRENT_DATE, 'September 21,2026 | 12:34')
ON CONFLICT DO NOTHING;