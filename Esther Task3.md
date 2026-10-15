# E-commerce Orders Dataset

A cleaned dataset of 1,200 e-commerce orders placed between **1 January 2023 and 30 June 2025**. It was prepared for a data analytics project and is ready for exploration, SQL practice, and visualisation.

**File:** `Dataset_for_Data_Analytics_-_cleaned.csv`

## Dataset at a glance

| | |
|---|---|
| Rows | 1,200 orders (one row per order) |
| Columns | 14 |
| Period covered | 2023-01-01 to 2025-06-30 |
| Products | 7 (Chair, Desk, Laptop, Monitor, Phone, Printer, Tablet) |
| Missing values | Only `CouponCode` (309 blanks, meaning no coupon was used) |
| Duplicate order IDs | None |

## Data dictionary

| Column | Type | Description |
|---|---|---|
| `OrderID` | text | Unique order identifier (e.g. `ORD200000`) |
| `Date` | date | Order date, in `M/D/YYYY` format |
| `CustomerID` | text | Customer identifier (e.g. `C72649`) |
| `Product` | text | Product ordered |
| `Quantity` | integer | Units ordered (1 to 5) |
| `UnitPrice` | decimal | Price per unit (11.39 to 699.93) |
| `ShippingAddress` | text | Shipping street address |
| `PaymentMethod` | text | `Cash`, `Credit Card`, `Debit Card`, `Gift Card`, `Online` |
| `OrderStatus` | text | `Delivered`, `Shipped`, `Pending`, `Cancelled`, `Returned` |
| `TrackingNumber` | text | Unique shipment tracking number (e.g. `TRK37947903`) |
| `ItemsInCart` | integer | Number of items in the cart at checkout (1 to 10) |
| `CouponCode` | text | `SAVE10`, `FREESHIP`, `WINTER15`, or blank if none |
| `ReferralSource` | text | `Email`, `Facebook`, `Google`, `Instagram`, `Referral` |
| `TotalPrice` | decimal | `Quantity` x `UnitPrice` |

## Data cleaning (Power Query)

The raw data was cleaned in Excel Power Query:

1. **Removed duplicate rows.**
2. **Converted the `Date` column** from text to a proper date type.

## Things to know before analysing

- `TotalPrice` always equals `Quantity` x `UnitPrice`.
- `CouponCode` blanks are genuine "no coupon" values, not data errors.
- 11 customer IDs appear more than once, so a customer can have multiple orders.

## Loading the data into PostgreSQL (Supabase)

```sql
CREATE SCHEMA IF NOT EXISTS e_commerce;

CREATE TABLE e_commerce.sales (
    OrderID       TEXT,
    Date          DATE,
    CustomerID      TEXT,
    Product          TEXT,
    Quantity         INTEGER,
    UnitPrice       NUMERIC(10,2),
    ShippingAddress TEXT,
    PaymentMethod   TEXT,
    OrderStatus     TEXT,
    TrackingNumber  TEXT,
    ItemsInCart    INTEGER,
    CouponCode      TEXT,
    ReferralSource  TEXT,
    TotalPrice      NUMERIC(10,2),
);
```

Then import the CSV with the Supabase Table Editor (**Insert > Import data from CSV**) or with `psql`:

```
\copy e_commerce.sales FROM 'Dataset_for_Data_Analytics_-_cleaned.csv' WITH (FORMAT csv, HEADER true)
```

Dates are in `M/D/YYYY`, so run `SET datestyle = 'MDY';` first if your database defaults to a different format.

## SQL analysis

All queries are in [`queries.sql`](queries.sql). They use `SELECT`, `WHERE`, `ORDER BY`, `GROUP BY`, and the aggregate functions `COUNT`, `SUM` and `AVG` to answer questions about revenue, products, order status, coupons and referral sources.

## Key insights

### 1. Overview

| Metric | Value |
|---|---|
| Total orders | 1,200 |
| Total order value | 1,264,761.96 |
| Average order value | 1,053.97 |
| Median order value | 823.62 |
| Smallest / largest order | 11.39 / 3,456.40 |

The average is well above the median, so a smaller number of large orders pulls the average up.

### 2. Only about 1 in 5 orders is delivered

| Order status | Orders | Share |
|---|---|---|
| Cancelled | 250 | 20.8% |
| Returned | 247 | 20.6% |
| Pending | 237 | 19.8% |
| Shipped | 235 | 19.6% |
| Delivered | 231 | 19.2% |

