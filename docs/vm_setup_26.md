# تجهيز خادم نونا 26 على Oracle Linux (جهاز افتراضي أو خادم)

سكربت واحد يثبّت: Oracle AI Database 26ai (Free أو Enterprise Edition) + APEX 26.x + ORDS + Java 21 + قاعدة نونا 26
وتطبيقاتها الخمسة عشر، والبيانات التجريبية اختيارياً: `tools/vm/setup_noona26_ol.sh`

## 1) الملفات المطلوبة

ضعها في `/opt/noona/downloads` على الخادم:

| الملف | ملاحظة |
|---|---|
| حزمة القاعدة 26ai لنفس إصدار النظام | `...el8.x86_64.rpm` لـ Oracle Linux 8، و`...el9.x86_64.rpm` لـ Oracle Linux 9. Free أو EE |
| `apex_26.2.zip` | إن لم يوجد ينزّل السكربت `apex-latest.zip` |
| `ords-latest.zip` | إن لم يوجد ينزّله السكربت |
| `jdk-21.x_linux-x64_bin.rpm` (اختياري) | إن لم يوجد يثبّت OpenJDK 21 |

حزمة el9 لا تثبت على Oracle Linux 8 والعكس، والسكربت ينبهك إن اختلفتا.

## 2) نسخ المشروع للخادم

من Windows (PowerShell) بعد تنزيل المستودع:
```
scp -r noona-plus-26 user@192.168.150.50:~/
scp apex_26.2.zip ords-latest.zip jdk-21*.rpm oracle-*26ai*.rpm user@192.168.150.50:~/
```
على الخادم:
```
sudo mkdir -p /opt/noona/downloads && sudo mv ~/*.zip ~/*.rpm /opt/noona/downloads/
```

## 3) التشغيل
```
cd ~/noona-plus-26
sudo bash tools/vm/setup_noona26_ol.sh
```
يسأل عن كلمات المرور (لا تحفظ في أي ملف): SYS، NOONA_OWNER، NOONA_APP، مسؤول APEX، ومستخدمي نونا ADMIN وPLATFORM.
القواعد: 10 أحرف على الأقل، حرف كبير وصغير ورقم، بلا مسافات أو علامات تنصيص أو `\ $ ``. كلمة مرور APEX يلزم فيها رمز
مثل `#` أو `!`.

المدة التقريبية: Free ساعة تقريباً، EE ساعة ونصف إلى ساعتين (أطولها تهيئة القاعدة وتثبيت APEX). يعاد تشغيله بأمان:
الخطوات المكتملة تتخطى. السجل: `/var/log/noona26_setup.log`.

## 4) الخطوات التي ينفذها

| # | الخطوة |
|---|---|
| 0 | فحص النظام والذاكرة والمساحة |
| 1 | الحزم الأساسية، Java 21، حزمة التهيئة (preinstall) |
| 2 | تثبيت القاعدة وتهيئتها وتشغيلها تلقائياً مع الجهاز |
| 3 | APEX ومسؤوله، وصلاحية الاتصال بمزود الذكاء الاصطناعي |
| 4 | ORDS كخدمة systemd على المنفذ 8080 |
| 5-6 | مخططات نونا، الجداول والحزم، ترقيات الذكاء الاصطناعي، واجهة REST |
| 7 | مساحة عمل APEX باسم NOONAPLUS ومطوّرها NOONA |
| 8 | استيراد التطبيقات الخمسة عشر |
| 9 | كلمات مرور ADMIN وPLATFORM، والبيانات التجريبية |
| 10 | فتح المنفذين 1521 و8080 في جدار الحماية والتحقق |

## 5) بعد الانتهاء

| ما تريد | العنوان |
|---|---|
| الدخول للنظام | `http://IP:8080/ords/r/noonaplus/noona_master/home` |
| تطوير APEX | `http://IP:8080/ords/r/apex/workspace-sign-in` (مساحة NOONAPLUS، المستخدم NOONA) |
| إدارة APEX | `http://IP:8080/ords/apex_admin` |
| SQL*Plus / SQL Developer | `NOONA_APP@//IP:1521/FREEPDB1` (أو `ORCLPDB1` للنسخة EE) |

الخدمات: `systemctl status oracle-free-26ai ords` (اسم خدمة القاعدة يختلف في EE، والسكربت يطبعه).
الذكاء الاصطناعي: اضبط خدمة Claude ومفتاحك من داخل APEX حسب `docs/ai_setup_26.md`.

## ترخيص Enterprise Edition

النسخة EE تنزل مجاناً للتطوير والاختبار حسب ترخيص Oracle، لكن استخدامها في الإنتاج يحتاج ترخيصاً مدفوعاً. النسخة Free
مجانية للإنتاج أيضاً بحدودها (نواتان، 2 جيجابايت ذاكرة، 12 جيجابايت بيانات).
