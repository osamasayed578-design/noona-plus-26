# قاموس البيانات — الحزمة 05: المراسلات والإشعارات والتدقيق

**Correspondence, Notifications & Audit** · الحزمة البرمجية المالكة `NOONA_CORRESPONDENCE_PKG` · ملف DDL `db/ddl/p05_cor.sql` · [ERD](../erd/p05_cor.md)

المراسلات الواردة والصادرة والداخلية مع فصل الجهة المقصودة عن المستلم الفعلي، وسجل تسليم مستقل لكل مستلم بأبعاد التسليم/الاطلاع/الإجراء/العرض، والتداول والتعليمات والأولوية؛ ومحرك الإشعارات المركزي (NOONA_NOTIFICATION_PKG)؛ وسجل التدقيق المركزي غير القابل للتعديل (NOONA_AUDIT_PKG).

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`COR_INSTRUCTION`](#cor_instruction) | قاموس تعليمات المراسلات | Correspondence Instructions | TO | INTERNAL |
| [`COR_TYPE`](#cor_type) | أنواع المراسلات | Correspondence Types | TO | INTERNAL |
| [`COR_PRIORITY_POLICY`](#cor_priority_policy) | سياسات الأولوية والمهل | Priority Policies | TO | INTERNAL |
| [`COR_CORRESPONDENCE`](#cor_correspondence) | المراسلات | Correspondence | T | CONFIDENTIAL |
| [`COR_PARTY`](#cor_party) | أطراف المراسلة الخارجية | Correspondence External Parties | T | INTERNAL |
| [`COR_ADDRESSEE`](#cor_addressee) | الجهات المخاطبة | Intended Addressees | T | INTERNAL |
| [`COR_RECIPIENT`](#cor_recipient) | سجلات تسليم المستلمين | Recipient Delivery Records | T | INTERNAL |
| [`COR_RECIPIENT_EVENT`](#cor_recipient_event) | أحداث المستلمين | Recipient Events | T | INTERNAL |
| [`COR_CIRCULATION`](#cor_circulation) | محطات تداول المراسلة | Circulation Stations | T | INTERNAL |
| [`COR_CIRCULATION_NOTE`](#cor_circulation_note) | تعليقات التداول | Circulation Notes | T | INTERNAL |
| [`COR_DUE_CHANGE`](#cor_due_change) | تغييرات المواعيد والأولوية | Due Date & Priority Changes | T | INTERNAL |
| [`COR_DISPATCH`](#cor_dispatch) | محاولات الإرسال الخارجي | Outbound Dispatch Attempts | T | INTERNAL |
| [`COR_CASE_FILE`](#cor_case_file) | ملفات القضايا | Case Files | T | INTERNAL |
| [`COR_CASE_LINK`](#cor_case_link) | ربط المراسلات بالقضايا | Case File Links | T | INTERNAL |
| [`NTF_EVENT_TYPE`](#ntf_event_type) | أنواع أحداث الإشعار | Notification Event Types | TO | INTERNAL |
| [`NTF_TEMPLATE`](#ntf_template) | قوالب الإشعارات | Notification Templates | TO | INTERNAL |
| [`NTF_RULE`](#ntf_rule) | قواعد الإشعار | Notification Rules | T | INTERNAL |
| [`NTF_USER_PREFERENCE`](#ntf_user_preference) | تفضيلات الإشعار | Notification Preferences | T | INTERNAL |
| [`NTF_NOTIFICATION`](#ntf_notification) | الإشعارات | Notifications | TO | INTERNAL |
| [`NTF_DELIVERY`](#ntf_delivery) | محاولات تسليم الإشعارات | Notification Deliveries | TO | INTERNAL |
| [`AUD_EVENT`](#aud_event) | سجل التدقيق المركزي | Audit Events | TO | CONFIDENTIAL |
| [`AUD_HASH_ANCHOR`](#aud_hash_anchor) | نقاط تثبيت سلسلة التدقيق | Audit Hash Anchors | TO | INTERNAL |
| [`AUD_ALERT_RULE`](#aud_alert_rule) | قواعد تنبيهات الرقابة | Audit Alert Rules | TO | INTERNAL |
| [`AUD_ALERT`](#aud_alert) | تنبيهات الرقابة | Audit Alerts | TO | INTERNAL |

## COR_INSTRUCTION

| البند | القيمة |
|---|---|
| الاسم العربي | قاموس تعليمات المراسلات |
| English | Correspondence Instructions |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | للعلم، للمراجعة، للدراسة، لاتخاذ اللازم، للتنفيذ، لإبداء الرأي، للإفادة، للحفظ (25.1) |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE, VERSION_NO) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 | UK1 |  | إدخال المستخدم |  | الإصدار (المهام التاريخية تحفظ نسختها) |
| 7 | `REQUIRES_REPLY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يتطلب رداً |
| 8 | `REQUIRES_DECISION` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يتطلب قراراً |
| 9 | `REQUIRES_ATTACHMENT` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يتطلب مرفقاً |
| 10 | `DEFAULT_SLA_POLICY_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_SLA_POLICY |  | إدخال المستخدم |  | المهلة الافتراضية |
| 11 | `RESULTING_TASK_TYPE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | NONE, INFO, REVIEW, STUDY, ACTION, EXECUTE, OPINION, REPORT, FILE | إدخال المستخدم |  | نوع المهمة الناتجة |
| 12 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 13 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 14 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 15 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## COR_TYPE

| البند | القيمة |
|---|---|
| الاسم العربي | أنواع المراسلات |
| English | Correspondence Types |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `DIRECTION` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | INCOMING, OUTGOING, INTERNAL | إدخال المستخدم |  | الاتجاه |
| 7 | `REQUIRES_APPROVAL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يتطلب اعتماداً قبل الإرسال |
| 8 | `DEFAULT_CONFIDENTIALITY` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | السرية الافتراضية |
| 9 | `WF_DEFINITION_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_DEFINITION |  | إدخال المستخدم |  | مسار الاعتماد |
| 10 | `RETENTION_POLICY_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_RETENTION_POLICY |  | إدخال المستخدم |  | الاحتفاظ |
| 11 | `ACK_POLICY` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NONE' |  | NONE, ALL, CATEGORY, MAJORITY, MANDATORY_RECIPIENT | إدخال المستخدم |  | سياسة الإقرار |
| 12 | `MAX_AUDIENCE` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الحد الأقصى للجمهور |
| 13 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## COR_PRIORITY_POLICY

| البند | القيمة |
|---|---|
| الاسم العربي | سياسات الأولوية والمهل |
| English | Priority Policies |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COR_TYPE_ID, PRIORITY_CODE, EFFECTIVE_FROM) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `COR_TYPE_ID` | معرف | `NUMBER(19)` |  |  | FK→COR_TYPE UK1 |  | إدخال المستخدم |  | النوع |
| 4 | `PRIORITY_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 | LOW, NORMAL, HIGH, URGENT, VERY_URGENT | إدخال المستخدم |  | الأولوية |
| 5 | `SLA_POLICY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→WF_SLA_POLICY |  | إدخال المستخدم |  | المهل والتصعيد |
| 6 | `ALLOWED_CHANNELS` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | القنوات المسموحة للتنبيه |
| 7 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) | UK1 |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 8 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## COR_CORRESPONDENCE

| البند | القيمة |
|---|---|
| الاسم العربي | المراسلات |
| English | Correspondence |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | حالة الرأس مستقلة عن حالات المستلمين ومهام Workflow والتسليم التقني (20.4) |
| مفاتيح فريدة | UK2: (PUBLIC_ID) |
| مفاتيح فريدة مشروطة | NUK1: (TENANT_ID, COMPANY_ID, CORRESPONDENCE_NO) عند عدم فراغ CORRESPONDENCE_NO |
| قيود أعمال | PARENT_ID IS NULL OR PARENT_ID <> ID |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 5 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 6 | `COR_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→COR_TYPE |  | إدخال المستخدم |  | النوع |
| 7 | `DIRECTION` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | INCOMING, OUTGOING, INTERNAL | إدخال المستخدم |  | الاتجاه |
| 8 | `CORRESPONDENCE_NO` | نص | `VARCHAR2(50 CHAR)` |  |  | NUK1 |  | إدخال المستخدم |  | الرقم الداخلي (يخصص عند المرحلة المناسبة) |
| 9 | `NUMBERING_YEAR` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | سنة الترقيم |
| 10 | `EXTERNAL_NO` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | الرقم الخارجي (ليس مفتاحاً) |
| 11 | `SUBJECT` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الموضوع |
| 12 | `SUMMARY` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الملخص |
| 13 | `BODY_TEXT` | نص طويل | `CLOB` |  |  |  |  | إدخال المستخدم |  | نص المراسلة |
| 14 | `LANGUAGE_CODE` | رمز لغة | `VARCHAR2(10 CHAR)` |  |  | FK→REF_LANGUAGE |  | إدخال المستخدم |  | اللغة |
| 15 | `OWNER_UNIT_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_UNIT |  | إدخال المستخدم |  | الوحدة المالكة |
| 16 | `AUTHOR_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المنشئ |
| 17 | `LETTER_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الخطاب |
| 18 | `RECEIVED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الاستلام |
| 19 | `SENT_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الإرسال |
| 20 | `TIMEZONE_CODE` | نص | `VARCHAR2(64 CHAR)` |  |  |  |  | إدخال المستخدم |  | المنطقة الزمنية |
| 21 | `PRIORITY_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NORMAL' |  | LOW, NORMAL, HIGH, URGENT, VERY_URGENT | إدخال المستخدم |  | الأولوية |
| 22 | `DUE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | موعد المراسلة |
| 23 | `INBOUND_CHANNEL` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | MANUAL, EMAIL, PORTAL, API, SCAN, INTEGRATION | إدخال المستخدم |  | قناة الورود |
| 24 | `EXTERNAL_PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الجهة الخارجية |
| 25 | `THREAD_ID` | معرف | `NUMBER(19)` |  |  | FK→COR_CORRESPONDENCE |  | إدخال المستخدم |  | السلسلة (الجذر) |
| 26 | `PARENT_ID` | معرف | `NUMBER(19)` |  |  | FK→COR_CORRESPONDENCE |  | إدخال المستخدم |  | الرسالة الأم المباشرة |
| 27 | `ORIGINAL_ID` | معرف | `NUMBER(19)` |  |  | FK→COR_CORRESPONDENCE |  | إدخال المستخدم |  | الأصل |
| 28 | `RELATION_TYPE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | REPLY, REPLY_ALL, FORWARD, REFER, CORRECTION, FOLLOW_UP | إدخال المستخدم |  | نوع العلاقة |
| 29 | `IS_INCOMPLETE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | بيانات ناقصة (وارد بلا رقم خارجي) |
| 30 | `CLOSED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | من أغلق |
| 31 | `CLOSE_REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الإغلاق |
| 32 | `CORRELATION_ID` | نص | `VARCHAR2(64 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف الارتباط |
| 33 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, REGISTERED, VALIDATED, UNDER_REVIEW, APPROVED, READY_TO_SEND, SENT, RECEIVED, DISTRIBUTED, IN_PROGRESS, RETURNED_FOR_INFO, DELIVERED, DELIVERY_FAILED, COMPLETED, CLOSED, ARCHIVED, REJECTED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 34 | `CONFIDENTIALITY_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | درجة السرية؛ لا تمنح الوصول منفردة |
| 35 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 36 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 37 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 38 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 39 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## COR_PARTY

| البند | القيمة |
|---|---|
| الاسم العربي | أطراف المراسلة الخارجية |
| English | Correspondence External Parties |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CORRESPONDENCE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→COR_CORRESPONDENCE |  | إدخال المستخدم |  | المراسلة |
| 4 | `PARTY_ROLE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SENDER, RECIPIENT, CC, ON_BEHALF_OF | إدخال المستخدم |  | الدور |
| 5 | `PARTY_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_PARTY |  | إدخال المستخدم |  | الطرف المركزي |
| 6 | `NAME_SNAPSHOT` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم وقت المراسلة |
| 7 | `ADDRESS_SNAPSHOT` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | العنوان وقت المراسلة |
| 8 | `EMAIL` | نص | `VARCHAR2(320 CHAR)` |  |  |  |  | إدخال المستخدم | ✔ | البريد |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## COR_ADDRESSEE

| البند | القيمة |
|---|---|
| الاسم العربي | الجهات المخاطبة |
| English | Intended Addressees |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | العنوان المقصود كما اختاره المرسل؛ يحفظ حتى لو تغير الهيكل (21.1) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CORRESPONDENCE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→COR_CORRESPONDENCE |  | إدخال المستخدم |  | المراسلة |
| 4 | `TARGET_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | USER, EMPLOYEE, POSITION, ORG_UNIT, BRANCH, COMPANY, COMMITTEE, GROUP, EXPRESSION | إدخال المستخدم |  | نوع الجهة |
| 5 | `TARGET_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرف الجهة |
| 6 | `TARGET_NAME_SNAPSHOT` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم كما اختاره المرسل |
| 7 | `ADDRESSEE_ROLE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'TO' |  | TO, CC, BCC, FYI | إدخال المستخدم |  | الدور |
| 8 | `RESOLUTION_POLICY` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | HEAD, OFFICE, AUTHORIZED_MEMBERS, ALL_MEMBERS, CHAIR, ALL_COMMITTEE | إدخال المستخدم |  | سياسة الحل للوحدات واللجان |
| 9 | `INSTRUCTION_ID` | معرف | `NUMBER(19)` |  |  | FK→COR_INSTRUCTION |  | إدخال المستخدم |  | التعليمة |
| 10 | `PRIORITY_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | LOW, NORMAL, HIGH, URGENT, VERY_URGENT | إدخال المستخدم |  | أولوية التكليف |
| 11 | `DUE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | مهلة الجهة |
| 12 | `IS_MANDATORY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | مستلم إلزامي |
| 13 | `RESOLVED_COUNT` | عدد صحيح | `NUMBER(10)` |  |  |  |  | النظام/الحزمة |  | عدد المستلمين الفعليين |
| 14 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## COR_RECIPIENT

| البند | القيمة |
|---|---|
| الاسم العربي | سجلات تسليم المستلمين |
| English | Recipient Delivery Records |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لكل مستلم حالة قراءة وإجراء مستقلة (BR-003) |
| الاحتفاظ | حسب سياسة المراسلة؛ مرشح للتقسيم |
| مفاتيح فريدة | UK2: (TENANT_ID, IDEMPOTENCY_KEY) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CORRESPONDENCE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→COR_CORRESPONDENCE |  | إدخال المستخدم |  | المراسلة |
| 4 | `ADDRESSEE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→COR_ADDRESSEE |  | إدخال المستخدم |  | الجهة المقصودة |
| 5 | `MEMBERSHIP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المستلم الفعلي |
| 6 | `RECIPIENT_ROLE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | TO, CC, BCC, FYI | إدخال المستخدم |  | الدور |
| 7 | `POSITION_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_POSITION |  | إدخال المستخدم |  | المنصب وقت الحل |
| 8 | `DELEGATION_ID` | معرف | `NUMBER(19)` |  |  | FK→DLG_DELEGATION |  | إدخال المستخدم |  | البديل بالتفويض |
| 9 | `ORIGINAL_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | صاحب المنصب الأصلي |
| 10 | `DELIVERY_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, DELIVERED, FAILED, RETURNED | إدخال المستخدم |  | بعد التسليم |
| 11 | `READ_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'UNREAD' |  | UNREAD, READ | إدخال المستخدم |  | بعد الاطلاع |
| 12 | `ACTION_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'NONE' |  | NONE, ACKNOWLEDGED, FORWARDED, ACTIONED, CLOSED | إدخال المستخدم |  | بعد الإجراء |
| 13 | `VIEW_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, ARCHIVED, RESTORED | إدخال المستخدم |  | العرض الشخصي (Inbox) |
| 14 | `DELIVERED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت التسليم |
| 15 | `FIRST_READ_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | أول قراءة فعلية |
| 16 | `LAST_READ_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر اطلاع |
| 17 | `ACKNOWLEDGED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الإقرار |
| 18 | `INSTRUCTION_ID` | معرف | `NUMBER(19)` |  |  | FK→COR_INSTRUCTION |  | إدخال المستخدم |  | التعليمة |
| 19 | `INSTRUCTION_SNAPSHOT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | لقطة التعليمة ومعناها التنفيذي |
| 20 | `DUE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | مهلة المستلم |
| 21 | `RESOLUTION_SNAPSHOT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | لقطة الهيكل والقاعدة والصفة وقت الحل |
| 22 | `IDEMPOTENCY_KEY` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | منع إنشاء تسليم مكرر عند Retry |
| 23 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 24 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 25 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 26 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 27 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## COR_RECIPIENT_EVENT

| البند | القيمة |
|---|---|
| الاسم العربي | أحداث المستلمين |
| English | Recipient Events |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `RECIPIENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→COR_RECIPIENT |  | إدخال المستخدم |  | سجل التسليم |
| 4 | `EVENT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | RESOLVED, DELIVERED, DELIVERY_FAILED, OPENED, ACKNOWLEDGED, FORWARDED, ACTIONED, ARCHIVED, RESTORED, ACCESS_REVOKED | إدخال المستخدم |  | الحدث |
| 5 | `ACTOR_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | الفاعل |
| 6 | `DELEGATION_ID` | معرف | `NUMBER(19)` |  |  | FK→DLG_DELEGATION |  | إدخال المستخدم |  | بالتفويض |
| 7 | `SESSION_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_SESSION |  | إدخال المستخدم |  | الجلسة |
| 8 | `EVENT_INFO` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | تفاصيل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## COR_CIRCULATION

| البند | القيمة |
|---|---|
| الاسم العربي | محطات تداول المراسلة |
| English | Circulation Stations |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CORRESPONDENCE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→COR_CORRESPONDENCE |  | إدخال المستخدم |  | المراسلة |
| 4 | `PARENT_CIRCULATION_ID` | معرف | `NUMBER(19)` |  |  | FK→COR_CIRCULATION |  | إدخال المستخدم |  | المحطة السابقة |
| 5 | `FROM_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | من |
| 6 | `TO_TARGET_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | USER, POSITION, ORG_UNIT, COMMITTEE, QUEUE | إدخال المستخدم |  | نوع الجهة المحال إليها |
| 7 | `TO_TARGET_ID` | معرف | `NUMBER(19)` | ✔ |  |  |  | إدخال المستخدم |  | معرفها |
| 8 | `TO_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | الشخص الفعلي المحلول |
| 9 | `INSTRUCTION_ID` | معرف | `NUMBER(19)` |  |  | FK→COR_INSTRUCTION |  | إدخال المستخدم |  | التعليمة |
| 10 | `REQUIRED_ACTION` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الإجراء المطلوب |
| 11 | `DUE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | المهلة |
| 12 | `ENTERED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | إدخال المستخدم |  | وقت الوصول للمحطة |
| 13 | `LEFT_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الخروج منها |
| 14 | `DWELL_MINUTES` | عدد صحيح | `NUMBER(10)` |  |  |  |  | محسوب |  | زمن البقاء بدقائق العمل |
| 15 | `WF_TASK_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_TASK |  | إدخال المستخدم |  | المهمة المرتبطة |
| 16 | `IS_PARALLEL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | فرع متوازٍ |
| 17 | `RESULT_ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | معاملة ناتجة |
| 18 | `RESULT_ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرفها |
| 19 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ASSIGNED' |  | ASSIGNED, RECEIVED, ACCEPTED, INFO_REQUESTED, RETURNED, REFERRED, FORWARDED, COMPLETED, ESCALATED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 20 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 21 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 22 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 23 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 24 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## COR_CIRCULATION_NOTE

| البند | القيمة |
|---|---|
| الاسم العربي | تعليقات التداول |
| English | Circulation Notes |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CIRCULATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→COR_CIRCULATION |  | إدخال المستخدم |  | المحطة |
| 4 | `AUTHOR_MEMBER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | الكاتب |
| 5 | `NOTE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'COMMENT' |  | COMMENT, INSTRUCTION, CORRECTION_ADDENDUM, DECISION | إدخال المستخدم |  | النوع (التصحيح ملحق مؤرخ) |
| 6 | `NOTE_TEXT` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | النص |
| 7 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 8 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## COR_DUE_CHANGE

| البند | القيمة |
|---|---|
| الاسم العربي | تغييرات المواعيد والأولوية |
| English | Due Date & Priority Changes |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |
| الغرض | التمديد لا يمحو واقعة تأخر سابقة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CORRESPONDENCE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→COR_CORRESPONDENCE |  | إدخال المستخدم |  | المراسلة |
| 4 | `RECIPIENT_ID` | معرف | `NUMBER(19)` |  |  | FK→COR_RECIPIENT |  | إدخال المستخدم |  | المستلم |
| 5 | `CHANGE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | DUE_DATE, PRIORITY, SLA_PAUSE, SLA_RESUME, EXTENSION | إدخال المستخدم |  | النوع |
| 6 | `OLD_VALUE` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | القيمة السابقة |
| 7 | `NEW_VALUE` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | القيمة الجديدة |
| 8 | `REASON` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | السبب |
| 9 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## COR_DISPATCH

| البند | القيمة |
|---|---|
| الاسم العربي | محاولات الإرسال الخارجي |
| English | Outbound Dispatch Attempts |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, IDEMPOTENCY_KEY) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CORRESPONDENCE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→COR_CORRESPONDENCE |  | إدخال المستخدم |  | المراسلة |
| 4 | `CHANNEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | IN_SYSTEM, EMAIL, PRINT_HANDOVER, COURIER, API, PORTAL | إدخال المستخدم |  | القناة |
| 5 | `DESTINATION` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | العنوان المستهدف |
| 6 | `ATTEMPT_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | رقم المحاولة |
| 7 | `PROVIDER_MESSAGE_ID` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف الرسالة لدى المزود |
| 8 | `PROOF_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | إثبات الإرسال/الاستلام |
| 9 | `IDEMPOTENCY_KEY` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | منع الإرسال المكرر |
| 10 | `ERROR_MESSAGE` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الخطأ |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'QUEUED' |  | QUEUED, SENDING, SENT, DELIVERED, FAILED, BOUNCED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## COR_CASE_FILE

| البند | القيمة |
|---|---|
| الاسم العربي | ملفات القضايا |
| English | Case Files |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 7 | `OWNER_UNIT_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_UNIT |  | إدخال المستخدم |  | الوحدة المالكة |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, CLOSED, ARCHIVED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `CONFIDENTIALITY_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | درجة السرية؛ لا تمنح الوصول منفردة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## COR_CASE_LINK

| البند | القيمة |
|---|---|
| الاسم العربي | ربط المراسلات بالقضايا |
| English | Case File Links |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (CASE_FILE_ID, CORRESPONDENCE_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CASE_FILE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→COR_CASE_FILE UK1 |  | إدخال المستخدم |  | الملف |
| 4 | `CORRESPONDENCE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→COR_CORRESPONDENCE UK1 |  | إدخال المستخدم |  | المراسلة |
| 5 | `LINK_REASON` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب |
| 6 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 7 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 8 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 9 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 10 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## NTF_EVENT_TYPE

| البند | القيمة |
|---|---|
| الاسم العربي | أنواع أحداث الإشعار |
| English | Notification Event Types |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الحزمة المصدر |
| 7 | `CATEGORY` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ACTION_REQUIRED, INFO, REMINDER, ESCALATION, SECURITY, LEGAL, BILLING, SYSTEM | إدخال المستخدم |  | الفئة |
| 8 | `IS_MANDATORY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | إلزامي لا يلغيه تفضيل المستخدم |
| 9 | `DEFAULT_CHANNELS` | نص | `VARCHAR2(200 CHAR)` | ✔ | 'IN_APP' |  |  | إدخال المستخدم |  | القنوات الافتراضية |
| 10 | `ALLOW_DIGEST` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | يقبل التجميع اليومي |
| 11 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## NTF_TEMPLATE

| البند | القيمة |
|---|---|
| الاسم العربي | قوالب الإشعارات |
| English | Notification Templates |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, EVENT_TYPE_ID, CHANNEL, LANGUAGE_CODE, VERSION_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `EVENT_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→NTF_EVENT_TYPE UK1 |  | إدخال المستخدم |  | الحدث |
| 4 | `CHANNEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 | IN_APP, EMAIL, SMS, PUSH, WHATSAPP | إدخال المستخدم |  | القناة |
| 5 | `LANGUAGE_CODE` | رمز لغة | `VARCHAR2(10 CHAR)` | ✔ |  | FK→REF_LANGUAGE UK1 |  | إدخال المستخدم |  | اللغة |
| 6 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 | UK1 |  | إدخال المستخدم |  | الإصدار |
| 7 | `MAX_CONFIDENTIALITY` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | أعلى سرية يسمح بعرض تفاصيلها |
| 8 | `SUBJECT_TEMPLATE` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الموضوع |
| 9 | `BODY_TEMPLATE` | نص طويل | `CLOB` | ✔ |  |  |  | إدخال المستخدم |  | النص بمتغيرات مسموحة فقط |
| 10 | `ALLOWED_VARIABLES` | نص | `VARCHAR2(2000 CHAR)` |  |  |  |  | إدخال المستخدم |  | المتغيرات المسموحة |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, PUBLISHED, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## NTF_RULE

| البند | القيمة |
|---|---|
| الاسم العربي | قواعد الإشعار |
| English | Notification Rules |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `EVENT_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→NTF_EVENT_TYPE |  | إدخال المستخدم |  | الحدث |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 5 | `RECIPIENT_RULE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ASSIGNEE, REQUESTER, OWNER, MANAGER, ROLE, POSITION, ORG_UNIT, GROUP, WATCHERS | إدخال المستخدم |  | قاعدة المستلم |
| 6 | `RECIPIENT_REF_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرف الجهة |
| 7 | `CHANNELS` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | القنوات |
| 8 | `CONDITION_INFO` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | الشروط |
| 9 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## NTF_USER_PREFERENCE

| البند | القيمة |
|---|---|
| الاسم العربي | تفضيلات الإشعار |
| English | Notification Preferences |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, MEMBERSHIP_ID, EVENT_TYPE_ID, CHANNEL) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `MEMBERSHIP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP UK1 |  | إدخال المستخدم |  | المستخدم |
| 4 | `EVENT_TYPE_ID` | معرف | `NUMBER(19)` |  |  | FK→NTF_EVENT_TYPE UK1 |  | إدخال المستخدم |  | الحدث (فارغ = عام) |
| 5 | `CHANNEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 | IN_APP, EMAIL, SMS, PUSH, WHATSAPP | إدخال المستخدم |  | القناة |
| 6 | `IS_ENABLED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | مفعلة |
| 7 | `QUIET_FROM` | نص | `VARCHAR2(5 CHAR)` |  |  |  |  | إدخال المستخدم |  | بداية فترة الهدوء HH24:MI |
| 8 | `QUIET_TO` | نص | `VARCHAR2(5 CHAR)` |  |  |  |  | إدخال المستخدم |  | نهاية فترة الهدوء |
| 9 | `DIGEST_MODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'IMMEDIATE' |  | IMMEDIATE, DAILY_DIGEST | إدخال المستخدم |  | نمط الاستلام |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## NTF_NOTIFICATION

| البند | القيمة |
|---|---|
| الاسم العربي | الإشعارات |
| English | Notifications |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, IDEMPOTENCY_KEY) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `EVENT_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→NTF_EVENT_TYPE |  | إدخال المستخدم |  | الحدث |
| 4 | `MEMBERSHIP_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المستلم |
| 5 | `USER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER |  | إدخال المستخدم |  | المستلم (إشعارات المنصة) |
| 6 | `SOURCE_ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | الكائن المصدر |
| 7 | `SOURCE_ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرفه |
| 8 | `SOURCE_VERSION` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | إصدار الكائن |
| 9 | `TITLE` | نص | `VARCHAR2(500 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | العنوان المنقح حسب السرية |
| 10 | `BODY_TEXT` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | النص المنقح |
| 11 | `LINK_URL` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | رابط الدخول (يفحص الصلاحية عند الفتح) |
| 12 | `REASON_TEXT` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الإشعار |
| 13 | `IDEMPOTENCY_KEY` | نص | `VARCHAR2(200 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الحدث + المستلم + النوع |
| 14 | `TEMPLATE_ID` | معرف | `NUMBER(19)` |  |  | FK→NTF_TEMPLATE |  | إدخال المستخدم |  | القالب المستخدم |
| 15 | `READ_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت القراءة داخل التطبيق |
| 16 | `DUE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | موعد الإجراء المطلوب |
| 17 | `CORRELATION_ID` | نص | `VARCHAR2(64 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف الارتباط |
| 18 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'CREATED' |  | CREATED, QUEUED, SENT, DELIVERED, READ, ACKNOWLEDGED, FAILED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 19 | `CONFIDENTIALITY_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | درجة السرية؛ لا تمنح الوصول منفردة |
| 20 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 21 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 22 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 23 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 24 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## NTF_DELIVERY

| البند | القيمة |
|---|---|
| الاسم العربي | محاولات تسليم الإشعارات |
| English | Notification Deliveries |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | قبول مزود الرسائل ليس دليل قراءة المستلم (27.3) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `NOTIFICATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→NTF_NOTIFICATION |  | إدخال المستخدم |  | الإشعار |
| 4 | `CHANNEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | IN_APP, EMAIL, SMS, PUSH, WHATSAPP | إدخال المستخدم |  | القناة |
| 5 | `DESTINATION_MASKED` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | العنوان مقنعاً |
| 6 | `ATTEMPT_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | المحاولة |
| 7 | `NEXT_RETRY_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | المحاولة التالية (Backoff) |
| 8 | `PROVIDER_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | المزود |
| 9 | `PROVIDER_MESSAGE_ID` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف المزود |
| 10 | `RESPONSE_CODE` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | استجابة المزود |
| 11 | `COST_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | تكلفة القناة |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, QUEUED, SENT, DELIVERED, FAILED, BOUNCED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AUD_EVENT

| البند | القيمة |
|---|---|
| الاسم العربي | سجل التدقيق المركزي |
| English | Audit Events |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | CONFIDENTIAL |
| النمط | Append-only (غير قابل للتعديل) |
| الغرض | Who/What/When/Object/Action/Old/New/Session/IP (المرحلة 32) |
| الاحتفاظ | حسب Country Pack ونوع الحدث؛ تقسيم شهري مقترح؛ لا يعدل عبر التطبيق |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `EVENT_CATEGORY` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | AUTH, SECURITY, CONFIG, DATA_CHANGE, APPROVAL, POSTING, PAYMENT, INVENTORY, SIGNATURE, DOCUMENT, CORRESPONDENCE, AI, API, SUPPORT, DEPLOYMENT, EXPORT | إدخال المستخدم |  | الفئة |
| 4 | `ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | الكيان |
| 5 | `ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | المعرف |
| 6 | `ACTION_CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الإجراء |
| 7 | `RESULT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SUCCESS, DENIED, FAILED | إدخال المستخدم |  | النتيجة |
| 8 | `ACTOR_USER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER |  | إدخال المستخدم |  | المستخدم الفعلي |
| 9 | `MEMBERSHIP_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | العضوية |
| 10 | `ON_BEHALF_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | صاحب السلطة عند التفويض |
| 11 | `DELEGATION_ID` | معرف | `NUMBER(19)` |  |  | FK→DLG_DELEGATION |  | إدخال المستخدم |  | سند التفويض |
| 12 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 13 | `SESSION_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_SESSION |  | إدخال المستخدم |  | الجلسة |
| 14 | `CORRELATION_ID` | نص | `VARCHAR2(64 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف الارتباط APEX → PL/SQL → ORDS → التكامل |
| 15 | `REQUEST_SOURCE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | APEX, ORDS, JOB, SYSTEM, AI, INTEGRATION | إدخال المستخدم |  | مصدر الطلب |
| 16 | `IP_ADDRESS` | نص | `VARCHAR2(45 CHAR)` |  |  |  |  | إدخال المستخدم |  | IP |
| 17 | `OCCURRED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | إدخال المستخدم |  | وقت وقوع الحدث (يخزن مع المنطقة الزمنية ويعرض UTC) |
| 18 | `OLD_VALUES` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | القيم السابقة (الحقول الحساسة مخفاة) |
| 19 | `NEW_VALUES` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | القيم الجديدة |
| 20 | `REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب |
| 21 | `PREV_HASH` | Hash | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | Hash السجل السابق (سلسلة مقاومة للعبث) |
| 22 | `ROW_HASH` | Hash | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | Hash السجل |
| 23 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 24 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## AUD_HASH_ANCHOR

| البند | القيمة |
|---|---|
| الاسم العربي | نقاط تثبيت سلسلة التدقيق |
| English | Audit Hash Anchors |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `FROM_EVENT_ID` | معرف | `NUMBER(19)` | ✔ |  |  |  | إدخال المستخدم |  | أول حدث |
| 4 | `TO_EVENT_ID` | معرف | `NUMBER(19)` | ✔ |  |  |  | إدخال المستخدم |  | آخر حدث |
| 5 | `CHAIN_HASH` | Hash | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | Hash التجميعي |
| 6 | `EXTERNAL_ANCHOR_REF` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع التثبيت خارج نطاق كتابة التطبيق |
| 7 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 8 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## AUD_ALERT_RULE

| البند | القيمة |
|---|---|
| الاسم العربي | قواعد تنبيهات الرقابة |
| English | Audit Alert Rules |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `EVENT_CATEGORY` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الفئة |
| 7 | `CONDITION_INFO` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | الشرط (رفع صلاحيات، تغيير بنك، موافقة ذاتية، تنزيل متكرر...) |
| 8 | `SEVERITY` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | LOW, MEDIUM, HIGH, CRITICAL | إدخال المستخدم |  | الخطورة |
| 9 | `NOTIFY_ROLE_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_ROLE |  | إدخال المستخدم |  | الدور المبلغ |
| 10 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AUD_ALERT

| البند | القيمة |
|---|---|
| الاسم العربي | تنبيهات الرقابة |
| English | Audit Alerts |
| الحزمة المالكة | 05 — `NOONA_CORRESPONDENCE_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `ALERT_RULE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AUD_ALERT_RULE |  | إدخال المستخدم |  | القاعدة |
| 4 | `AUDIT_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→AUD_EVENT |  | إدخال المستخدم |  | الحدث |
| 5 | `SECURITY_INCIDENT_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_INCIDENT |  | إدخال المستخدم |  | الحادث المفتوح |
| 6 | `ASSIGNED_TO` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المكلف |
| 7 | `RESOLUTION` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | النتيجة |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, ACKNOWLEDGED, INVESTIGATING, CLOSED, FALSE_POSITIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

