# ERD — الحزمة 28: الإطلاق التجريبي

**Pilot Launch** · الحزمة البرمجية `NOONA_PILOT_PKG` · عدد الجداول: **4**

إدارة الإطلاق التجريبي لعميل مؤسس: النطاق والمستخدمون ومعايير النجاح والملاحظات والقياس وقرار الانتقال إلى الإنتاج ومصير البيانات.

الجداول الخارجية المرتبطة (من حزم أخرى): `PLT_TRIAL`, `QA_DEFECT`, `SEC_USER_MEMBERSHIP`

```mermaid
erDiagram
  PIL_PILOT {
    NUMBER ID PK
    NUMBER TENANT_ID FK,UK
    VARCHAR2 CODE UK
    VARCHAR2 NAME_AR
    NUMBER TRIAL_ID FK
    VARCHAR2 STATUS_CODE
  }
  PIL_SUCCESS_CRITERION {
    NUMBER ID PK
    NUMBER TENANT_ID FK
    NUMBER PILOT_ID FK
    VARCHAR2 STATUS_CODE
  }
  PIL_FEEDBACK {
    NUMBER ID PK
    NUMBER TENANT_ID FK
    NUMBER PILOT_ID FK
    NUMBER MEMBERSHIP_ID FK
    NUMBER DEFECT_ID FK
    VARCHAR2 STATUS_CODE
  }
  PIL_USAGE_METRIC {
    NUMBER ID PK
    NUMBER TENANT_ID FK
    NUMBER PILOT_ID FK
  }
  PLT_TRIAL {
    NUMBER ID PK
  }
  SEC_USER_MEMBERSHIP {
    NUMBER ID PK
  }
  QA_DEFECT {
    NUMBER ID PK
  }
  PIL_PILOT ||--o{ PIL_FEEDBACK : "PILOT_ID"
  PIL_PILOT ||--o{ PIL_SUCCESS_CRITERION : "PILOT_ID"
  PIL_PILOT ||--o{ PIL_USAGE_METRIC : "PILOT_ID"
  PLT_TRIAL |o--o{ PIL_PILOT : "TRIAL_ID"
  QA_DEFECT |o--o{ PIL_FEEDBACK : "DEFECT_ID"
  SEC_USER_MEMBERSHIP |o--o{ PIL_FEEDBACK : "MEMBERSHIP_ID"
```

## الجداول

| الجدول | الاسم العربي | English | النطاق |
|---|---|---|---|
| `PIL_PILOT` | المشروعات التجريبية | Pilots | T |
| `PIL_SUCCESS_CRITERION` | معايير النجاح | Success Criteria | T |
| `PIL_FEEDBACK` | ملاحظات المستخدمين | Pilot Feedback | T |
| `PIL_USAGE_METRIC` | مقاييس الاستخدام التجريبي | Pilot Usage Metrics | T |