- Orders are split almost evenly across the five statuses.
- **Cancelled and returned orders together make up 41.4% of all orders** (497 of 1,200).
- Delivered orders account for 242,600.32 of the total order value, which is only about 19% of it. The headline total therefore overstates revenue actually completed, since `TotalPrice` includes cancelled and returned orders.

### 3. Product performance

| Product | Orders | Total order value | Share | Avg order value |
|---|---|---|---|---|
| Chair | 178 | 195,620.11 | 15.5% | 1,098.99 |
| Printer | 181 | 195,612.61 | 15.5% | 1,080.73 |
| Laptop | 173 | 192,126.56 | 15.2% | 1,110.56 |
| Tablet | 179 | 186,568.95 | 14.8% | 1,042.28 |
| Monitor | 163 | 175,651.41 | 13.9% | 1,077.62 |
| Desk | 170 | 167,459.93 | 13.2% | 985.06 |
| Phone | 156 | 151,722.39 | 12.0% | 972.58 |

- Revenue is spread fairly evenly. The top product (Chair) holds 15.5% and the lowest (Phone) 12.0%.
- Phone has the fewest orders and the lowest average order value.
- **Looking at delivered orders only changes the ranking.** Laptop (40,714) and Phone (40,345) lead, while Desk is lowest (24,226). A product's ranking depends on whether you count all orders or only completed ones.
- Average quantity per order is similar across products, from 2.63 (Phone) to 3.16 (Chair), so quantity alone does not explain the differences.

### 4. Orders and revenue are declining

| Year | Orders | Total order value |
|---|---|---|
| 2023 | 510 | 552,643.24 |
| 2024 | 459 | 480,235.87 |
| 2025 (Jan to Jun only) | 231 | 231,882.85 |

2025 covers only six months, so the fair comparison is the first half (Q1 and Q2) of each year:

| First half | Orders | Total order value |
|---|---|---|
| 2023 | 252 | 286,501.52 |
| 2024 | 237 | 257,059.34 |
| 2025 | 231 | 231,882.85 |

Order value fell by about 10% from H1 2023 to H1 2024, and by about 10% again to H1 2025. Order counts fell more slowly (252 to 237 to 231), so the drop comes from both fewer orders and lower value per order.

### 5. Cancellation rate by payment method

| Payment method | Orders | Cancellation rate |
|---|---|---|
| Credit Card | 234 | 23.08% |
| Gift Card | 230 | 21.74% |
| Online | 258 | 20.54% |
| Cash | 246 | 19.92% |
| Debit Card | 232 | 18.97% |

Credit Card has the highest cancellation rate and Debit Card the lowest, but the gap is about 4 percentage points on roughly 230 to 260 orders per method. That is a small sample, so treat it as a hint rather than a firm conclusion.

### 6. Coupons and referral sources

| Coupon | Orders | Avg order value |
|---|---|---|
| FREESHIP | 313 | 1,070.41 |
| WINTER15 | 292 | 1,035.90 |
| SAVE10 | 286 | 1,065.87 |
| No coupon | 309 | 1,043.37 |

- FREESHIP is the most used code, but the three codes are close together.
- About 74% of orders used a coupon, and coupon orders are not noticeably larger than orders without one, so there is no clear sign that coupons lift order value.

| Referral source | Orders |
|---|---|
| Instagram | 259 |
| Email | 250 |
| Google | 241 |
| Facebook | 228 |
| Referral | 222 |

Instagram brings the most orders and Referral the fewest, but all five channels are within about 17% of each other. Note that this counts orders per channel, not conversion rates, which would need visit data.

### 7. Customers rarely come back

Of 1,189 unique customers, only 11 placed more than one order. Almost all revenue comes from first-time buyers, so repeat purchases are a possible area to improve.

### Suggested actions

1. **Reduce cancellations and returns.** About 41% of orders end this way, which is the largest gap between orders placed and revenue completed.
2. **Investigate the decline** in order value across 2023, 2024 and H1 2025.
3. **Build repeat purchases,** for example with follow-up emails or loyalty offers.
4. **Review coupon strategy.** Coupons are widely used without a visible effect on order size.

### Limitations

- Differences between products, payment methods, coupons and referral sources are small, and no statistical tests were run, so they may not be significant.
- `TotalPrice` includes cancelled and returned orders. Use `OrderStatus = 'Delivered'` for completed revenue.
- The data has no cost or margin figures, so profitability cannot be assessed.

## Tools used

- Excel and Power Query for data cleaning
- PostgreSQL (Supabase) for SQL analysis

## Author

Your name: [@highflyer](https://github.com/your-github-username)

