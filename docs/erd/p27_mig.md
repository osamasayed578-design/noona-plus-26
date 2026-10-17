# ERD — الحزمة 27: ترحيل البيانات

**Data Migration** · الحزمة البرمجية `NOONA_MIGRATION_PKG` · عدد الجداول: **6**

تحميل بيانات العملاء من الأنظمة السابقة عبر Staging بحمولة JSON، وتعيين الحقول، والتحقق والمعاينة وتقرير الأخطاء قبل الاعتماد، ثم المطابقة (عدد السجلات والأرصدة) مع إمكانية الإلغاء.

الجداول الخارجية المرتبطة (من حزم أخرى): `DMS_DOCUMENT`, `ORG_COMPANY`, `REF_ENTITY_TYPE`, `SEC_USER_MEMBERSHIP`

```mermaid
erDiagram
  MIG_PROJECT {
    NUMBER ID PK
    NUMBER TENANT_ID FK,UK
    VARCHAR2 CODE UK
    VARCHAR2 NAME_AR
    NUMBER COMPANY_ID FK
    NUMBER OWNER_MEMBER_ID FK
    VARCHAR2 STATUS_CODE
  }
  MIG_MAPPING {
    NUMBER ID PK
    NUMBER TENANT_ID FK
    NUMBER PROJECT_ID FK,UK
    VARCHAR2 TARGET_ENTITY FK,UK
    NUMBER VERSION_NO UK
    VARCHAR2 STATUS_CODE
  }
  MIG_BATCH {
    NUMBER ID PK
    NUMBER TENANT_ID FK
    NUMBER PROJECT_ID FK
    NUMBER MAPPING_ID FK
    VARCHAR2 TARGET_ENTITY FK
    NUMBER SOURCE_DOCUMENT_ID FK
    VARCHAR2 STATUS_CODE
  }
  MIG_STAGING_ROW {
    NUMBER ID PK
    NUMBER TENANT_ID FK
    NUMBER BATCH_ID FK,UK
    NUMBER ROW_NO UK
    VARCHAR2 STATUS_CODE
  }
  MIG_ERROR {
    NUMBER ID PK
    NUMBER TENANT_ID FK
    NUMBER STAGING_ROW_ID FK
  }
  MIG_RECONCILIATION {
    NUMBER ID PK
    NUMBER TENANT_ID FK
    NUMBER BATCH_ID FK
    VARCHAR2 STATUS_CODE
  }
  ORG_COMPANY {
    NUMBER ID PK
  }
  SEC_USER_MEMBERSHIP {
    NUMBER ID PK
  }
  REF_ENTITY_TYPE {
    NUMBER ID PK
  }
  DMS_DOCUMENT {
    NUMBER ID PK
  }
  DMS_DOCUMENT |o--o{ MIG_BATCH : "SOURCE_DOCUMENT_ID"
  MIG_BATCH ||--o{ MIG_RECONCILIATION : "BATCH_ID"
  MIG_BATCH ||--o{ MIG_STAGING_ROW : "BATCH_ID"
  MIG_MAPPING ||--o{ MIG_BATCH : "MAPPING_ID"
  MIG_PROJECT ||--o{ MIG_BATCH : "PROJECT_ID"
  MIG_PROJECT ||--o{ MIG_MAPPING : "PROJECT_ID"
  MIG_STAGING_ROW ||--o{ MIG_ERROR : "STAGING_ROW_ID"
  ORG_COMPANY |o--o{ MIG_PROJECT : "COMPANY_ID"
  REF_ENTITY_TYPE ||--o{ MIG_BATCH : "TARGET_ENTITY"
  REF_ENTITY_TYPE ||--o{ MIG_MAPPING : "TARGET_ENTITY"
  SEC_USER_MEMBERSHIP |o--o{ MIG_PROJECT : "OWNER_MEMBER_ID"
```

## الجداول

| الجدول | الاسم العربي | English | النطاق |
|---|---|---|---|
| `MIG_PROJECT` | مشروعات الترحيل | Migration Projects | T |
| `MIG_MAPPING` | تعيين الحقول | Field Mappings | T |
| `MIG_BATCH` | دفعات الترحيل | Migration Batches | T |
| `MIG_STAGING_ROW` | سجلات التجهيز | Staging Rows | T |
| `MIG_ERROR` | أخطاء الترحيل | Migration Errors | T |
| `MIG_RECONCILIATION` | مطابقة الترحيل | Migration Reconciliation | T |
