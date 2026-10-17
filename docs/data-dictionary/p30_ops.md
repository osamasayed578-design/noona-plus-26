# قاموس البيانات — الحزمة 30: التشغيل والدعم والتطوير المستمر

**Operations, Support & Continuous Improvement** · الحزمة البرمجية المالكة `NOONA_OPERATIONS_PKG` · ملف DDL `db/ddl/p30_ops.sql` · [ERD](../erd/p30_ops.md)

الحوادث التشغيلية SEV-1..4 وخطها الزمني، ونوافذ الصيانة، وتذاكر الدعم، والمهام الخلفية بطوابير Interactive/Background/Critical لكل Tenant، والنسخ الاحتياطي واختبارات الاستعادة، وسجل القرارات وطلبات التغيير (Change Control).

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`OPS_INCIDENT`](#ops_incident) | الحوادث التشغيلية | Operational Incidents | G | INTERNAL |
| [`OPS_INCIDENT_EVENT`](#ops_incident_event) | الخط الزمني للحادث | Incident Timeline | G | INTERNAL |
| [`OPS_INCIDENT_TENANT`](#ops_incident_tenant) | المؤسسات المتأثرة بالحادث | Incident Affected Tenants | T | INTERNAL |
| [`OPS_MAINTENANCE_WINDOW`](#ops_maintenance_window) | نوافذ الصيانة | Maintenance Windows | G | INTERNAL |
| [`OPS_SUPPORT_TICKET`](#ops_support_ticket) | تذاكر الدعم | Support Tickets | T | INTERNAL |
| [`OPS_TICKET_COMMENT`](#ops_ticket_comment) | تعليقات التذاكر | Ticket Comments | T | INTERNAL |
| [`OPS_JOB_DEFINITION`](#ops_job_definition) | تعريفات المهام الخلفية | Background Job Definitions | G | INTERNAL |
| [`OPS_JOB_RUN`](#ops_job_run) | تشغيلات المهام الخلفية | Background Job Runs | TO | INTERNAL |
| [`OPS_BACKUP_RUN`](#ops_backup_run) | عمليات النسخ الاحتياطي | Backup Runs | G | INTERNAL |
| [`OPS_RESTORE_TEST`](#ops_restore_test) | اختبارات الاستعادة | Restore Tests | TO | INTERNAL |
| [`OPS_DECISION_LOG`](#ops_decision_log) | سجل القرارات | Decision Log | G | INTERNAL |
| [`OPS_CHANGE_REQUEST`](#ops_change_request) | طلبات التغيير | Change Requests | G | INTERNAL |

## OPS_INCIDENT

| البند | القيمة |
|---|---|
| الاسم العربي | الحوادث التشغيلية |
| English | Operational Incidents |
| الحزمة المالكة | 30 — `NOONA_OPERATIONS_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (INCIDENT_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `INCIDENT_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرقم |
| 3 | `SEVERITY` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SEV1, SEV2, SEV3, SEV4 | إدخال المستخدم |  | الخطورة |
| 4 | `TITLE` | نص | `VARCHAR2(500 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | العنوان |
| 5 | `CELL_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_CELL |  | إدخال المستخدم |  | الخلية المتأثرة |
| 6 | `AFFECTED_TENANTS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | عدد المؤسسات المتأثرة |
| 7 | `STARTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 8 | `DETECTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الاكتشاف |
| 9 | `RESOLVED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | الحل |
| 10 | `ROOT_CAUSE` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب الجذري |
| 11 | `CUSTOMER_SUMMARY` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملخص العميل (منفصل عن التقرير الفني) |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, INVESTIGATING, MITIGATED, RESOLVED, POSTMORTEM, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## OPS_INCIDENT_EVENT

| البند | القيمة |
|---|---|
| الاسم العربي | الخط الزمني للحادث |
| English | Incident Timeline |
| الحزمة المالكة | 30 — `NOONA_OPERATIONS_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `INCIDENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→OPS_INCIDENT |  | إدخال المستخدم |  | الحادث |
| 3 | `EVENT_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | الوقت |
| 4 | `EVENT_TEXT` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الحدث/الإجراء |
| 5 | `AUTHOR` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | الكاتب |
| 6 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 7 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## OPS_INCIDENT_TENANT

| البند | القيمة |
|---|---|
| الاسم العربي | المؤسسات المتأثرة بالحادث |
| English | Incident Affected Tenants |
| الحزمة المالكة | 30 — `NOONA_OPERATIONS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (INCIDENT_ID, TENANT_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `INCIDENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→OPS_INCIDENT UK1 |  | إدخال المستخدم |  | الحادث |
| 4 | `IMPACT_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | FULL_OUTAGE, DEGRADED, DATA_RISK, NONE | إدخال المستخدم |  | الأثر |
| 5 | `NOTIFIED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الإخطار |
| 6 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 7 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 8 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 9 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 10 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## OPS_MAINTENANCE_WINDOW

| البند | القيمة |
|---|---|
| الاسم العربي | نوافذ الصيانة |
| English | Maintenance Windows |
| الحزمة المالكة | 30 — `NOONA_OPERATIONS_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | ENDS_AT > STARTS_AT |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `CELL_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_CELL |  | إدخال المستخدم |  | الخلية |
| 3 | `REGION_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_REGION |  | إدخال المستخدم |  | المنطقة |
| 4 | `STARTS_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 5 | `ENDS_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | النهاية |
| 6 | `IS_EMERGENCY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | طارئة |
| 7 | `DESCRIPTION` | نص | `VARCHAR2(2000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SCHEDULED' |  | SCHEDULED, NOTIFIED, IN_PROGRESS, COMPLETED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## OPS_SUPPORT_TICKET

| البند | القيمة |
|---|---|
| الاسم العربي | تذاكر الدعم |
| English | Support Tickets |
| الحزمة المالكة | 30 — `NOONA_OPERATIONS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (TENANT_ID, TICKET_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `TICKET_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | الرقم |
| 5 | `REQUESTER_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | الطالب |
| 6 | `CATEGORY` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الفئة |
| 7 | `PRIORITY_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NORMAL' |  | LOW, NORMAL, HIGH, URGENT | إدخال المستخدم |  | الأولوية |
| 8 | `SUBJECT` | نص | `VARCHAR2(500 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الموضوع |
| 9 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 10 | `ASSIGNED_TO` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | مسؤول الدعم |
| 11 | `SUPPORT_ACCESS_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_SUPPORT_ACCESS |  | إدخال المستخدم |  | وصول الدعم الممنوح |
| 12 | `SLA_DUE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | موعد SLA |
| 13 | `RESOLVED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الحل |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NEW' |  | NEW, OPEN, WAITING_CUSTOMER, IN_PROGRESS, ESCALATED, RESOLVED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## OPS_TICKET_COMMENT

| البند | القيمة |
|---|---|
| الاسم العربي | تعليقات التذاكر |
| English | Ticket Comments |
| الحزمة المالكة | 30 — `NOONA_OPERATIONS_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `TICKET_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→OPS_SUPPORT_TICKET |  | إدخال المستخدم |  | التذكرة |
| 4 | `IS_INTERNAL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | داخلي لفريق الدعم |
| 5 | `COMMENT_TEXT` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | النص |
| 6 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 7 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## OPS_JOB_DEFINITION

| البند | القيمة |
|---|---|
| الاسم العربي | تعريفات المهام الخلفية |
| English | Background Job Definitions |
| الحزمة المالكة | 30 — `NOONA_OPERATIONS_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 3 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 4 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 5 | `QUEUE_CLASS` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | INTERACTIVE, BACKGROUND, CRITICAL | إدخال المستخدم |  | فئة الطابور |
| 6 | `HANDLER_API` | نص | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الإجراء المنفذ |
| 7 | `MAX_CONCURRENT_PER_TENANT` | عدد صحيح | `NUMBER(10)` | ✔ | 2 |  |  | إدخال المستخدم |  | الحد المتزامن لكل Tenant (منع Noisy Neighbor) |
| 8 | `MAX_RUNTIME_MINUTES` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | أقصى مدة |
| 9 | `SCHEDULE_EXPR` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الجدولة |
| 10 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## OPS_JOB_RUN

| البند | القيمة |
|---|---|
| الاسم العربي | تشغيلات المهام الخلفية |
| English | Background Job Runs |
| الحزمة المالكة | 30 — `NOONA_OPERATIONS_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `JOB_DEFINITION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→OPS_JOB_DEFINITION |  | إدخال المستخدم |  | التعريف |
| 4 | `REQUESTED_BY_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | الطالب |
| 5 | `PARAMETERS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | المعاملات |
| 6 | `STARTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | البداية |
| 7 | `FINISHED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | النهاية |
| 8 | `PROGRESS_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | التقدم |
| 9 | `RESULT_INFO` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | النتيجة |
| 10 | `ERROR_MESSAGE` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الخطأ |
| 11 | `CORRELATION_ID` | نص | `VARCHAR2(64 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف الارتباط |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'QUEUED' |  | QUEUED, RUNNING, SUCCEEDED, FAILED, CANCELLED, TIMED_OUT | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## OPS_BACKUP_RUN

| البند | القيمة |
|---|---|
| الاسم العربي | عمليات النسخ الاحتياطي |
| English | Backup Runs |
| الحزمة المالكة | 30 — `NOONA_OPERATIONS_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `CELL_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_CELL |  | إدخال المستخدم |  | الخلية |
| 3 | `BACKUP_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | RMAN_FULL, RMAN_INCREMENTAL, ARCHIVELOG, DATAPUMP_TENANT, FILE_STORAGE, CONFIG | إدخال المستخدم |  | النوع |
| 4 | `STARTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 5 | `FINISHED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | النهاية |
| 6 | `RESULT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SUCCESS, FAILED, PARTIAL | إدخال المستخدم |  | النتيجة |
| 7 | `SIZE_BYTES` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | الحجم |
| 8 | `LOCATION_REF` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | الموقع (خارجي) |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## OPS_RESTORE_TEST

| البند | القيمة |
|---|---|
| الاسم العربي | اختبارات الاستعادة |
| English | Restore Tests |
| الحزمة المالكة | 30 — `NOONA_OPERATIONS_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | نجاح النسخ وحده لا يثبت القدرة على التعافي |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `TEST_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | CELL_RESTORE, TENANT_RESTORE, DOCUMENT_RESTORE, PITR, DR_FAILOVER | إدخال المستخدم |  | النوع |
| 4 | `BACKUP_RUN_ID` | معرف | `NUMBER(19)` |  |  | FK→OPS_BACKUP_RUN |  | إدخال المستخدم |  | النسخة المختبرة |
| 5 | `TARGET_RPO_MIN` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | RPO المستهدف |
| 6 | `TARGET_RTO_MIN` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | RTO المستهدف |
| 7 | `ACTUAL_DATA_LOSS_MIN` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الفقد الفعلي |
| 8 | `ACTUAL_DURATION_MIN` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | المدة الفعلية |
| 9 | `FINDINGS` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الملاحظات والثغرات |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, RUNNING, PASSED, FAILED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## OPS_DECISION_LOG

| البند | القيمة |
|---|---|
| الاسم العربي | سجل القرارات |
| English | Decision Log |
| الحزمة المالكة | 30 — `NOONA_OPERATIONS_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 3 | `TITLE` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | القرار |
| 4 | `RATIONALE` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | المبرر |
| 5 | `DECIDED_ON` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | التاريخ |
| 6 | `DECIDED_BY` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | صاحب القرار |
| 7 | `SOURCE_REF` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | المرجع في الوثيقة |
| 8 | `SUPERSEDED_BY_ID` | معرف | `NUMBER(19)` |  |  | FK→OPS_DECISION_LOG |  | إدخال المستخدم |  | القرار البديل |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PROPOSED' |  | PROPOSED, APPROVED, SUPERSEDED, REJECTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## OPS_CHANGE_REQUEST

| البند | القيمة |
|---|---|
| الاسم العربي | طلبات التغيير |
| English | Change Requests |
| الحزمة المالكة | 30 — `NOONA_OPERATIONS_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | أي تعديل في Baseline يمر عبر Change Control |
| مفاتيح فريدة | UK1: (CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 3 | `TITLE` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | العنوان |
| 4 | `CHANGE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | BASELINE, SCOPE, DESIGN, SCHEMA, SECURITY, COUNTRY_PACK, OPERATIONAL | إدخال المستخدم |  | النوع |
| 5 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 6 | `IMPACT_ANALYSIS` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | تحليل الأثر |
| 7 | `DECISION_ID` | معرف | `NUMBER(19)` |  |  | FK→OPS_DECISION_LOG |  | إدخال المستخدم |  | القرار المرتبط |
| 8 | `RELEASE_ID` | معرف | `NUMBER(19)` |  |  | FK→DEP_RELEASE |  | إدخال المستخدم |  | الإصدار المنفذ فيه |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, SUBMITTED, IMPACT_ANALYSIS, APPROVED, REJECTED, IMPLEMENTED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

