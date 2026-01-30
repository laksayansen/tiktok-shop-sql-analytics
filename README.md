# TikTok Shop–Style E-commerce Retention Analysis (SQL)

![SQL](https://img.shields.io/badge/database-SQL-blue.svg)
![Status](https://img.shields.io/badge/status-completed-success.svg)

## Overview
This project analyzes customer retention behavior in a **social-commerce / marketplace-style e-commerce platform**, inspired by **TikTok Shop–like purchasing patterns**. Using transactional order data, the analysis focuses on **cohort retention, repeat purchase behavior, and time to second purchase**, implemented entirely in **MySQL 8.0**.

The goal of this project is to demonstrate practical SQL skills used in real-world analytics: data modeling, cohort analysis, window functions, and business interpretation.

---

## Business Questions
- How many customers return after their first purchase?
- How quickly do customers make a second purchase?
- How does retention change across monthly cohorts?
- Is the platform driven more by repeat buyers or one-time purchases?

---

## Dataset
- **Source:** Olist Brazilian E-commerce Dataset (public)
- **Contextualized as:** TikTok Shop–style marketplace data
- **Core tables used:**
  - orders
  - customers
  - order_items
  - products
  - reviews

> Raw CSV files are intentionally **excluded** from this repository.

---

## Tools & Skills
- **SQL (MySQL 8.0)**
- Common Table Expressions (CTEs)
- Window functions
- Cohort analysis
- Data aggregation & joins
- MySQL Workbench

---

## Data Modeling
A consolidated table called `base_orders` was created to support analysis:

- One row per order per customer
- Includes:
  - purchase timestamp
  - cohort month
  - order value
  - review score

This table serves as the foundation for all retention calculations.

---

## Key Analyses & Results

### 1. Cohort Retention (Month 0–6)
Customers were grouped by their **first purchase month** and tracked across subsequent months.

**Key insight:**
- Retention drops sharply after the first purchase
- Most cohorts fall below **1% retention after Month 1**

This behavior is consistent with **impulse-driven social commerce platforms**.

---

### 2. One-Time vs Repeat Customers

| Customer Type | Customers | Percentage |
|--------------|-----------|------------|
| One-time     | 92,507    | 96.95%     |
| Repeat       | 2,913     | 3.05%      |

**Key insight:**
- The platform is dominated by **one-time buyers**
- Repeat purchasing behavior is rare

---

### 3. Time to Second Purchase
Among repeat customers:

- **Repeat customers:** 2,913  
- **Median time to 2nd purchase:** **28 days**  
- **Average time to 2nd purchase:** **80.8 days**

**Key insight:**
- Customers who return often do so within one month
- A long average tail suggests weak habit formation

---

## Business Interpretation
The results suggest a platform driven primarily by:
- Discovery-based shopping
- Promotional or viral content
- Low customer loyalty

Potential strategies to improve retention:
- Post-purchase remarketing within 30 days
- Incentives for second purchases
- Creator-led follow-up campaigns
- Loyalty or subscription-style features

---

## Repository Structure

```text
tiktok-shop-sql-analytics/
│
├── queries.sql
├── README.md
└── data/
    └── raw/
```

---

## How to Reproduce
1. Load the Olist CSV files into MySQL tables
2. Run `queries.sql` sequentially in MySQL Workbench
3. View results directly in the query output

---

**Author:** Laksa Fadhil Yansen  
Data Analysis | Modeling | Visualization
- GitHub: [@laksayansen](https://github.com/laksayansen)
- LinkedIn: [Laksa Fadhil Yansen](https://linkedin.com/in/laksafadhilyansen)
- Email: laksafadhil.yansen@mail.utoronto.ca
