# ERD — الحزمة 30: التشغيل والدعم والتطوير المستمر

**Operations, Support & Continuous Improvement** · الحزمة البرمجية `NOONA_OPERATIONS_PKG` · عدد الجداول: **12**

الحوادث التشغيلية SEV-1..4 وخطها الزمني، ونوافذ الصيانة، وتذاكر الدعم، والمهام الخلفية بطوابير Interactive/Background/Critical لكل Tenant، والنسخ الاحتياطي واختبارات الاستعادة، وسجل القرارات وطلبات التغيير (Change Control).

الجداول الخارجية المرتبطة (من حزم أخرى): `DEP_RELEASE`, `PLT_CELL`, `PLT_REGION`, `PLT_SUPPORT_ACCESS`, `SEC_USER_MEMBERSHIP`

```mermaid
erDiagram
  OPS_INCIDENT {
    NUMBER ID PK
    VARCHAR2 INCIDENT_NO UK
    NUMBER CELL_ID FK
    VARCHAR2 STATUS_CODE
  }
  OPS_INCIDENT_EVENT {
    NUMBER ID PK
    NUMBER INCIDENT_ID FK
  }
  OPS_INCIDENT_TENANT {
    NUMBER ID PK
    NUMBER TENANT_ID FK,UK
    NUMBER INCIDENT_ID FK,UK
  }
  OPS_MAINTENANCE_WINDOW {
    NUMBER ID PK
    NUMBER CELL_ID FK
    NUMBER REGION_ID FK
    VARCHAR2 STATUS_CODE
  }
  OPS_SUPPORT_TICKET {
    NUMBER ID PK
    RAW PUBLIC_ID UK
    NUMBER TENANT_ID FK,UK
    VARCHAR2 TICKET_NO UK
    NUMBER REQUESTER_MEMBER_ID FK
    NUMBER SUPPORT_ACCESS_ID FK
    VARCHAR2 STATUS_CODE
  }
  OPS_TICKET_COMMENT {
    NUMBER ID PK
    NUMBER TENANT_ID FK
    NUMBER TICKET_ID FK
  }
  OPS_JOB_DEFINITION {
    NUMBER ID PK
    VARCHAR2 CODE UK
    VARCHAR2 NAME_AR
  }
  OPS_JOB_RUN {
    NUMBER ID PK
    NUMBER TENANT_ID FK
    NUMBER JOB_DEFINITION_ID FK
    NUMBER REQUESTED_BY_MEMBER_ID FK
    VARCHAR2 STATUS_CODE
  }
  OPS_BACKUP_RUN {
    NUMBER ID PK
    NUMBER CELL_ID FK
  }
  OPS_RESTORE_TEST {
    NUMBER ID PK
    NUMBER TENANT_ID FK
    NUMBER BACKUP_RUN_ID FK
    VARCHAR2 STATUS_CODE
  }
  OPS_DECISION_LOG {
    NUMBER ID PK
    VARCHAR2 CODE UK
    NUMBER SUPERSEDED_BY_ID FK
    VARCHAR2 STATUS_CODE
  }
  OPS_CHANGE_REQUEST {
    NUMBER ID PK
    VARCHAR2 CODE UK
    NUMBER DECISION_ID FK
    NUMBER RELEASE_ID FK
    VARCHAR2 STATUS_CODE
  }
  PLT_CELL {
    NUMBER ID PK
  }
  PLT_REGION {
    NUMBER ID PK
  }
  SEC_USER_MEMBERSHIP {
    NUMBER ID PK
  }
  PLT_SUPPORT_ACCESS {
    NUMBER ID PK
  }
  DEP_RELEASE {
    NUMBER ID PK
  }
  DEP_RELEASE |o--o{ OPS_CHANGE_REQUEST : "RELEASE_ID"
  OPS_BACKUP_RUN |o--o{ OPS_RESTORE_TEST : "BACKUP_RUN_ID"
  OPS_DECISION_LOG |o--o{ OPS_CHANGE_REQUEST : "DECISION_ID"
  OPS_DECISION_LOG |o--o{ OPS_DECISION_LOG : "SUPERSEDED_BY_ID"
  OPS_INCIDENT ||--o{ OPS_INCIDENT_EVENT : "INCIDENT_ID"
  OPS_INCIDENT ||--o{ OPS_INCIDENT_TENANT : "INCIDENT_ID"
  OPS_JOB_DEFINITION ||--o{ OPS_JOB_RUN : "JOB_DEFINITION_ID"
  OPS_SUPPORT_TICKET ||--o{ OPS_TICKET_COMMENT : "TICKET_ID"
  PLT_CELL |o--o{ OPS_BACKUP_RUN : "CELL_ID"
  PLT_CELL |o--o{ OPS_INCIDENT : "CELL_ID"
  PLT_CELL |o--o{ OPS_MAINTENANCE_WINDOW : "CELL_ID"
  PLT_REGION |o--o{ OPS_MAINTENANCE_WINDOW : "REGION_ID"
  PLT_SUPPORT_ACCESS |o--o{ OPS_SUPPORT_TICKET : "SUPPORT_ACCESS_ID"
  SEC_USER_MEMBERSHIP |o--o{ OPS_JOB_RUN : "REQUESTED_BY_MEMBER_ID"
  SEC_USER_MEMBERSHIP |o--o{ OPS_SUPPORT_TICKET : "REQUESTER_MEMBER_ID"
```

## الجداول

| الجدول | الاسم العربي | English | النطاق |
|---|---|---|---|
| `OPS_INCIDENT` | الحوادث التشغيلية | Operational Incidents | G |
| `OPS_INCIDENT_EVENT` | الخط الزمني للحادث | Incident Timeline | G |
| `OPS_INCIDENT_TENANT` | المؤسسات المتأثرة بالحادث | Incident Affected Tenants | T |
| `OPS_MAINTENANCE_WINDOW` | نوافذ الصيانة | Maintenance Windows | G |
| `OPS_SUPPORT_TICKET` | تذاكر الدعم | Support Tickets | T |
| `OPS_TICKET_COMMENT` | تعليقات التذاكر | Ticket Comments | T |
| `OPS_JOB_DEFINITION` | تعريفات المهام الخلفية | Background Job Definitions | G |
| `OPS_JOB_RUN` | تشغيلات المهام الخلفية | Background Job Runs | TO |
| `OPS_BACKUP_RUN` | عمليات النسخ الاحتياطي | Backup Runs | G |
| `OPS_RESTORE_TEST` | اختبارات الاستعادة | Restore Tests | TO |
| `OPS_DECISION_LOG` | سجل القرارات | Decision Log | G |
| `OPS_CHANGE_REQUEST` | طلبات التغيير | Change Requests | G |
