# ERD — الحزمة 22: التقارير وذكاء الأعمال

**Reporting & Business Intelligence** · الحزمة البرمجية `NOONA_BI_PKG` · عدد الجداول: **10**

طبقة تعريف المقاييس KPIs بإصدارات، وكتالوج التقارير ولوحات المعلومات، وسجل التصدير، وجدولة التقارير، ومتابعة تحديث الملخصات؛ مع تطبيق Tenant و Data Scope على المصدر والتصدير.

الجداول الخارجية المرتبطة (من حزم أخرى): `DMS_DOCUMENT`, `ORG_BRANCH`, `ORG_COMPANY`, `REF_CURRENCY`, `SEC_PERMISSION`, `SEC_ROLE`, `SEC_USER_MEMBERSHIP`

```mermaid
erDiagram
  BI_KPI {
    NUMBER ID PK
    NUMBER TENANT_ID FK,UK
    VARCHAR2 CODE UK
    VARCHAR2 NAME_AR
    NUMBER VERSION_NO UK
    NUMBER OWNER_ROLE_ID FK
    VARCHAR2 STATUS_CODE
  }
  BI_KPI_VALUE {
    NUMBER ID PK
    NUMBER TENANT_ID FK
    NUMBER KPI_ID FK
    NUMBER COMPANY_ID FK
    NUMBER BRANCH_ID FK
    VARCHAR2 CURRENCY_CODE FK
  }
  BI_REPORT {
    NUMBER ID PK
    NUMBER TENANT_ID FK,UK
    VARCHAR2 CODE UK
    VARCHAR2 NAME_AR
    NUMBER VERSION_NO UK
    NUMBER PERMISSION_ID FK
    VARCHAR2 STATUS_CODE
  }
  BI_REPORT_USER {
    NUMBER ID PK
    NUMBER TENANT_ID FK,UK
    NUMBER MEMBERSHIP_ID FK,UK
    NUMBER REPORT_ID FK,UK
  }
  BI_DASHBOARD {
    NUMBER ID PK
    NUMBER TENANT_ID FK,UK
    VARCHAR2 CODE UK
    VARCHAR2 NAME_AR
    VARCHAR2 STATUS_CODE
  }
  BI_DASHBOARD_WIDGET {
    NUMBER ID PK
    NUMBER TENANT_ID FK
    NUMBER DASHBOARD_ID FK
    NUMBER KPI_ID FK
    NUMBER REPORT_ID FK
  }
  BI_REPORT_SCHEDULE {
    NUMBER ID PK
    NUMBER TENANT_ID FK
    NUMBER REPORT_ID FK
    NUMBER OWNER_MEMBER_ID FK
    VARCHAR2 STATUS_CODE
  }
  BI_EXPORT_LOG {
    NUMBER ID PK
    NUMBER TENANT_ID FK
    NUMBER REPORT_ID FK
    NUMBER MEMBERSHIP_ID FK
    NUMBER FILE_DOCUMENT_ID FK
  }
  BI_REFRESH_LOG {
    NUMBER ID PK
  }
  BI_HISTORY_VALUE {
    NUMBER ID PK
    NUMBER TENANT_ID FK,UK
    NUMBER COMPANY_ID FK,UK
    VARCHAR2 METRIC_CODE UK
    DATE PERIOD_MONTH UK
    NUMBER BRANCH_ID FK,UK
  }
  SEC_ROLE {
    NUMBER ID PK
  }
  ORG_COMPANY {
    NUMBER ID PK
  }
  ORG_BRANCH {
    NUMBER ID PK
  }
  REF_CURRENCY {
    NUMBER ID PK
  }
  SEC_PERMISSION {
    NUMBER ID PK
  }
  SEC_USER_MEMBERSHIP {
    NUMBER ID PK
  }
  DMS_DOCUMENT {
    NUMBER ID PK
  }
  BI_DASHBOARD ||--o{ BI_DASHBOARD_WIDGET : "DASHBOARD_ID"
  BI_KPI |o--o{ BI_DASHBOARD_WIDGET : "KPI_ID"
  BI_KPI ||--o{ BI_KPI_VALUE : "KPI_ID"
  BI_REPORT |o--o{ BI_DASHBOARD_WIDGET : "REPORT_ID"
  BI_REPORT |o--o{ BI_EXPORT_LOG : "REPORT_ID"
  BI_REPORT ||--o{ BI_REPORT_SCHEDULE : "REPORT_ID"
  BI_REPORT ||--o{ BI_REPORT_USER : "REPORT_ID"
  DMS_DOCUMENT |o--o{ BI_EXPORT_LOG : "FILE_DOCUMENT_ID"
  ORG_BRANCH |o--o{ BI_HISTORY_VALUE : "BRANCH_ID"
  ORG_BRANCH |o--o{ BI_KPI_VALUE : "BRANCH_ID"
  ORG_COMPANY |o--o{ BI_KPI_VALUE : "COMPANY_ID"
  ORG_COMPANY ||--o{ BI_HISTORY_VALUE : "COMPANY_ID"
  REF_CURRENCY |o--o{ BI_KPI_VALUE : "CURRENCY_CODE"
  SEC_PERMISSION |o--o{ BI_REPORT : "PERMISSION_ID"
  SEC_ROLE |o--o{ BI_KPI : "OWNER_ROLE_ID"
  SEC_USER_MEMBERSHIP ||--o{ BI_EXPORT_LOG : "MEMBERSHIP_ID"
  SEC_USER_MEMBERSHIP ||--o{ BI_REPORT_SCHEDULE : "OWNER_MEMBER_ID"
  SEC_USER_MEMBERSHIP ||--o{ BI_REPORT_USER : "MEMBERSHIP_ID"
```

## الجداول

| الجدول | الاسم العربي | English | النطاق |
|---|---|---|---|
| `BI_KPI` | تعريفات المؤشرات | KPI Definitions | TO |
| `BI_KPI_VALUE` | قيم المؤشرات | KPI Snapshots | T |
| `BI_REPORT` | كتالوج التقارير | Report Catalog | TO |
| `BI_REPORT_USER` | تقارير المستخدم المفضلة والأخيرة | User Favourite & Recent Reports | T |
| `BI_DASHBOARD` | لوحات المعلومات | Dashboards | TO |
| `BI_DASHBOARD_WIDGET` | عناصر اللوحات | Dashboard Widgets | TO |
| `BI_REPORT_SCHEDULE` | جدولة التقارير | Report Schedules | T |
| `BI_EXPORT_LOG` | سجل التصدير | Export Log | T |
| `BI_REFRESH_LOG` | سجل تحديث الملخصات | Summary Refresh Log | G |
| `BI_HISTORY_VALUE` | أرقام السنوات السابقة | Prior Years Figures | C |
