# كتالوجات الاستخدام

كتالوج لكل موديول: صورة كل شاشة من النظام نفسه، حقولها ونوع كل حقل والإلزامي منها والقيم المتاحة، الأزرار، أعمدة القوائم،
خطوات الإدخال، تسلسل الإدخال بين الشاشات، والشاشات البديلة. المخرجات HTML وPDF.

| الملف | الكتالوج |
|---|---|
| `specs/m00_foundation.py` | التأسيس: المنصة، المؤسسة والشركة الأم، الشركات الثانية، الفروع، الهيكل، الأدوار والمستخدمون، الاعتمادات، البيانات المرجعية، مهامي |
| `specs/m01_finance.py` | المالية: الأستاذ، النقدية، القوائم، الأصول الثابتة، الضرائب، المطابقة البنكية |
| `specs/m02_supply_chain.py` | سلسلة الإمداد: الأصناف والمستودعات والمخزون والمشتريات |
| `specs/m03_sales_pos.py` | المبيعات ونقاط البيع والمطاعم |
| `specs/m04_manufacturing.py` | التصنيع |
| `specs/m05_hr_payroll.py` | الموارد البشرية والرواتب |
| `specs/m06_documents.py` | المستندات والمراسلات |
| `specs/m07_real_estate.py` | العقارات والضيافة والصيانة وبيع الوحدات والإيجارات والمشروعات |
| `specs/m08_healthcare.py` | المستشفيات والمراكز الطبية |
| `specs/m09_auto_service.py` | مراكز خدمة السيارات |
| `specs/m10_reports_integrations.py` | مركز التقارير والتكاملات |

## التوليد

يتطلب قاعدة بيانات بها البيانات التجريبية وORDS يعمل (المنفذ 8090 افتراضياً) وPlaywright:

```bash
PW_PATH=/path/to/node_modules/playwright NOONA_PWD_ADMIN='...' NOONA_PWD_PLATFORM='...' python3 tools/manual/build_manual.py
python3 tools/manual/build_manual.py m01 m02          # موديولات محددة
python3 tools/manual/build_manual.py --no-capture     # إعادة الإخراج من آخر التقاط بعد تعديل الشرح
```

المخرجات في `apex/_manual/out/`: `index.html` وملف HTML وPDF لكل كتالوج ومجلد الصور `img/` والخطوط `fonts/`.

## إضافة شاشة أو تعديل الشرح

كل شاشة في ملف الموديول قاموس: `app` و`alias` (اسم الصفحة المستعار) و`shot` (اسم فريد للصورة)، والشرح: `purpose`، `steps`،
`notes`، `alt` (الشاشات البديلة)، `fields` (وصف حقل باسمه)، `buttons` (وصف زر بنصه)، `doc_fields` (للشاشات المخصصة بلا حقول APEX).
للوصول لشاشة تحتاج سجلاً: `via` (افتح قائمة وانقر أول رابط)، أو `actions` (نقر أو انتقال عبر القائمة الجانبية `nav('...')`).

## فيديوهات الشرح: فيديوهان لكل نظام بشرح عربي على الشاشة

المخرجات في `apex/_manual/out/video3/`:
- `short/`: **الفيديو القصير** لكل نظام: إدخال حقيقي سريع (سكربتات `video/v00..v11`) بشرح عربي مختصر.
- `long/`: **الفيديو المطول** لكل نظام: جولة على كل الشاشات بشرح كل حقل وعمود وزر (`video2/tour.js`) مع مشاهد إدخال حقيقي.

دليل الحسابات في الفيديوهين (`video/coa_scene.js`): إدخال يدوي لحساب رئيسي تجميعي ثم حساب حركة تحته، واستيراد حسابات من ملف
CSV خارجي (`video/assets/coa_import.csv`، فيه صف بأب غير موجود عمداً ليظهر تقرير الرفض). في شركة فيها الرموز مسبقاً يختار المشهد
أول رموز خالية ويولد ملف الاستيراد بها.

