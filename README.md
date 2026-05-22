# UPDATED MASTER README — PRINTONEX ERP

This README now includes:

* Complete module functionality
* Full enterprise folder structure
* UI behavior
* Responsive rules
* Master Data system
* Popup system
* Sync architecture
* Database architecture
* UI consistency rules
* Development rules for AI agents
* All pages and functionality from uploaded file

---

# PRINTONEX ERP

Enterprise POS + Inventory + GST + Billing + Sync ERP

Built using:

* Flutter
* SQLite / Drift
* Hive
* Firebase Sync
* Offline-first architecture

Supported Platforms:

* Windows
* Android
* Tablet
* Desktop

---

# PROJECT GOAL

Create a modern ERP system that feels like:

* Shopify POS
* Stripe Dashboard
* Odoo Enterprise
* Zoho Inventory
* Linear
* Notion Enterprise

The UI must look:

* Professional
* Compact
* Enterprise-grade
* Clean
* Responsive
* Fast
* Modern

---

# FINAL FOLDER STRUCTURE

```text
lib/
 ├── core/
 │    ├── config/
 │    ├── constants/
 │    ├── theme/
 │    ├── routes/
 │    ├── network/
 │    ├── errors/
 │    ├── helpers/
 │    ├── responsive/
 │    ├── permissions/
 │    └── layouts/
 │
 ├── database/
 │    ├── local/
 │    ├── sqlite/
 │    ├── hive/
 │    ├── drift/
 │    ├── repositories/
 │    ├── migrations/
 │    └── dao/
 │
 ├── services/
 │    ├── auth/
 │    ├── barcode/
 │    ├── printer/
 │    ├── export/
 │    ├── import/
 │    ├── notification/
 │    ├── analytics/
 │    ├── backup/
 │    ├── gst/
 │    ├── cloud/
 │    └── logging/
 │
 ├── sync/
 │    ├── engine/
 │    ├── websocket/
 │    ├── queue/
 │    ├── device_manager/
 │    ├── conflict_resolver/
 │    ├── sync_logs/
 │    └── offline_manager/
 │
 ├── modules/
 │
 │    ├── dashboard/
 │    │    ├── controllers/
 │    │    ├── pages/
 │    │    ├── widgets/
 │    │    ├── models/
 │    │    └── services/
 │
 │    ├── invoice/
 │    │    ├── pos/
 │    │    ├── billing/
 │    │    ├── quotations/
 │    │    ├── returns/
 │    │    ├── orders/
 │    │    ├── controllers/
 │    │    ├── widgets/
 │    │    └── pages/
 │
 │    ├── inventory/
 │    │    ├── products/
 │    │    ├── categories/
 │    │    ├── brands/
 │    │    ├── units/
 │    │    ├── stock/
 │    │    ├── warehouse/
 │    │    ├── transfers/
 │    │    ├── adjustments/
 │    │    ├── suppliers/
 │    │    ├── purchases/
 │    │    ├── widgets/
 │    │    ├── controllers/
 │    │    └── pages/
 │
 │    ├── sales/
 │    ├── expenses/
 │    ├── customers/
 │    ├── reports/
 │    ├── gst/
 │    ├── users/
 │    ├── settings/
 │    ├── backup_restore/
 │    └── sync_center/
 │
 ├── widgets/
 │    ├── cards/
 │    ├── charts/
 │    ├── forms/
 │    ├── dialogs/
 │    ├── tables/
 │    ├── sidebar/
 │    ├── appbar/
 │    ├── buttons/
 │    ├── navigation/
 │    └── layouts/
 │
 ├── models/
 ├── utils/
 └── main.dart
```

---

# GLOBAL UI RULES

# MUST LOOK LIKE

* Enterprise SaaS
* Compact dashboard
* Professional ERP
* Clean business software

---

# MUST NOT LOOK LIKE

* Mobile app stretched on desktop
* Floating cards everywhere
* Giant spacing
* Giant text
* Cartoon UI
* Student project

---

# MAIN LAYOUT RULE

## CORRECT LAYOUT

