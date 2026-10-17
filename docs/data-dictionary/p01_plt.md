# قاموس البيانات — الحزمة 01: نواة المنصة والمؤسسات والترخيص

**Platform Core, Tenancy, Licensing & Companies** · الحزمة البرمجية المالكة `NOONA_PLATFORM_PKG` · ملف DDL `db/ddl/p01_plt.sql` · [ERD](../erd/p01_plt.md)

Control Plane للمنصة: دليل المؤسسات والخلايا الإقليمية ودورة حياة Tenant والإعدادات الهرمية وكتالوج المنتجات والباقات والعقود والاشتراكات والاستحقاقات والفوترة والتحصيل وترخيص On-Premises، إضافة إلى الهيكل القانوني Tenant → Business Group → Company → Branch → Business Site.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`PLT_REGION`](#plt_region) | المناطق الإقليمية للاستضافة | Hosting Regions | G | INTERNAL |
| [`PLT_CELL`](#plt_cell) | الخلايا الإقليمية | Regional Cells | G | INTERNAL |
| [`PLT_TENANT`](#plt_tenant) | المؤسسات المشتركة | Tenants | G | CONFIDENTIAL |
| [`PLT_TENANT_DOMAIN`](#plt_tenant_domain) | نطاقات دخول المؤسسة | Tenant Domains | T | INTERNAL |
| [`PLT_TENANT_STATUS_HIST`](#plt_tenant_status_hist) | سجل حالات المؤسسة | Tenant Status History | T | INTERNAL |
| [`PLT_PROVISIONING_RUN`](#plt_provisioning_run) | عمليات تجهيز المؤسسة | Tenant Provisioning Runs | T | INTERNAL |
| [`PLT_PROVISIONING_STEP`](#plt_provisioning_step) | خطوات التجهيز | Provisioning Steps | T | INTERNAL |
| [`PLT_ENVIRONMENT`](#plt_environment) | بيئات المؤسسة | Tenant Environments | T | INTERNAL |
| [`PLT_SUPPORT_ACCESS`](#plt_support_access) | وصول الدعم المؤقت | Support Access Grants | T | CONFIDENTIAL |
| [`PLT_SETTING_DEF`](#plt_setting_def) | تعريفات الإعدادات | Setting Definitions | G | INTERNAL |
| [`PLT_SETTING_VALUE`](#plt_setting_value) | قيم الإعدادات | Setting Values | TO | INTERNAL |
| [`PLT_FEATURE_FLAG`](#plt_feature_flag) | مفاتيح الخصائص | Feature Flags | G | INTERNAL |
| [`PLT_FEATURE_FLAG_TENANT`](#plt_feature_flag_tenant) | تفعيل الخاصية للمؤسسة | Tenant Feature Flags | T | INTERNAL |
| [`PLT_MODULE`](#plt_module) | وحدات المنتج | Product Modules | G | INTERNAL |
| [`PLT_FEATURE`](#plt_feature) | خصائص الوحدات | Module Features | G | INTERNAL |
| [`PLT_USAGE_METRIC`](#plt_usage_metric) | مقاييس الاستهلاك | Usage Metrics | G | INTERNAL |
| [`PLT_PRODUCT`](#plt_product) | المنتجات | Products | G | INTERNAL |
| [`PLT_EDITION`](#plt_edition) | الإصدارات التجارية | Editions | G | INTERNAL |
| [`PLT_PLAN`](#plt_plan) | الباقات | Plans | G | INTERNAL |
| [`PLT_PLAN_VERSION`](#plt_plan_version) | إصدارات الباقة | Plan Versions | G | INTERNAL |
| [`PLT_PLAN_MODULE`](#plt_plan_module) | وحدات إصدار الباقة | Plan Version Modules | G | INTERNAL |
| [`PLT_PLAN_LIMIT`](#plt_plan_limit) | حدود إصدار الباقة | Plan Version Limits | G | INTERNAL |
| [`PLT_ADDON`](#plt_addon) | الإضافات | Add-ons | G | INTERNAL |
| [`PLT_PRICE_BOOK`](#plt_price_book) | دفاتر الأسعار | Price Books | G | INTERNAL |
| [`PLT_PRICE_BOOK_ENTRY`](#plt_price_book_entry) | أسعار دفتر الأسعار | Price Book Entries | G | INTERNAL |
| [`PLT_PARTNER`](#plt_partner) | الشركاء والموزعون | Partners & Resellers | G | INTERNAL |
| [`PLT_PROMOTION`](#plt_promotion) | العروض الترويجية | Promotions | G | INTERNAL |
| [`PLT_QUOTE`](#plt_quote) | عروض أسعار الاشتراك | Subscription Quotes | T | INTERNAL |
| [`PLT_QUOTE_LINE`](#plt_quote_line) | بنود عرض الاشتراك | Subscription Quote Lines | T | INTERNAL |
| [`PLT_CONTRACT`](#plt_contract) | عقود المنصة | Platform Contracts | T | INTERNAL |
| [`PLT_CONTRACT_VERSION`](#plt_contract_version) | تعديلات العقد | Contract Amendments | T | INTERNAL |
| [`PLT_SUBSCRIPTION`](#plt_subscription) | الاشتراكات | Subscriptions | T | INTERNAL |
| [`PLT_SUBSCRIPTION_ITEM`](#plt_subscription_item) | بنود الاشتراك | Subscription Items | T | INTERNAL |
| [`PLT_SUBSCRIPTION_SNAPSHOT`](#plt_subscription_snapshot) | لقطات حقوق الاشتراك | Subscription Snapshots | T | INTERNAL |
| [`PLT_ENTITLEMENT`](#plt_entitlement) | الاستحقاقات الفعلية | Effective Entitlements | T | INTERNAL |
| [`PLT_ENTITLEMENT_OVERRIDE`](#plt_entitlement_override) | الاستثناءات التعاقدية للحقوق | Entitlement Overrides | T | INTERNAL |
| [`PLT_TRIAL`](#plt_trial) | التجارب و Pilot | Trials & Pilots | T | INTERNAL |
| [`PLT_USAGE_EVENT`](#plt_usage_event) | أحداث الاستهلاك | Usage Events | T | INTERNAL |
| [`PLT_USAGE_SUMMARY`](#plt_usage_summary) | ملخص الاستهلاك للفترة | Usage Summary | T | INTERNAL |
| [`PLT_BILLING_PERIOD`](#plt_billing_period) | فترات الفوترة | Billing Periods | G | INTERNAL |
| [`PLT_BILLING_INVOICE`](#plt_billing_invoice) | فواتير المنصة | Platform Invoices | T | INTERNAL |
| [`PLT_BILLING_INVOICE_LINE`](#plt_billing_invoice_line) | بنود فواتير المنصة | Platform Invoice Lines | T | INTERNAL |
| [`PLT_BILLING_PAYMENT`](#plt_billing_payment) | مدفوعات المنصة | Platform Payments | T | INTERNAL |
| [`PLT_BILLING_ALLOCATION`](#plt_billing_allocation) | تخصيص مدفوعات المنصة | Platform Payment Allocations | T | INTERNAL |
| [`PLT_REFUND`](#plt_refund) | الاسترداد ورد المبالغ المتنازع عليها | Refunds & Chargebacks | T | INTERNAL |
| [`PLT_DUNNING_POLICY`](#plt_dunning_policy) | سياسات التحصيل | Dunning Policies | G | INTERNAL |
| [`PLT_DUNNING_EVENT`](#plt_dunning_event) | أحداث التحصيل | Dunning Events | T | INTERNAL |
| [`PLT_BILLING_DISPUTE`](#plt_billing_dispute) | نزاعات الفوترة | Billing Disputes | T | INTERNAL |
| [`PLT_PAYMENT_PROMISE`](#plt_payment_promise) | وعود الدفع | Payment Promises | T | INTERNAL |
| [`PLT_COMMISSION`](#plt_commission) | العمولات | Commissions | T | INTERNAL |
| [`PLT_ONPREM_LICENSE`](#plt_onprem_license) | تراخيص On-Premises | On-Premises Licenses | G | CONFIDENTIAL |
| [`PLT_LICENSE_ACTIVATION`](#plt_license_activation) | تفعيلات الترخيص | License Activations | G | INTERNAL |
| [`ORG_BUSINESS_GROUP`](#org_business_group) | مجموعات الأعمال | Business Groups | T | INTERNAL |
| [`ORG_COMPANY`](#org_company) | الشركات (الكيانات القانونية) | Companies / Legal Entities | T | INTERNAL |
| [`ORG_COMPANY_CURRENCY`](#org_company_currency) | تاريخ عملات الشركة | Company Currency History | C | INTERNAL |
| [`ORG_BRANCH`](#org_branch) | الفروع | Branches | C | INTERNAL |
| [`ORG_BUSINESS_SITE`](#org_business_site) | المواقع التشغيلية | Business Sites | C | INTERNAL |
| [`ORG_LEGAL_REGISTRATION`](#org_legal_registration) | التسجيلات القانونية | Legal Registrations | T | INTERNAL |
| [`ORG_OWNERSHIP`](#org_ownership) | سجل الملكية بين الشركات | Company Ownership | T | INTERNAL |
| [`ORG_INTERCOMPANY_RULE`](#org_intercompany_rule) | قواعد التعامل بين الشركات | Intercompany Rules | T | INTERNAL |
| [`ORG_LEGAL_EVENT`](#org_legal_event) | أحداث التغيير القانوني | Legal Entity Change Events | T | INTERNAL |
| [`ORG_LEGAL_EVENT_ENTITY`](#org_legal_event_entity) | أطراف حدث التغيير القانوني | Legal Event Entities | T | INTERNAL |
| [`ORG_COMPANY_CHECK`](#org_company_check) | فحوصات ما قبل تفعيل الشركة | Company Activation Checks | C | INTERNAL |
| [`ORG_CONFIG_SNAPSHOT`](#org_config_snapshot) | لقطات إعدادات الشركة | Configuration Snapshots | C | INTERNAL |
| [`ORG_COMPANY_TEMPLATE`](#org_company_template) | قوالب إنشاء الشركات | Company Templates | TO | INTERNAL |

## PLT_REGION

| البند | القيمة |
|---|---|
| الاسم العربي | المناطق الإقليمية للاستضافة |
| English | Hosting Regions |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
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
| 5 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | دولة الاستضافة |
| 6 | `RESIDENCY_ZONE` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | نطاق إقامة البيانات |
| 7 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_CELL

| البند | القيمة |
|---|---|
| الاسم العربي | الخلايا الإقليمية |
| English | Regional Cells |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | Data Plane مقسم إلى Regional Cells (10.11) |
| مفاتيح فريدة | UK1: (CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 3 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 4 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 5 | `REGION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_REGION |  | إدخال المستخدم |  | المنطقة |
| 6 | `CELL_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SHARED' |  | SHARED, DEDICATED, GOVERNMENT | إدخال المستخدم |  | نوع الخلية |
| 7 | `DB_SERVICE_NAME` | نص | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | خدمة قاعدة البيانات (لا تعرض للمتصفح) |
| 8 | `CAPACITY_TENANTS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | السعة التصميمية من Tenants |
| 9 | `ROLLOUT_CHANNEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'GENERAL' |  | INTERNAL, PILOT, LIMITED, GENERAL | إدخال المستخدم |  | قناة الإصدار |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLANNED' |  | PLANNED, ACTIVE, DRAINING, MAINTENANCE, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_TENANT

| البند | القيمة |
|---|---|
| الاسم العربي | المؤسسات المشتركة |
| English | Tenants |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | المفتاح TENANT_ID ثابت ولا يعاد استخدامه؛ التعليق لا يحذف البيانات (BR-006) |
| مفاتيح فريدة | UK1: (PUBLIC_ID)<br>UK2: (TENANT_CODE)<br>UK3: (TENANT_SLUG) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK1 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 4 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 5 | `TENANT_CODE` | نص | `VARCHAR2(30 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز التجاري الفريد (ثابت بعد التفعيل) |
| 6 | `TENANT_SLUG` | نص | `VARCHAR2(63 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | عنوان الدخول (يتغير بضوابط) |
| 7 | `EXTERNAL_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع خارجي للتكاملات |
| 8 | `ISOLATION_TIER` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SHARED' |  | SHARED, ENHANCED_SHARED, DEDICATED_PDB, DEDICATED_DB, ON_PREMISES | إدخال المستخدم |  | مستوى العزل المتدرج (10.2) |
| 9 | `DEPLOYMENT_MODEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SAAS' |  | SAAS, PRIVATE_CLOUD, ON_PREMISES | إدخال المستخدم |  | نموذج النشر |
| 10 | `HOME_REGION_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_REGION |  | إدخال المستخدم |  | منطقة إقامة البيانات |
| 11 | `CELL_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_CELL |  | إدخال المستخدم |  | الخلية المستضيفة |
| 12 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` | ✔ |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | دولة المؤسسة / Country Pack الأساسي |
| 13 | `DEFAULT_LANGUAGE` | رمز لغة | `VARCHAR2(10 CHAR)` | ✔ | 'ar' | FK→REF_LANGUAGE |  | إدخال المستخدم |  | اللغة الافتراضية |
| 14 | `DEFAULT_TIMEZONE` | نص | `VARCHAR2(64 CHAR)` | ✔ | 'Asia/Riyadh' |  |  | إدخال المستخدم |  | المنطقة الزمنية |
| 15 | `BASE_CURRENCY` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المؤسسة الافتراضية |
| 16 | `LEGAL_HOLD` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | حجز قانوني يمنع الأرشفة والحذف |
| 17 | `AI_ENABLED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | تفعيل AI على مستوى المؤسسة |
| 18 | `ACTIVATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت التفعيل |
| 19 | `SUSPENDED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت التعليق |
| 20 | `CLOSED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الإغلاق |
| 21 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PROSPECT' |  | PROSPECT, TRIAL, PENDING_ACTIVATION, ACTIVE, GRACE_PERIOD, READ_ONLY, SUSPENDED, ARCHIVED, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 22 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 23 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 24 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 25 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 26 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_TENANT_DOMAIN

| البند | القيمة |
|---|---|
| الاسم العربي | نطاقات دخول المؤسسة |
| English | Tenant Domains |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | النطاق يرشح Tenant ولا يثبت الصلاحية؛ يجب التحقق من العضوية |
| مفاتيح فريدة | UK1: (DOMAIN_NAME) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `DOMAIN_NAME` | نص | `VARCHAR2(253 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | النطاق الفرعي أو المخصص (فريد على مستوى المنصة) |
| 4 | `DOMAIN_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SUBDOMAIN, CUSTOM | إدخال المستخدم |  | نوع النطاق |
| 5 | `VERIFICATION_TOKEN_HASH` | Hash | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | Hash رمز إثبات الملكية |
| 6 | `VERIFIED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الإثبات |
| 7 | `IS_PRIMARY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | النطاق الرئيسي |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING_VERIFICATION' |  | PENDING_VERIFICATION, VERIFIED, ACTIVE, DISABLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_TENANT_STATUS_HIST

| البند | القيمة |
|---|---|
| الاسم العربي | سجل حالات المؤسسة |
| English | Tenant Status History |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `FROM_STATUS` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الحالة السابقة |
| 4 | `TO_STATUS` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الحالة الجديدة |
| 5 | `REASON` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | السبب |
| 6 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد |
| 7 | `EFFECTIVE_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | إدخال المستخدم |  | وقت السريان |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## PLT_PROVISIONING_RUN

| البند | القيمة |
|---|---|
| الاسم العربي | عمليات تجهيز المؤسسة |
| English | Tenant Provisioning Runs |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | Provisioning آلي Idempotent قابل للاستئناف من آخر خطوة سليمة (10.4) |
| مفاتيح فريدة | UK2: (TENANT_ID, IDEMPOTENCY_KEY) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `RUN_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | CREATE, ACTIVATE, MOVE_CELL, UPGRADE_TIER, RESTORE, DECOMMISSION | إدخال المستخدم |  | نوع العملية |
| 4 | `IDEMPOTENCY_KEY` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | مفتاح منع التكرار (العملية قابلة للاستئناف) |
| 5 | `LAST_STEP_NO` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | آخر خطوة سليمة |
| 6 | `STARTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | البداية |
| 7 | `FINISHED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | النهاية |
| 8 | `ERROR_MESSAGE` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | رسالة الخطأ (بدون أسرار) |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, RUNNING, WAITING_INPUT, FAILED, COMPLETED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_PROVISIONING_STEP

| البند | القيمة |
|---|---|
| الاسم العربي | خطوات التجهيز |
| English | Provisioning Steps |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (RUN_ID, STEP_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `RUN_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_PROVISIONING_RUN UK1 |  | إدخال المستخدم |  | العملية |
| 4 | `STEP_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الترتيب |
| 5 | `STEP_CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الخطوة (RESERVE_CODE، CREATE_COMPANY، CREATE_ADMIN، SEED_REFERENCE...) |
| 6 | `ATTEMPTS` | عدد صحيح | `NUMBER(10)` | ✔ | 0 |  |  | إدخال المستخدم |  | عدد المحاولات |
| 7 | `STARTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | البداية |
| 8 | `FINISHED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | النهاية |
| 9 | `RESULT_INFO` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | نتيجة الخطوة |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, RUNNING, DONE, FAILED, SKIPPED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_ENVIRONMENT

| البند | القيمة |
|---|---|
| الاسم العربي | بيئات المؤسسة |
| English | Tenant Environments |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `ENV_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PRODUCTION, SANDBOX, TRAINING, UAT, SUPPORT_RECOVERY | إدخال المستخدم |  | نوع البيئة |
| 5 | `SOURCE_ENV_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_ENVIRONMENT |  | إدخال المستخدم |  | البيئة المصدر للنسخ |
| 6 | `DATA_MODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'EMPTY' |  | EMPTY, DEMO, CONFIG_ONLY, MASKED_COPY | إدخال المستخدم |  | نوع البيانات (BR-012) |
| 7 | `IS_MASKED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | تم إخفاء البيانات الحساسة |
| 8 | `INTEGRATIONS_DISABLED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | التكاملات الحقيقية معطلة |
| 9 | `EXPIRES_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | تاريخ الانتهاء |
| 10 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'REQUESTED' |  | REQUESTED, ACTIVE, EXPIRED, DECOMMISSIONED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_SUPPORT_ACCESS

| البند | القيمة |
|---|---|
| الاسم العربي | وصول الدعم المؤقت |
| English | Support Access Grants |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | وصول الدعم مؤقت بسبب وموافقة وينتهي تلقائياً ويرى العميل سجله (10.3) |
| قيود أعمال | ENDS_AT > STARTS_AT |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `SUPPORT_USER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→SEC_USER |  | إدخال المستخدم |  | موظف دعم NOONA |
| 4 | `REASON` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | السبب |
| 5 | `TICKET_REF` | نص | `VARCHAR2(100 CHAR)` |  |  |  |  | إدخال المستخدم |  | رقم التذكرة |
| 6 | `SCOPE_INFO` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | النطاق المسموح |
| 7 | `APPROVED_BY_MEMBER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER_MEMBERSHIP |  | إدخال المستخدم |  | معتمد المؤسسة |
| 8 | `STARTS_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 9 | `ENDS_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | النهاية (ينتهي تلقائياً) |
| 10 | `ALLOW_SENSITIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يسمح بالبيانات الحساسة للضرورة |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'REQUESTED' |  | REQUESTED, APPROVED, ACTIVE, EXPIRED, REVOKED, REJECTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_SETTING_DEF

| البند | القيمة |
|---|---|
| الاسم العربي | تعريفات الإعدادات |
| English | Setting Definitions |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | هرم الإعدادات Platform → Country → Plan → Tenant → Company → Branch → User (10.5) |
| مفاتيح فريدة | UK1: (SETTING_KEY) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 3 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 4 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 5 | `SETTING_KEY` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | مفتاح الإعداد |
| 6 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الحزمة |
| 7 | `DATA_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | STRING, NUMBER, BOOLEAN, DATE, JSON, LOV, SECRET_REF | إدخال المستخدم |  | نوع القيمة |
| 8 | `DEFAULT_VALUE` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | القيمة الافتراضية للمنصة |
| 9 | `ALLOWED_VALUES` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | القيم المسموحة |
| 10 | `MIN_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PLATFORM' |  | PLATFORM, COUNTRY, PLAN, TENANT, COMPANY, BRANCH, USER | إدخال المستخدم |  | أعلى مستوى يمكنه التعديل |
| 11 | `MAX_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'TENANT' |  | PLATFORM, COUNTRY, PLAN, TENANT, COMPANY, BRANCH, USER | إدخال المستخدم |  | أدنى مستوى يمكنه التجاوز |
| 12 | `REQUIRES_APPROVAL` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يحتاج موافقة |
| 13 | `IS_SENSITIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | حساس (لا يعرض كاملاً) |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_SETTING_VALUE

| البند | القيمة |
|---|---|
| الاسم العربي | قيم الإعدادات |
| English | Setting Values |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `SETTING_DEF_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_SETTING_DEF |  | إدخال المستخدم |  | الإعداد |
| 4 | `LEVEL_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PLATFORM, COUNTRY, PLAN, TENANT, COMPANY, BRANCH, USER | إدخال المستخدم |  | مستوى القيمة |
| 5 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | الدولة عند COUNTRY |
| 6 | `PLAN_VERSION_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_PLAN_VERSION |  | إدخال المستخدم |  | الباقة عند PLAN |
| 7 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة عند COMPANY |
| 8 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع عند BRANCH |
| 9 | `USER_ID` | معرف | `NUMBER(19)` |  |  | FK→SEC_USER |  | إدخال المستخدم |  | المستخدم عند USER |
| 10 | `SETTING_VALUE` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | القيمة (الأسرار تخزن كمرجع Vault فقط) |
| 11 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد |
| 12 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 13 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_FEATURE_FLAG

| البند | القيمة |
|---|---|
| الاسم العربي | مفاتيح الخصائص |
| English | Feature Flags |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
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
| 5 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 6 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الحزمة |
| 7 | `FLAG_STATE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DISABLED' |  | DISABLED, INTERNAL, PILOT, PERCENT_ROLLOUT, PLAN_ENABLED, TENANT_ENABLED, GA, DEPRECATED | إدخال المستخدم |  | الحالة |
| 8 | `ROLLOUT_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | نسبة الإطلاق التدريجي |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_FEATURE_FLAG_TENANT

| البند | القيمة |
|---|---|
| الاسم العربي | تفعيل الخاصية للمؤسسة |
| English | Tenant Feature Flags |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, FEATURE_FLAG_ID) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `FEATURE_FLAG_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_FEATURE_FLAG UK1 |  | إدخال المستخدم |  | الخاصية |
| 4 | `IS_ENABLED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | مفعلة |
| 5 | `REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب |
| 6 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 7 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_MODULE

| البند | القيمة |
|---|---|
| الاسم العربي | وحدات المنتج |
| English | Product Modules |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | السجل الموحد للحزم الثلاثين |
| مفاتيح فريدة | UK1: (MODULE_CODE)<br>UK2: (PACKAGE_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 3 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 4 | `MODULE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رمز الحزمة (PLT، GL، AR...) |
| 5 | `PACKAGE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم الحزمة في السجل الموحد (01..30) |
| 6 | `PLSQL_PACKAGE` | نص | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | الحزمة البرمجية المالكة |
| 7 | `IS_CORE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | نواة إلزامية |
| 8 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 9 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_FEATURE

| البند | القيمة |
|---|---|
| الاسم العربي | خصائص الوحدات |
| English | Module Features |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
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
| 5 | `MODULE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_MODULE |  | إدخال المستخدم |  | الوحدة |
| 6 | `IS_METERED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | خاصية مقاسة الاستهلاك |
| 7 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 10 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 11 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_USAGE_METRIC

| البند | القيمة |
|---|---|
| الاسم العربي | مقاييس الاستهلاك |
| English | Usage Metrics |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | مستخدمون، فروع، شركات، تخزين، AI، OCR، API، رسائل... |
| مفاتيح فريدة | UK1: (CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 3 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 4 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 5 | `UNIT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الوحدة (USER، GB، CALL، TOKEN، PAGE...) |
| 6 | `AGGREGATION` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'MAX' |  | SUM, MAX, LAST, COUNT_DISTINCT | إدخال المستخدم |  | طريقة التجميع للفترة |
| 7 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 10 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 11 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_PRODUCT

| البند | القيمة |
|---|---|
| الاسم العربي | المنتجات |
| English | Products |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
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
| 5 | `DESCRIPTION` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوصف |
| 6 | `PRODUCT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SAAS, ON_PREMISES, PRIVATE_CLOUD, SERVICE, USAGE | إدخال المستخدم |  | نوع المنتج |
| 7 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_EDITION

| البند | القيمة |
|---|---|
| الاسم العربي | الإصدارات التجارية |
| English | Editions |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
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
| 5 | `PRODUCT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_PRODUCT |  | إدخال المستخدم |  | المنتج |
| 6 | `SEGMENT_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | STARTER, BUSINESS, ENTERPRISE, GOVERNMENT, ONPREM_ENTERPRISE | إدخال المستخدم |  | الشريحة |
| 7 | `TARGET_AVAILABILITY` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | التوفر المستهدف |
| 8 | `RPO_MINUTES` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | RPO المستهدف بالدقائق |
| 9 | `RTO_MINUTES` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | RTO المستهدف بالدقائق |
| 10 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 11 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_PLAN

| البند | القيمة |
|---|---|
| الاسم العربي | الباقات |
| English | Plans |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
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
| 5 | `EDITION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_EDITION |  | إدخال المستخدم |  | الإصدار |
| 6 | `BILLING_CYCLE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | MONTHLY, QUARTERLY, SEMI_ANNUAL, ANNUAL, MULTI_YEAR, ONE_TIME, CONTRACT | إدخال المستخدم |  | دورة الفوترة |
| 7 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_PLAN_VERSION

| البند | القيمة |
|---|---|
| الاسم العربي | إصدارات الباقة |
| English | Plan Versions |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا تعدل Plan Version بعد استخدامها في عقد؛ تنشأ نسخة جديدة (11.2) |
| مفاتيح فريدة | UK1: (PLAN_ID, VERSION_NO) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PLAN_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_PLAN UK1 |  | إدخال المستخدم |  | الباقة |
| 3 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رقم الإصدار |
| 4 | `TRIAL_DAYS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | مدة التجربة |
| 5 | `GRACE_DAYS` | عدد صحيح | `NUMBER(10)` | ✔ | 15 |  |  | إدخال المستخدم |  | فترة السماح |
| 6 | `READ_ONLY_DAYS` | عدد صحيح | `NUMBER(10)` | ✔ | 30 |  |  | إدخال المستخدم |  | فترة القراءة فقط |
| 7 | `SLA_INFO` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | مستوى الخدمة والدعم |
| 8 | `IS_LOCKED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | مقفلة بعد استخدامها في عقد (لا تعدل) |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, PUBLISHED, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 11 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_PLAN_MODULE

| البند | القيمة |
|---|---|
| الاسم العربي | وحدات إصدار الباقة |
| English | Plan Version Modules |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (PLAN_VERSION_ID, MODULE_ID, FEATURE_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PLAN_VERSION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_PLAN_VERSION UK1 |  | إدخال المستخدم |  | إصدار الباقة |
| 3 | `MODULE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_MODULE UK1 |  | إدخال المستخدم |  | الوحدة |
| 4 | `FEATURE_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_FEATURE UK1 |  | إدخال المستخدم |  | الخاصية (فارغ = الوحدة كاملة) |
| 5 | `INCLUSION_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | INCLUDED, OPTIONAL_ADDON, TRIAL, NOT_AVAILABLE, CONTRACT_ONLY | إدخال المستخدم |  | نوع الإتاحة |
| 6 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 7 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 8 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 9 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 10 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_PLAN_LIMIT

| البند | القيمة |
|---|---|
| الاسم العربي | حدود إصدار الباقة |
| English | Plan Version Limits |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (PLAN_VERSION_ID, METRIC_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PLAN_VERSION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_PLAN_VERSION UK1 |  | إدخال المستخدم |  | إصدار الباقة |
| 3 | `METRIC_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_USAGE_METRIC UK1 |  | إدخال المستخدم |  | المقياس |
| 4 | `INCLUDED_QTY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الكمية المشمولة |
| 5 | `SOFT_LIMIT` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد المرن (تنبيه مراقب) |
| 6 | `HARD_LIMIT` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد الصلب (منع) |
| 7 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 10 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 11 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_ADDON

| البند | القيمة |
|---|---|
| الاسم العربي | الإضافات |
| English | Add-ons |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
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
| 5 | `ADDON_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | USERS, BRANCHES, COMPANIES, TENANT_SLOT, STORAGE, AI, OCR, API, SANDBOX, PREMIUM_SUPPORT, DEDICATED_CELL, COUNTRY_PACK, TRAINING, IMPLEMENTATION | إدخال المستخدم |  | نوع الإضافة |
| 6 | `METRIC_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_USAGE_METRIC |  | إدخال المستخدم |  | المقياس المرتبط |
| 7 | `MODULE_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_MODULE |  | إدخال المستخدم |  | الوحدة المرتبطة |
| 8 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_PRICE_BOOK

| البند | القيمة |
|---|---|
| الاسم العربي | دفاتر الأسعار |
| English | Price Books |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | الأسعار منفصلة عن تعريف الباقة؛ تغييرها لا يمس العقود القائمة |
| مفاتيح فريدة | UK1: (CODE) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 3 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 4 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 5 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | الدولة |
| 6 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 7 | `SALES_CHANNEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DIRECT' |  | DIRECT, PARTNER, RESELLER, ONLINE, GOVERNMENT | إدخال المستخدم |  | قناة البيع |
| 8 | `CUSTOMER_CLASS` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | فئة العميل |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 11 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_PRICE_BOOK_ENTRY

| البند | القيمة |
|---|---|
| الاسم العربي | أسعار دفتر الأسعار |
| English | Price Book Entries |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM<br>(CASE WHEN PLAN_VERSION_ID IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN ADDON_ID IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN METRIC_ID IS NOT NULL THEN 1 ELSE 0 END) = 1 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PRICE_BOOK_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_PRICE_BOOK |  | إدخال المستخدم |  | دفتر الأسعار |
| 3 | `PLAN_VERSION_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_PLAN_VERSION |  | إدخال المستخدم |  | إصدار الباقة |
| 4 | `ADDON_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_ADDON |  | إدخال المستخدم |  | الإضافة |
| 5 | `METRIC_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_USAGE_METRIC |  | إدخال المستخدم |  | المقياس (تسعير الاستهلاك) |
| 6 | `PRICING_MODEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | FLAT, PER_UNIT, TIERED, VOLUME, PACKAGE, OVERAGE, MINIMUM | إدخال المستخدم |  | نموذج التسعير |
| 7 | `UNIT_PRICE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | سعر الوحدة |
| 8 | `TIERS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | شرائح التسعير |
| 9 | `MIN_PRICE` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد الأدنى للسعر |
| 10 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 11 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_PARTNER

| البند | القيمة |
|---|---|
| الاسم العربي | الشركاء والموزعون |
| English | Partners & Resellers |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
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
| 5 | `PARTNER_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PARTNER, RESELLER, REFERRAL, IMPLEMENTER | إدخال المستخدم |  | النوع |
| 6 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | الدولة |
| 7 | `COMMISSION_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | نسبة العمولة الافتراضية |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, SUSPENDED, TERMINATED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_PROMOTION

| البند | القيمة |
|---|---|
| الاسم العربي | العروض الترويجية |
| English | Promotions |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (CODE)<br>UK2: (COUPON_CODE) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 3 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 4 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 5 | `DISCOUNT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PERCENT, FIXED, FREE_PERIOD, SETUP_WAIVER, CREDIT | إدخال المستخدم |  | نوع الخصم |
| 6 | `DISCOUNT_VALUE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | قيمة الخصم |
| 7 | `COUPON_CODE` | نص | `VARCHAR2(50 CHAR)` |  |  | UK2 |  | إدخال المستخدم |  | كود الخصم |
| 8 | `MAX_REDEMPTIONS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | حد الاستخدام |
| 9 | `SINGLE_USE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | استخدام مرة واحدة لكل عميل |
| 10 | `SCOPE_RULES` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | نطاق الدولة/الباقة/العملة/القطاع |
| 11 | `STACKABLE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | قابل للجمع مع خصومات أخرى |
| 12 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, EXPIRED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 13 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 14 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_QUOTE

| البند | القيمة |
|---|---|
| الاسم العربي | عروض أسعار الاشتراك |
| English | Subscription Quotes |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (QUOTE_NO, REVISION_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 5 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 6 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 7 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 8 | `QUOTE_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | رقم العرض |
| 9 | `REVISION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 | UK3 |  | إدخال المستخدم |  | رقم المراجعة (التعديل بعد الإرسال ينشئ Revision) |
| 10 | `PREVIOUS_QUOTE_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_QUOTE |  | إدخال المستخدم |  | المراجعة السابقة |
| 11 | `PRICE_BOOK_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_PRICE_BOOK |  | إدخال المستخدم |  | دفتر الأسعار |
| 12 | `PARTNER_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_PARTNER |  | إدخال المستخدم |  | الشريك |
| 13 | `VALID_UNTIL` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | صلاحية العرض |
| 14 | `TOTAL_BEFORE_DISCOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الإجمالي قبل الخصم |
| 15 | `DISCOUNT_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الخصم |
| 16 | `ESTIMATED_TAX` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الضريبة التقديرية |
| 17 | `TOTAL_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الإجمالي |
| 18 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | معتمد الخصم (فصل واجبات عن المنشئ) |
| 19 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, UNDER_REVIEW, APPROVED, SENT, ACCEPTED, REJECTED, EXPIRED, SUPERSEDED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 20 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 21 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 22 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 23 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 24 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_QUOTE_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | بنود عرض الاشتراك |
| English | Subscription Quote Lines |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (QUOTE_ID, LINE_NO) |
| قيود أعمال | NET_PRICE >= 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `QUOTE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_QUOTE UK1 |  | إدخال المستخدم |  | العرض |
| 4 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | السطر |
| 5 | `PLAN_VERSION_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_PLAN_VERSION |  | إدخال المستخدم |  | إصدار الباقة |
| 6 | `ADDON_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_ADDON |  | إدخال المستخدم |  | الإضافة |
| 7 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ | 1 |  |  | إدخال المستخدم |  | الكمية |
| 8 | `LIST_PRICE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | السعر الأصلي |
| 9 | `DISCOUNT_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | نسبة الخصم |
| 10 | `NET_PRICE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | السعر النهائي |
| 11 | `PROMOTION_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_PROMOTION |  | إدخال المستخدم |  | العرض الترويجي |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_CONTRACT

| البند | القيمة |
|---|---|
| الاسم العربي | عقود المنصة |
| English | Platform Contracts |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا يعدل العقد الموقع مباشرة؛ تنشأ Amendment بإصدار مستقل (11.3) |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (TENANT_ID, CONTRACT_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 5 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 6 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 7 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 8 | `CONTRACT_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | رقم العقد |
| 9 | `QUOTE_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_QUOTE |  | إدخال المستخدم |  | العرض المصدر |
| 10 | `LEGAL_PARTY_NAME` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الجهة القانونية المتعاقدة |
| 11 | `START_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 12 | `END_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | النهاية |
| 13 | `AUTO_RENEW` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | تجديد تلقائي |
| 14 | `GRACE_DAYS` | عدد صحيح | `NUMBER(10)` | ✔ | 15 |  |  | إدخال المستخدم |  | فترة السماح التعاقدية |
| 15 | `READ_ONLY_DAYS` | عدد صحيح | `NUMBER(10)` | ✔ | 30 |  |  | إدخال المستخدم |  | فترة القراءة فقط التعاقدية |
| 16 | `SIGNED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت التوقيع |
| 17 | `SIGNED_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | نسخة العقد الموقعة |
| 18 | `CURRENT_VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | رقم آخر Amendment |
| 19 | `TERMINATION_REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الإنهاء |
| 20 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, UNDER_REVIEW, APPROVED, SIGNED, ACTIVE, EXPIRED, TERMINATED, RENEWED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 21 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 22 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 23 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 24 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 25 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_CONTRACT_VERSION

| البند | القيمة |
|---|---|
| الاسم العربي | تعديلات العقد |
| English | Contract Amendments |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (CONTRACT_ID, VERSION_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CONTRACT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_CONTRACT UK1 |  | إدخال المستخدم |  | العقد |
| 4 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رقم الإصدار |
| 5 | `AMENDMENT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ORIGINAL, AMENDMENT, ADDENDUM, RENEWAL | إدخال المستخدم |  | النوع |
| 6 | `EFFECTIVE_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ السريان |
| 7 | `TERMS_SNAPSHOT` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | لقطة الشروط والأسعار والحدود |
| 8 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | المستند |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, SIGNED, EFFECTIVE, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_SUBSCRIPTION

| البند | القيمة |
|---|---|
| الاسم العربي | الاشتراكات |
| English | Subscriptions |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (TENANT_ID, SUBSCRIPTION_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `SUBSCRIPTION_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | رقم الاشتراك |
| 5 | `CONTRACT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_CONTRACT |  | إدخال المستخدم |  | العقد |
| 6 | `PLAN_VERSION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_PLAN_VERSION |  | إدخال المستخدم |  | إصدار الباقة المتعاقد عليه |
| 7 | `BILLING_CYCLE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | MONTHLY, QUARTERLY, SEMI_ANNUAL, ANNUAL, MULTI_YEAR, ONE_TIME, CONTRACT | إدخال المستخدم |  | دورة الفوترة |
| 8 | `CURRENT_PERIOD_START` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | بداية الفترة الحالية |
| 9 | `CURRENT_PERIOD_END` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | نهاية الفترة الحالية |
| 10 | `NEXT_BILLING_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الفوترة التالي |
| 11 | `GRACE_ENDS_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | نهاية فترة السماح |
| 12 | `READ_ONLY_ENDS_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | نهاية القراءة فقط |
| 13 | `SCHEDULED_PLAN_VERSION_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_PLAN_VERSION |  | إدخال المستخدم |  | الباقة المجدولة (Downgrade) |
| 14 | `CANCEL_REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الإلغاء |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, TRIAL, ACTIVE, GRACE_PERIOD, READ_ONLY, SUSPENDED, CANCELLED, EXPIRED, UPGRADE_PENDING, DOWNGRADE_SCHEDULED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_SUBSCRIPTION_ITEM

| البند | القيمة |
|---|---|
| الاسم العربي | بنود الاشتراك |
| English | Subscription Items |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `SUBSCRIPTION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_SUBSCRIPTION |  | إدخال المستخدم |  | الاشتراك |
| 4 | `ADDON_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_ADDON |  | إدخال المستخدم |  | الإضافة (فارغ = الباقة الأساسية) |
| 5 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ | 1 |  |  | إدخال المستخدم |  | الكمية |
| 6 | `UNIT_PRICE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | السعر المتعاقد |
| 7 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 8 | `PRICE_SNAPSHOT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | لقطة التسعير |
| 9 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 10 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_SUBSCRIPTION_SNAPSHOT

| البند | القيمة |
|---|---|
| الاسم العربي | لقطات حقوق الاشتراك |
| English | Subscription Snapshots |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `SUBSCRIPTION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_SUBSCRIPTION |  | إدخال المستخدم |  | الاشتراك |
| 4 | `SNAPSHOT_REASON` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ACTIVATION, RENEWAL, UPGRADE, DOWNGRADE, AMENDMENT, REACTIVATION | إدخال المستخدم |  | سبب اللقطة |
| 5 | `SNAPSHOT_DATA` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | ما اشتراه العميل فعلياً (لا يتغير بتعديل الكتالوج) |
| 6 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 7 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## PLT_ENTITLEMENT

| البند | القيمة |
|---|---|
| الاسم العربي | الاستحقاقات الفعلية |
| English | Effective Entitlements |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | Plan + Add-ons + Overrides + Trial - Suspended = Effective Entitlements؛ يطبق في APEX وPL/SQL وORDS |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `MODULE_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_MODULE |  | إدخال المستخدم |  | الوحدة |
| 4 | `FEATURE_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_FEATURE |  | إدخال المستخدم |  | الخاصية |
| 5 | `METRIC_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_USAGE_METRIC |  | إدخال المستخدم |  | المقياس |
| 6 | `IS_ENABLED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | مفعل |
| 7 | `LIMIT_QTY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد الفعلي |
| 8 | `SOFT_LIMIT` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد المرن |
| 9 | `HARD_LIMIT` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد الصلب |
| 10 | `SOURCE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PLAN, ADDON, CONTRACT_OVERRIDE, TRIAL, EXCEPTION, SUSPENSION | إدخال المستخدم |  | مصدر الحق |
| 11 | `SUBSCRIPTION_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_SUBSCRIPTION |  | إدخال المستخدم |  | الاشتراك |
| 12 | `COMPUTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | إدخال المستخدم |  | وقت الحساب (Cache؛ المصدر الرسمي العقد) |
| 13 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 14 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 15 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 16 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 17 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 18 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 19 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_ENTITLEMENT_OVERRIDE

| البند | القيمة |
|---|---|
| الاسم العربي | الاستثناءات التعاقدية للحقوق |
| English | Entitlement Overrides |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `MODULE_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_MODULE |  | إدخال المستخدم |  | الوحدة |
| 4 | `FEATURE_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_FEATURE |  | إدخال المستخدم |  | الخاصية |
| 5 | `METRIC_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_USAGE_METRIC |  | إدخال المستخدم |  | المقياس |
| 6 | `OVERRIDE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ENABLE, DISABLE, LIMIT, BURST, GRACE_EXTENSION, GOVERNMENT_EXEMPTION | إدخال المستخدم |  | النوع |
| 7 | `LIMIT_QTY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد الجديد |
| 8 | `REASON` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | السبب |
| 9 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, ACTIVE, EXPIRED, REVOKED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 12 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 13 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 14 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 15 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 16 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 17 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_TRIAL

| البند | القيمة |
|---|---|
| الاسم العربي | التجارب و Pilot |
| English | Trials & Pilots |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `TRIAL_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SELF_SERVICE, SALES_INVITE, PILOT, MODULE_TRIAL, ADDON_TRIAL, POC | إدخال المستخدم |  | نوع التجربة |
| 4 | `PLAN_VERSION_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_PLAN_VERSION |  | إدخال المستخدم |  | الباقة المجربة |
| 5 | `STARTS_ON` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 6 | `ENDS_ON` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | النهاية |
| 7 | `IDENTITY_HASH` | Hash | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | Hash هوية المسجل لمنع التجارب المتكررة |
| 8 | `CONVERTED_SUBSCRIPTION_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_SUBSCRIPTION |  | إدخال المستخدم |  | الاشتراك الناتج بعد التحويل |
| 9 | `SUCCESS_CRITERIA` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | معايير نجاح Pilot |
| 10 | `DATA_FATE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | KEEP, EXPORT_AND_ARCHIVE, PURGE_AFTER_RETENTION | إدخال المستخدم |  | مصير البيانات عند عدم التعاقد |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, EXTENDED, CONVERTED, EXPIRED, READ_ONLY, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_USAGE_EVENT

| البند | القيمة |
|---|---|
| الاسم العربي | أحداث الاستهلاك |
| English | Usage Events |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |
| الاحتفاظ | حسب سياسة الفوترة؛ تقسيم مقترح بالشهر |
| مفاتيح فريدة | UK1: (TENANT_ID, IDEMPOTENCY_KEY) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `METRIC_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_USAGE_METRIC |  | إدخال المستخدم |  | المقياس |
| 4 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الكمية |
| 5 | `OCCURRED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ |  |  |  | إدخال المستخدم |  | وقت الحدث |
| 6 | `IDEMPOTENCY_KEY` | نص | `VARCHAR2(100 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | مفتاح منع التكرار |
| 7 | `SOURCE_MODULE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الوحدة المصدر |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## PLT_USAGE_SUMMARY

| البند | القيمة |
|---|---|
| الاسم العربي | ملخص الاستهلاك للفترة |
| English | Usage Summary |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, METRIC_ID, PERIOD_START) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `METRIC_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_USAGE_METRIC UK1 |  | إدخال المستخدم |  | المقياس |
| 4 | `PERIOD_START` | تاريخ | `DATE` | ✔ |  | UK1 |  | إدخال المستخدم |  | بداية الفترة |
| 5 | `PERIOD_END` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | نهاية الفترة |
| 6 | `TOTAL_QTY` | كمية | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الإجمالي |
| 7 | `INCLUDED_QTY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المشمول |
| 8 | `BILLABLE_QTY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | القابل للفوترة |
| 9 | `ALERT_LEVEL_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | آخر عتبة تنبيه (70/85/100) |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, LOCKED, BILLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_BILLING_PERIOD

| البند | القيمة |
|---|---|
| الاسم العربي | فترات الفوترة |
| English | Billing Periods |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (PERIOD_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PERIOD_CODE` | نص | `VARCHAR2(20 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | رمز الفترة (YYYY-MM) |
| 3 | `START_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 4 | `END_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | النهاية |
| 5 | `CLOSED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | منفذ الإقفال |
| 6 | `CLOSED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الإقفال |
| 7 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, CLOSING, CLOSED, REOPENED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_BILLING_INVOICE

| البند | القيمة |
|---|---|
| الاسم العربي | فواتير المنصة |
| English | Platform Invoices |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | Platform Billing مستقل عن محاسبة أعمال Tenant (11.4) |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (TENANT_ID, INVOICE_NO) |
| مفاتيح فريدة مشروطة | NUK1: (TENANT_ID, IDEMPOTENCY_KEY) عند عدم فراغ IDEMPOTENCY_KEY |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 5 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 6 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 7 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 8 | `INVOICE_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | رقم الفاتورة |
| 9 | `DOC_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INVOICE' |  | INVOICE, CREDIT_NOTE, DEBIT_NOTE | إدخال المستخدم |  | النوع |
| 10 | `ORIGINAL_INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_BILLING_INVOICE |  | إدخال المستخدم |  | الفاتورة الأصلية للإشعار |
| 11 | `SUBSCRIPTION_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_SUBSCRIPTION |  | إدخال المستخدم |  | الاشتراك |
| 12 | `BILLING_PERIOD_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_BILLING_PERIOD |  | إدخال المستخدم |  | فترة الفوترة |
| 13 | `INVOICE_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ الإصدار |
| 14 | `DUE_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ الاستحقاق |
| 15 | `SUBTOTAL` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | قبل الضريبة والخصم |
| 16 | `DISCOUNT_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الخصم |
| 17 | `TAX_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الضريبة |
| 18 | `TOTAL_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الإجمالي |
| 19 | `PAID_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المدفوع |
| 20 | `TAX_SNAPSHOT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | لقطة الضريبة |
| 21 | `IDEMPOTENCY_KEY` | نص | `VARCHAR2(100 CHAR)` |  |  | NUK1 |  | إدخال المستخدم |  | منع إصدار الفاتورة مرتين |
| 22 | `ISSUED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الإصدار (لا تعدل بعده) |
| 23 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, CALCULATED, REVIEWED, APPROVED, ISSUED, PARTIALLY_PAID, PAID, VOID, OVERDUE, DISPUTED, CREDITED, WRITTEN_OFF | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 24 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 25 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 26 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 27 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 28 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_BILLING_INVOICE_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | بنود فواتير المنصة |
| English | Platform Invoice Lines |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (INVOICE_ID, LINE_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `INVOICE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_BILLING_INVOICE UK1 |  | إدخال المستخدم |  | الفاتورة |
| 4 | `LINE_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | السطر |
| 5 | `LINE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SUBSCRIPTION, ADDON, USAGE, PRORATION, SETUP, SERVICE, DISCOUNT, ADJUSTMENT | إدخال المستخدم |  | نوع البند |
| 6 | `SUBSCRIPTION_ITEM_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_SUBSCRIPTION_ITEM |  | إدخال المستخدم |  | بند الاشتراك |
| 7 | `METRIC_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_USAGE_METRIC |  | إدخال المستخدم |  | المقياس |
| 8 | `DESCRIPTION` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الوصف |
| 9 | `QUANTITY` | كمية | `NUMBER(24,6)` | ✔ | 1 |  |  | إدخال المستخدم |  | الكمية |
| 10 | `UNIT_PRICE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | السعر |
| 11 | `LINE_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 12 | `TAX_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الضريبة |
| 13 | `CALC_INFO` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | معادلة الحساب (Proration/Usage) |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_BILLING_PAYMENT

| البند | القيمة |
|---|---|
| الاسم العربي | مدفوعات المنصة |
| English | Platform Payments |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (TENANT_ID, PAYMENT_NO) |
| مفاتيح فريدة مشروطة | NUK1: (TENANT_ID, IDEMPOTENCY_KEY) عند عدم فراغ IDEMPOTENCY_KEY<br>NUK2: (PROVIDER_CODE, PROVIDER_REFERENCE) عند عدم فراغ PROVIDER_REFERENCE |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 5 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 6 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 7 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 8 | `PAYMENT_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | رقم الدفعة |
| 9 | `PAYMENT_METHOD` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | GATEWAY, BANK_TRANSFER, CHEQUE, CASH, MANUAL | إدخال المستخدم |  | طريقة الدفع |
| 10 | `PROVIDER_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | مزود الدفع |
| 11 | `PROVIDER_REFERENCE` | نص | `VARCHAR2(200 CHAR)` |  |  | NUK2 |  | إدخال المستخدم |  | مرجع المزود (فريد مع المزود لمنع التكرار) |
| 12 | `IDEMPOTENCY_KEY` | نص | `VARCHAR2(100 CHAR)` |  |  | NUK1 |  | إدخال المستخدم |  | مفتاح Webhook |
| 13 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 14 | `UNALLOCATED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | غير المخصص |
| 15 | `RECEIVED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الاستلام |
| 16 | `RECEIPT_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | إيصال التحويل البنكي |
| 17 | `VERIFIED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المطابق (فصل واجبات عن المدخل) |
| 18 | `VERIFIED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت المطابقة |
| 19 | `REJECT_REASON` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الرفض |
| 20 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, PENDING_VERIFICATION, CONFIRMED, REJECTED, FAILED, REFUNDED, PARTIALLY_REFUNDED, CHARGEBACK | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 21 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 22 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 23 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 24 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 25 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_BILLING_ALLOCATION

| البند | القيمة |
|---|---|
| الاسم العربي | تخصيص مدفوعات المنصة |
| English | Platform Payment Allocations |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | AMOUNT > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `PAYMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_BILLING_PAYMENT |  | إدخال المستخدم |  | الدفعة |
| 4 | `INVOICE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_BILLING_INVOICE |  | إدخال المستخدم |  | الفاتورة |
| 5 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ المخصص |
| 6 | `APPLIED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | إدخال المستخدم |  | وقت التخصيص |
| 7 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'APPLIED' |  | APPLIED, REVERSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_REFUND

| البند | القيمة |
|---|---|
| الاسم العربي | الاسترداد ورد المبالغ المتنازع عليها |
| English | Refunds & Chargebacks |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | AMOUNT > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `PAYMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_BILLING_PAYMENT |  | إدخال المستخدم |  | الدفعة الأصلية |
| 4 | `REFUND_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | REFUND, PARTIAL_REFUND, CHARGEBACK | إدخال المستخدم |  | النوع |
| 5 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 6 | `REASON` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | السبب |
| 7 | `PROVIDER_REFERENCE` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | مرجع المزود |
| 8 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'REQUESTED' |  | REQUESTED, APPROVED, PROCESSED, REJECTED, DISPUTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_DUNNING_POLICY

| البند | القيمة |
|---|---|
| الاسم العربي | سياسات التحصيل |
| English | Dunning Policies |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
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
| 5 | `EDITION_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_EDITION |  | إدخال المستخدم |  | الإصدار |
| 6 | `REMINDER_DAYS` | نص | `VARCHAR2(100 CHAR)` | ✔ | '30,15,7,3' |  |  | إدخال المستخدم |  | أيام التنبيه قبل الاستحقاق |
| 7 | `GRACE_DAYS` | عدد صحيح | `NUMBER(10)` | ✔ | 15 |  |  | إدخال المستخدم |  | فترة السماح |
| 8 | `READ_ONLY_DAYS` | عدد صحيح | `NUMBER(10)` | ✔ | 30 |  |  | إدخال المستخدم |  | فترة القراءة فقط |
| 9 | `CHANNELS` | نص | `VARCHAR2(200 CHAR)` | ✔ | 'IN_APP,EMAIL' |  |  | إدخال المستخدم |  | قنوات التنبيه |
| 10 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_DUNNING_EVENT

| البند | القيمة |
|---|---|
| الاسم العربي | أحداث التحصيل |
| English | Dunning Events |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_BILLING_INVOICE |  | إدخال المستخدم |  | الفاتورة |
| 4 | `SUBSCRIPTION_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_SUBSCRIPTION |  | إدخال المستخدم |  | الاشتراك |
| 5 | `EVENT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | REMINDER, OVERDUE_NOTICE, GRACE_STARTED, READ_ONLY_STARTED, SUSPENDED, REACTIVATED, HOLD_APPLIED | إدخال المستخدم |  | الحدث |
| 6 | `CHANNEL` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | القناة |
| 7 | `NOTIFICATION_ID` | معرف | `NUMBER(19)` |  |  | FK→NTF_NOTIFICATION |  | إدخال المستخدم |  | الإشعار المرسل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## PLT_BILLING_DISPUTE

| البند | القيمة |
|---|---|
| الاسم العربي | نزاعات الفوترة |
| English | Billing Disputes |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `INVOICE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_BILLING_INVOICE |  | إدخال المستخدم |  | الفاتورة |
| 4 | `DISPUTED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ المتنازع عليه |
| 5 | `REASON` | نص | `VARCHAR2(1000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | السبب |
| 6 | `SUSPEND_DUNNING` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | تعليق التحصيل للمبلغ |
| 7 | `OWNER_USER` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المسؤول |
| 8 | `RESOLUTION` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | النتيجة |
| 9 | `CREDIT_NOTE_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_BILLING_INVOICE |  | إدخال المستخدم |  | الإشعار الدائن الناتج |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, UNDER_REVIEW, RESOLVED_CREDIT, RESOLVED_NO_CHANGE, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_PAYMENT_PROMISE

| البند | القيمة |
|---|---|
| الاسم العربي | وعود الدفع |
| English | Payment Promises |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `INVOICE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_BILLING_INVOICE |  | إدخال المستخدم |  | الفاتورة |
| 4 | `PROMISED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 5 | `PROMISED_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | التاريخ المتوقع |
| 6 | `PAYMENT_METHOD` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الطريقة |
| 7 | `STOPS_SUSPENSION` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يوقف التعليق (يتطلب موافقة) |
| 8 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, KEPT, BROKEN, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_COMMISSION

| البند | القيمة |
|---|---|
| الاسم العربي | العمولات |
| English | Commissions |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا تستحق نهائياً قبل تحقق شروط التحصيل، وتعكس عند الاسترداد |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `PARTNER_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_PARTNER |  | إدخال المستخدم |  | الشريك |
| 4 | `CONTRACT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_CONTRACT |  | إدخال المستخدم |  | العقد |
| 5 | `INVOICE_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_BILLING_INVOICE |  | إدخال المستخدم |  | الفاتورة |
| 6 | `BASE_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | أساس العمولة |
| 7 | `COMMISSION_PCT` | نسبة | `NUMBER(9,6)` | ✔ |  |  |  | إدخال المستخدم |  | النسبة |
| 8 | `COMMISSION_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACCRUED' |  | ACCRUED, ELIGIBLE, APPROVED, PAID, REVERSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_ONPREM_LICENSE

| البند | القيمة |
|---|---|
| الاسم العربي | تراخيص On-Premises |
| English | On-Premises Licenses |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (PUBLIC_ID)<br>UK2: (LICENSE_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK1 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `LICENSE_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم الترخيص |
| 4 | `CUSTOMER_NAME` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | العميل |
| 5 | `LICENSE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ANNUAL, PERPETUAL, ENTERPRISE_CONTRACT, GOVERNMENT_CONTRACT | إدخال المستخدم |  | نوع الترخيص |
| 6 | `MAX_TENANTS` | عدد صحيح | `NUMBER(10)` | ✔ |  |  |  | إدخال المستخدم |  | الحد الأقصى للمؤسسات (لا يحرر التعليق Slot - BR-010) |
| 7 | `MAX_USERS` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | المستخدمون |
| 8 | `MAX_COMPANIES` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الشركات |
| 9 | `MAX_BRANCHES` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | الفروع |
| 10 | `ENVIRONMENTS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | حدود البيئات Production/DR/UAT/Test... |
| 11 | `MODULES` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | الوحدات المرخصة |
| 12 | `VALID_FROM` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 13 | `VALID_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | النهاية (فارغ للدائم) |
| 14 | `MAINTENANCE_EXPIRY` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | نهاية الصيانة والدعم |
| 15 | `GRACE_DAYS` | عدد صحيح | `NUMBER(10)` | ✔ | 30 |  |  | إدخال المستخدم |  | فترة السماح |
| 16 | `ENV_FINGERPRINT` | Hash | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | بصمة البيئة |
| 17 | `LICENSE_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | إصدار صيغة الترخيص |
| 18 | `SIGNED_PAYLOAD` | نص طويل | `CLOB` | ✔ |  |  |  | إدخال المستخدم |  | ملف الترخيص الموقع رقمياً |
| 19 | `SIGNATURE` | نص | `VARCHAR2(4000 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | التوقيع |
| 20 | `PREVIOUS_LICENSE_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_ONPREM_LICENSE |  | إدخال المستخدم |  | الترخيص السابق |
| 21 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ISSUED, ACTIVE, GRACE, READ_ONLY, EXPIRED, REVOKED, SUPERSEDED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 22 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 23 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 24 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 25 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 26 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PLT_LICENSE_ACTIVATION

| البند | القيمة |
|---|---|
| الاسم العربي | تفعيلات الترخيص |
| English | License Activations |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `G` — منصة عامة Platform Global (بدون TENANT_ID) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `LICENSE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_ONPREM_LICENSE |  | إدخال المستخدم |  | الترخيص |
| 3 | `ACTIVATION_MODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ONLINE, OFFLINE | إدخال المستخدم |  | نمط التفعيل |
| 4 | `SERVER_FINGERPRINT` | Hash | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | بصمة الخادم |
| 5 | `ACTIVATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | إدخال المستخدم |  | وقت التفعيل |
| 6 | `DEACTIVATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت إلغاء التفعيل (النقل لخادم جديد) |
| 7 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, DEACTIVATED, TRANSFERRED, RECOVERED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 8 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 9 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 10 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 11 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 12 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_BUSINESS_GROUP

| البند | القيمة |
|---|---|
| الاسم العربي | مجموعات الأعمال |
| English | Business Groups |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | مجموعة قابضة اختيارية لتنظيم شركات مرتبطة (12.2) |
| مفاتيح فريدة | UK2: (TENANT_ID, CODE) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `CONSOLIDATION_CURRENCY` | رمز عملة ISO | `VARCHAR2(3 CHAR)` |  |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة التجميع |
| 7 | `PARENT_GROUP_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_GROUP |  | إدخال المستخدم |  | المجموعة الأم |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, INACTIVE | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 10 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_COMPANY

| البند | القيمة |
|---|---|
| الاسم العربي | الشركات (الكيانات القانونية) |
| English | Companies / Legal Entities |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | كيان قانوني مستقل له تسجيل وضرائب ودفاتر وعملة؛ تغيير الاسم لا يغير COMPANY_ID |
| مفاتيح فريدة | UK2: (TENANT_ID, CODE)<br>UK3: (PUBLIC_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK3 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `BUSINESS_GROUP_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BUSINESS_GROUP |  | إدخال المستخدم |  | مجموعة الأعمال |
| 6 | `LEGAL_NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم القانوني بالعربية |
| 7 | `LEGAL_NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم القانوني بالإنجليزية |
| 8 | `TRADE_NAME_AR` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم التجاري بالعربية |
| 9 | `TRADE_NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم التجاري بالإنجليزية |
| 10 | `LEGAL_FORM_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | الشكل القانوني (من Country Pack) |
| 11 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` | ✔ |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | دولة التسجيل |
| 12 | `COUNTRY_PACK_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_COUNTRY_PACK |  | إدخال المستخدم |  | حزمة الدولة المطبقة |
| 13 | `INCORPORATION_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ التأسيس |
| 14 | `FUNCTIONAL_CURRENCY` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة الوظيفية الحالية (التغيير Migration مالية) |
| 15 | `REPORTING_CURRENCY` | رمز عملة ISO | `VARCHAR2(3 CHAR)` |  |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة التقارير |
| 16 | `DEFAULT_LANGUAGE` | رمز لغة | `VARCHAR2(10 CHAR)` | ✔ | 'ar' | FK→REF_LANGUAGE |  | إدخال المستخدم |  | اللغة |
| 17 | `TIMEZONE_CODE` | نص | `VARCHAR2(64 CHAR)` | ✔ | 'Asia/Riyadh' |  |  | إدخال المستخدم |  | المنطقة الزمنية |
| 18 | `INDUSTRY_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | النشاط/القطاع |
| 19 | `LOGO_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | الشعار |
| 20 | `SEAL_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | الختم |
| 21 | `ACTIVATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت التفعيل |
| 22 | `ACTIVATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المفعل |
| 23 | `CONFIG_LOCKED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | الإعدادات الجوهرية مقفلة بعد أول معاملة |
| 24 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, UNDER_CONFIGURATION, READY_FOR_REVIEW, ACTIVE, SUSPENDED, INACTIVE, CLOSURE_REQUESTED, UNDER_LIQUIDATION, TRANSACTIONS_BLOCKED, FINANCIALLY_CLOSED, LEGALLY_CLOSED, CLOSED, ARCHIVED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 25 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 26 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 27 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 28 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 29 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_COMPANY_CURRENCY

| البند | القيمة |
|---|---|
| الاسم العربي | تاريخ عملات الشركة |
| English | Company Currency History |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CURRENCY_ROLE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | FUNCTIONAL, REPORTING, CONSOLIDATION | إدخال المستخدم |  | دور العملة |
| 5 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 6 | `CHANGE_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_LEGAL_EVENT |  | إدخال المستخدم |  | حدث التغيير المعتمد |
| 7 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 8 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_BRANCH

| البند | القيمة |
|---|---|
| الاسم العربي | الفروع |
| English | Branches |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CODE)<br>UK3: (PUBLIC_ID) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK3 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 5 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 6 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 7 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 8 | `BRANCH_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | نوع الفرع (Lookup: HEAD_OFFICE، REGIONAL، SALES، PROJECT...) |
| 9 | `INDEPENDENCE_LEVEL` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPERATIONAL' |  | OPERATIONAL, COST_CENTER, PROFIT_CENTER, SEPARATE_SEQUENCE, SEPARATE_TAX | إدخال المستخدم |  | مستوى الاستقلال |
| 10 | `IS_HEAD_OFFICE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | الفرع الرئيسي |
| 11 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` | ✔ |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | الدولة |
| 12 | `CITY_ID` | معرف | `NUMBER(19)` |  |  | FK→REF_CITY |  | إدخال المستخدم |  | المدينة |
| 13 | `TIMEZONE_CODE` | نص | `VARCHAR2(64 CHAR)` |  |  |  |  | إدخال المستخدم |  | المنطقة الزمنية |
| 14 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` |  |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة الفرع (عادة عملة الشركة) |
| 15 | `MANAGER_POSITION_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_POSITION |  | إدخال المستخدم |  | منصب مدير الفرع |
| 16 | `COST_CENTER_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_COST_CENTER |  | إدخال المستخدم |  | مركز التكلفة الافتراضي |
| 17 | `COUNTRY_PACK_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_COUNTRY_PACK |  | إدخال المستخدم |  | حزمة الدولة |
| 18 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, ACTIVE, SUSPENDED, CLOSING, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 19 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 20 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 21 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 22 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 23 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 24 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 25 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_BUSINESS_SITE

| البند | القيمة |
|---|---|
| الاسم العربي | المواقع التشغيلية |
| English | Business Sites |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | الموقع لا يحل محل المستودع أو المشروع أو الوحدة العقارية (12.4) |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CODE) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع المدير للموقع |
| 8 | `SITE_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | نوع الموقع (مكتب، متجر، مصنع، ورشة، موقع مشروع، عقار، مركز بيانات...) |
| 9 | `OWNERSHIP_TYPE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | OWNED, LEASED, MANAGED, TEMPORARY | إدخال المستخدم |  | الملكية |
| 10 | `MANAGER_POSITION_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_POSITION |  | إدخال المستخدم |  | منصب المدير |
| 11 | `WORKING_HOURS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | ساعات العمل |
| 12 | `LATITUDE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | خط العرض |
| 13 | `LONGITUDE` | رقم | `NUMBER` |  |  |  |  | إدخال المستخدم |  | خط الطول |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'ACTIVE' |  | ACTIVE, INACTIVE, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 16 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_LEGAL_REGISTRATION

| البند | القيمة |
|---|---|
| الاسم العربي | التسجيلات القانونية |
| English | Legal Registrations |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 4 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع (فارغ = على مستوى الشركة) |
| 5 | `REG_TYPE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→LOC_REGISTRATION_TYPE |  | إدخال المستخدم |  | نوع التسجيل (سجل تجاري، ضريبي، VAT، زكاة، بلدي...) |
| 6 | `REG_NUMBER` | نص | `VARCHAR2(100 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الرقم |
| 7 | `ISSUING_AUTHORITY` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | جهة الإصدار |
| 8 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` | ✔ |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | الدولة |
| 9 | `REGION_CODE` | نص | `VARCHAR2(50 CHAR)` |  |  |  |  | إدخال المستخدم |  | المنطقة |
| 10 | `ISSUE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الإصدار |
| 11 | `EXPIRY_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ الانتهاء |
| 12 | `IS_PRIMARY` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | التسجيل الرئيسي لنوعه |
| 13 | `PREVIOUS_REG_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_LEGAL_REGISTRATION |  | إدخال المستخدم |  | التسجيل السابق (لا يستبدل؛ ينتهي سريانه) |
| 14 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | المستند المثبت |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, UNDER_REVIEW, ACTIVE, EXPIRING, EXPIRED, SUSPENDED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 17 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_OWNERSHIP

| البند | القيمة |
|---|---|
| الاسم العربي | سجل الملكية بين الشركات |
| English | Company Ownership |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا تتجاوز الملكية الفعالة 100% للفترة نفسها ولا تحذف العلاقة القديمة (12.5) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM<br>OWNER_COMPANY_ID <> OWNED_COMPANY_ID<br>OWNERSHIP_PCT BETWEEN 0 AND 100 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `OWNER_COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة المالكة |
| 4 | `OWNED_COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة المملوكة |
| 5 | `OWNERSHIP_PCT` | نسبة | `NUMBER(9,6)` | ✔ |  |  |  | إدخال المستخدم |  | نسبة الملكية |
| 6 | `VOTING_PCT` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | نسبة التصويت/السيطرة |
| 7 | `RELATION_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | PARENT_SUBSIDIARY, SISTER, JOINT_VENTURE, ASSOCIATE, FOREIGN_BRANCH, MANAGEMENT_ONLY, CONSOLIDATION_ONLY, COMMERCIAL | إدخال المستخدم |  | نوع العلاقة |
| 8 | `CONSOLIDATION_METHOD` | رمز | `VARCHAR2(30 CHAR)` |  |  |  | FULL, PROPORTIONAL, EQUITY, NONE | إدخال المستخدم |  | طريقة التجميع |
| 9 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | المستند القانوني |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, ACTIVE, ENDED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 12 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 13 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_INTERCOMPANY_RULE

| البند | القيمة |
|---|---|
| الاسم العربي | قواعد التعامل بين الشركات |
| English | Intercompany Rules |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, FROM_COMPANY_ID, TO_COMPANY_ID, EFFECTIVE_FROM) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM<br>FROM_COMPANY_ID <> TO_COMPANY_ID |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `FROM_COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | إدخال المستخدم |  | الشركة المصدرة |
| 4 | `TO_COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | إدخال المستخدم |  | الشركة المقابلة |
| 5 | `RECEIVABLE_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | حساب الذمم بين الشركات |
| 6 | `PAYABLE_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | حساب الدائنين بين الشركات |
| 7 | `PAYMENT_TERM_ID` | معرف | `NUMBER(19)` |  |  | FK→REF_PAYMENT_TERM |  | إدخال المستخدم |  | شروط الدفع |
| 8 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` |  |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 9 | `PRICING_POLICY` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | سياسة التسعير الداخلي |
| 10 | `REQUIRES_CONFIRMATION` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | يحتاج تأكيد الطرف الثاني |
| 11 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) | UK1 |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 12 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 13 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_LEGAL_EVENT

| البند | القيمة |
|---|---|
| الاسم العربي | أحداث التغيير القانوني |
| English | Legal Entity Change Events |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | Legal Entity Change Engine مع Dry Run و Validation و Rollback (12.8) |
| مفاتيح فريدة | UK2: (TENANT_ID, EVENT_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `EVENT_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | رقم الحدث |
| 4 | `EVENT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | MERGER, ACQUISITION, SPLIT, GROUP_TRANSFER, LEGAL_FORM_CHANGE, RENAME, OWNERSHIP_CHANGE, BRANCH_TO_COMPANY, COMPANY_TO_BRANCH, CURRENCY_CHANGE, SUSPENSION, LIQUIDATION, CLOSURE | إدخال المستخدم |  | نوع العملية |
| 5 | `DECISION_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ القرار |
| 6 | `LEGAL_EFFECTIVE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | السريان القانوني |
| 7 | `ACCOUNTING_EFFECTIVE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | السريان المحاسبي |
| 8 | `REASON` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | السبب |
| 9 | `ISSUING_AUTHORITY` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الجهة المصدرة |
| 10 | `IMPACT_ANALYSIS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | تحليل الأثر |
| 11 | `TRANSFER_PLAN` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | خطة التحويل |
| 12 | `DRY_RUN_RESULT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | نتيجة المحاكاة |
| 13 | `VALIDATION_RESULT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | نتائج التحقق والمطابقة |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, UNDER_REVIEW, APPROVED, SCHEDULED, IN_PROGRESS, VALIDATED, COMPLETED, REJECTED, CANCELLED, ROLLED_BACK, PARTIALLY_COMPLETED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_LEGAL_EVENT_ENTITY

| البند | القيمة |
|---|---|
| الاسم العربي | أطراف حدث التغيير القانوني |
| English | Legal Event Entities |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `LEGAL_EVENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_LEGAL_EVENT |  | إدخال المستخدم |  | الحدث |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 5 | `BRANCH_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_BRANCH |  | إدخال المستخدم |  | الفرع |
| 6 | `ROLE_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | SOURCE, TARGET, SUCCESSOR, AFFECTED | إدخال المستخدم |  | دور الطرف |
| 7 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 8 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 9 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 10 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 11 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_COMPANY_CHECK

| البند | القيمة |
|---|---|
| الاسم العربي | فحوصات ما قبل تفعيل الشركة |
| English | Company Activation Checks |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, CHECK_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CHECK_CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الفحص (LEGAL_REG، CURRENCY، FISCAL_YEAR، COA، TAX، HEAD_BRANCH، ADMIN، SEQUENCES، LICENSE...) |
| 5 | `CHECKED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الفحص |
| 6 | `RESULT_INFO` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | النتيجة |
| 7 | `WAIVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | معتمد الاستثناء |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, PASSED, FAILED, WAIVED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## ORG_CONFIG_SNAPSHOT

| البند | القيمة |
|---|---|
| الاسم العربي | لقطات إعدادات الشركة |
| English | Configuration Snapshots |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | Append-only (غير قابل للتعديل) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `SNAPSHOT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | ACTIVATION, PERIOD_CLOSE, CURRENCY_CHANGE, LEGAL_EVENT, MANUAL | إدخال المستخدم |  | سبب اللقطة |
| 5 | `SNAPSHOT_DATA` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | الإعدادات المعتمدة |
| 6 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 7 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء UTC |

## ORG_COMPANY_TEMPLATE

| البند | القيمة |
|---|---|
| الاسم العربي | قوالب إنشاء الشركات |
| English | Company Templates |
| الحزمة المالكة | 01 — `NOONA_PLATFORM_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | لا تنسخ المعاملات أو المستخدمين أو الحسابات البنكية أو الأسرار |
| مفاتيح فريدة | UK1: (TENANT_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 4 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 5 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 6 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | الدولة |
| 7 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | إدخال المستخدم |  | الإصدار |
| 8 | `TEMPLATE_DATA` | JSON | `CLOB` | ✔ |  |  | JSON صالح | إدخال المستخدم |  | دليل الحسابات والضرائب والتسلسلات والأدوار وWorkflow |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

