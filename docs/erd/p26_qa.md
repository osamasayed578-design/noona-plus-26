# ERD — الحزمة 26: الاختبار الشامل وضمان الجودة

**Quality Assurance & Traceability** · الحزمة البرمجية `NOONA_QA_PKG` · عدد الجداول: **7**

سجل المتطلبات وقواعد الأعمال (FR/NFR/BR) وربطها بحالات الاختبار وتشغيلاتها والعيوب، لتحقيق Traceability من المتطلب إلى الاختبار إلى الإصدار.

```mermaid
erDiagram
  QA_REQUIREMENT {
    NUMBER ID PK
    VARCHAR2 CODE UK
    VARCHAR2 STATUS_CODE
  }
  QA_TEST_SUITE {
    NUMBER ID PK
    VARCHAR2 CODE UK
    VARCHAR2 NAME_AR
  }
  QA_TEST_CASE {
    NUMBER ID PK
    VARCHAR2 CODE UK
    NUMBER SUITE_ID FK
    VARCHAR2 STATUS_CODE
  }
  QA_TRACE_LINK {
    NUMBER ID PK
    NUMBER REQUIREMENT_ID FK,UK
    NUMBER TEST_CASE_ID FK,UK
  }
  QA_TEST_RUN {
    NUMBER ID PK
    VARCHAR2 STATUS_CODE
  }
  QA_TEST_RESULT {
    NUMBER ID PK
    NUMBER RUN_ID FK
    NUMBER TEST_CASE_ID FK
  }
  QA_DEFECT {
    NUMBER ID PK
    VARCHAR2 CODE UK
    NUMBER TEST_RESULT_ID FK
    NUMBER REQUIREMENT_ID FK
    VARCHAR2 STATUS_CODE
  }
  QA_REQUIREMENT |o--o{ QA_DEFECT : "REQUIREMENT_ID"
  QA_REQUIREMENT ||--o{ QA_TRACE_LINK : "REQUIREMENT_ID"
  QA_TEST_CASE ||--o{ QA_TEST_RESULT : "TEST_CASE_ID"
  QA_TEST_CASE ||--o{ QA_TRACE_LINK : "TEST_CASE_ID"
  QA_TEST_RESULT |o--o{ QA_DEFECT : "TEST_RESULT_ID"
  QA_TEST_RUN ||--o{ QA_TEST_RESULT : "RUN_ID"
  QA_TEST_SUITE ||--o{ QA_TEST_CASE : "SUITE_ID"
```

## الجداول

| الجدول | الاسم العربي | English | النطاق |
|---|---|---|---|
| `QA_REQUIREMENT` | سجل المتطلبات | Requirements Register | G |
| `QA_TEST_SUITE` | مجموعات الاختبار | Test Suites | G |
| `QA_TEST_CASE` | حالات الاختبار | Test Cases | G |
| `QA_TRACE_LINK` | روابط التتبع | Traceability Links | G |
| `QA_TEST_RUN` | تشغيلات الاختبار | Test Runs | G |
| `QA_TEST_RESULT` | نتائج الاختبار | Test Results | G |
| `QA_DEFECT` | العيوب | Defects | G |