```text
Sidebar fixed
Topbar fixed
Content aligned inside container
Cards connected visually
Proper spacing
Unified layout
```

## WRONG LAYOUT

```text
Floating sidebar
Floating dashboard
Huge margins
Oversized cards
```

---

# DESIGN SYSTEM

## Background

```dart
Color(0xFFF5F7FB)
```

## Primary

```dart
Color(0xFF5B3DF5)
```

## Card

```dart
Colors.white
```

## Border

```dart
Color(0xFFE7ECF5)
```

---

# TYPOGRAPHY RULES

## Page Title

```dart
18px
FontWeight.w700
```

## Card Title

```dart
14px
FontWeight.w600
```

## Body Text

```dart
13px
```

## Caption

```dart
11px
```

---

# RESPONSIVE RULES

## Desktop

```text
>= 1200
```

* Full sidebar
* 4-column layouts
* Compact spacing

## Tablet

```text
768 - 1199
```

* Collapsible sidebar
* 2-column layout

## Mobile

```text
< 768
```

* Drawer sidebar
* Single column layout

---

# SIDEBAR RULES

## Sidebar MUST

* Be fixed
* Full height
* Non-floating
* Integrated with dashboard
* Compact
* Scrollable
* Smooth hover animation

## Sidebar Sections

* Dashboard
* POS/Billing
* Sales
* Products
* Inventory
* Purchases
* Suppliers
* Expenses
* Customers
* Reports
* GST/Tax
* Users
* Settings
* Backup & Restore
* Sync Center

---

# DASHBOARD MODULE

## Features

* Business overview
* KPI cards
* Sales analytics
* Profit graph
* Expense graph
* Revenue graph
* Inventory summary
* GST summary
* Quick actions
* Notifications
* Recent transactions
* Top products
* Pending invoices
* Device status
* Sync status
* Backup status

## Functions

* Filter analytics
* Refresh dashboard
* Export dashboard
* Navigate modules
* Open reports
* Real-time updates

---

# POS / BILLING MODULE

## Features

* Fast billing UI
* Barcode scanner
* Product search
* Customer selection
* Hold invoice
* Draft invoice
* Split payment
* GST calculation
* Multi-payment
* Thermal printing
* Offline billing
* Return/refund
* Keyboard shortcuts

## Functions

* Create invoice
* Edit invoice
* Print receipt
* Share invoice
* Apply discount
* Add taxes
* Process refund
* Generate PDF

---

# SALES MODULE

## Features

* Sales analytics
* Sales history
* Quotations
* Orders management
* Returns
* Payment tracking
* Top products
* Top customers

## Functions

* Create quotation
* Convert to invoice
* Cancel invoice
* Track payments
* Export reports

---

# PRODUCTS MODULE

# MASTER DATA SYSTEM

This is a unified management page for:

* Products
* Categories
* Brands
* Units

---

# PRODUCTS PAGE FEATURES

## Product Management

* Product list
* Product cards
* Grid/list view
* Barcode generation
* SKU generation
* Product images
* Variants
* Multi-unit support
* Pricing
* Tax assignment
* Batch tracking
* Serial tracking
* Import/export

## Functions

* Add product
* Edit product
* Delete product
* Search products
* Filter products
* Export products
* Import CSV

---

# CATEGORY FEATURES

## Features

* Parent category
* Category icon
* Category image
* Category status
* Product count

## Functions

* Add category
* Edit category
* Delete category
* Assign products

---

# BRAND FEATURES

## Features

* Brand logo
* Brand code
* Brand description
* Product count

## Functions

* Add brand
* Edit brand
* Delete brand

---

# UNIT FEATURES

## Features

* Unit name
* Unit abbreviation
* Base unit
* Conversion ratio

## Functions

* Add unit
* Edit unit
* Delete unit
* Conversion support

---

# MASTER DATA PAGE UI

## Top Area

* Page title
* Breadcrumb
* Search bar
* Import button
* Export button
* Add New button

---

# TABS

* Products
* Categories
* Brands
* Units

---

# STATS CARDS

* Total products
* Total categories
* Total brands
* Total units

---

# FILTER AREA

