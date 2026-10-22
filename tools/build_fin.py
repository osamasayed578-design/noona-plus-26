"""NOONA_FIN (المالية): الأستاذ العام، مراكز التكلفة، النقدية والبنوك (سندات القبض والصرف والمصروفات)، القوائم المالية والتحليلات
الاستخدام: python3 tools/build_fin.py   ->  apex/NOONA_FIN/f127
القيود والسندات: شبكة إدخال رأس/تفاصيل (tools/fin_grid.py) تحفظ السطور JSON في عنصر مخفي؛
التحقق والترحيل في NOONA_GL_PKG و NOONA_CSH_PKG (عبر المحرك المحاسبي NOONA_ACE_PKG).
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App
from fin_grid import GRID_JS, grid_region
from fin_doc import DOC_JS, doc_region, doc_ajax
from dms_panel import dms_panel, download_page, dl_link, VIEWER_JS

ROOT = os.path.join(os.path.dirname(__file__), '..')
app = App(template_dir=os.path.join(ROOT, 'apex/_templates/f119_original'),
          out_dir=os.path.join(ROOT, 'apex/NOONA_FIN/f127'),
          app_id=127, alias='NOONA_FIN', name='NOONA Finance', id_base=91820266000000000)
app.wire_security()
app.add_branding()
TENANT = app.schemes['tenant']

def url(page_no, items='', values='', clear=''):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:{clear}:{items}:{values}'

LEDGER_ACCOUNTS = ("select a.account_code || ' - ' || a.name_ar d, a.id r from gl_account a "
                   "join gl_ledger g on g.coa_id = a.coa_id where g.id = noona_gl_pkg.primary_ledger and a.is_postable = 'Y' "
                   "order by a.account_code")
JOURNALS_SQL = [
    "select j.id, j.doc_no, to_char(j.doc_date, 'YYYY-MM-DD') as doc_date, noona_gl_pkg.type_label(j.journal_category) as journal_type,",
    '       j.description, j.reference_no,',
    '       j.total_debit_func as amount, j.currency_code, j.created_by, j.approved_by,',
    '       noona_ui_pkg.status_badge(j.status_code) as status_html',
    '  from gl_journal j where j.company_id = noona_gl_pkg.company']
JOURNALS_COLS = [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'رقم القيد', {}), ('DOC_DATE', 'التاريخ', {}),
                 ('JOURNAL_TYPE', 'نوع القيد', {}),
                 ('DESCRIPTION', 'البيان', {}), ('REFERENCE_NO', 'المرجع', {}), ('AMOUNT', 'المبلغ', {'type': 'NUMBER'}),
                 ('CURRENCY_CODE', 'العملة', {}), ('CREATED_BY', 'أنشأه', {}), ('APPROVED_BY', 'اعتمده', {}),
                 ('STATUS_HTML', 'الحالة', {'html': True})]
CC_LOV = ("select code || ' - ' || name_ar d, id r from gl_cost_center "
          "where company_id = noona_gl_pkg.company order by code")
CUR_LOV = ("select currency_code || ' - ' || name_ar d, currency_code r from ref_currency where is_active = 'Y' "
           "order by case when currency_code = noona_gl_pkg.ledger_currency then 0 else 1 end, currency_code")
JOURNAL_LINK = 'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:RP,21:P21_ID:#ID#'
JTYPE_LOV = ("select name_ar d, code r from (select t.*, row_number() over (partition by code order by tenant_id nulls last) rn "
             "from gl_journal_type t where is_active = 'Y') where rn = 1 order by case type_group when 'MANUAL' then 1 else 2 end, sort_order")

# =============================================================== 1) لوحة المالية
p = app.page(1, 'Home', 'HOME', 'المالية', scheme=TENANT)
hd = p.dynamic('الأستاذ العام', 10, 'return noona_gl_pkg.gl_summary(p_session => :APP_SESSION);', hide_header=True)
st = p.static('تجهيز الأستاذ العام', 15, condition='noona_gl_pkg.primary_ledger is null')
b_setup = p.button(st, 10, 'SETUP', 'تجهيز الأستاذ العام (دليل حسابات قياسي ودفتر رئيسي)', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Quick Setup', [
    'declare l_id number;',
    'begin',
    '    l_id := noona_gl_pkg.quick_setup;',
    'end;'], when_button=b_setup, success='تم تجهيز الأستاذ العام: دليل الحسابات والدفتر الرئيسي وفترات السنة المفتوحة')
p.dynamic('النقدية والبنوك', 12, 'return noona_csh_pkg.summary(p_session => :APP_SESSION);', hide_header=True,
          condition='noona_gl_pkg.primary_ledger is not null')
st2 = p.static('تجهيز النقدية', 16, condition=(
    "noona_gl_pkg.primary_ledger is not null and noona_csh_pkg.is_ready = 'N'"))
b_cash = p.button(st2, 10, 'CASH_SETUP', 'تجهيز النقدية (الصندوق الرئيسي وتسلسلات السندات)', hot=True)
p.process(20, 'AFTER_SUBMIT', 'Cash Setup', [
    'declare l_id number;',
    'begin',
    '    l_id := noona_csh_pkg.quick_setup;',
    'end;'], when_button=b_cash, success='تم تجهيز النقدية: الصندوق الرئيسي وتسلسلات سندات القبض والصرف والمصروفات')
r = p.ir('آخر القيود', 20, JOURNALS_SQL[:-1] + [JOURNALS_SQL[-1] + ' order by j.id desc fetch first 15 rows only'],
         JOURNALS_COLS, link=JOURNAL_LINK, titled=True)
p.button(r, 10, 'NEW_JOURNAL', 'قيد جديد', hot=True, redirect=url(21, clear='RP,21'), position='RIGHT_OF_IR_SEARCH_BAR')
p.branch(10, url(1) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 10) دليل الحسابات
p = app.page(10, 'Chart of Accounts', 'ACCOUNTS', 'دليل الحسابات', scheme=TENANT)
p.ir('دليل الحسابات', 10, [
    "select a.id, a.account_code, lpad(' ', (a.account_level - 1) * 4, ' ') || a.name_ar as name_ar,",
    "       case a.account_type when 'ASSET' then 'أصول' when 'LIABILITY' then 'خصوم' when 'EQUITY' then 'حقوق ملكية'",
    "            when 'REVENUE' then 'إيرادات' when 'EXPENSE' then 'مصروفات' else a.account_type end as account_type,",
    "       case a.normal_balance when 'DEBIT' then 'مدين' else 'دائن' end as normal_balance,",
    "       case a.is_postable when 'Y' then 'حركة' else 'تجميعي' end as kind,",
    "       decode(a.subledger_code, 'AR', 'العملاء', 'AP', 'الموردون', 'INV', 'المخزون', 'FA', 'الأصول الثابتة',",
    "              'CASH', 'النقدية', 'TAX', 'الضرائب', 'PAYROLL', 'الرواتب', a.subledger_code) as subledger,",
    '       noona_ui_pkg.code_label(a.allow_manual_posting) as manual, noona_ui_pkg.status_badge(a.status_code) as status_html',
    '  from gl_account a join gl_ledger g on g.coa_id = a.coa_id where g.id = noona_gl_pkg.primary_ledger',
    ' order by a.account_code'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('ACCOUNT_CODE', 'الرمز', {}), ('NAME_AR', 'الحساب', {}),
     ('ACCOUNT_TYPE', 'النوع', {}), ('NORMAL_BALANCE', 'الطبيعة', {}), ('KIND', 'تجميعي/حركة', {}),
     ('SUBLEDGER', 'نظام فرعي', {}), ('MANUAL', 'قيد يدوي', {}), ('STATUS_HTML', 'الحالة', {'html': True})], rows=200)
f = p.static('حساب جديد', 20)
p.select('P10_PARENT', f, 10, 'تحت الحساب الرئيسي', required=True, lov_sql=(
    "select a.account_code || ' - ' || a.name_ar d, a.account_code r from gl_account a join gl_ledger g on g.coa_id = a.coa_id "
    "where g.id = noona_gl_pkg.primary_ledger and a.is_postable = 'N' order by a.account_code"))
p.text('P10_CODE', f, 20, 'رمز الحساب', required=True, maxlen=20, width=15)
p.text('P10_NAME', f, 30, 'اسم الحساب', required=True)
p.select('P10_POSTABLE', f, 40, 'نوع الحساب', null_text=None, lov_sql='STATIC2:حساب حركة;Y,حساب تجميعي;N')
b = p.button(f, 10, 'ADD_ACCOUNT', 'إضافة الحساب', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Add Account', [
    'declare l_id number;',
    'begin',
    '    l_id := noona_gl_pkg.add_account(p_coa_id => noona_gl_pkg.primary_coa, p_code => :P10_CODE, p_name_ar => :P10_NAME,',
    '                p_parent_code => :P10_PARENT, p_postable => :P10_POSTABLE);',
    'end;'], when_button=b, success='تمت إضافة الحساب')
stf = p.static('إيقاف أو تفعيل حساب', 30)
p.select('P10_ACCOUNT', stf, 10, 'الحساب', lov_sql=LEDGER_ACCOUNTS)
p.select('P10_STATUS', stf, 20, 'الحالة', null_text=None, lov_sql='STATIC2:موقوف;BLOCKED,نشط;ACTIVE')
b2 = p.button(stf, 10, 'SET_STATUS', 'تطبيق')
p.process(20, 'AFTER_SUBMIT', 'Account Status', 'noona_gl_pkg.set_account_status(:P10_ACCOUNT, :P10_STATUS);',
          when_button=b2, success='تم تغيير حالة الحساب')
p.branch(10, url(10, clear='10') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 11) الفترات المحاسبية
p = app.page(11, 'Periods', 'PERIODS', 'الفترات المحاسبية', scheme=TENANT)
p.ir('الفترات المحاسبية', 10, [
    "select p.id, y.name_ar as fiscal_year, p.period_no, p.name_ar, to_char(p.start_date, 'YYYY-MM-DD') as start_date,",
    "       to_char(p.end_date, 'YYYY-MM-DD') as end_date,",
    "       decode(s.status_code, 'OPEN', '<span class=\"nn-badge is-success\">مفتوحة</span>',",
    "              'SOFT_CLOSED', '<span class=\"nn-badge is-warning\">مقفلة مبدئياً</span>',",
    "              'HARD_CLOSED', '<span class=\"nn-badge is-danger\">مقفلة نهائياً</span>', '<span class=\"nn-badge is-muted\">غير مهيأة</span>') as status_html,",
    '       s.closed_by, s.closed_at',
    '  from gl_period p join gl_fiscal_year y on y.id = p.fiscal_year_id',
    '  left join gl_period_status s on s.period_id = p.id and s.ledger_id = noona_gl_pkg.primary_ledger and s.module_code = \'GL\'',
    ' where p.company_id = noona_gl_pkg.company order by p.start_date'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('FISCAL_YEAR', 'السنة', {}), ('PERIOD_NO', 'رقم', {'type': 'NUMBER'}),
     ('NAME_AR', 'الفترة', {}), ('START_DATE', 'من', {}), ('END_DATE', 'إلى', {}), ('STATUS_HTML', 'الحالة', {'html': True}),
     ('CLOSED_BY', 'أقفلها', {}), ('CLOSED_AT', 'وقت الإقفال', {'type': 'DATE'})])
f = p.static('تغيير حالة فترة', 20)
p.select('P11_PERIOD', f, 10, 'الفترة', required=True, lov_sql=(
    "select p.name_ar d, p.id r from gl_period p where p.company_id = noona_gl_pkg.company order by p.start_date"))
p.select('P11_STATUS', f, 20, 'الحالة الجديدة', null_text=None, lov_sql=(
    'STATIC2:مفتوحة;OPEN,مقفلة مبدئياً (تمنع الترحيل);SOFT_CLOSED,مقفلة نهائياً;HARD_CLOSED'))
b = p.button(f, 10, 'APPLY', 'تطبيق', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Period Status', 'noona_gl_pkg.set_period_status(:P11_PERIOD, :P11_STATUS);',
          when_button=b, success='تم تغيير حالة الفترة')
p.branch(10, url(11) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 20) القيود اليومية
p = app.page(20, 'Journals', 'JOURNALS', 'القيود اليومية', scheme=TENANT)
r = p.ir('القيود اليومية', 10, JOURNALS_SQL + [' order by j.id desc'], JOURNALS_COLS, link=JOURNAL_LINK)
p.button(r, 10, 'NEW_JOURNAL', 'قيد جديد', hot=True, redirect=url(21, clear='RP,21'), position='RIGHT_OF_IR_SEARCH_BAR')

# =============================================================== 21) القيد
p = app.page(21, 'Journal', 'JOURNAL', 'قيد يومية', scheme=TENANT)
hd = p.static('القيد', 1, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P21_ID', hd, 1)
p.hidden('P21_STATUS', hd, 2)
p.process(10, 'BEFORE_HEADER', 'Load Journal', [
    'if :P21_ID is not null then',
    '    select status_code into :P21_STATUS from gl_journal where id = :P21_ID and company_id = noona_gl_pkg.company;',
    'end if;'])
p.dynamic('ملخص القيد', 5, 'return noona_gl_pkg.journal_header(:P21_ID);', hide_header=True,
          condition=":P21_ID is not null and :P21_STATUS <> 'DRAFT'")
p.dynamic('مستند القيد', 10, doc_region('JE', 'noona_gl_pkg.journal_doc_json(:P21_ID)', 'noona_gl_pkg.accounts_json',
                                        "case when :P21_ID is null or :P21_STATUS = 'DRAFT' then 'N' else 'Y' end",
                                        extra=[('nnDocTypes', 'noona_gl_pkg.journal_types_json')]),
          hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.process(1, 'ON_DEMAND', 'SAVE_DOC', doc_ajax('noona_gl_pkg.save_journal_doc', 21))
ac = p.static('الإجراءات', 30, condition=":P21_ID is not null and :P21_STATUS in ('DRAFT', 'SUBMITTED', 'POSTED')")
p.textarea('P21_REASON', ac, 10, 'الملاحظة أو السبب (إلزامي للرفض والعكس والإلغاء)', rows=2)
p.date('P21_REV_DATE', ac, 20, 'تاريخ العكس')
b_app = p.button(ac, 10, 'APPROVE', 'اعتماد وترحيل', hot=True, condition=":P21_STATUS = 'SUBMITTED'")
b_rej = p.button(ac, 20, 'REJECT', 'رفض وإعادة للمنشئ', condition=":P21_STATUS = 'SUBMITTED'")
b_rev = p.button(ac, 30, 'REVERSE', 'عكس القيد', condition=":P21_STATUS = 'POSTED'")
b_can = p.button(ac, 40, 'CANCEL_JOURNAL', 'إلغاء المسودة', condition=":P21_STATUS = 'DRAFT'")
p.button(ac, 50, 'BACK', 'رجوع', redirect=url(20))
p.process(40, 'AFTER_SUBMIT', 'Approve', 'noona_gl_pkg.approve_journal(:P21_ID, :P21_REASON);', when_button=b_app,
          success='تم اعتماد القيد وترحيله')
p.process(50, 'AFTER_SUBMIT', 'Reject', 'noona_gl_pkg.reject_journal(:P21_ID, :P21_REASON);', when_button=b_rej,
          success='تم رفض القيد وإعادته للمنشئ')
p.process(60, 'AFTER_SUBMIT', 'Reverse', [
    ":P21_ID := noona_gl_pkg.reverse_journal(:P21_ID, nvl(to_date(:P21_REV_DATE, 'YYYY-MM-DD'), trunc(sysdate)), :P21_REASON);"],
    when_button=b_rev, success='تم عكس القيد بقيد مقابل مرحل')
p.process(70, 'AFTER_SUBMIT', 'Cancel', 'noona_gl_pkg.cancel_journal(:P21_ID, :P21_REASON);', when_button=b_can,
          success='تم إلغاء المسودة')
dms_panel(p, 40, 'GL_JOURNAL', 'P21_ID', 49)
p.onload(DOC_JS + GRID_JS + VIEWER_JS)
p.branch(10, 'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:21:P21_ID:&P21_ID.&success_msg=#SUCCESS_MSG#')

# =============================================================== 30) ميزان المراجعة
p = app.page(30, 'Trial Balance', 'TRIAL-BALANCE', 'ميزان المراجعة', scheme=TENANT)
f = p.static('معايير التقرير', 10)
p.date('P30_FROM', f, 10, 'من تاريخ')
p.date('P30_TO', f, 20, 'إلى تاريخ')
p.yesno('P30_ZERO', f, 30, 'إظهار الحسابات الصفرية')
p.select('P30_CC', f, 40, 'مركز التكلفة', lov_sql=CC_LOV, null_text='كل المراكز')
p.select('P30_BASIS', f, 50, 'أساس الاحتساب', null_text=None,
         lov_sql='STATIC2:القيود المرحلة فقط;POSTED,شامل المرسلة والمعتمدة غير المرحلة;ALL')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'BEFORE_HEADER', 'Defaults', [
    ":P30_FROM := nvl(:P30_FROM, to_char(trunc(sysdate, 'YYYY'), 'YYYY-MM-DD'));",
    ":P30_TO := nvl(:P30_TO, to_char(sysdate, 'YYYY-MM-DD'));"])
p.dynamic('ميزان المراجعة', 20, [
    "return noona_gl_pkg.trial_balance(to_date(:P30_FROM, 'YYYY-MM-DD'), to_date(:P30_TO, 'YYYY-MM-DD'), nvl(:P30_ZERO, 'N'), :P30_CC,",
    "    nvl(:P30_BASIS, 'POSTED'), 'f?p=' || :APP_ID || ':31:' || :APP_SESSION || '::NO:RP:P31_ACCOUNT,P31_FROM,P31_TO,P31_CC:#ID#,'",
    "    || :P30_FROM || ',' || :P30_TO || ',' || :P30_CC);"],
    hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

# =============================================================== 31) كشف حساب
p = app.page(31, 'Account Statement', 'STATEMENT', 'كشف حساب', scheme=TENANT, protection='N')
f = p.static('معايير التقرير', 10)
p.select('P31_ACCOUNT', f, 10, 'الحساب', lov_sql=LEDGER_ACCOUNTS)
p.date('P31_FROM', f, 20, 'من تاريخ')
p.date('P31_TO', f, 30, 'إلى تاريخ')
p.select('P31_CC', f, 40, 'مركز التكلفة', lov_sql=CC_LOV, null_text='كل المراكز')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'BEFORE_HEADER', 'Defaults', [
    ":P31_FROM := nvl(:P31_FROM, to_char(trunc(sysdate, 'YYYY'), 'YYYY-MM-DD'));",
    ":P31_TO := nvl(:P31_TO, to_char(sysdate, 'YYYY-MM-DD'));"])
p.dynamic('كشف الحساب', 20, [
    "return noona_gl_pkg.account_statement(:P31_ACCOUNT, to_date(:P31_FROM, 'YYYY-MM-DD'), to_date(:P31_TO, 'YYYY-MM-DD'), :P31_CC,",
    "    'f?p=' || :APP_ID || ':22:' || :APP_SESSION || '::NO:RP:P22_ID:#ID#');"],
    hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

# =============================================================== 12) مراكز التكلفة
p = app.page(12, 'Cost Centers', 'COST-CENTERS', 'مراكز التكلفة', scheme=TENANT)
p.ir('مراكز التكلفة', 10, [
    "select c.id, c.code, c.name_ar, decode(c.center_type, 'COST', 'تكلفة', 'PROFIT', 'ربحية', 'REVENUE', 'إيراد',",
    "       'INVESTMENT', 'استثمار', c.center_type) as cc_type, p.code || ' ' || p.name_ar as parent_name,",
    '       noona_ui_pkg.status_badge(c.status_code) as status_html',
    '  from gl_cost_center c left join gl_cost_center p on p.id = c.parent_center_id',
    ' where c.company_id = noona_gl_pkg.company order by c.code'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'مركز التكلفة', {}),
     ('CC_TYPE', 'النوع', {}), ('PARENT_NAME', 'يتبع', {}), ('STATUS_HTML', 'الحالة', {'html': True})])
f = p.static('مركز تكلفة جديد', 20)
p.text('P12_CODE', f, 10, 'الرمز', maxlen=30, width=15)
p.text('P12_NAME', f, 20, 'الاسم')
p.select('P12_TYPE', f, 30, 'النوع', null_text=None, lov_sql='STATIC2:تكلفة;COST,ربحية;PROFIT,إيراد;REVENUE,استثمار;INVESTMENT')
p.select('P12_PARENT', f, 40, 'يتبع المركز', lov_sql=("select code || ' - ' || name_ar d, code r from gl_cost_center "
                                                    "where company_id = noona_gl_pkg.company order by code"), null_text='- رئيسي -')
b = p.button(f, 10, 'ADD_CC', 'إضافة المركز', hot=True)
b0 = p.button(f, 20, 'SEED_CC', 'إضافة المراكز الافتراضية')
p.process(5, 'AFTER_SUBMIT', 'Seed Cost Centers', [
    'declare l_n number;',
    'begin',
    '    l_n := noona_gl_pkg.seed_cost_centers;',
    "    apex_application.g_print_success_message := case when l_n > 0 then 'أضيفت ' || l_n || ' مراكز تكلفة وربحية افتراضية'",
    "                                                     else 'توجد مراكز للشركة؛ لم يضف شيء' end;",
    'end;'], when_button=b0)
p.process(10, 'AFTER_SUBMIT', 'Add Cost Center', [
    'declare l_id number;',
    'begin',
    '    l_id := noona_gl_pkg.create_cost_center(:P12_CODE, :P12_NAME, :P12_TYPE, :P12_PARENT);',
    'end;'], when_button=b, success='تمت إضافة مركز التكلفة')
f2 = p.static('إيقاف أو تفعيل مركز', 30)
p.select('P12_CC', f2, 10, 'المركز', lov_sql=CC_LOV)
p.select('P12_STATUS', f2, 20, 'الحالة', null_text=None, lov_sql='STATIC2:موقوف;BLOCKED,مغلق;CLOSED,نشط;ACTIVE')
b2 = p.button(f2, 10, 'SET_STATUS', 'تطبيق')
p.process(20, 'AFTER_SUBMIT', 'CC Status', 'noona_gl_pkg.set_cost_center_status(:P12_CC, :P12_STATUS);', when_button=b2,
          success='تم تغيير حالة المركز')
f3 = p.static('قاعدة مركز التكلفة للحساب', 40)
p.select('P12_ACCOUNT', f3, 10, 'الحساب', lov_sql=LEDGER_ACCOUNTS)
p.select('P12_RULE', f3, 20, 'القاعدة', null_text=None,
         lov_sql='STATIC2:إلزامي في كل قيد;REQUIRED,اختياري;OPTIONAL,ممنوع;FORBIDDEN')
b3 = p.button(f3, 10, 'SET_RULE', 'حفظ القاعدة')
p.process(30, 'AFTER_SUBMIT', 'CC Rule', 'noona_gl_pkg.set_cc_rule(:P12_ACCOUNT, :P12_RULE);', when_button=b3,
          success='تم حفظ قاعدة مركز التكلفة للحساب')
p.ir('حسابات لها قاعدة مركز تكلفة', 50, [
    "select a.id, a.account_code, a.name_ar, decode(r.rule_code, 'REQUIRED', 'إلزامي', 'FORBIDDEN', 'ممنوع', 'اختياري') as rule_name",
    '  from gl_account_dim_rule r join gl_dimension d on d.id = r.dimension_id and d.code = \'COST_CENTER\'',
    '  join gl_account a on a.id = r.account_id',
    ' where a.coa_id = noona_gl_pkg.primary_coa and r.rule_code <> \'OPTIONAL\' order by a.account_code'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('ACCOUNT_CODE', 'الرمز', {}), ('NAME_AR', 'الحساب', {}),
     ('RULE_NAME', 'القاعدة', {})], titled=True)
p.branch(10, url(12, clear='12') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 40) الصناديق والبنوك
CASH_ACCOUNTS = ("select a.account_code || ' - ' || a.name_ar d, a.account_code r from gl_account a "
                 "where a.coa_id = noona_gl_pkg.primary_coa and a.subledger_code = 'CASH' and a.is_postable = 'Y' "
                 "and a.status_code = 'ACTIVE' order by a.account_code")
p = app.page(40, 'Cash and Banks', 'CASH-BANKS', 'الصناديق والبنوك', scheme=TENANT)
p.dynamic('أرصدة الصناديق والبنوك', 10, 'return noona_csh_pkg.balances_html;')
f = p.static('صندوق جديد', 20)
p.text('P40_BOX_CODE', f, 10, 'الرمز', maxlen=30, width=15)
p.text('P40_BOX_NAME', f, 20, 'اسم الصندوق')
p.select('P40_BOX_TYPE', f, 30, 'النوع', null_text=None,
         lov_sql='STATIC2:صندوق رئيسي;MAIN,عهدة نثرية;PETTY_CASH,درج نقاط بيع;POS_DRAWER,صندوق استقبال;FRONT_DESK,عهدة;CUSTODY')
p.select('P40_BOX_ACC', f, 40, 'حساب النقدية', lov_sql=CASH_ACCOUNTS, null_text=None)
p.number('P40_BOX_MAX', f, 50, 'الحد الأعلى للرصيد (اختياري)')
p.select('P40_BOX_CUR', f, 60, 'العملة', lov_sql=CUR_LOV, null_text=None)
b = p.button(f, 10, 'ADD_BOX', 'إضافة الصندوق', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Add Box', [
    'declare l_id number;',
    'begin',
    '    l_id := noona_csh_pkg.create_cash_box(:P40_BOX_CODE, :P40_BOX_NAME, :P40_BOX_ACC, :P40_BOX_TYPE, :P40_BOX_MAX, :P40_BOX_CUR);',
    'end;'], when_button=b, success='تمت إضافة الصندوق')
f2 = p.static('حساب بنكي جديد', 30)
p.text('P40_BANK_CODE', f2, 10, 'الرمز', maxlen=30, width=15)
p.text('P40_BANK_NAME', f2, 20, 'اسم الحساب (مثل: الحساب الجاري)')
p.select('P40_BANK', f2, 30, 'البنك', lov_sql="select name_ar d, id r from ref_bank where is_active = 'Y' order by name_ar")
p.text('P40_ACC_NO', f2, 40, 'رقم الحساب', maxlen=40, width=25)
p.text('P40_IBAN', f2, 50, 'الآيبان', maxlen=40, width=30)
p.select('P40_BANK_ACC', f2, 60, 'حساب النقدية في الدليل', lov_sql=CASH_ACCOUNTS, null_text=None)
p.number('P40_BANK_MAX', f2, 70, 'حد الدفع للسند الواحد (اختياري)')
p.select('P40_BANK_CUR', f2, 80, 'العملة', lov_sql=CUR_LOV, null_text=None)
b2 = p.button(f2, 10, 'ADD_BANK', 'إضافة الحساب البنكي', hot=True)
p.process(20, 'AFTER_SUBMIT', 'Add Bank', [
    'declare l_id number;',
    'begin',
    '    l_id := noona_csh_pkg.create_bank_account(:P40_BANK_CODE, :P40_BANK_NAME, :P40_BANK, :P40_ACC_NO, :P40_IBAN,',
    '                                               :P40_BANK_ACC, :P40_BANK_MAX, :P40_BANK_CUR);',
    'end;'], when_button=b2, success='تمت إضافة الحساب البنكي (يحفظ الرقم مقنعاً)')
fe = p.static('تعديل حساب بنكي', 35)
p.select('P40_EDIT_BANK', fe, 10, 'الحساب البنكي', lov_sql=(
    "select code || ' ' || name_ar || ' ' || account_no_masked d, id r from csh_bank_account "
    "where company_id = noona_gl_pkg.company order by code"))
p.text('P40_EDIT_NAME', fe, 20, 'الاسم')
p.select('P40_EDIT_BNK', fe, 30, 'البنك', lov_sql="select name_ar d, id r from ref_bank where is_active = 'Y' order by name_ar")
p.text('P40_EDIT_NO', fe, 40, 'رقم الحساب الجديد (اتركه فارغاً للإبقاء)', maxlen=40, width=25)
p.text('P40_EDIT_IBAN', fe, 50, 'الآيبان الجديد', maxlen=40, width=30)
p.number('P40_EDIT_MAX', fe, 60, 'حد الدفع للسند')
be = p.button(fe, 10, 'EDIT_BANK', 'حفظ التعديل', hot=True)
p.process(25, 'AFTER_SUBMIT', 'Edit Bank', [
    'noona_csh_pkg.update_bank_account(:P40_EDIT_BANK, :P40_EDIT_NAME, :P40_EDIT_BNK, :P40_EDIT_NO, :P40_EDIT_IBAN, :P40_EDIT_MAX);'],
    when_button=be, success='تم تعديل الحساب البنكي')
fd = p.static('الإعدادات الافتراضية', 38, text='<p class="nn-hint">يضيف صندوق العهد النثرية وحساباً بنكياً جارياً افتراضياً (عدّل رقمه من "تعديل حساب بنكي") إن لم توجد.</p>')
bd = p.button(fd, 10, 'SEED_CASH', 'إضافة الصناديق والبنوك الافتراضية')
p.process(26, 'AFTER_SUBMIT', 'Seed Cash', [
    'declare l_n number;',
    'begin',
    '    l_n := noona_csh_pkg.seed_defaults;',
    "    apex_application.g_print_success_message := case when l_n > 0 then 'أضيف ' || l_n || ' (صندوق/حساب بنكي) افتراضي'",
    "                                                     else 'موجودة مسبقاً؛ لم يضف شيء' end;",
    'end;'], when_button=bd)
f3 = p.static('حالة صندوق أو حساب بنكي', 40)
PLACES_ALL = ("select 'صندوق: ' || code || ' ' || name_ar d, 'BOX:' || id r from csh_cash_box where company_id = noona_gl_pkg.company "
              "union all select 'بنك: ' || code || ' ' || name_ar || ' ' || account_no_masked, 'BANK:' || id from csh_bank_account "
              "where company_id = noona_gl_pkg.company order by 1")
p.select('P40_PLACE', f3, 10, 'الصندوق / الحساب', lov_sql=PLACES_ALL)
p.select('P40_STATUS', f3, 20, 'الحالة', null_text=None,
         lov_sql='STATIC2:نشط;ACTIVE,معلق (صندوق);SUSPENDED,مجمد (بنك);FROZEN,مغلق;CLOSED')
b3 = p.button(f3, 10, 'SET_STATUS', 'تطبيق')
p.process(30, 'AFTER_SUBMIT', 'Place Status', [
    "if :P40_PLACE like 'BOX:%' then",
    '    noona_csh_pkg.set_box_status(to_number(substr(:P40_PLACE, 5)), :P40_STATUS);',
    'else',
    '    noona_csh_pkg.set_bank_status(to_number(substr(:P40_PLACE, 6)), :P40_STATUS);',
    'end if;'], when_button=b3, success='تم تغيير الحالة')
p.branch(10, url(40, clear='40') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 41) السندات
VOUCHER_LINK = 'f?p=&APP_ID.:42:&SESSION.::&DEBUG.:RP,42:P42_ID:#ID#'
def new_voucher(t):
    return f'f?p=&APP_ID.:42:&SESSION.::&DEBUG.:RP,42:P42_TYPE:{t}'
p = app.page(41, 'Vouchers', 'VOUCHERS', 'سندات القبض والصرف', scheme=TENANT)
r = p.ir('السندات', 10, [
    "select t.id, noona_csh_pkg.type_label(t.txn_type) as type_name, t.doc_no, to_char(t.doc_date, 'YYYY-MM-DD') as doc_date,",
    "       nvl(b.name_ar, k.name_ar) as place, t.counterparty_name, t.description, t.amount, t.currency_code, t.created_by,",
    '       t.posted_by, noona_ui_pkg.status_badge(t.status_code) as status_html',
    '  from csh_transaction t left join csh_cash_box b on b.id = t.cash_box_id left join csh_bank_account k on k.id = t.bank_account_id',
    " where t.company_id = noona_gl_pkg.company and t.txn_type in ('RECEIPT', 'PAYMENT', 'EXPENSE') order by t.id desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('TYPE_NAME', 'النوع', {}), ('DOC_NO', 'رقم السند', {}),
     ('DOC_DATE', 'التاريخ', {}), ('PLACE', 'الصندوق / البنك', {}), ('COUNTERPARTY_NAME', 'الطرف', {}),
     ('DESCRIPTION', 'البيان', {}), ('AMOUNT', 'المبلغ', {'type': 'NUMBER'}), ('CURRENCY_CODE', 'العملة', {}),
     ('CREATED_BY', 'أنشأه', {}), ('POSTED_BY', 'اعتمده', {}), ('STATUS_HTML', 'الحالة', {'html': True})], link=VOUCHER_LINK)
p.button(r, 10, 'NEW_RV', 'سند قبض', hot=True, redirect=new_voucher('RECEIPT'), position='RIGHT_OF_IR_SEARCH_BAR')
p.button(r, 20, 'NEW_PV', 'سند صرف', redirect=new_voucher('PAYMENT'), position='RIGHT_OF_IR_SEARCH_BAR')
p.button(r, 30, 'NEW_EV', 'سند مصروفات', redirect=new_voucher('EXPENSE'), position='RIGHT_OF_IR_SEARCH_BAR')

# =============================================================== 42) السند (رأس وتفاصيل)
PLACES = ("select 'صندوق: ' || name_ar d, 'BOX:' || id r from csh_cash_box where company_id = noona_gl_pkg.company "
          "and status_code = 'ACTIVE' union all select 'بنك: ' || name_ar || ' ' || account_no_masked, 'BANK:' || id "
          "from csh_bank_account where company_id = noona_gl_pkg.company and status_code = 'ACTIVE' order by 2 desc, 1")
p = app.page(42, 'Voucher', 'VOUCHER', 'سند', scheme=TENANT)
hd = p.static('السند', 1, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P42_ID', hd, 1)
p.hidden('P42_STATUS', hd, 2)
p.hidden('P42_TYPE', hd, 3)
p.process(10, 'BEFORE_HEADER', 'Load Voucher', [
    'if :P42_ID is not null then',
    '    select status_code, txn_type into :P42_STATUS, :P42_TYPE from csh_transaction',
    '     where id = :P42_ID and company_id = noona_gl_pkg.company;',
    'else',
    "    :P42_TYPE := case when :P42_TYPE in ('RECEIPT', 'PAYMENT', 'EXPENSE') then :P42_TYPE else 'RECEIPT' end;",
    'end if;'])
p.dynamic('ملخص السند', 5, 'return noona_csh_pkg.voucher_header(:P42_ID);', hide_header=True,
          condition=":P42_ID is not null and :P42_STATUS <> 'DRAFT'")
p.dynamic('مستند السند', 10, doc_region('CV', 'noona_csh_pkg.voucher_doc_json(:P42_ID, :P42_TYPE)', 'noona_csh_pkg.accounts_json(:P42_TYPE)',
                                         "case when :P42_ID is null or :P42_STATUS = 'DRAFT' then 'N' else 'Y' end",
                                         extra=[('nnDocPlaces', 'noona_csh_pkg.places_json')]),
          hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.process(1, 'ON_DEMAND', 'SAVE_DOC', doc_ajax('noona_csh_pkg.save_voucher_doc', 42))
ac = p.static('الإجراءات', 30, condition=":P42_ID is not null")
p.textarea('P42_REASON', ac, 10, 'الملاحظة أو السبب (إلزامي للرفض والعكس)', rows=2)
p.date('P42_REV_DATE', ac, 20, 'تاريخ العكس')
b_app = p.button(ac, 10, 'APPROVE', 'اعتماد وترحيل', hot=True, condition=":P42_STATUS = 'SUBMITTED'")
b_rej = p.button(ac, 20, 'REJECT', 'رفض وإعادة للمنشئ', condition=":P42_STATUS = 'SUBMITTED'")
b_rev = p.button(ac, 30, 'REVERSE', 'عكس السند', condition=":P42_STATUS = 'SETTLED'")
b_can = p.button(ac, 40, 'CANCEL_VOUCHER', 'إلغاء المسودة', condition=":P42_STATUS = 'DRAFT'")
p.button(ac, 50, 'PRINT', 'طباعة السند', redirect='f?p=&APP_ID.:43:&SESSION.::&DEBUG.:RP,43:P43_ID:&P42_ID.',
         condition=":P42_STATUS in ('SETTLED', 'REVERSED', 'SUBMITTED')")
p.button(ac, 60, 'BACK', 'رجوع', redirect=url(41))
p.process(40, 'AFTER_SUBMIT', 'Approve', 'noona_csh_pkg.approve_voucher(:P42_ID, :P42_REASON);', when_button=b_app,
          success='تم اعتماد السند وترحيل قيده')
p.process(50, 'AFTER_SUBMIT', 'Reject', 'noona_csh_pkg.reject_voucher(:P42_ID, :P42_REASON);', when_button=b_rej,
          success='تم رفض السند وإعادته للمنشئ')
p.process(60, 'AFTER_SUBMIT', 'Reverse', [
    'declare l_id number;',
    'begin',
    "    l_id := noona_csh_pkg.reverse_voucher(:P42_ID, nvl(to_date(:P42_REV_DATE, 'YYYY-MM-DD'), trunc(sysdate)), :P42_REASON);",
    'end;'], when_button=b_rev, success='تم عكس السند بقيد مقابل مرحل')
p.process(70, 'AFTER_SUBMIT', 'Cancel', 'noona_csh_pkg.cancel_voucher(:P42_ID, :P42_REASON);', when_button=b_can,
          success='تم إلغاء المسودة')
dms_panel(p, 40, 'CSH_TRANSACTION', 'P42_ID', 49)
p.onload(DOC_JS + GRID_JS + VIEWER_JS)
p.branch(10, 'f?p=&APP_ID.:42:&SESSION.::&DEBUG.:42:P42_ID:&P42_ID.&success_msg=#SUCCESS_MSG#')

# =============================================================== 43) طباعة السند
p = app.page(43, 'Voucher Print', 'VOUCHER-PRINT', 'طباعة السند', scheme=TENANT)
f = p.static('السند', 5)
p.hidden('P43_ID', f, 1)
p.button(f, 10, 'PRINT', 'طباعة', hot=True, redirect='javascript:window.print();')
p.button(f, 20, 'BACK', 'رجوع للسند', redirect='f?p=&APP_ID.:42:&SESSION.::&DEBUG.:RP,42:P42_ID:&P43_ID.')
p.dynamic('السند', 10, 'return noona_csh_pkg.voucher_print(:P43_ID);', hide_header=True,
          opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

# =============================================================== 44) دفتر الصندوق / البنك
p = app.page(44, 'Cash Book', 'CASH-BOOK', 'دفتر الصندوق والبنك', scheme=TENANT)
f = p.static('معايير التقرير', 10)
p.select('P44_PLACE', f, 10, 'الصندوق / الحساب', lov_sql=PLACES_ALL)
p.date('P44_FROM', f, 20, 'من تاريخ')
p.date('P44_TO', f, 30, 'إلى تاريخ')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'BEFORE_HEADER', 'Defaults', [
    ":P44_FROM := nvl(:P44_FROM, to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD'));",
    ":P44_TO := nvl(:P44_TO, to_char(sysdate, 'YYYY-MM-DD'));"])
p.dynamic('الدفتر', 20, [
    'return noona_csh_pkg.cash_book(',
    "    case when :P44_PLACE like 'BOX:%' then to_number(substr(:P44_PLACE, 5)) end,",
    "    case when :P44_PLACE like 'BANK:%' then to_number(substr(:P44_PLACE, 6)) end,",
    "    to_date(:P44_FROM, 'YYYY-MM-DD'), to_date(:P44_TO, 'YYYY-MM-DD'));"],
    hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

# =============================================================== 32) قائمة الدخل  33) الميزانية  34) التحليل
p = app.page(32, 'Income Statement', 'INCOME-STATEMENT', 'قائمة الدخل', scheme=TENANT)
f = p.static('معايير التقرير', 10)
p.date('P32_FROM', f, 10, 'من تاريخ')
p.date('P32_TO', f, 20, 'إلى تاريخ')
p.select('P32_CC', f, 30, 'مركز التكلفة', lov_sql=CC_LOV, null_text='كل المراكز')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'BEFORE_HEADER', 'Defaults', [
    ":P32_FROM := nvl(:P32_FROM, to_char(trunc(sysdate, 'YYYY'), 'YYYY-MM-DD'));",
    ":P32_TO := nvl(:P32_TO, to_char(sysdate, 'YYYY-MM-DD'));"])
p.dynamic('قائمة الدخل', 20, [
    "return noona_gl_pkg.income_statement(to_date(:P32_FROM, 'YYYY-MM-DD'), to_date(:P32_TO, 'YYYY-MM-DD'), :P32_CC);"],
    hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

p = app.page(33, 'Balance Sheet', 'BALANCE-SHEET', 'الميزانية العمومية', scheme=TENANT)
f = p.static('معايير التقرير', 10)
p.date('P33_ASOF', f, 10, 'كما في تاريخ')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'BEFORE_HEADER', 'Defaults', [":P33_ASOF := nvl(:P33_ASOF, to_char(sysdate, 'YYYY-MM-DD'));"])
p.dynamic('الميزانية العمومية', 20, ["return noona_gl_pkg.balance_sheet(to_date(:P33_ASOF, 'YYYY-MM-DD'));"],
          hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

p = app.page(34, 'Analysis', 'ANALYSIS', 'تحليل الإيرادات والمصروفات', scheme=TENANT)
f = p.static('معايير التحليل', 10)
p.select('P34_TYPE', f, 10, 'التحليل', null_text=None, lov_sql='STATIC2:المصروفات;EXPENSE,الإيرادات;REVENUE')
p.select('P34_BY', f, 20, 'حسب', null_text=None, lov_sql='STATIC2:الأشهر;MONTH,مراكز التكلفة;CC')
p.date('P34_FROM', f, 30, 'من تاريخ')
p.date('P34_TO', f, 40, 'إلى تاريخ')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'BEFORE_HEADER', 'Defaults', [
    ":P34_FROM := nvl(:P34_FROM, to_char(trunc(sysdate, 'YYYY'), 'YYYY-MM-DD'));",
    ":P34_TO := nvl(:P34_TO, to_char(sysdate, 'YYYY-MM-DD'));"])
p.dynamic('التحليل', 20, [
    "return noona_gl_pkg.analysis(to_date(:P34_FROM, 'YYYY-MM-DD'), to_date(:P34_TO, 'YYYY-MM-DD'),",
    "                             nvl(:P34_TYPE, 'EXPENSE'), nvl(:P34_BY, 'MONTH'));"],
    hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

# =============================================================== تقارير الأستاذ والقوائم والرقابة (روابط التفصيل)
JV_LINK = "'f?p=' || :APP_ID || ':22:' || :APP_SESSION || '::NO:RP:P22_ID:#ID#'"
ACC_CODES = ("select a.account_code || ' - ' || a.name_ar d, a.account_code r from gl_account a "
             "where a.coa_id = noona_gl_pkg.primary_coa order by a.account_code")


YEAR_START = ":{0} := nvl(:{0}, to_char(trunc(sysdate, 'YYYY'), 'YYYY-MM-DD'));"
TODAY = ":{0} := nvl(:{0}, to_char(sysdate, 'YYYY-MM-DD'));"

# 22) عرض القيد ومستند المصدر (نهاية مسار التفصيل)
p = app.page(22, 'Journal View', 'JOURNAL-VIEW', 'عرض القيد', scheme=TENANT, protection='N')
f = p.static('القيد', 5)
p.hidden('P22_ID', f, 1, protected=False)
p.button(f, 10, 'PRINT', 'طباعة', hot=True, redirect='javascript:window.print();')
p.button(f, 20, 'BACK', 'رجوع', redirect='javascript:history.back();')
p.button(f, 30, 'OPEN', 'فتح القيد للإجراءات', redirect='f?p=&APP_ID.:21:&SESSION.::&DEBUG.:RP,21:P21_ID:&P22_ID.')
p.onload(VIEWER_JS)
p.dynamic('القيد ومستند المصدر', 10, f'return noona_fin_rpt_pkg.journal_view(:P22_ID, {dl_link(49)});', hide_header=True,
          opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

# 35) دفتر الأستاذ
p = app.page(35, 'General Ledger', 'GENERAL-LEDGER', 'دفتر الأستاذ', scheme=TENANT)
f = p.static('معايير التقرير', 10)
p.date('P35_FROM', f, 10, 'من تاريخ')
p.date('P35_TO', f, 20, 'إلى تاريخ')
p.select('P35_ACC_FROM', f, 30, 'من حساب', lov_sql=ACC_CODES, null_text='الأول')
p.select('P35_ACC_TO', f, 40, 'إلى حساب', lov_sql=ACC_CODES, null_text='الأخير')
p.select('P35_CC', f, 50, 'مركز التكلفة', lov_sql=CC_LOV, null_text='كل المراكز')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'BEFORE_HEADER', 'Defaults', [YEAR_START.format('P35_FROM'), TODAY.format('P35_TO')])
p.dynamic('دفتر الأستاذ', 20, [
    "return noona_fin_rpt_pkg.general_ledger(to_date(:P35_FROM, 'YYYY-MM-DD'), to_date(:P35_TO, 'YYYY-MM-DD'),",
    f"    :P35_ACC_FROM, :P35_ACC_TO, :P35_CC, {JV_LINK});"], hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

# 36) يومية القيود
p = app.page(36, 'Journal Register', 'JOURNAL-REGISTER', 'يومية القيود', scheme=TENANT, protection='N')
f = p.static('معايير التقرير', 10)
p.date('P36_FROM', f, 10, 'من تاريخ')
p.date('P36_TO', f, 20, 'إلى تاريخ')
p.select('P36_STATUS', f, 30, 'القيود', null_text=None,
         lov_sql='STATIC2:المرحلة;POSTED,غير المرحلة (مسودة ومرسلة ومعتمدة);UNPOSTED,المعكوسة وقيود عكسها;REVERSED,الكل عدا الملغاة;ALL')
p.select('P36_TYPE', f, 40, 'نوع القيد', null_text='- كل الأنواع -', lov_sql=JTYPE_LOV)
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'BEFORE_HEADER', 'Defaults', [
    ":P36_FROM := nvl(:P36_FROM, to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD'));", TODAY.format('P36_TO')])
p.dynamic('يومية القيود', 20, [
    "return noona_fin_rpt_pkg.journal_register(to_date(:P36_FROM, 'YYYY-MM-DD'), to_date(:P36_TO, 'YYYY-MM-DD'),",
    f"    nvl(:P36_STATUS, 'POSTED'), {JV_LINK}, :P36_TYPE);"], hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

# 50) القيود حسب النوع (التفصيل يفتح يومية القيود مفلترة بالنوع)
p = app.page(50, 'Journals by Type', 'JOURNALS-BY-TYPE', 'القيود حسب النوع', scheme=TENANT)
f = p.static('معايير التقرير', 10)
p.date('P50_FROM', f, 10, 'من تاريخ')
p.date('P50_TO', f, 20, 'إلى تاريخ')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'BEFORE_HEADER', 'Defaults', [YEAR_START.format('P50_FROM'), TODAY.format('P50_TO')])
p.dynamic('القيود حسب النوع', 20, [
    "return noona_fin_rpt_pkg.journal_type_summary(to_date(:P50_FROM, 'YYYY-MM-DD'), to_date(:P50_TO, 'YYYY-MM-DD'),",
    "    'f?p=' || :APP_ID || ':36:' || :APP_SESSION || '::NO:36:P36_FROM,P36_TO,P36_STATUS,P36_TYPE:' || :P50_FROM || ','",
    "    || :P50_TO || ',POSTED,#ID#');"], hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

# 14) أنواع القيود
p = app.page(14, 'Journal Types', 'JOURNAL-TYPES', 'أنواع القيود', scheme=TENANT)
p.ir('أنواع القيود', 10, [
    "select t.code, t.name_ar, case t.type_group when 'MANUAL' then 'يدوي' else 'آلي من مستند' end as grp,",
    "       case when t.tenant_id is null then 'النظام' else 'المؤسسة' end as owner,",
    "       noona_ui_pkg.code_label(t.allow_manual) as manual, noona_ui_pkg.code_label(t.is_opening) as opening,",
    "       noona_ui_pkg.code_label(t.is_adjustment) as adjustment, noona_ui_pkg.code_label(t.auto_reverse) as auto_reverse,",
    "       noona_ui_pkg.code_label(t.requires_reference) as req_ref, noona_ui_pkg.code_label(t.is_active) as active, t.description,",
    "       (select count(*) from gl_journal j where j.company_id = noona_gl_pkg.company and j.journal_category = t.code) as journals",
    '  from gl_journal_type t',
    " order by case t.type_group when 'MANUAL' then 1 else 2 end, t.sort_order, t.code"],
    [('CODE', 'الرمز', {}), ('NAME_AR', 'النوع', {}), ('GRP', 'المجموعة', {}), ('OWNER', 'المصدر', {}), ('MANUAL', 'إدخال يدوي', {}),
     ('OPENING', 'افتتاحي', {}), ('ADJUSTMENT', 'تسوية', {}), ('AUTO_REVERSE', 'عكس آلي', {}), ('REQ_REF', 'مرجع إلزامي', {}),
     ('ACTIVE', 'نشط', {}), ('DESCRIPTION', 'الوصف', {}), ('JOURNALS', 'عدد القيود', {'type': 'NUMBER'})])
f = p.static('نوع يدوي خاص بالمؤسسة', 20, text=(
    '<p class="nn-hint">أنواع النظام ثابتة. أضف نوعاً يدوياً خاصاً بمؤسستك (مثل استحقاق المكافآت) برمز إنجليزي؛ '
    'تعديل نوع موجود بنفس الرمز يحدّثه.</p>'))
p.text('P14_CODE', f, 10, 'الرمز (إنجليزي)', maxlen=30, width=20)
p.text('P14_NAME', f, 20, 'الاسم')
p.select('P14_ADJ', f, 30, 'قيد تسوية', null_text=None, lov_sql='STATIC2:لا;N,نعم;Y')
p.select('P14_REV', f, 40, 'يعكس آلياً في الفترة التالية', null_text=None, lov_sql='STATIC2:لا;N,نعم;Y')
p.select('P14_REF', f, 50, 'يتطلب مرجعاً', null_text=None, lov_sql='STATIC2:لا;N,نعم;Y')
p.select('P14_ACTIVE', f, 60, 'الحالة', null_text=None, lov_sql='STATIC2:نشط;Y,موقوف;N')
p.text('P14_DESC', f, 70, 'الوصف ومتى يستخدم', maxlen=1000)
b1 = p.button(f, 10, 'SAVE_TYPE', 'حفظ النوع', hot=True)
fr = p.static('العكس الآلي للاستحقاقات', 30, text=(
    '<p class="nn-hint">قيود الاستحقاق وإعادة التقييم المرحلة تحمل تاريخ عكس آلي (أول يوم في الفترة التالية). '
    'نفذ العكس بعد فتح الفترة الجديدة؛ القيود التي حل تاريخ عكسها فقط تعكس.</p>'))
b2 = p.button(fr, 10, 'AUTO_REVERSE', 'عكس القيود المستحقة الآن')
p.process(10, 'AFTER_SUBMIT', 'Save Type',
          'noona_gl_pkg.save_journal_type(:P14_CODE, :P14_NAME, null, :P14_ADJ, :P14_REV, :P14_REF, :P14_ACTIVE, :P14_DESC);',
          when_button=b1, success='تم حفظ نوع القيد')
p.process(20, 'AFTER_SUBMIT', 'Auto Reverse', [
    'declare l_n number;', 'begin', '    l_n := noona_gl_pkg.process_auto_reversals;',
    "    apex_application.g_print_success_message := case when l_n > 0 then 'تم عكس ' || l_n || ' قيد' else 'لا توجد قيود حل تاريخ عكسها' end;",
    'end;'], when_button=b2)
p.branch(10, url(14, clear='14') + '&success_msg=#SUCCESS_MSG#')

# 37) التدفقات النقدية  38) التغيرات في حقوق الملكية  45) النسب المالية
for pid, alias, title, fn in [(37, 'CASH-FLOW', 'قائمة التدفقات النقدية', 'cash_flow'),
                              (38, 'EQUITY-CHANGES', 'التغيرات في حقوق الملكية', 'equity_changes'),
                              (45, 'RATIOS', 'النسب المالية', 'ratios')]:
    p = app.page(pid, title, alias, title, scheme=TENANT)
    f = p.static('معايير التقرير', 10)
    p.date(f'P{pid}_FROM', f, 10, 'من تاريخ')
    p.date(f'P{pid}_TO', f, 20, 'إلى تاريخ')
    p.button(f, 10, 'RUN', 'عرض', hot=True)
    p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
    p.process(10, 'BEFORE_HEADER', 'Defaults', [YEAR_START.format(f'P{pid}_FROM'), TODAY.format(f'P{pid}_TO')])
    p.dynamic(title, 20, [f"return noona_fin_rpt_pkg.{fn}(to_date(:P{pid}_FROM, 'YYYY-MM-DD'), to_date(:P{pid}_TO, 'YYYY-MM-DD'));"],
              hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

# 39) قائمة الدخل المقارنة
p = app.page(39, 'Income Comparison', 'INCOME-COMPARE', 'مقارنة الفترات', scheme=TENANT)
f = p.static('الفترتان', 10)
p.date('P39_FROM', f, 10, 'الفترة الحالية من')
p.date('P39_TO', f, 20, 'الفترة الحالية إلى')
p.date('P39_FROM2', f, 30, 'فترة المقارنة من')
p.date('P39_TO2', f, 40, 'فترة المقارنة إلى')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'BEFORE_HEADER', 'Defaults', [
    YEAR_START.format('P39_FROM'), TODAY.format('P39_TO'),
    ":P39_FROM2 := nvl(:P39_FROM2, to_char(add_months(trunc(sysdate, 'YYYY'), -12), 'YYYY-MM-DD'));",
    ":P39_TO2 := nvl(:P39_TO2, to_char(add_months(sysdate, -12), 'YYYY-MM-DD'));"])
p.dynamic('مقارنة الفترات', 20, [
    "return noona_fin_rpt_pkg.income_compare(to_date(:P39_FROM, 'YYYY-MM-DD'), to_date(:P39_TO, 'YYYY-MM-DD'),",
    "    to_date(:P39_FROM2, 'YYYY-MM-DD'), to_date(:P39_TO2, 'YYYY-MM-DD'));"],
    hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

# 46) الرقابة والتسويات
p = app.page(46, 'Controls', 'CONTROLS', 'الرقابة والتسويات', scheme=TENANT)
f = p.static('معايير التقرير', 10)
p.date('P46_ASOF', f, 10, 'كما في تاريخ')
p.button(f, 10, 'RUN', 'تشغيل الفحوص', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'BEFORE_HEADER', 'Defaults', [TODAY.format('P46_ASOF')])
p.dynamic('الرقابة والتسويات', 20, ["return noona_fin_rpt_pkg.controls(to_date(:P46_ASOF, 'YYYY-MM-DD'));"],
          hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

# 47) سجل التدقيق المالي
p = app.page(47, 'Financial Audit', 'FIN-AUDIT', 'سجل التدقيق المالي', scheme=TENANT)
f = p.static('معايير التقرير', 10)
p.date('P47_FROM', f, 10, 'من تاريخ')
p.date('P47_TO', f, 20, 'إلى تاريخ')
p.select('P47_SCOPE', f, 30, 'النطاق', null_text=None,
         lov_sql='STATIC2:الكل;ALL,القيود;GL_JOURNAL,السندات;CSH_TRANSACTION,تغييرات الإعدادات المحاسبية;CONFIG')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'BEFORE_HEADER', 'Defaults', [":P47_FROM := nvl(:P47_FROM, to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD'));",
                                            TODAY.format('P47_TO')])
p.dynamic('سجل التدقيق', 20, [
    "return noona_fin_rpt_pkg.audit_log(to_date(:P47_FROM, 'YYYY-MM-DD'), to_date(:P47_TO, 'YYYY-MM-DD'), nvl(:P47_SCOPE, 'ALL'));"],
    hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

# 13) إقفال السنة المالية
p = app.page(13, 'Year End', 'YEAR-END', 'إقفال السنة المالية', scheme=TENANT)
p.ir('السنوات المالية', 10, [
    "select y.id, y.code, y.name_ar, to_char(y.start_date, 'YYYY-MM-DD') as start_date, to_char(y.end_date, 'YYYY-MM-DD') as end_date,",
    '       noona_ui_pkg.status_badge(y.status_code) as status_html,',
    "       (select max(j.doc_no) from gl_journal j where j.ledger_id = noona_gl_pkg.primary_ledger and j.journal_category = 'CLOSING'",
    "           and j.status_code = 'POSTED' and j.reversal_of_id is null and j.doc_date = y.end_date) as closing_jv",
    '  from gl_fiscal_year y where y.company_id = noona_gl_pkg.company order by y.start_date'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'السنة', {}), ('START_DATE', 'من', {}),
     ('END_DATE', 'إلى', {}), ('STATUS_HTML', 'الحالة', {'html': True}), ('CLOSING_JV', 'قيد الإقفال', {})])
f = p.static('الإقفال', 20, text=(
    '<p class="nn-hint">الإقفال ينشئ قيداً آلياً بتاريخ نهاية السنة يصفّر الإيرادات والمصروفات (لكل مركز تكلفة) ويرحل صافي الربح '
    'أو الخسارة إلى حساب الأرباح المبقاة، ثم يقفل كل فترات السنة. يشترط ألا توجد قيود أو سندات غير مرحلة في السنة، '
    'وأن تقفل السنوات السابقة أولاً. إعادة الفتح لمسؤول المؤسسة فقط وتعكس قيد الإقفال.</p>'))
YEARS = ("select name_ar || ' (' || to_char(start_date, 'YYYY-MM-DD') || ' - ' || to_char(end_date, 'YYYY-MM-DD') || ')' d, id r "
         "from gl_fiscal_year where company_id = noona_gl_pkg.company order by start_date")
p.select('P13_YEAR', f, 10, 'السنة المالية', lov_sql=YEARS, required=True)
p.textarea('P13_REASON', f, 20, 'سبب إعادة الفتح', rows=2)
b1 = p.button(f, 10, 'CLOSE_YEAR', 'إقفال السنة', hot=True)
b2 = p.button(f, 20, 'REOPEN_YEAR', 'إعادة فتح السنة')
p.process(10, 'AFTER_SUBMIT', 'Close Year', [
    'declare l_id number;',
    'begin',
    '    l_id := noona_gl_pkg.close_year(:P13_YEAR);',
    'end;'], when_button=b1, success='تم إقفال السنة وترحيل النتيجة إلى الأرباح المبقاة')
p.process(20, 'AFTER_SUBMIT', 'Reopen Year', 'noona_gl_pkg.reopen_year(:P13_YEAR, :P13_REASON);', when_button=b2,
          success='تمت إعادة فتح السنة وعكس قيد الإقفال')
p.branch(10, url(13, clear='13') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 48) أسعار الصرف (لكل شركة)
p = app.page(48, 'Exchange Rates', 'EXCHANGE-RATES', 'أسعار الصرف', scheme=TENANT)
p.ir('أسعار صرف الشركة', 10, [
    "select r.id, r.from_currency || ' - ' || c.name_ar as cur, r.to_currency, t.name_ar as rate_type,",
    "       to_char(r.rate_date, 'YYYY-MM-DD') as rate_date, r.rate, round(1 / r.rate, 6) as inverse_rate,",
    "       noona_ui_pkg.status_badge(r.status_code) as status_html, r.reason, r.created_by, r.approved_by",
    '  from ref_exchange_rate r join ref_rate_type t on t.id = r.rate_type_id left join ref_currency c on c.currency_code = r.from_currency',
    " where r.company_id = noona_gl_pkg.company order by r.rate_date desc, r.from_currency"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CUR', 'العملة', {}), ('TO_CURRENCY', 'مقابل', {}), ('RATE_TYPE', 'نوع السعر', {}),
     ('RATE_DATE', 'ساري من', {}), ('RATE', 'السعر', {'type': 'NUMBER'}), ('INVERSE_RATE', 'العكسي', {'type': 'NUMBER'}),
     ('STATUS_HTML', 'الحالة', {'html': True}), ('REASON', 'المصدر / الملاحظة', {}), ('CREATED_BY', 'أدخله', {}),
     ('APPROVED_BY', 'اعتمده', {})])
f = p.static('سعر جديد', 20, text='<p class="nn-hint">أسعار الصرف خاصة بالشركة الحالية ولا تظهر ولا تستخدم في غيرها. '
                                   'السعر = عدد وحدات العملة الوظيفية لوحدة واحدة من العملة الأجنبية، ويسري من تاريخه '
                                   'حتى يضاف سعر أحدث. السعر المحاسبي يستخدم آلياً في القيود والسندات بالعملات الأجنبية.</p>')
p.select('P48_TYPE', f, 5, 'نوع السعر', null_text=None, lov_sql=(
    "select name_ar d, id r from ref_rate_type where is_active = 'Y' "
    "order by case code when 'ACCOUNTING' then 0 else 1 end, name_ar"))
p.select('P48_CUR', f, 10, 'العملة', lov_sql=(
    "select currency_code || ' - ' || name_ar d, currency_code r from ref_currency where is_active = 'Y' "
    "and currency_code <> noona_gl_pkg.ledger_currency order by currency_code"))
p.date('P48_DATE', f, 20, 'ساري من تاريخ')
p.number('P48_RATE', f, 30, 'السعر')
p.text('P48_REASON', f, 40, 'المصدر (مثل: البنك المركزي)')
b1 = p.button(f, 10, 'ADD_RATE', 'إضافة السعر', hot=True)
b2 = p.button(f, 20, 'SEED_RATES', 'إضافة أسعار الربط الافتراضية')
p.process(5, 'BEFORE_HEADER', 'Defaults', [
    'begin',
    '    if :P48_TYPE is null then :P48_TYPE := noona_gl_pkg.rate_type; end if;',
    'end;'])
p.process(10, 'AFTER_SUBMIT', 'Add Rate', [
    'declare l_id number; l_status varchar2(30);',
    'begin',
    "    l_id := noona_refdata_pkg.add_rate(nvl(:P48_TYPE, noona_gl_pkg.rate_type), :P48_CUR, noona_gl_pkg.ledger_currency,",
    "                                       to_date(:P48_DATE, 'YYYY-MM-DD'), :P48_RATE, :P48_REASON);",
    '    select status_code into l_status from ref_exchange_rate where id = l_id;',
    "    apex_application.g_print_success_message := case l_status",
    "        when 'DRAFT' then 'تم حفظ السعر بانتظار اعتماد مستخدم آخر' else 'تمت إضافة السعر' end;",
    'end;'], when_button=b1)
p.process(20, 'AFTER_SUBMIT', 'Seed Rates', [
    'declare l_n number;',
    'begin',
    '    l_n := noona_gl_pkg.seed_rates;',
    "    apex_application.g_print_success_message := case when l_n > 0 then 'أضيف ' || l_n || ' سعر ربط رسمي (راجعها)'",
    "                                                     else 'لا توجد أسعار ناقصة (أو العملة الوظيفية ليست الريال)' end;",
    'end;'], when_button=b2)
ap = p.static('اعتماد الأسعار المعلقة (لا يعتمد المدخل سعره)', 30)
p.select('P48_PENDING', ap, 10, 'سعر معلق', lov_sql=(
    "select to_char(r.rate_date, 'YYYY-MM-DD') || ' · ' || r.from_currency || '/' || r.to_currency || ' = ' || r.rate "
    "|| ' · ' || r.created_by d, r.id r from ref_exchange_rate r "
    "where r.status_code = 'DRAFT' and r.company_id = noona_gl_pkg.company order by r.rate_date desc"))
p.text('P48_REJECT_REASON', ap, 20, 'سبب الرفض')
b_ap = p.button(ap, 10, 'APPROVE_RATE', 'اعتماد', hot=True)
b_rj = p.button(ap, 20, 'REJECT_RATE', 'رفض')
p.process(30, 'AFTER_SUBMIT', 'Approve Rate', 'noona_refdata_pkg.approve_rate(:P48_PENDING);', when_button=b_ap,
          success='تم اعتماد السعر')
p.process(40, 'AFTER_SUBMIT', 'Reject Rate', 'noona_refdata_pkg.reject_rate(:P48_PENDING, :P48_REJECT_REASON);',
          when_button=b_rj, success='تم رفض السعر')
p.branch(10, url(48, clear='48') + '&success_msg=#SUCCESS_MSG#')

download_page(app, 49, TENANT)

app.nav_item('لوحة المالية', 1, 'fa-calculator', 10)
gl = app.nav_item('الأستاذ العام', None, 'fa-book', 20)
app.nav_item('القيود اليومية', 20, 'fa-list-alt', 21, parent=gl)
app.nav_item('قيد جديد', 21, 'fa-plus', 22, parent=gl)
app.nav_item('دليل الحسابات', 10, 'fa-sitemap', 23, parent=gl)
app.nav_item('مراكز التكلفة', 12, 'fa-crosshairs', 24, parent=gl)
app.nav_item('الفترات المحاسبية', 11, 'fa-calendar', 25, parent=gl)
app.nav_item('أنواع القيود', 14, 'fa-tags', 28, parent=gl)
app.nav_item('إقفال السنة المالية', 13, 'fa-lock', 26, parent=gl)
app.nav_item('أسعار الصرف', 48, 'fa-exchange', 27, parent=gl)
cs = app.nav_item('النقدية والبنوك', None, 'fa-money', 30)
app.nav_item('السندات', 41, 'fa-files-o', 31, parent=cs)
app.nav_item('سند قبض جديد', new_voucher('RECEIPT'), 'fa-arrow-down', 32, parent=cs)
app.nav_item('سند صرف جديد', new_voucher('PAYMENT'), 'fa-arrow-up', 33, parent=cs)
app.nav_item('سند مصروفات جديد', new_voucher('EXPENSE'), 'fa-shopping-cart', 34, parent=cs)
app.nav_item('الصناديق والبنوك', 40, 'fa-university', 35, parent=cs)
app.nav_item('دفتر الصندوق والبنك', 44, 'fa-book', 36, parent=cs)
fs = app.nav_item('القوائم المالية', None, 'fa-file-text', 40)
app.nav_item('قائمة المركز المالي', 33, 'fa-columns', 41, parent=fs)
app.nav_item('قائمة الربح أو الخسارة', 32, 'fa-line-chart', 42, parent=fs)
app.nav_item('التدفقات النقدية', 37, 'fa-exchange', 43, parent=fs)
app.nav_item('التغيرات في حقوق الملكية', 38, 'fa-users', 44, parent=fs)
lr = app.nav_item('تقارير الأستاذ', None, 'fa-book', 50)
app.nav_item('ميزان المراجعة', 30, 'fa-balance-scale', 51, parent=lr)
app.nav_item('دفتر الأستاذ', 35, 'fa-bookmark', 52, parent=lr)
app.nav_item('كشف حساب', 31, 'fa-file-text-o', 53, parent=lr)
app.nav_item('يومية القيود', 36, 'fa-list', 54, parent=lr)
app.nav_item('القيود حسب النوع', 50, 'fa-tags', 55, parent=lr)
an = app.nav_item('التحليل المالي', None, 'fa-bar-chart', 60)
app.nav_item('تحليل الإيرادات والمصروفات', 34, 'fa-pie-chart', 61, parent=an)
app.nav_item('مقارنة الفترات', 39, 'fa-sliders', 62, parent=an)
app.nav_item('النسب المالية', 45, 'fa-percent', 63, parent=an)
ct = app.nav_item('الرقابة والتدقيق', None, 'fa-shield', 70)
app.nav_item('الرقابة والتسويات', 46, 'fa-check-square-o', 71, parent=ct)
app.nav_item('سجل التدقيق المالي', 47, 'fa-history', 72, parent=ct)

app.finalize()
print('NOONA_FIN built:', len(app.pages), 'pages')
