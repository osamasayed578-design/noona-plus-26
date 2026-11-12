# قاموس البيانات — الحزمة 20: الرواتب

**Payroll** · الحزمة البرمجية المالكة `NOONA_PAYROLL_PKG` · ملف DDL `db/ddl/p20_pay.sql` · [ERD](../erd/p20_pay.md)

سياسة رواتب مؤرخة حسب Country Pack، وعناصر الراتب وقواعدها بإصدارات (لا SQL حر)، ودورة التشغيل OPEN → INPUT_CUTOFF → CALCULATED → REVIEWED → APPROVED → PAYABLE → PAID → POSTED → CLOSED، والقروض والسلف وملفات البنك وقسائم الرواتب الآمنة وقيد الرواتب عبر المحرك المحاسبي.

## فهرس الجداول

| الجدول | الاسم العربي | English | النطاق | الحساسية |
|---|---|---|---|---|
| [`PAY_PAYROLL_GROUP`](#pay_payroll_group) | مجموعات الرواتب | Payroll Groups | C | INTERNAL |
| [`PAY_PERIOD`](#pay_period) | فترات الرواتب | Payroll Periods | C | INTERNAL |
| [`PAY_ELEMENT`](#pay_element) | عناصر الراتب | Pay Elements | TO | INTERNAL |
| [`PAY_ELEMENT_RULE`](#pay_element_rule) | قواعد احتساب العناصر | Element Calculation Rules | TO | INTERNAL |
| [`PAY_EMPLOYEE_ELEMENT`](#pay_employee_element) | عناصر رواتب الموظفين | Employee Element Entries | T | HIGHLY_RESTRICTED |
| [`PAY_EMPLOYEE_PAYMENT_METHOD`](#pay_employee_payment_method) | طرق صرف رواتب الموظفين | Employee Payment Methods | T | HIGHLY_RESTRICTED |
| [`PAY_INPUT`](#pay_input) | المدخلات المتغيرة | Variable Payroll Inputs | C | INTERNAL |
| [`PAY_RUN`](#pay_run) | تشغيلات الرواتب | Payroll Runs | C | HIGHLY_RESTRICTED |
| [`PAY_RUN_EMPLOYEE`](#pay_run_employee) | موظفو تشغيل الرواتب | Payroll Run Employees | C | HIGHLY_RESTRICTED |
| [`PAY_RUN_RESULT`](#pay_run_result) | نتائج عناصر الراتب | Payroll Run Results | C | HIGHLY_RESTRICTED |
| [`PAY_LOAN`](#pay_loan) | القروض والسلف | Employee Loans & Advances | C | CONFIDENTIAL |
| [`PAY_LOAN_INSTALLMENT`](#pay_loan_installment) | أقساط القروض | Loan Installments | C | INTERNAL |
| [`PAY_BANK_FILE`](#pay_bank_file) | ملفات تحويل الرواتب | Payroll Bank Files | C | HIGHLY_RESTRICTED |
| [`PAY_BANK_FILE_LINE`](#pay_bank_file_line) | أسطر ملف التحويل | Bank File Lines | C | HIGHLY_RESTRICTED |
| [`PAY_PAYSLIP`](#pay_payslip) | قسائم الرواتب | Payslips | C | HIGHLY_RESTRICTED |
| [`PAY_ACCRUAL`](#pay_accrual) | المخصصات والاستحقاقات | Payroll Accruals (EOS, Leave, Tickets) | C | HIGHLY_RESTRICTED |
| [`PAY_FIELD_EARNING`](#pay_field_earning) | مستحقات العاملين الميدانيين | Field Worker Earnings | C | INTERNAL |

## PAY_PAYROLL_GROUP

| البند | القيمة |
|---|---|
| الاسم العربي | مجموعات الرواتب |
| English | Payroll Groups |
| الحزمة المالكة | 20 — `NOONA_PAYROLL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `CODE` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز الفريد ضمن النطاق |
| 5 | `NAME_AR` | اسم | `VARCHAR2(200 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الاسم بالعربية |
| 6 | `NAME_EN` | اسم | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | الاسم بالإنجليزية |
| 7 | `FREQUENCY` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'MONTHLY' |  | MONTHLY, SEMI_MONTHLY, BIWEEKLY, WEEKLY | إدخال المستخدم |  | الدورية |
| 8 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | العملة |
| 9 | `COUNTRY_PACK_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_COUNTRY_PACK |  | إدخال المستخدم |  | حزمة الدولة |
| 10 | `CUTOFF_DAY` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | يوم إقفال المدخلات |
| 11 | `PAY_DAY` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | يوم الصرف |
| 12 | `BANK_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→CSH_BANK_ACCOUNT |  | إدخال المستخدم |  | حساب الصرف |
| 13 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PAY_PERIOD

| البند | القيمة |
|---|---|
| الاسم العربي | فترات الرواتب |
| English | Payroll Periods |
| الحزمة المالكة | 20 — `NOONA_PAYROLL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PAYROLL_GROUP_ID, PERIOD_CODE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PAYROLL_GROUP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PAY_PAYROLL_GROUP UK2 |  | إدخال المستخدم |  | المجموعة |
| 5 | `PERIOD_CODE` | نص | `VARCHAR2(20 CHAR)` | ✔ |  | UK2 |  | إدخال المستخدم |  | الرمز |
| 6 | `START_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | البداية |
| 7 | `END_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | النهاية |
| 8 | `CUTOFF_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | إقفال المدخلات |
| 9 | `PAY_DATE` | تاريخ | `DATE` | ✔ |  |  |  | إدخال المستخدم |  | تاريخ الصرف |
| 10 | `GL_PERIOD_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_PERIOD |  | إدخال المستخدم |  | الفترة المحاسبية |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'FUTURE' |  | FUTURE, OPEN, CUTOFF, CLOSED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PAY_ELEMENT

| البند | القيمة |
|---|---|
| الاسم العربي | عناصر الراتب |
| English | Pay Elements |
| الحزمة المالكة | 20 — `NOONA_PAYROLL_PKG` |
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
| 6 | `COUNTRY_PACK_ID` | معرف | `NUMBER(19)` |  |  | FK→LOC_COUNTRY_PACK |  | إدخال المستخدم |  | حزمة الدولة |
| 7 | `ELEMENT_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | EARNING, DEDUCTION, EMPLOYER_CONTRIBUTION, EMPLOYEE_CONTRIBUTION, TAX, LOAN_REPAYMENT, INFORMATION, BENEFIT | إدخال المستخدم |  | النوع |
| 8 | `CLASSIFICATION` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | BASE_SALARY, HOUSING, TRANSPORT, ALLOWANCE, OVERTIME, BONUS, COMMISSION, INSURANCE, SOCIAL_SECURITY, ABSENCE, PENALTY, ADVANCE, EOS, LEAVE_PAY, OTHER | إدخال المستخدم |  | التصنيف |
| 9 | `IS_RECURRING` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | متكرر |
| 10 | `IS_TAXABLE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | خاضع للضريبة |
| 11 | `IS_PRORATED` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | يحتسب نسبياً عند منتصف الشهر |
| 12 | `AFFECTS_EOS` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | يدخل في أساس نهاية الخدمة |
| 13 | `SHOW_ON_PAYSLIP` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | يظهر في القسيمة |
| 14 | `EXPENSE_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | حساب المصروف |
| 15 | `LIABILITY_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→GL_ACCOUNT |  | إدخال المستخدم |  | حساب الالتزام |
| 16 | `IS_ACTIVE` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'Y' |  | Y, N | إدخال المستخدم |  | نشط؟ |
| 17 | `SORT_ORDER` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | ترتيب العرض |
| 18 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 19 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 20 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 21 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 22 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PAY_ELEMENT_RULE

| البند | القيمة |
|---|---|
| الاسم العربي | قواعد احتساب العناصر |
| English | Element Calculation Rules |
| الحزمة المالكة | 20 — `NOONA_PAYROLL_PKG` |
| نطاق الملكية | `TO` — منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية) |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (ELEMENT_ID, VERSION_NO) |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` |  |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع |
| 3 | `ELEMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PAY_ELEMENT UK1 |  | إدخال المستخدم |  | العنصر |
| 4 | `VERSION_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الإصدار (يثبت للنتيجة) |
| 5 | `COMPANY_ID` | معرف | `NUMBER(19)` |  |  | FK→ORG_COMPANY |  | إدخال المستخدم |  | الشركة |
| 6 | `EMPLOYEE_CATEGORY` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | فئة الموظف |
| 7 | `FORMULA_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | FIXED, PCT_OF_ELEMENT, HOURLY, DAILY, TABLE, BRACKET, APPROVED_FUNCTION | إدخال المستخدم |  | نوع المعادلة |
| 8 | `PARAMETERS` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | المعاملات (النسب، الأساس، الحدود) |
| 9 | `APPROVED_FUNCTION` | نص | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | دالة PL/SQL معتمدة (لا صيغ SQL حرة) |
| 10 | `MIN_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد الأدنى |
| 11 | `MAX_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الحد الأعلى |
| 12 | `COUNTRY_CODE` | رمز دولة ISO | `VARCHAR2(2 CHAR)` |  |  | FK→REF_COUNTRY |  | إدخال المستخدم |  | الدولة (القاعدة لكل شركات المؤسسة في هذه الدولة؛ فارغ = كل الدول) |
| 13 | `IS_AUTO` | منطقي Y/N | `CHAR(1 CHAR)` | ✔ | 'N' |  | Y, N | إدخال المستخدم |  | تطبق تلقائياً على كل موظفي النطاق (ما لم يحدد للموظف غيرها) |
| 14 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, ACTIVE, RETIRED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 15 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 16 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 17 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 18 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 19 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 20 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 21 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PAY_EMPLOYEE_ELEMENT

| البند | القيمة |
|---|---|
| الاسم العربي | عناصر رواتب الموظفين |
| English | Employee Element Entries |
| الحزمة المالكة | 20 — `NOONA_PAYROLL_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `EMPLOYMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYMENT |  | إدخال المستخدم |  | علاقة التوظيف |
| 4 | `ELEMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PAY_ELEMENT |  | إدخال المستخدم |  | العنصر |
| 5 | `AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المبلغ |
| 6 | `PERCENTAGE` | نسبة | `NUMBER(9,6)` |  |  |  |  | إدخال المستخدم |  | النسبة |
| 7 | `CALC_METHOD` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'FIXED' |  | FIXED, PERCENT, POLICY, EXCLUDED | إدخال المستخدم |  | طريقة الاحتساب: مبلغ ثابت، نسبة، حسب سياسة الشركة، مستثنى |
| 8 | `BASIS_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | العنصر الأساس للنسبة (افتراضياً الأساسي BASIC) |
| 9 | `SOURCE_ACTION_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYEE_ACTION |  | إدخال المستخدم |  | الحركة المصدر |
| 10 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 11 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PAY_EMPLOYEE_PAYMENT_METHOD

| البند | القيمة |
|---|---|
| الاسم العربي | طرق صرف رواتب الموظفين |
| English | Employee Payment Methods |
| الحزمة المالكة | 20 — `NOONA_PAYROLL_PKG` |
| نطاق الملكية | `T` — مملوك للمؤسسة Tenant-Owned |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |
| قيود أعمال | EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `EMPLOYMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYMENT |  | إدخال المستخدم |  | علاقة التوظيف |
| 4 | `METHOD_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | BANK_TRANSFER, CASH, CHEQUE, WPS, PAYCARD | إدخال المستخدم |  | الطريقة |
| 5 | `BANK_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_BANK_ACCOUNT |  | إدخال المستخدم |  | الحساب البنكي (Maker-Checker) |
| 6 | `SPLIT_PCT` | نسبة | `NUMBER(9,6)` | ✔ | 100 |  |  | إدخال المستخدم |  | نسبة التوزيع |
| 7 | `EFFECTIVE_FROM` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ بداية السريان |
| 8 | `EFFECTIVE_TO` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ نهاية السريان (فارغ = مفتوح) |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PAY_INPUT

| البند | القيمة |
|---|---|
| الاسم العربي | المدخلات المتغيرة |
| English | Variable Payroll Inputs |
| الحزمة المالكة | 20 — `NOONA_PAYROLL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `SOURCE_ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE |  | إدخال المستخدم |  | نوع كيان المصدر من سجل الأنواع REF_ENTITY_TYPE |
| 5 | `SOURCE_ENTITY_ID` | معرف | `NUMBER(19)` |  |  |  |  | إدخال المستخدم |  | معرف كيان المصدر (يتحقق منه خادمياً عبر حزمة الوحدة المالكة) |
| 6 | `PERIOD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PAY_PERIOD |  | إدخال المستخدم |  | الفترة |
| 7 | `EMPLOYMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYMENT |  | إدخال المستخدم |  | علاقة التوظيف |
| 8 | `ELEMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PAY_ELEMENT |  | إدخال المستخدم |  | العنصر |
| 9 | `QUANTITY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الكمية (ساعات/أيام) |
| 10 | `AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | المبلغ |
| 11 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, VALIDATED, APPLIED, REJECTED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 12 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 13 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 14 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 15 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 16 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PAY_RUN

| البند | القيمة |
|---|---|
| الاسم العربي | تشغيلات الرواتب |
| English | Payroll Runs |
| الحزمة المالكة | 20 — `NOONA_PAYROLL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (PUBLIC_ID)<br>UK3: (TENANT_ID, COMPANY_ID, RUN_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `PUBLIC_ID` | GUID | `RAW(16)` | ✔ | SYS_GUID() | UK2 |  | النظام/الحزمة |  | معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي |
| 3 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK3 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 4 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK3 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 5 | `RUN_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK3 |  | إدخال المستخدم |  | رقم التشغيل |
| 6 | `PAYROLL_GROUP_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PAY_PAYROLL_GROUP |  | إدخال المستخدم |  | المجموعة |
| 7 | `PERIOD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PAY_PERIOD |  | إدخال المستخدم |  | الفترة |
| 8 | `RUN_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'REGULAR' |  | REGULAR, OFF_CYCLE, ADJUSTMENT, RETRO, FINAL_SETTLEMENT, BONUS | إدخال المستخدم |  | النوع |
| 9 | `ADJUSTS_RUN_ID` | معرف | `NUMBER(19)` |  |  | FK→PAY_RUN |  | إدخال المستخدم |  | التشغيل المصحح (لا يمحى السابق) |
| 10 | `EMPLOYEE_COUNT` | عدد صحيح | `NUMBER(10)` |  |  |  |  | إدخال المستخدم |  | عدد الموظفين |
| 11 | `TOTAL_GROSS` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الإجمالي |
| 12 | `TOTAL_DEDUCTIONS` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الخصومات |
| 13 | `TOTAL_NET` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الصافي |
| 14 | `TOTAL_EMPLOYER_COST` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | تكلفة صاحب العمل |
| 15 | `ANOMALY_REPORT` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | الحالات الشاذة والمقارنة بالفترة السابقة |
| 16 | `CALCULATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الحساب |
| 17 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'OPEN' |  | OPEN, INPUT_CUTOFF, CALCULATED, REVIEWED, APPROVED, PAYABLE, PAID, POSTED, CLOSED, FAILED, REOPENED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 18 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 19 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | النظام/الحزمة |  | الحدث المحاسبي المولد |
| 20 | `POSTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | وقت الترحيل؛ يملؤه محرك الترحيل فقط |
| 21 | `POSTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | النظام/الحزمة |  | منفذ الترحيل |
| 22 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 23 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 24 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 25 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 26 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PAY_RUN_EMPLOYEE

| البند | القيمة |
|---|---|
| الاسم العربي | موظفو تشغيل الرواتب |
| English | Payroll Run Employees |
| الحزمة المالكة | 20 — `NOONA_PAYROLL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (RUN_ID, EMPLOYMENT_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `RUN_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PAY_RUN UK2 |  | إدخال المستخدم |  | التشغيل |
| 5 | `EMPLOYMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYMENT UK2 |  | إدخال المستخدم |  | علاقة التوظيف |
| 6 | `PAYABLE_DAYS` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الأيام المستحقة |
| 7 | `ABSENCE_DAYS` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | أيام الغياب والإجازة غير المدفوعة |
| 8 | `OVERTIME_HOURS` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | ساعات العمل الإضافي |
| 9 | `GROSS_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الإجمالي |
| 10 | `DEDUCTION_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الخصومات |
| 11 | `NET_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الصافي |
| 12 | `EMPLOYER_COST` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | تكلفة صاحب العمل |
| 13 | `COST_ALLOCATION` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | التوزيع على المشاريع ومراكز التكلفة |
| 14 | `ERROR_MESSAGE` | نص | `VARCHAR2(1000 CHAR)` |  |  |  |  | إدخال المستخدم |  | الخطأ |
| 15 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'INCLUDED' |  | INCLUDED, CALCULATED, ERROR, EXCLUDED, APPROVED, PAID | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 16 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 17 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 18 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 19 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 20 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PAY_RUN_RESULT

| البند | القيمة |
|---|---|
| الاسم العربي | نتائج عناصر الراتب |
| English | Payroll Run Results |
| الحزمة المالكة | 20 — `NOONA_PAYROLL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `RUN_EMPLOYEE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PAY_RUN_EMPLOYEE |  | إدخال المستخدم |  | الموظف في التشغيل |
| 5 | `ELEMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PAY_ELEMENT |  | إدخال المستخدم |  | العنصر |
| 6 | `RULE_ID` | معرف | `NUMBER(19)` |  |  | FK→PAY_ELEMENT_RULE |  | إدخال المستخدم |  | إصدار القاعدة المطبق |
| 7 | `QUANTITY` | كمية | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الكمية |
| 8 | `RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | المعدل |
| 9 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 10 | `SOURCE_INFO` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | مصدر المبلغ (حضور، إجازة، عقد) |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PAY_LOAN

| البند | القيمة |
|---|---|
| الاسم العربي | القروض والسلف |
| English | Employee Loans & Advances |
| الحزمة المالكة | 20 — `NOONA_PAYROLL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | CONFIDENTIAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK2: (TENANT_ID, COMPANY_ID, DOC_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK2 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK2 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `DOC_NO` | نص | `VARCHAR2(50 CHAR)` | ✔ |  | UK2 |  | النظام/الحزمة |  | رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة) |
| 5 | `DOC_DATE` | تاريخ | `DATE` | ✔ | TRUNC(SYSDATE) |  |  | إدخال المستخدم |  | تاريخ المستند (تاريخ الأعمال) |
| 6 | `CURRENCY_CODE` | رمز عملة ISO | `VARCHAR2(3 CHAR)` | ✔ |  | FK→REF_CURRENCY |  | إدخال المستخدم |  | عملة المعاملة |
| 7 | `RATE_TYPE_CODE` | رمز | `VARCHAR2(30 CHAR)` |  |  |  |  | إدخال المستخدم |  | نوع سعر الصرف المستخدم |
| 8 | `EXCHANGE_RATE` | سعر/معدل | `NUMBER(28,12)` |  |  |  |  | إدخال المستخدم |  | سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل) |
| 9 | `RATE_DATE` | تاريخ | `DATE` |  |  |  |  | إدخال المستخدم |  | تاريخ سعر الصرف |
| 10 | `EMPLOYMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYMENT |  | إدخال المستخدم |  | علاقة التوظيف |
| 11 | `LOAN_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | LOAN, SALARY_ADVANCE, HOUSING_ADVANCE, OTHER | إدخال المستخدم |  | النوع |
| 12 | `PRINCIPAL_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | أصل المبلغ |
| 13 | `INSTALLMENT_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | القسط |
| 14 | `INSTALLMENTS_COUNT` | عدد صحيح | `NUMBER(10)` | ✔ |  |  |  | إدخال المستخدم |  | عدد الأقساط |
| 15 | `START_PERIOD_ID` | معرف | `NUMBER(19)` |  |  | FK→PAY_PERIOD |  | إدخال المستخدم |  | فترة بدء الخصم |
| 16 | `OUTSTANDING_BALANCE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | النظام/الحزمة |  | الرصيد القائم |
| 17 | `CASH_TRANSACTION_ID` | معرف | `NUMBER(19)` |  |  | FK→CSH_TRANSACTION |  | إدخال المستخدم |  | الصرف |
| 18 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'DRAFT' |  | DRAFT, APPROVED, ACTIVE, SUSPENDED, SETTLED, WRITTEN_OFF, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 19 | `WF_INSTANCE_ID` | معرف | `NUMBER(19)` |  |  | FK→WF_INSTANCE |  | النظام/الحزمة |  | مسار الاعتماد المرتبط |
| 20 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 21 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 22 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 23 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 24 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PAY_LOAN_INSTALLMENT

| البند | القيمة |
|---|---|
| الاسم العربي | أقساط القروض |
| English | Loan Installments |
| الحزمة المالكة | 20 — `NOONA_PAYROLL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (LOAN_ID, INSTALLMENT_NO) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `LOAN_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PAY_LOAN UK1 |  | إدخال المستخدم |  | القرض |
| 5 | `INSTALLMENT_NO` | عدد صحيح | `NUMBER(10)` | ✔ |  | UK1 |  | إدخال المستخدم |  | الرقم |
| 6 | `PERIOD_ID` | معرف | `NUMBER(19)` |  |  | FK→PAY_PERIOD |  | إدخال المستخدم |  | الفترة |
| 7 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 8 | `DEDUCTED_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | المخصوم فعلياً |
| 9 | `RUN_RESULT_ID` | معرف | `NUMBER(19)` |  |  | FK→PAY_RUN_RESULT |  | إدخال المستخدم |  | نتيجة الخصم |
| 10 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'SCHEDULED' |  | SCHEDULED, DEDUCTED, DEFERRED, SETTLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 11 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 12 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 13 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 14 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 15 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PAY_BANK_FILE

| البند | القيمة |
|---|---|
| الاسم العربي | ملفات تحويل الرواتب |
| English | Payroll Bank Files |
| الحزمة المالكة | 20 — `NOONA_PAYROLL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |
| الغرض | يفصل FILE_SENT عن PAYMENT_CONFIRMED ويمنع الدفع المكرر |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `RUN_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PAY_RUN |  | إدخال المستخدم |  | التشغيل |
| 5 | `BANK_ACCOUNT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→CSH_BANK_ACCOUNT |  | إدخال المستخدم |  | حساب الصرف |
| 6 | `FILE_FORMAT` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  |  | إدخال المستخدم |  | الصيغة (WPS/SIF...) |
| 7 | `TOTAL_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الإجمالي (يطابق صافي التشغيل) |
| 8 | `RECORD_COUNT` | عدد صحيح | `NUMBER(10)` | ✔ |  |  |  | إدخال المستخدم |  | عدد السجلات |
| 9 | `FILE_HASH` | Hash | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | Hash الملف |
| 10 | `FILE_DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | الملف (سري) |
| 11 | `SENT_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الإرسال |
| 12 | `CONFIRMED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | تأكيد البنك |
| 13 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'GENERATED' |  | GENERATED, APPROVED, FILE_SENT, PAYMENT_CONFIRMED, PARTIALLY_RETURNED, FAILED, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PAY_BANK_FILE_LINE

| البند | القيمة |
|---|---|
| الاسم العربي | أسطر ملف التحويل |
| English | Bank File Lines |
| الحزمة المالكة | 20 — `NOONA_PAYROLL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `BANK_FILE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PAY_BANK_FILE |  | إدخال المستخدم |  | الملف |
| 5 | `RUN_EMPLOYEE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PAY_RUN_EMPLOYEE |  | إدخال المستخدم |  | الموظف |
| 6 | `BANK_ACCOUNT_ID` | معرف | `NUMBER(19)` |  |  | FK→PTY_BANK_ACCOUNT |  | إدخال المستخدم |  | الحساب المستخدم |
| 7 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المبلغ |
| 8 | `RETURN_REASON` | نص | `VARCHAR2(500 CHAR)` |  |  |  |  | إدخال المستخدم |  | سبب الرد |
| 9 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, PAID, RETURNED, REISSUED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 10 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 11 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 12 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 13 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 14 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PAY_PAYSLIP

| البند | القيمة |
|---|---|
| الاسم العربي | قسائم الرواتب |
| English | Payslips |
| الحزمة المالكة | 20 — `NOONA_PAYROLL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, RUN_EMPLOYEE_ID) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `RUN_EMPLOYEE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PAY_RUN_EMPLOYEE UK1 |  | إدخال المستخدم |  | الموظف في التشغيل |
| 5 | `DOCUMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→DMS_DOCUMENT |  | إدخال المستخدم |  | القسيمة (سرية عالية) |
| 6 | `PUBLISHED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | النشر للموظف |
| 7 | `VIEWED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | أول اطلاع |
| 8 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'GENERATED' |  | GENERATED, PUBLISHED, VIEWED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 9 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 10 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 11 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 12 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 13 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PAY_ACCRUAL

| البند | القيمة |
|---|---|
| الاسم العربي | المخصصات والاستحقاقات |
| English | Payroll Accruals (EOS, Leave, Tickets) |
| الحزمة المالكة | 20 — `NOONA_PAYROLL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | HIGHLY_RESTRICTED |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (PERIOD_ID, EMPLOYMENT_ID, ACCRUAL_TYPE) |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `PERIOD_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PAY_PERIOD UK1 |  | إدخال المستخدم |  | الفترة |
| 5 | `EMPLOYMENT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYMENT UK1 |  | إدخال المستخدم |  | علاقة التوظيف |
| 6 | `ACCRUAL_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 | END_OF_SERVICE, LEAVE_PAY, AIR_TICKET, BONUS | إدخال المستخدم |  | النوع |
| 7 | `OPENING_BALANCE` | مبلغ | `NUMBER(24,6)` | ✔ | 0 |  |  | إدخال المستخدم |  | الرصيد السابق |
| 8 | `PERIOD_AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | مخصص الفترة |
| 9 | `CLOSING_BALANCE` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | الرصيد |
| 10 | `CALC_INFO` | JSON | `CLOB` |  |  |  | JSON صالح | إدخال المستخدم |  | أساس الحساب |
| 11 | `ACCOUNTING_EVENT_ID` | معرف | `NUMBER(19)` |  |  | FK→ACE_ACCOUNTING_EVENT |  | النظام/الحزمة |  | الحدث المحاسبي المولد |
| 12 | `POSTED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | النظام/الحزمة |  | وقت الترحيل؛ يملؤه محرك الترحيل فقط |
| 13 | `POSTED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | النظام/الحزمة |  | منفذ الترحيل |
| 14 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 15 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 16 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 17 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 18 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

## PAY_FIELD_EARNING

| البند | القيمة |
|---|---|
| الاسم العربي | مستحقات العاملين الميدانيين |
| English | Field Worker Earnings |
| الحزمة المالكة | 20 — `NOONA_PAYROLL_PKG` |
| نطاق الملكية | `C` — مملوك للشركة Company-Owned |
| الحساسية | INTERNAL |
| النمط | قابل للتعديل وفق دورة الحياة |
| مفاتيح فريدة | UK1: (TENANT_ID, COMPANY_ID, SOURCE_ENTITY_TYPE, SOURCE_ENTITY_ID, EARNING_TYPE, PERIOD_MONTH) |
| قيود أعمال | AMOUNT > 0 |

| # | العمود | النوع المنطقي | Oracle Type | إلزامي | افتراضي | مفاتيح | القيم المقبولة | المصدر | PII | الوصف |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|
| 1 | `ID` | معرف | `NUMBER(19)` | ✔ |  | PK |  | النظام/الحزمة |  | المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه |
| 2 | `TENANT_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→PLT_TENANT UK1 |  | Security Context |  | المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم |
| 3 | `COMPANY_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→ORG_COMPANY UK1 |  | Security Context |  | الشركة (الكيان القانوني) المالكة للسجل |
| 4 | `SOURCE_ENTITY_TYPE` | نص | `VARCHAR2(50 CHAR)` |  |  | FK→REF_ENTITY_TYPE UK1 |  | إدخال المستخدم |  | نوع كيان المصدر من سجل الأنواع REF_ENTITY_TYPE |
| 5 | `SOURCE_ENTITY_ID` | معرف | `NUMBER(19)` |  |  | UK1 |  | إدخال المستخدم |  | معرف كيان المصدر (يتحقق منه خادمياً عبر حزمة الوحدة المالكة) |
| 6 | `EMPLOYEE_ID` | معرف | `NUMBER(19)` | ✔ |  | FK→HR_EMPLOYEE |  | إدخال المستخدم |  | الموظف |
| 7 | `EMPLOYMENT_ID` | معرف | `NUMBER(19)` |  |  | FK→HR_EMPLOYMENT |  | إدخال المستخدم |  | علاقة التوظيف |
| 8 | `SOURCE_MODULE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  |  | TRN, DST, AUT, OTHER | إدخال المستخدم |  | المصدر |
| 9 | `EARNING_TYPE` | رمز | `VARCHAR2(30 CHAR)` | ✔ |  | UK1 | TRIP_ALLOWANCE, SALES_COMMISSION, COLLECTION_COMMISSION, VISIT_COMMISSION, SERVICE_COMMISSION, BONUS, OTHER | إدخال المستخدم |  | النوع |
| 10 | `PERIOD_MONTH` | تاريخ | `DATE` | ✔ |  | UK1 |  | إدخال المستخدم |  | الشهر |
| 11 | `SOURCE_REF` | نص | `VARCHAR2(200 CHAR)` |  |  |  |  | إدخال المستخدم |  | المرجع (الرحلة، الشهر، أمر الإصلاح) |
| 12 | `BASE_AMOUNT` | مبلغ | `NUMBER(24,6)` |  |  |  |  | إدخال المستخدم |  | الأساس (مبيعات، تحصيل، خدمات) |
| 13 | `AMOUNT` | مبلغ | `NUMBER(24,6)` | ✔ |  |  |  | إدخال المستخدم |  | المستحق |
| 14 | `PAY_METHOD` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PAYROLL' |  | PAYROLL, CASH, BANK_TRANSFER | إدخال المستخدم |  | طريقة الصرف |
| 15 | `PAY_INPUT_ID` | معرف | `NUMBER(19)` |  |  | FK→PAY_INPUT |  | إدخال المستخدم |  | المدخل في مسير الرواتب |
| 16 | `CASH_TXN_ID` | معرف | `NUMBER(19)` |  |  | FK→CSH_TRANSACTION |  | إدخال المستخدم |  | سند الصرف |
| 17 | `PAID_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الصرف |
| 18 | `APPROVED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | إدخال المستخدم |  | المعتمد |
| 19 | `APPROVED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | إدخال المستخدم |  | وقت الاعتماد |
| 20 | `STATUS_CODE` | رمز | `VARCHAR2(30 CHAR)` | ✔ | 'PENDING' |  | PENDING, APPROVED, IN_PAYROLL, IN_VOUCHER, PAID, CANCELLED | النظام/الحزمة |  | الحالة ضمن دورة الحياة المعتمدة |
| 21 | `NOTES` | نص | `VARCHAR2(4000 CHAR)` |  |  |  |  | إدخال المستخدم |  | ملاحظات |
| 22 | `ROW_VERSION` | عدد صحيح | `NUMBER(10)` | ✔ | 1 |  |  | Trigger |  | رقم الإصدار للتحكم في التزامن المتفائل |
| 23 | `CREATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` | ✔ |  |  |  | Trigger |  | منشئ السجل |
| 24 | `CREATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` | ✔ | SYSTIMESTAMP |  |  | Trigger |  | وقت الإنشاء |
| 25 | `UPDATED_BY` | اسم مستخدم | `VARCHAR2(128 CHAR)` |  |  |  |  | Trigger |  | آخر من عدل السجل |
| 26 | `UPDATED_AT` | طابع زمني | `TIMESTAMP(6) WITH LOCAL TIME ZONE` |  |  |  |  | Trigger |  | وقت آخر تعديل |

