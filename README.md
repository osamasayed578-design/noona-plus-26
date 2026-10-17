# NOONA PLUS ERP

منصة ERP سحابية متعددة المؤسسات (SaaS + On-Premises) للمؤسسات التجارية والخدمية والصناعية والحكومية، مع قطاعات الإنشاءات والتطوير العقاري وإدارة الأملاك والضيافة.

**التقنية:** Oracle Database 21c · Oracle APEX 24.2 · PL/SQL · ORDS

## محتويات المستودع

| المسار | المحتوى |
|---|---|
| [`docs/baseline/`](docs/baseline/NOONA_PLUS_Baseline.md) | الوثيقة المرجعية للمشروع (المراحل الخمسون) |
| [`docs/design/DESIGN.md`](docs/design/DESIGN.md) | وثيقة التصميم التقني: العزل، المفاتيح، الحزم، تصميم APEX، خطة AI |
| [`docs/erd/`](docs/erd/README.md) | مخططات ERD لكل حزمة (Mermaid + SVG) |
| [`docs/data-dictionary/`](docs/data-dictionary/README.md) | قاموس البيانات (Markdown لكل حزمة + Excel) |
| `db/` | سكربتات قاعدة البيانات الجاهزة للتشغيل |
| `tools/model/` | النموذج الموحد: المصدر الوحيد للحقيقة |
| `tools/generate.py` | مولد DDL و ERD والقاموس والـVPD والصلاحيات |

## الأرقام

**30 حزمة · 568 جدولاً · 9,722 عموداً · 2,435 مفتاحاً أجنبياً · 1,557 صلاحية ذرية**، كلها مختبرة على Oracle Database 21c بدون أخطاء.

## التثبيت

```bash
cd db
# 1) مرة واحدة: إنشاء المخططات (DBA) ومنح حزم SYS
sqlplus system@//HOST:1521/PDB              @admin/00_create_schemas.sql
sqlplus sys@//HOST:1521/PDB as sysdba       @admin/01_sys_grants.sql
# 2) الجداول والقيود والـTriggers والحزم والبيانات المرجعية و VPD والصلاحيات
sqlplus NOONA_OWNER@//HOST:1521/PDB         @install.sql
# 3) مرادفات مخطط التطبيق
sqlplus NOONA_APP@//HOST:1521/PDB           @security/41_synonyms_noona_app.sql
# 4) (اختياري - تطوير فقط) مؤسسة تجريبية ومستخدم ADMIN
sqlplus NOONA_OWNER@//HOST:1521/PDB         @seed/90_demo_tenant_DEV_ONLY.sql
```

غيّر كلمات المرور الافتراضية في `db/admin/00_create_schemas.sql` قبل التشغيل.

في APEX 24.2: أنشئ Workspace على المخطط `NOONA_APP`، ثم اربط Authentication و Initialization/Cleanup بـ `NOONA_SECURITY_PKG` كما في [القسم 5.2 من وثيقة التصميم](docs/design/DESIGN.md#52-دورة-الطلب-الآمنة-في-apex).

## تعديل التصميم

```bash
# عدّل tools/model/mNN_*.py ثم:
python3 tools/generate.py
```