`video/vlib.js` يسجل المتصفح (1280×720) مع شريط الشرح العربي، شارة الخطوة، مؤشر الفأرة وإبراز الحقل الحالي، وبطاقات البداية والنهاية.
كل فيديو يكمل المؤسسة التي أنشأها الفيديو الأول (مجموعة النور):

| السكربت | الفيديو |
|---|---|
| `video/v00_foundation.js` | 1 التأسيس: المؤسسة والشركة الأم، فرع، شركة ثانية، مستخدم ودوره (يطبع `USERS <المسؤول> <المحاسبة>`) |
| `video/prep_finance_role.sql` | خارج التسجيل: دور «المدير المالي» للمحاسبة |
| `video/v01_finance.js` | 2 المالية: التجهيز، السنة المالية وفتح التالية، السندات والقيد، الاعتماد، التقارير |
| `video/v02_supply_chain.js` | 3 سلسلة الإمداد: صنف، مورد، فاتورة مشتريات، سداد، التقارير |
| `video/v03_sales_pos.js` | 4 المبيعات ونقاط البيع: عميل، فاتورة، تحصيل، بيع سريع، إقفال الوردية |
| `video/prep_mfg.js` + `video/v04_manufacturing.js` | 5 التصنيع: مركز عمل، قائمة مواد، مسار، أمر إنتاج حتى الإقفال |
| `video/v05_hr_payroll.js` | 6 الموارد البشرية والرواتب |
| `video/v06_documents.js` | 7 المستندات والمراسلات |
| `video/v07_real_estate.js` | 8 العقارات والإيجارات |
| `video/v08_hospitality.js` | 9 الضيافة والفنادق |
| `video/v09_healthcare.js` | 10 المستشفيات والمراكز الطبية |
| `video/v10_auto_service.js` | 11 مراكز خدمة السيارات |
| `video/v11_reports_integrations.js` | 12 مركز التقارير والتكاملات |

```bash
export PW_PATH=/path/to/node_modules/playwright
NOONA_PWD_PLATFORM='...' node tools/manual/video/v00_foundation.js out/v00     # يطبع USERS
sqlplus NOONA_APP@... @tools/manual/video/prep_finance_role.sql <المسؤول> <المحاسبة>
NOONA_VADMIN=<المسؤول> NOONA_VACC=<المحاسبة> NOONA_VPWD='...' node tools/manual/video/v01_finance.js out/v01
ffmpeg -i out/v01/v01_finance.webm -c:v libx264 -crf 26 -pix_fmt yuv420p -movflags +faststart video3/short/02_المالية_ودليل_الحسابات.mp4
```

## الفيديو المطول: جولة كل الشاشات + المرتجعات + دليل الحسابات

`video2/tour.js` يجول على كل شاشات الموديول من الكتالوج نفسه: لكل شاشة الغرض منها، ثم إبراز الحقول (الإلزامي ونوعه وقيمه)
والأعمدة والأزرار واحداً واحداً بشرحها، ثم خطوات الإدخال والملاحظات والبدائل. `video2/returns.js` مشاهد إدخال حقيقي داخل الجولة:
مرتجع المشتريات، مرتجع المبيعات (إشعار دائن)، مرتجع نقطة البيع (F8) بعد بيع حقيقي، وإرجاع خامات أمر الإنتاج،
ودليل الحسابات (إدخال يدوي واستيراد من ملف).

```bash
python3 tools/manual/video2/export_specs.py /tmp/specs.json
PW_PATH=... NOONA_PWD_ADMIN=... NOONA_PWD_PLATFORM=... node tools/manual/video2/tour.js /tmp/specs.json m02 <outDir> 3
ONLY=scm-preturn,pos-return node tools/manual/video2/tour.js ...     # شاشات محددة للتجربة
```
