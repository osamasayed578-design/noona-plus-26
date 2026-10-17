# ERD — الحزمة 29: النشر الإنتاجي والإصدارات

**Deployment & Release Management** · الحزمة البرمجية `NOONA_DEPLOYMENT_PKG` · عدد الجداول: **6**

سجل الإصدارات وقنوات النشر Internal → Pilot → Early Access → GA → On-Premises، وسجل ترحيلات المخطط (Migration Scripts مرقمة لا تعدل بعد النشر)، ونشر كل بيئة/خلية وفحوص الصحة وإصدارات مكونات كل Tenant.

الجداول الخارجية المرتبطة (من حزم أخرى): `PLT_CELL`

```mermaid
erDiagram
  DEP_RELEASE {
    NUMBER ID PK
    VARCHAR2 VERSION_LABEL UK
    VARCHAR2 STATUS_CODE
  }
  DEP_COMPONENT_VERSION {
    NUMBER ID PK
    NUMBER RELEASE_ID FK,UK
    VARCHAR2 COMPONENT_CODE UK
  }
  DEP_SCHEMA_MIGRATION {
    NUMBER ID PK
    VARCHAR2 SCRIPT_NAME UK
    NUMBER RELEASE_ID FK
  }
  DEP_DEPLOYMENT {
    NUMBER ID PK
    NUMBER RELEASE_ID FK
    NUMBER CELL_ID FK
    VARCHAR2 STATUS_CODE
  }
  DEP_HEALTH_CHECK {
    NUMBER ID PK
    NUMBER DEPLOYMENT_ID FK
  }
  DEP_TENANT_VERSION {
    NUMBER ID PK
    NUMBER TENANT_ID FK,UK
    VARCHAR2 COMPONENT_CODE UK
    NUMBER RELEASE_ID FK
  }
  PLT_CELL {
    NUMBER ID PK
  }
  DEP_DEPLOYMENT ||--o{ DEP_HEALTH_CHECK : "DEPLOYMENT_ID"
  DEP_RELEASE |o--o{ DEP_SCHEMA_MIGRATION : "RELEASE_ID"
  DEP_RELEASE |o--o{ DEP_TENANT_VERSION : "RELEASE_ID"
  DEP_RELEASE ||--o{ DEP_COMPONENT_VERSION : "RELEASE_ID"
  DEP_RELEASE ||--o{ DEP_DEPLOYMENT : "RELEASE_ID"
  PLT_CELL |o--o{ DEP_DEPLOYMENT : "CELL_ID"
```

## الجداول

| الجدول | الاسم العربي | English | النطاق |
|---|---|---|---|
| `DEP_RELEASE` | الإصدارات | Releases | G |
| `DEP_COMPONENT_VERSION` | إصدارات المكونات | Release Component Versions | G |
| `DEP_SCHEMA_MIGRATION` | سجل ترحيلات المخطط | Schema Migrations | G |
| `DEP_DEPLOYMENT` | عمليات النشر | Deployments | G |
| `DEP_HEALTH_CHECK` | فحوص الصحة | Health Checks | G |
| `DEP_TENANT_VERSION` | إصدارات مكونات المؤسسة | Tenant Component Versions | T |
