# NOONA PLUS — قاموس البيانات (Data Dictionary)

مولد آلياً من النموذج الموحد `tools/model` وفق معيار القسم 45.1 من الوثيقة المرجعية. التعليقات نفسها مثبتة داخل قاعدة البيانات عبر `COMMENT ON TABLE/COLUMN`، فتظهر في APEX و SQL Developer.

نسخة Excel كاملة: [NOONA_PLUS_Data_Dictionary.xlsx](NOONA_PLUS_Data_Dictionary.xlsx)

## الاصطلاحات

| الرمز | المعنى |
|---|---|
| `G` | منصة عامة Platform Global (بدون TENANT_ID) |
| `TO` | منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| `T` | مملوك للمؤسسة Tenant-Owned |
| `C` | مملوك للشركة Company-Owned |

**الأعمدة القياسية** الموجودة في كل جدول تقريباً: `ID` (Identity)، `TENANT_ID` (من السياق الأمني)، `ROW_VERSION`، `CREATED_BY/AT`، `UPDATED_BY/AT` (تملؤها Triggers). الجداول ذات النمط *Append-only* لا تقبل التعديل أو الحذف (سجلات تدقيق وأحداث).

**مصدر القيمة:** إدخال المستخدم، النظام/الحزمة (PL/SQL)، Security Context، Trigger.

## الحزم

| # | الحزمة | Package | PL/SQL | الجداول | الملف |
|---:|---|---|---|---:|---|
| 01 | نواة المنصة والمؤسسات والترخيص | Platform Core, Tenancy, Licensing & Companies | `NOONA_PLATFORM_PKG` | 65 | [p01_plt](p01_plt.md) |
| 02 | الهيكل التنظيمي والهوية والأمن | Organization Structure, Identity & Security | `NOONA_SECURITY_PKG` | 37 | [p02_sec](p02_sec.md) |
| 03 | سير العمل والطلبات والاعتمادات والتفويض | Workflow, Requests, Approvals & Delegation | `NOONA_WORKFLOW_PKG` | 27 | [p03_wf](p03_wf.md) |
| 04 | إدارة المستندات والأرشفة | Document Management & Archive | `NOONA_DMS_PKG` | 29 | [p04_dms](p04_dms.md) |
| 05 | المراسلات والإشعارات والتدقيق | Correspondence, Notifications & Audit | `NOONA_CORRESPONDENCE_PKG` | 24 | [p05_cor](p05_cor.md) |
| 06 | البيانات المرجعية المشتركة والأطراف | Shared Reference Data & Global Party Model | `NOONA_REFERENCE_PKG` | 29 | [p06_ref](p06_ref.md) |
| 07 | المحاسبة العامة والمحرك المحاسبي | General Ledger & Accounting Engine | `NOONA_GL_PKG` | 41 | [p07_gl](p07_gl.md) |
| 08 | العملاء والحسابات المدينة | Customers & Accounts Receivable | `NOONA_AR_PKG` | 19 | [p08_ar](p08_ar.md) |
| 09 | الموردون والحسابات الدائنة | Suppliers & Accounts Payable | `NOONA_AP_PKG` | 12 | [p09_ap](p09_ap.md) |
| 10 | النقدية والبنوك | Cash & Banks | `NOONA_CASH_PKG` | 13 | [p10_csh](p10_csh.md) |
| 11 | المخزون والبيانات السلعية | Inventory & Item Master | `NOONA_INVENTORY_PKG` | 25 | [p11_inv](p11_inv.md) |
| 12 | المشتريات | Procurement | `NOONA_PROCUREMENT_PKG` | 17 | [p12_pur](p12_pur.md) |
| 13 | المبيعات ونقاط البيع | Sales & Point of Sale | `NOONA_SALES_PKG` | 24 | [p13_sal](p13_sal.md) |
| 14 | الأصول الثابتة | Fixed Assets | `NOONA_ASSETS_PKG` | 11 | [p14_fa](p14_fa.md) |
| 15 | المشروعات والمقاولات والإنشاءات | Projects, Contracting & Construction | `NOONA_PROJECTS_PKG` | 15 | [p15_prj](p15_prj.md) |
| 16 | التطوير العقاري وبيع الوحدات | Real Estate Development & Unit Sales | `NOONA_REAL_ESTATE_PKG` | 17 | [p16_re](p16_re.md) |
| 17 | إدارة الأملاك والإيجارات والضيافة | Property Management, Leasing & Hospitality | `NOONA_PROPERTY_PKG` | 25 | [p17_prp](p17_prp.md) |
| 18 | الصيانة وإدارة المرافق | Maintenance & Facility Management | `NOONA_MAINTENANCE_PKG` | 11 | [p18_mnt](p18_mnt.md) |
| 19 | الموارد البشرية | Human Resources | `NOONA_HR_PKG` | 24 | [p19_hr](p19_hr.md) |
| 20 | الرواتب | Payroll | `NOONA_PAYROLL_PKG` | 16 | [p20_pay](p20_pay.md) |
| 21 | التصنيع | Manufacturing | `NOONA_MANUFACTURING_PKG` | 13 | [p21_mfg](p21_mfg.md) |
| 22 | التقارير وذكاء الأعمال | Reporting & Business Intelligence | `NOONA_BI_PKG` | 9 | [p22_bi](p22_bi.md) |
| 23 | ORDS وواجهات API والتكاملات | ORDS, APIs & Integrations | `NOONA_API_PKG` | 13 | [p23_api](p23_api.md) |
| 24 | الذكاء الاصطناعي و RAG والوكلاء | AI, RAG & Agents | `NOONA_AI_PKG` | 15 | [p24_ai](p24_ai.md) |
| 25 | حزم الدول والتوطين والضرائب | Country Packs, Localization & Tax Engine | `NOONA_LOCALIZATION_PKG` | 15 | [p25_loc](p25_loc.md) |
| 26 | الاختبار الشامل وضمان الجودة | Quality Assurance & Traceability | `NOONA_QA_PKG` | 7 | [p26_qa](p26_qa.md) |
| 27 | ترحيل البيانات | Data Migration | `NOONA_MIGRATION_PKG` | 6 | [p27_mig](p27_mig.md) |
| 28 | الإطلاق التجريبي | Pilot Launch | `NOONA_PILOT_PKG` | 4 | [p28_pil](p28_pil.md) |
| 29 | النشر الإنتاجي والإصدارات | Deployment & Release Management | `NOONA_DEPLOYMENT_PKG` | 6 | [p29_dep](p29_dep.md) |
| 30 | التشغيل والدعم والتطوير المستمر | Operations, Support & Continuous Improvement | `NOONA_OPERATIONS_PKG` | 12 | [p30_ops](p30_ops.md) |
| 31 | المستشفيات والمراكز الطبية | Hospital & Clinics | `NOONA_HIS_PKG` | 40 | [p31_his](p31_his.md) |

**الإجمالي:** 621 جدول · 10897 عمود.

