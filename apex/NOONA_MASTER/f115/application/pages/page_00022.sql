prompt --application/pages/page_00022
begin
--   Manifest
--     PAGE: 00022
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>115
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>22
,p_name=>'Welcome'
,p_alias=>'WELCOME'
,p_step_title=>'نونا بلس - نظام إدارة المؤسسات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_step_template=>2977628563533209425
,p_page_is_public_y_n=>'Y'
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000090)
,p_plug_name=>'الرأس'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<header class="nnw-top"><div class="nnw-wrap nnw-top-in"><a class="nnw-logo" href="f?p=&APP_ID.:WELCOME:&SESSION."><img src="#APP_FILES#noona-logo.svg" alt="">نونا بلس</a><nav class="nnw-nav"><a href="f?p=&APP_ID.:WELCOME:&SESSION.#features">المزايا</a><a href="f?p=&APP_ID.:WELCOME:&SESSION.#systems">الأنظمة</a><a href="f?p=&APP_ID.:WELCOME:&SESSION.#pricing">الأسعار</a><a href="f?p=&APP_ID.:WELCOME:&SESSION.#faq">الأسئلة</a></nav><div class="nnw-act"><a class="nnw-link" href="f?p=&APP_ID.:1:&SESSION.">تسجيل الدخول</a><a class="nnw-btn nnw-btn-primary" href="f?p=&APP_ID.:SIGNUP:&SESSION.">ابدأ مجاناً</a></div></div></header><section class="nnw-hero"><div class="nnw-wrap nnw-hero-in"><div class="nnw-hero-txt"><span class="nnw-pill">نظام سحابي سعودي · عربي بالكامل</span><h1>أدر مؤسستك كلها من نظام واحد</h1><p>المالية والمخزون والمبيعات والموارد البشرية والعقارات والمقاولات والمستشفيات وغيرها، بفاتورة إلكترونية ومساعد ذكي، وقوائم موحدة لمجموعتك.</p><div class="nnw-cta"><a class="nnw-btn nnw-btn-primary nnw-btn-lg" href="f?p=&APP_ID.:SIGNUP:&SESSION.">ابدأ تجربتك المجانية 14 يوماً</a><a class="nnw-btn nnw-btn-ghost nnw-btn-lg" href="f?p=&APP_ID.:WELCOME:&SESSION.#pricing">شاهد الأسعار</a></div><ul class="nnw-ticks"><li>بلا بطاقة</li><li>جاهز خلال دقائق</li><li>انقل بياناتك من Excel</li></ul></div><div class="nnw-hero-art"><img src="#APP_FILES#noona-logo-white.svg" alt=""><div class="nnw-kpi"><b>12</b><span>نظاماً متكاملاً</span></div><div class="nnw-kpi"><b>8</b><span>دول خليجية وعربية</span></div><div class="nnw-kpi"><b>14</b><span>يوماً مجاناً</span></div></div></div></section>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000091)
,p_plug_name=>'المزايا'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<section class="nnw-sec" id="features"><div class="nnw-wrap"><h2>لماذا نونا بلس؟</h2><p class="nnw-sub">صُمم لمؤسسات المنطقة: لغتها وأنظمتها الضريبية وطريقة عملها.</p><div class="nnw-grid nnw-feat"><div class="nnw-card"><div class="nnw-ic"><span class="fa fa-sitemap"></span></div><h3>مؤسسة وشركات وفروع</h3><p>شركة قابضة وتابعاتها وفروع بعملات مختلفة، وقوائم مالية موحدة بضغطة.</p></div><div class="nnw-card"><div class="nnw-ic"><span class="fa fa-file-text-o"></span></div><h3>فاتورة إلكترونية</h3><p>متوافقة مع متطلبات هيئة الزكاة والضريبة والدخل (فاتورة)، مع الإقرار الضريبي.</p></div><div class="nnw-card"><div class="nnw-ic"><span class="fa fa-magic"></span></div><h3>مساعد ذكي</h3><p>«اسأل نونا» يجيب من بياناتك بالعربية، وملخصات وتحليلات وتنبؤات.</p></div><div class="nnw-card"><div class="nnw-ic"><span class="fa fa-upload"></span></div><h3>انتقال سهل</h3><p>استورد حساباتك وعملاءك وأصنافك وموظفيك وأرصدتك من ملفات Excel.</p></div><div class="nnw-card"><div class="nnw-ic"><span class="fa fa-shield"></span></div><h3>أمان وصلاحيات</h3><p>عزل تام لبيانات كل مؤسسة، وأدوار وصلاحيات دقيقة، وسجل تدقيق لا يعدل.</p></div><div class="nnw-card"><div class="nnw-ic"><span class="fa fa-mobile"></span></div><h3>من أي جهاز</h3><p>يعمل من المتصفح على الحاسب والجوال، عربي بالكامل من اليمين لليسار.</p></div></div></div></section>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000092)
,p_plug_name=>'الأنظمة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<section class="nnw-sec nnw-alt" id="systems"><div class="nnw-wrap"><h2>اختر الأنظمة التي تحتاجها</h2>''',
'  || ''<p class="nnw-sub">ادفع فقط لما تستخدمه، وأضف غيره متى احتجت.</p>''',
'  || noona_signup_pkg.site_systems_html(''f?p='' || :APP_ID || '':SIGNUP:'' || :APP_SESSION) || ''</div></section>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000093)
,p_plug_name=>'الأسعار'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<section class="nnw-sec" id="pricing"><div class="nnw-wrap"><h2>أسعار واضحة</h2>''',
'  || ''<p class="nnw-sub">كلما طالت المدة زاد الخصم.</p>''',
'  || noona_signup_pkg.site_plans_html(''f?p='' || :APP_ID || '':SIGNUP:'' || :APP_SESSION) || ''</div></section>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000000094)
,p_plug_name=>'الخطوات والأسئلة'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<section class="nnw-sec nnw-alt"><div class="nnw-wrap"><h2>ابدأ في أربع خطوات</h2><ol class="nnw-steps"><li><span>1</span><b>أنشئ حسابك</b><small>بريدك وجوالك ورمز تحقق</small></li><li><span>2</span><b>أدخل مؤسستك</b><small>الاسم والسجل والرقم الضريبي</small></li><li><span>3</span><b>اختر أنظمتك</b><small>وعدد المستخدمين، والسعر يظهر فوراً</small></li><li><span>4</span><b>ابدأ العمل</b><small>تجربة 14 يوماً وانقل بياناتك من Excel</small></li></ol></div></section><section class="nnw-sec" id="faq"><div class="nnw-wrap nnw-narrow"><h2>أسئلة شائعة</h2><details class="nnw-faq"><summary>هل أحتاج بطاقة للتجربة؟</summary><p>لا. التجربة المجانية 14 يوماً بلا أي دفع، وبكل الأنظمة التي تختارها.</p></details><details class="nnw-faq"><summary>ماذا يحدث لبياناتي بعد التجربة؟</summary><p>تبقى كما هي. عند الاشتراك تستمر عليها، وإن لم تشترك تتحول المؤسسة للقراءة فقط دون حذف.</p></details><details class="nnw-faq"><summary>كيف أدفع؟</summary><p>بالتحويل البنكي حالياً: تكتب مرجع التحويل، ونفعل اشتراكك ونرسل فاتورتك الضريبية بالبريد.</p></details><details class="nnw-faq"><summary>هل أستطيع إضافة أنظمة أو مستخدمين لاحقاً؟</summary><p>نعم، من «إدارة المؤسسة ← اشتراكي» في أي وقت، بالسعر المعلن.</p></details><details class="nnw-faq"><summary>كيف أنقل بياناتي من نظامي الحالي؟</summary><p>من «بدء التشغيل ونقل البيانات» بملفات Excel جاهزة النماذج، مع مطابقة الأرصدة الافتتاحية.</p></details></div></section><section class="nnw-final"><div class="nnw-wrap"><h2>جاهز تبدأ؟</h2><p>أنشئ مؤسستك الآن وجرّب كل شيء مجاناً.</p><a class="nnw-btn nnw-btn-light nnw-btn-lg" href="f?p=&APP_ID.:SIGNUP:&SESSION.">ابدأ مجاناً</a></div></section><footer class="nnw-foot"><div class="nnw-wrap nnw-foot-in"><span><img src="#APP_FILES#noona-logo-white.svg" alt=""> نونا بلس</span><span>© 2026 جميع الحقوق محفوظة</span><span><a href="f?p=&APP_ID.:1:&SESSION.">تسجيل الدخول</a> · <a href="f?p=&APP_ID.:SIGNUP:&SESSION.">إنشاء حساب</a></span></div></footer>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);

wwv_flow_imp.component_end;
end;
/
