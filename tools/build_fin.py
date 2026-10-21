"""NOONA_FIN (المالية): الأستاذ العام، مراكز التكلفة، النقدية والبنوك (سندات القبض والصرف والمصروفات)، القوائم المالية والتحليلات
الاستخدام: python3 tools/build_fin.py   ->  apex/NOONA_FIN/f127
القيود والسندات: شبكة إدخال رأس/تفاصيل (tools/fin_grid.py) تحفظ السطور JSON في عنصر مخفي؛
التحقق والترحيل في NOONA_GL_PKG و NOONA_CSH_PKG (عبر المحرك المحاسبي NOONA_ACE_PKG).
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App
from fin_grid import GRID_JS, grid_region

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
    "select j.id, j.doc_no, to_char(j.doc_date, 'YYYY-MM-DD') as doc_date, j.description, j.reference_no,",
    '       j.total_debit_func as amount, j.currency_code, j.created_by, j.approved_by,',
    '       noona_ui_pkg.status_badge(j.status_code) as status_html',
    '  from gl_journal j where j.company_id = noona_gl_pkg.company']
JOURNALS_COLS = [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'رقم القيد', {}), ('DOC_DATE', 'التاريخ', {}),
                 ('DESCRIPTION', 'البيان', {}), ('REFERENCE_NO', 'المرجع', {}), ('AMOUNT', 'المبلغ', {'type': 'NUMBER'}),
                 ('CURRENCY_CODE', 'العملة', {}), ('CREATED_BY', 'أنشأه', {}), ('APPROVED_BY', 'اعتمده', {}),
                 ('STATUS_HTML', 'الحالة', {'html': True})]
CC_LOV = ("select code || ' - ' || name_ar d, id r from gl_cost_center "
          "where company_id = noona_gl_pkg.company order by code")
JOURNAL_LINK = 'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:RP,21:P21_ID:#ID#'

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
hdr = p.static('بيانات القيد', 10, condition=":P21_ID is null or :P21_STATUS = 'DRAFT'")
p.hidden('P21_ID', hdr, 1)
p.hidden('P21_STATUS', hdr, 2)
p.hidden('P21_LINES', hdr, 3, protected=False)
p.date('P21_DATE', hdr, 10, 'تاريخ القيد', required=True)
p.text('P21_REF', hdr, 20, 'المرجع (اختياري)', maxlen=100)
p.textarea('P21_DESC', hdr, 30, 'البيان', required=True, rows=2)
p.select('P21_CURRENCY', hdr, 40, 'العملة', lov_name='NOONA_CURRENCIES', null_text='عملة الشركة')
p.number('P21_RATE', hdr, 50, 'سعر الصرف (للعملة الأجنبية)')
b_create = p.button(hdr, 10, 'CREATE', 'إنشاء القيد', hot=True, condition=':P21_ID is null')
p.process(10, 'BEFORE_HEADER', 'Load Journal', [
    'if :P21_ID is not null then',
    "    select status_code, to_char(doc_date, 'YYYY-MM-DD'), description, reference_no, currency_code, exchange_rate",
    '      into :P21_STATUS, :P21_DATE, :P21_DESC, :P21_REF, :P21_CURRENCY, :P21_RATE from gl_journal where id = :P21_ID;',
    'else',
    "    :P21_DATE := nvl(:P21_DATE, to_char(sysdate, 'YYYY-MM-DD'));",
    'end if;'])
p.process(10, 'AFTER_SUBMIT', 'Create Journal', [
    ":P21_ID := noona_gl_pkg.create_journal(to_date(:P21_DATE, 'YYYY-MM-DD'), :P21_DESC, :P21_CURRENCY, :P21_RATE, :P21_REF);"],
    when_button=b_create, success='تم إنشاء القيد؛ أدخل السطور ثم احفظ')
p.dynamic('ملخص القيد', 5, 'return noona_gl_pkg.journal_header(:P21_ID);', hide_header=True, condition=':P21_ID is not null')
ln = p.dynamic('سطور القيد', 20, grid_region('noona_gl_pkg.lines_json(:P21_ID)', 'noona_gl_pkg.accounts_json',
                                            "case when :P21_STATUS = 'DRAFT' then 'N' else 'Y' end", 'JE', 'P21_LINES'),
               condition=':P21_ID is not null')
b_save = p.button(ln, 10, 'SAVE', 'حفظ', condition=":P21_STATUS = 'DRAFT'")
b_submit = p.button(ln, 20, 'SUBMIT', 'حفظ وإرسال للاعتماد', hot=True, condition=":P21_STATUS = 'DRAFT'")
for seq, btn, code, msg in [
        (20, b_save, ['noona_gl_pkg.update_header(:P21_ID, to_date(:P21_DATE, \'YYYY-MM-DD\'), :P21_DESC, :P21_REF);',
                      'noona_gl_pkg.save_lines(:P21_ID, :P21_LINES);'], 'تم حفظ القيد'),
        (30, b_submit, ['noona_gl_pkg.update_header(:P21_ID, to_date(:P21_DATE, \'YYYY-MM-DD\'), :P21_DESC, :P21_REF);',
                        'noona_gl_pkg.save_lines(:P21_ID, :P21_LINES);', 'noona_gl_pkg.submit_journal(:P21_ID);'],
         'تم إرسال القيد للاعتماد')]:
    p.process(seq, 'AFTER_SUBMIT', f'Journal Save {seq}', code, when_button=btn, success=msg)
ac = p.static('الإجراءات', 30, condition=":P21_STATUS in ('DRAFT', 'SUBMITTED', 'POSTED')")
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
p.onload(GRID_JS)
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
p.text('P12_CODE', f, 10, 'الرمز', required=True, maxlen=30, width=15)
p.text('P12_NAME', f, 20, 'الاسم', required=True)
p.select('P12_TYPE', f, 30, 'النوع', null_text=None, lov_sql='STATIC2:تكلفة;COST,ربحية;PROFIT,إيراد;REVENUE,استثمار;INVESTMENT')
p.select('P12_PARENT', f, 40, 'يتبع المركز', lov_sql=("select code || ' - ' || name_ar d, code r from gl_cost_center "
                                                    "where company_id = noona_gl_pkg.company order by code"), null_text='- رئيسي -')
b = p.button(f, 10, 'ADD_CC', 'إضافة المركز', hot=True)
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
b = p.button(f, 10, 'ADD_BOX', 'إضافة الصندوق', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Add Box', [
    'declare l_id number;',
    'begin',
    '    l_id := noona_csh_pkg.create_cash_box(:P40_BOX_CODE, :P40_BOX_NAME, :P40_BOX_ACC, :P40_BOX_TYPE, :P40_BOX_MAX);',
    'end;'], when_button=b, success='تمت إضافة الصندوق')
f2 = p.static('حساب بنكي جديد', 30)
p.text('P40_BANK_CODE', f2, 10, 'الرمز', maxlen=30, width=15)
p.text('P40_BANK_NAME', f2, 20, 'اسم الحساب (مثل: الحساب الجاري)')
p.select('P40_BANK', f2, 30, 'البنك', lov_sql="select name_ar d, id r from ref_bank where is_active = 'Y' order by name_ar")
p.text('P40_ACC_NO', f2, 40, 'رقم الحساب', maxlen=40, width=25)
p.text('P40_IBAN', f2, 50, 'الآيبان', maxlen=40, width=30)
p.select('P40_BANK_ACC', f2, 60, 'حساب النقدية في الدليل', lov_sql=CASH_ACCOUNTS, null_text=None)
p.number('P40_BANK_MAX', f2, 70, 'حد الدفع للسند الواحد (اختياري)')
b2 = p.button(f2, 10, 'ADD_BANK', 'إضافة الحساب البنكي', hot=True)
p.process(20, 'AFTER_SUBMIT', 'Add Bank', [
    'declare l_id number;',
    'begin',
    '    l_id := noona_csh_pkg.create_bank_account(:P40_BANK_CODE, :P40_BANK_NAME, :P40_BANK, :P40_ACC_NO, :P40_IBAN,',
    '                                               :P40_BANK_ACC, :P40_BANK_MAX);',
    'end;'], when_button=b2, success='تمت إضافة الحساب البنكي (يحفظ الرقم مقنعاً)')
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
p.dynamic('ملخص السند', 5, 'return noona_csh_pkg.voucher_header(:P42_ID);', hide_header=True, condition=':P42_ID is not null')
hdr = p.static('بيانات السند', 10, condition=":P42_ID is null or :P42_STATUS = 'DRAFT'")
p.hidden('P42_ID', hdr, 1)
p.hidden('P42_STATUS', hdr, 2)
p.hidden('P42_TYPE', hdr, 3)
p.hidden('P42_LINES', hdr, 4, protected=False)
p.date('P42_DATE', hdr, 10, 'التاريخ', required=True)
p.select('P42_PLACE', hdr, 20, 'الصندوق / الحساب البنكي', lov_sql=PLACES, required=True)
p.select('P42_CHANNEL', hdr, 30, 'طريقة الدفع (للبنك)', null_text=None,
         lov_sql='STATIC2:تحويل بنكي;BANK_TRANSFER,شيك;CHEQUE,بطاقة;CARD,محفظة إلكترونية;WALLET,بوابة دفع;GATEWAY,خصم مباشر;DIRECT_DEBIT')
p.text('P42_PARTY', hdr, 40, 'الطرف (استلمنا من / صرفنا إلى)', maxlen=200)
p.text('P42_REF', hdr, 50, 'المرجع (رقم الشيك أو الحوالة)', maxlen=200)
p.textarea('P42_DESC', hdr, 60, 'البيان (وذلك عن)', required=True, rows=2)
p.number('P42_RATE', hdr, 70, 'سعر الصرف (لحساب بعملة أجنبية)')
p.process(10, 'BEFORE_HEADER', 'Load Voucher', [
    'if :P42_ID is not null then',
    "    select status_code, txn_type, to_char(doc_date, 'YYYY-MM-DD'),",
    "           case when cash_box_id is not null then 'BOX:' || cash_box_id else 'BANK:' || bank_account_id end,",
    '           channel, counterparty_name, external_reference, description, exchange_rate',
    '      into :P42_STATUS, :P42_TYPE, :P42_DATE, :P42_PLACE, :P42_CHANNEL, :P42_PARTY, :P42_REF, :P42_DESC, :P42_RATE',
    '      from csh_transaction where id = :P42_ID and company_id = noona_gl_pkg.company;',
    'else',
    "    :P42_TYPE := case when :P42_TYPE in ('RECEIPT', 'PAYMENT', 'EXPENSE') then :P42_TYPE else 'RECEIPT' end;",
    "    :P42_DATE := nvl(:P42_DATE, to_char(sysdate, 'YYYY-MM-DD'));",
    'end if;'])
ln = p.dynamic('تفاصيل السند', 20, grid_region('noona_csh_pkg.lines_json(:P42_ID)', 'noona_csh_pkg.accounts_json(:P42_TYPE)',
                                              "case when :P42_ID is null or :P42_STATUS = 'DRAFT' then 'N' else 'Y' end",
                                              'CV', 'P42_LINES')
               )
b_save = p.button(ln, 10, 'SAVE', 'حفظ', condition=":P42_ID is null or :P42_STATUS = 'DRAFT'")
b_submit = p.button(ln, 20, 'SUBMIT', 'حفظ وإرسال للاعتماد', hot=True, condition=":P42_ID is null or :P42_STATUS = 'DRAFT'")
SAVE_CODE = [
    ':P42_ID := noona_csh_pkg.save_voucher(',
    "    p_id => :P42_ID, p_type => :P42_TYPE, p_date => to_date(:P42_DATE, 'YYYY-MM-DD'),",
    "    p_box_id => case when :P42_PLACE like 'BOX:%' then to_number(substr(:P42_PLACE, 5)) end,",
    "    p_bank_id => case when :P42_PLACE like 'BANK:%' then to_number(substr(:P42_PLACE, 6)) end,",
    '    p_channel => :P42_CHANNEL, p_party => :P42_PARTY, p_description => :P42_DESC, p_reference => :P42_REF,',
    '    p_lines => :P42_LINES, p_rate => :P42_RATE);']
p.process(20, 'AFTER_SUBMIT', 'Save Voucher', SAVE_CODE, when_button=b_save, success='تم حفظ السند')
p.process(30, 'AFTER_SUBMIT', 'Save Submit Voucher', SAVE_CODE + ['noona_csh_pkg.submit_voucher(:P42_ID);'],
          when_button=b_submit, success='تم إرسال السند للاعتماد')
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
p.onload(GRID_JS)
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
p.dynamic('القيد ومستند المصدر', 10, 'return noona_fin_rpt_pkg.journal_view(:P22_ID);', hide_header=True,
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
p = app.page(36, 'Journal Register', 'JOURNAL-REGISTER', 'يومية القيود', scheme=TENANT)
f = p.static('معايير التقرير', 10)
p.date('P36_FROM', f, 10, 'من تاريخ')
p.date('P36_TO', f, 20, 'إلى تاريخ')
p.select('P36_STATUS', f, 30, 'القيود', null_text=None,
         lov_sql='STATIC2:المرحلة;POSTED,غير المرحلة (مسودة ومرسلة ومعتمدة);UNPOSTED,المعكوسة وقيود عكسها;REVERSED,الكل عدا الملغاة;ALL')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'BEFORE_HEADER', 'Defaults', [
    ":P36_FROM := nvl(:P36_FROM, to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD'));", TODAY.format('P36_TO')])
p.dynamic('يومية القيود', 20, [
    "return noona_fin_rpt_pkg.journal_register(to_date(:P36_FROM, 'YYYY-MM-DD'), to_date(:P36_TO, 'YYYY-MM-DD'),",
    f"    nvl(:P36_STATUS, 'POSTED'), {JV_LINK});"], hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

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

app.nav_item('لوحة المالية', 1, 'fa-calculator', 10)
gl = app.nav_item('الأستاذ العام', None, 'fa-book', 20)
app.nav_item('القيود اليومية', 20, 'fa-list-alt', 21, parent=gl)
app.nav_item('قيد جديد', 21, 'fa-plus', 22, parent=gl)
app.nav_item('دليل الحسابات', 10, 'fa-sitemap', 23, parent=gl)
app.nav_item('مراكز التكلفة', 12, 'fa-crosshairs', 24, parent=gl)
app.nav_item('الفترات المحاسبية', 11, 'fa-calendar', 25, parent=gl)
app.nav_item('إقفال السنة المالية', 13, 'fa-lock', 26, parent=gl)
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
an = app.nav_item('التحليل المالي', None, 'fa-bar-chart', 60)
app.nav_item('تحليل الإيرادات والمصروفات', 34, 'fa-pie-chart', 61, parent=an)
app.nav_item('مقارنة الفترات', 39, 'fa-sliders', 62, parent=an)
app.nav_item('النسب المالية', 45, 'fa-percent', 63, parent=an)
ct = app.nav_item('الرقابة والتدقيق', None, 'fa-shield', 70)
app.nav_item('الرقابة والتسويات', 46, 'fa-check-square-o', 71, parent=ct)
app.nav_item('سجل التدقيق المالي', 47, 'fa-history', 72, parent=ct)

app.finalize()
print('NOONA_FIN built:', len(app.pages), 'pages')
