# قاموس البيانات — الحزمة 24: الذكاء الاصطناعي و RAG والوكلاء

**AI, RAG & Agents** · الحزمة البرمجية المالكة `NOONA_AI_PKG` · ملف DDL `db/ddl/p24_ai.sql` · [ERD](../erd/p24_ai.md)

بنية جاهزة لإضافة AI لاحقاً: المزودون والنماذج وإعدادات المؤسسة، ومصادر المعرفة والقطع المفهرسة (Embeddings تخزن BLOB على 21c وتنقل إلى VECTOR عند الترقية إلى 23ai/26ai)، والمحادثات والاسترجاع والاقتباسات، والأدوات READ/DRAFT/SUBMIT، والاستهلاك والتقييم. كل استرجاع يسبقه فحص Tenant والصلاحية.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`AI_PROVIDER`](#ai_provider) | مزودو الذكاء الاصطناعي | AI Providers | TO | INTERNAL |
| [`AI_MODEL`](#ai_model) | النماذج | AI Models | TO | INTERNAL |
| [`AI_TENANT_SETTING`](#ai_tenant_setting) | إعدادات AI للمؤسسة | Tenant AI Settings | T | INTERNAL |
| [`AI_KNOWLEDGE_SOURCE`](#ai_knowledge_source) | مصادر المعرفة | Knowledge Sources | T | INTERNAL |
| [`AI_DOCUMENT_CHUNK`](#ai_document_chunk) | قطع المعرفة المفهرسة | Indexed Knowledge Chunks | T | CONFIDENTIAL |
| [`AI_INDEX_JOB`](#ai_index_job) | مهام الفهرسة | Indexing Jobs | T | INTERNAL |
| [`AI_CONVERSATION`](#ai_conversation) | المحادثات | Conversations | T | INTERNAL |
| [`AI_MESSAGE`](#ai_message) | رسائل المحادثة | Conversation Messages | T | INTERNAL |
| [`AI_RETRIEVAL`](#ai_retrieval) | سجل الاسترجاع | Retrieval Log | T | INTERNAL |
| [`AI_TOOL`](#ai_tool) | أدوات الوكيل | AI Tools | TO | INTERNAL |
| [`AI_TOOL_CALL`](#ai_tool_call) | استدعاءات الأدوات | Tool Calls | T | INTERNAL |
| [`AI_PROMPT_TEMPLATE`](#ai_prompt_template) | قوالب التعليمات | Prompt Templates | TO | INTERNAL |
| [`AI_USAGE`](#ai_usage) | استهلاك AI | AI Usage | T | INTERNAL |
| [`AI_FEEDBACK`](#ai_feedback) | تقييم الإجابات | Answer Feedback | T | INTERNAL |
| [`AI_EVAL_CASE`](#ai_eval_case) | حالات تقييم AI | AI Evaluation Cases | TO | INTERNAL |

## AI_PROVIDER

| البند | القيمة |
|---|---|
| الاسم العربي | مزودو الذكاء الاصطناعي |
| English | AI Providers |
| الحزمة المالكة | 24 — `NOONA_AI_PKG` |
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
| 6 | `PROVIDER_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | CLOUD_API, PRIVATE_HOSTED, ORACLE_OCI_GENAI, ON_PREMISES | إدخال المستخدم |  | النوع |
| 7 | `ENDPOINT_REF` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع نقطة الاتصال |
| 8 | `SECRET_REF` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع المفتاح في Vault |
| 9 | `PROCESSING_REGION` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | مكان معالجة البيانات |
| 10 | `DATA_RETENTION_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | احتفاظ المزود بالبيانات |
| 11 | `TRAINING_OPT_OUT` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | منع التدريب على بيانات العميل |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, DISABLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AI_MODEL

| البند | القيمة |
|---|---|
| الاسم العربي | النماذج |
| English | AI Models |
| الحزمة المالكة | 24 — `NOONA_AI_PKG` |
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
| 6 | `PROVIDER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AI_PROVIDER |  | إدخال المستخدم |  | المزود |
| 7 | `MODEL_KIND` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | CHAT, EMBEDDING, RERANK, OCR, CLASSIFIER | إدخال المستخدم |  | النوع |
| 8 | `MODEL_IDENTIFIER` | نص | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | المعرف لدى المزود |
| 9 | `MODEL_VERSION` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | الإصدار |
| 10 | `EMBEDDING_DIM` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | أبعاد المتجه |
| 11 | `MAX_CONTEXT_TOKENS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | أقصى سياق |
| 12 | `COST_PER_1K_INPUT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | التكلفة لكل 1000 Token إدخال |
| 13 | `COST_PER_1K_OUTPUT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | التكلفة لكل 1000 Token إخراج |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, DEPRECATED, DISABLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AI_TENANT_SETTING

| البند | القيمة |
|---|---|
| الاسم العربي | إعدادات AI للمؤسسة |
| English | Tenant AI Settings |
| الحزمة المالكة | 24 — `NOONA_AI_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `IS_ENABLED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | مفعل (يمكن تعطيله كلياً) |
| 4 | `MODE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'CLOUD' |  | CLOUD, PRIVATE, DISABLED | إدخال المستخدم |  | النمط |
| 5 | `CHAT_MODEL_ID` | معرف | `NUMBER(19)` |  |  | FK→AI_MODEL |  | إدخال المستخدم |  | نموذج المحادثة |
| 6 | `EMBEDDING_MODEL_ID` | معرف | `NUMBER(19)` |  |  | FK→AI_MODEL |  | إدخال المستخدم |  | نموذج التضمين |
| 7 | `ALLOWED_FEATURES` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوظائف المسموحة (SEARCH، SUMMARIZE، QA، DRAFT) |
| 8 | `REDACTION_POLICY` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | سياسة إخفاء البيانات قبل الإرسال الخارجي |
| 9 | `CONVERSATION_RETENTION_DAYS` | عدد صحيح | `NUMBER(10)` | ✔ | 90 |  |  | إدخال المستخدم |  | الاحتفاظ بالمحادثات |
| 10 | `MONTHLY_TOKEN_QUOTA` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | الحصة الشهرية |
| 11 | `MAX_CONFIDENTIALITY` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | أعلى سرية يسمح بفهرستها |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AI_KNOWLEDGE_SOURCE

| البند | القيمة |
|---|---|
| الاسم العربي | مصادر المعرفة |
| English | Knowledge Sources |
| الحزمة المالكة | 24 — `NOONA_AI_PKG` |
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
| 6 | `SOURCE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | DMS_DOCUMENT_TYPE, CORRESPONDENCE_TYPE, ERP_VIEW, POLICY_LIBRARY | إدخال المستخدم |  | النوع |
| 7 | `SOURCE_REF` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | المرجع (نوع المستند، View...) |
| 8 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 9 | `LAST_INDEXED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر فهرسة |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, INDEXING, ACTIVE, PAUSED, FAILED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AI_DOCUMENT_CHUNK

| البند | القيمة |
|---|---|
| الاسم العربي | قطع المعرفة المفهرسة |
| English | Indexed Knowledge Chunks |
| الحزمة المالكة | 24 — `NOONA_AI_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا تدخل وثيقة معزولة أو غير مفحوصة؛ يزال من الفهرس عند سحب الإذن أو الإتلاف |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `SOURCE_ID` | معرف | `NUMBER(19)` |  |  | FK→AI_KNOWLEDGE_SOURCE |  | إدخال المستخدم |  | المصدر |
| 4 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | المستند |
| 5 | `VERSION_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT_VERSION |  | إدخال المستخدم |  | الإصدار المفهرس |
| 6 | `CORRESPONDENCE_ID` | معرف | `NUMBER(19)` |  |  | FK→COR_CORRESPONDENCE |  | إدخال المستخدم |  | المراسلة |
| 7 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة المالكة |
| 8 | `CHUNK_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  |  |  | إدخال المستخدم |  | رقم القطعة |
| 9 | `CHUNK_TEXT` | نص طويل | `CLOB` | ✔ |  |  |  | إدخال المستخدم |  | النص |
| 10 | `LANGUAGE_CODE` | رمز لغة | `VARCHAR2(10 CHAR)` |  |  | FK→REF_LANGUAGE |  | إدخال المستخدم |  | اللغة |
| 11 | `TOKEN_COUNT` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | عدد الرموز |
| 12 | `ACL_FINGERPRINT` | Hash | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | بصمة الصلاحيات وقت الفهرسة (يعاد التحقق عند الإجابة) |
| 13 | `EMBEDDING_MODEL_ID` | معرف | `NUMBER(19)` |  |  | FK→AI_MODEL |  | إدخال المستخدم |  | نموذج التضمين |
| 14 | `EMBEDDING_DIM` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الأبعاد |
| 15 | `EMBEDDING` | ثنائي | `BLOB` |  |  |  |  | إدخال المستخدم |  | المتجه (FLOAT32 ثنائي) - يتحول إلى VECTOR في 23ai/26ai |
| 16 | `CONTENT_HASH` | Hash | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | Hash النص |
| 17 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, STALE, REVOKED, PURGED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 18 | `CONFIDENTIALITY_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INTERNAL' |  | PUBLIC, INTERNAL, CONFIDENTIAL, SECRET, HIGHLY_RESTRICTED | إدخال المستخدم |  | درجة السرية؛ لا تمنح الوصول منفردة |
| 19 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 20 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 21 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 22 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 23 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AI_INDEX_JOB

| البند | القيمة |
|---|---|
| الاسم العربي | مهام الفهرسة |
| English | Indexing Jobs |
| الحزمة المالكة | 24 — `NOONA_AI_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `JOB_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | INDEX, REINDEX, REMOVE, REVALIDATE_ACL | إدخال المستخدم |  | النوع |
| 4 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | المستند |
| 5 | `VERSION_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT_VERSION |  | إدخال المستخدم |  | الإصدار |
| 6 | `CORRESPONDENCE_ID` | معرف | `NUMBER(19)` |  |  | FK→COR_CORRESPONDENCE |  | إدخال المستخدم |  | المراسلة |
| 7 | `ATTEMPTS` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | المحاولات |
| 8 | `ERROR_MESSAGE` | نص | `VARCHAR2(2000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الخطأ |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'QUEUED' |  | QUEUED, RUNNING, DONE, FAILED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AI_CONVERSATION

| البند | القيمة |
|---|---|
| الاسم العربي | المحادثات |
| English | Conversations |
| الحزمة المالكة | 24 — `NOONA_AI_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `MEMBERSHIP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المستخدم |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | سياق الشركة |
| 5 | `TITLE` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | العنوان |
| 6 | `CONTEXT_SNAPSHOT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | الدور والنطاق والتفويض وقت البدء |
| 7 | `PURGE_AFTER` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الإتلاف حسب الاحتفاظ |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, CLOSED, PURGED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AI_MESSAGE

| البند | القيمة |
|---|---|
| الاسم العربي | رسائل المحادثة |
| English | Conversation Messages |
| الحزمة المالكة | 24 — `NOONA_AI_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CONVERSATION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AI_CONVERSATION |  | إدخال المستخدم |  | المحادثة |
| 4 | `MESSAGE_ROLE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | USER, ASSISTANT, TOOL, SYSTEM | إدخال المستخدم |  | الدور |
| 5 | `CONTENT_REDACTED` | نص طويل | `CLOB` |  |  |  |  | إدخال المستخدم |  | المحتوى بعد الإخفاء |
| 6 | `MODEL_ID` | معرف | `NUMBER(19)` |  |  | FK→AI_MODEL |  | إدخال المستخدم |  | النموذج |
| 7 | `INPUT_TOKENS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | رموز الإدخال |
| 8 | `OUTPUT_TOKENS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | رموز الإخراج |
| 9 | `SAFETY_FLAGS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | نتائج الفحص (Prompt Injection...) |
| 10 | `UNCERTAINTY_NOTE` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | درجة عدم اليقين المعروضة |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## AI_RETRIEVAL

| البند | القيمة |
|---|---|
| الاسم العربي | سجل الاسترجاع |
| English | Retrieval Log |
| الحزمة المالكة | 24 — `NOONA_AI_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `MESSAGE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AI_MESSAGE |  | إدخال المستخدم |  | الرسالة |
| 4 | `CHUNK_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AI_DOCUMENT_CHUNK |  | إدخال المستخدم |  | القطعة |
| 5 | `SIMILARITY` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | درجة التشابه |
| 6 | `PERMITTED_AT_ANSWER` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ |  |  | Y, N | إدخال المستخدم |  | الصلاحية أعيد فحصها وقت الإجابة |
| 7 | `USED_IN_ANSWER` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | استخدمت في الإجابة |
| 8 | `CITED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | ظهرت كاقتباس |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## AI_TOOL

| البند | القيمة |
|---|---|
| الاسم العربي | أدوات الوكيل |
| English | AI Tools |
| الحزمة المالكة | 24 — `NOONA_AI_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا ينشئ AI تفويضاً ضمنياً ولا يوقع أو يدفع بلا إجراء بشري مخول |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `OPERATION_CLASS` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | READ, DRAFT, SUBMIT | إدخال المستخدم |  | فئة العملية (V1: READ فقط) |
| 7 | `PERMISSION_CODE` | نص | `VARCHAR2(100 CHAR)` |  |  | FK→SEC_PERMISSION |  | إدخال المستخدم |  | الصلاحية المطلوبة من المستخدم نفسه |
| 8 | `HANDLER_API` | نص | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | خدمة الأعمال المستدعاة |
| 9 | `INPUT_SCHEMA` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | مخطط المدخلات |
| 10 | `REQUIRES_HUMAN_CONFIRM` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | يتطلب تأكيداً بشرياً |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DISABLED' |  | DISABLED, ENABLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AI_TOOL_CALL

| البند | القيمة |
|---|---|
| الاسم العربي | استدعاءات الأدوات |
| English | Tool Calls |
| الحزمة المالكة | 24 — `NOONA_AI_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `MESSAGE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AI_MESSAGE |  | إدخال المستخدم |  | الرسالة |
| 4 | `TOOL_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AI_TOOL |  | إدخال المستخدم |  | الأداة |
| 5 | `ACTOR_MEMBER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المستخدم صاحب الصلاحية |
| 6 | `PARAMETERS_REDACTED` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | المعاملات بعد الإخفاء |
| 7 | `RESULT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SUCCESS, DENIED, FAILED, AWAITING_CONFIRMATION | إدخال المستخدم |  | النتيجة |
| 8 | `DATA_CUTOFF_TS` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | تاريخ قطع البيانات المرجعة |
| 9 | `CORRELATION_ID` | نص | `VARCHAR2(64 CHAR)` |  |  |  |  | إدخال المستخدم |  | معرف الارتباط |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## AI_PROMPT_TEMPLATE

| البند | القيمة |
|---|---|
| الاسم العربي | قوالب التعليمات |
| English | Prompt Templates |
| الحزمة المالكة | 24 — `NOONA_AI_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE, VERSION_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 | UK1 |  | إدخال المستخدم |  | الإصدار |
| 7 | `PURPOSE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SEARCH, SUMMARIZE, QA, DRAFT, CLASSIFY, EXTRACT | إدخال المستخدم |  | الغرض |
| 8 | `LANGUAGE_CODE` | رمز لغة | `VARCHAR2(10 CHAR)` |  |  | FK→REF_LANGUAGE |  | إدخال المستخدم |  | اللغة |
| 9 | `TEMPLATE_TEXT` | نص طويل | `CLOB` | ✔ |  |  |  | إدخال المستخدم |  | النص |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AI_USAGE

| البند | القيمة |
|---|---|
| الاسم العربي | استهلاك AI |
| English | AI Usage |
| الحزمة المالكة | 24 — `NOONA_AI_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, USAGE_DATE, MODEL_ID, FEATURE_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `USAGE_DATE` | تاريخ | `DATE` | ✔ |  | UK1 |  | إدخال المستخدم |  | اليوم |
| 4 | `MODEL_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AI_MODEL UK1 |  | إدخال المستخدم |  | النموذج |
| 5 | `FEATURE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الوظيفة |
| 6 | `REQUEST_COUNT` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | الطلبات |
| 7 | `INPUT_TOKENS` | رقم | `NUMBER` | ✔ | 0 |  |  | إدخال المستخدم |  | رموز الإدخال |
| 8 | `OUTPUT_TOKENS` | رقم | `NUMBER` | ✔ | 0 |  |  | إدخال المستخدم |  | رموز الإخراج |
| 9 | `COST_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | التكلفة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## AI_FEEDBACK

| البند | القيمة |
|---|---|
| الاسم العربي | تقييم الإجابات |
| English | Answer Feedback |
| الحزمة المالكة | 24 — `NOONA_AI_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `MESSAGE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→AI_MESSAGE |  | إدخال المستخدم |  | الرسالة |
| 4 | `MEMBERSHIP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | المستخدم |
| 5 | `RATING` | عدد صحيح | `NUMBER(10)` | ✔ |  |  |  | إدخال المستخدم |  | التقييم (-1/1 أو 1-5) |
| 6 | `COMMENT_TEXT` | نص | `VARCHAR2(2000 CHAR)` |  |  |  |  | إدخال المستخدم |  | التعليق |
| 7 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 8 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## AI_EVAL_CASE

| البند | القيمة |
|---|---|
| الاسم العربي | حالات تقييم AI |
| English | AI Evaluation Cases |
| الحزمة المالكة | 24 — `NOONA_AI_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | سيناريوهات اختبار المرحلة 34 قبل تفعيل أي نموذج |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `CATEGORY` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | CROSS_TENANT_LEAK, CONFIDENTIAL_ATTACHMENT, ROLE_CHANGE, PROMPT_INJECTION, BALANCE_ACCURACY, REVOKED_ACCESS, QUALITY | إدخال المستخدم |  | الفئة |
| 5 | `INPUT_TEXT` | نص طويل | `CLOB` | ✔ |  |  |  | إدخال المستخدم |  | السؤال/المدخل |
| 6 | `EXPECTED_BEHAVIOR` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | السلوك المتوقع |
| 7 | `LAST_RESULT` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | PASS, FAIL, NOT_RUN | إدخال المستخدم |  | آخر نتيجة |
| 8 | `LAST_RUN_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | آخر تشغيل |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