* Search
* Category filter
* Brand filter
* Unit filter
* Status filter
* Sort dropdown

---

# TABLE AREA

Compact professional tables:

* Products table
* Categories table
* Brands table
* Units table

---

# ADD NEW POPUP

## Must open modal popup

Popup includes:

* Add Product
* Add Category
* Add Brand
* Add Unit

---

# POPUP STYLE

* Glass blur background
* Rounded 28 radius
* Compact cards
* Hover effects
* Fade animation
* Smooth transitions

---

# INVENTORY MODULE

## Features

* Stock management
* Warehouse
* Transfers
* Adjustments
* Damage stock
* Expiry alerts
* Low stock alerts
* Overstock alerts
* Movement logs

## Functions

* Add stock
* Transfer stock
* Adjust stock
* Export inventory
* Track movements

---

# PURCHASES MODULE

## Features

* Purchase orders
* Supplier invoices
* GRN
* Returns
* Due tracking
* Supplier analytics

## Functions

* Create PO
* Receive products
* Return purchase
* Pay suppliers

---

# SUPPLIERS MODULE

## Features

* Supplier master
* Contact management
* Ledger
* Payables
* Purchase history

## Functions

* Add supplier
* Record payments
* Export supplier data

---

# EXPENSES MODULE

## Features

* Expense categories
* Recurring expenses
* Receipt upload
* Approval workflow

## Functions

* Add expense
* Approve expense
* Export reports

---

# CUSTOMERS MODULE

## Features

* Customer master
* Groups
* Loyalty system
* Credit limit
* Ledger
* Purchase history

## Functions

* Add customer
* Record payment
* Manage loyalty
* Print statements

---

# REPORTS MODULE

## Features

* Sales reports
* Inventory reports
* Purchase reports
* GST reports
* Profit/Loss
* Expense reports

## Functions

* Export PDF
* Export Excel
* Print reports
* Schedule reports

---

# GST / TAX MODULE

## Features

* GST summary
* CGST
* SGST
* IGST
* HSN management
* GST reconciliation

## Functions

* Calculate GST
* Generate returns
* Export GST reports

---

# USERS MODULE

## Features

* User management
* Roles
* Permissions
* Activity logs
* Session tracking

## Functions

* Add user
* Lock user
* Reset password

---

# SETTINGS MODULE

## Features

* Business settings
* Printer settings
* GST settings
* Theme settings
* Security settings
* Notification settings

## Functions

* Configure ERP
* Change theme
* Configure printers

---

# BACKUP & RESTORE MODULE

## Features

* Manual backup
* Auto backup
* Cloud backup
* Restore history

## Functions

* Create backup
* Restore backup
* Download backup

---

# SYNC CENTER MODULE

## Features

* Real-time sync
* Offline sync
* Conflict resolver
* Device management
* Sync logs

## Functions

* Manual sync
* Resolve conflicts
* Monitor devices

---

# DATABASE RULES

## Local Storage

Use:

* Drift
  OR
* SQLite

## Cache

Use:

* Hive

## Sync Queue

Store:

* Pending sync
* Offline invoices
* Conflict data

---

# STATE MANAGEMENT

Preferred:

* GetX
  OR
* Riverpod

Avoid:

* Massive StatefulWidgets

---

# PERFORMANCE RULES

## MUST

* Pagination
* Lazy loading
* Reusable widgets
* Optimized rebuilds
* Compact widget trees

## DO NOT

* Giant files
* Duplicate code
* Deep nested widgets

---

# AI AGENT DEVELOPMENT RULES

Before editing any page:

1. Analyze current UI
2. Preserve logic
3. Upgrade UI carefully
4. Reuse components
5. Keep responsive
6. Keep compact spacing
7. Avoid giant text
8. Avoid floating layouts
9. Maintain enterprise feel
10. Maintain routing

---

# FINAL UI TARGET

The ERP should feel like:

* Shopify POS
* Stripe Dashboard
* Odoo Enterprise
* Zoho Inventory
* Modern SaaS ERP

NOT:

* Mobile app on desktop
* Empty dashboard
* Oversized cards
* Floating UI
* Cartoon design
