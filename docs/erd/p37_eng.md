# ERD — الحزمة 37: مركز الإدارة والتواصل

**Management & Engagement Hub** · الحزمة البرمجية `NOONA_ENG_PKG` · عدد الجداول: **8**

بوابة العملاء والمحلات برابط آمن (الفواتير، الرصيد، كشف الحساب، تتبع الشحنات)، محرك واتساب (Cloud API أو روابط wa.me) بالقوالب وسجل الرسائل، توقع النقد 90 يوماً، قواعد الإنذار المبكر وتنبيهاتها، لوحة المدير على الهاتف، مركز المساعدة لكل شاشة، تصدير البيانات إلى Excel، وسجل التغييرات المقروء.

الجداول الخارجية المرتبطة (من حزم أخرى): `AR_CUSTOMER_ACCOUNT`, `ORG_COMPANY`

```mermaid
erDiagram
  ENG_PORTAL_LINK {
    NUMBER ID PK
    NUMBER TENANT_ID FK
    NUMBER COMPANY_ID FK
    NUMBER CUSTOMER_ACCOUNT_ID FK
    VARCHAR2 TOKEN_HASH UK
    VARCHAR2 STATUS_CODE
  }
  ENG_WA_SETTING {
    NUMBER ID PK
    NUMBER TENANT_ID FK,UK
    NUMBER COMPANY_ID FK,UK
  }
  ENG_WA_TEMPLATE {
    NUMBER ID PK
    NUMBER TENANT_ID FK,UK
    NUMBER COMPANY_ID FK,UK
    VARCHAR2 CODE UK
    VARCHAR2 NAME_AR
  }
  ENG_MESSAGE {
    NUMBER ID PK
    NUMBER TENANT_ID FK
    NUMBER COMPANY_ID FK
    NUMBER TEMPLATE_ID FK
    NUMBER CUSTOMER_ACCOUNT_ID FK
    VARCHAR2 STATUS_CODE
  }
  ENG_ALERT_RULE {
    NUMBER ID PK
    NUMBER TENANT_ID FK,UK
    NUMBER COMPANY_ID FK,UK
    VARCHAR2 CODE UK
    VARCHAR2 NAME_AR
  }
  ENG_ALERT {
    NUMBER ID PK
    NUMBER TENANT_ID FK,UK
    NUMBER COMPANY_ID FK,UK
    NUMBER RULE_ID FK,UK
    DATE ALERT_DATE UK
    VARCHAR2 STATUS_CODE
  }
  ENG_HELP {
    NUMBER ID PK
    NUMBER TENANT_ID FK
  }
  ENG_CHANGE_LOG {
    NUMBER ID PK
    NUMBER TENANT_ID FK
  }
  ORG_COMPANY {
    NUMBER ID PK
  }
  AR_CUSTOMER_ACCOUNT {
    NUMBER ID PK
  }
  AR_CUSTOMER_ACCOUNT |o--o{ ENG_MESSAGE : "CUSTOMER_ACCOUNT_ID"
  AR_CUSTOMER_ACCOUNT ||--o{ ENG_PORTAL_LINK : "CUSTOMER_ACCOUNT_ID"
  ENG_ALERT_RULE ||--o{ ENG_ALERT : "RULE_ID"
  ENG_WA_TEMPLATE |o--o{ ENG_MESSAGE : "TEMPLATE_ID"
  ORG_COMPANY ||--o{ ENG_ALERT : "COMPANY_ID"
  ORG_COMPANY ||--o{ ENG_ALERT_RULE : "COMPANY_ID"
  ORG_COMPANY ||--o{ ENG_MESSAGE : "COMPANY_ID"
  ORG_COMPANY ||--o{ ENG_PORTAL_LINK : "COMPANY_ID"
  ORG_COMPANY ||--o{ ENG_WA_TEMPLATE : "COMPANY_ID"
  ORG_COMPANY ||--o| ENG_WA_SETTING : "COMPANY_ID"
```

## الجداول

| الجدول | الاسم العربي | English | النطاق |
|---|---|---|---|
| `ENG_PORTAL_LINK` | روابط بوابة العملاء | Customer Portal Links | C |
| `ENG_WA_SETTING` | إعدادات واتساب | WhatsApp Settings | C |
| `ENG_WA_TEMPLATE` | قوالب الرسائل | Message Templates | C |
| `ENG_MESSAGE` | سجل الرسائل | Message Log | C |
| `ENG_ALERT_RULE` | قواعد الإنذار المبكر | Early-warning Rules | C |
| `ENG_ALERT` | تنبيهات الإنذار المبكر | Early-warning Alerts | C |
| `ENG_HELP` | مساعدة الشاشات | Screen Help | TO |
| `ENG_CHANGE_LOG` | سجل التغييرات | Change Log | T |
