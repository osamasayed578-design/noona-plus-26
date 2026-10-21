"""NOONA_FIN (المالية) - المرحلة الأولى: الأستاذ العام
الاستخدام: python3 tools/build_fin.py   ->  apex/NOONA_FIN/f127
القيود: شبكة إدخال مخصصة (JavaScript) تحفظ السطور JSON في عنصر مخفي؛ التحقق والترحيل في NOONA_GL_PKG.
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App

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
ln = p.dynamic('سطور القيد', 20, [
    'declare',
    "    l_ro varchar2(1) := case when :P21_STATUS = 'DRAFT' then 'N' else 'Y' end;",
    'begin',
    "    return '<script type=\"application/json\" id=\"nnJeLines\">' || replace(noona_gl_pkg.lines_json(:P21_ID), '</', '<\\/') || '</script>'",
    "        || case when l_ro = 'N' then '<script type=\"application/json\" id=\"nnJeAccts\">'",
    "                || replace(noona_gl_pkg.accounts_json, '</', '<\\/') || '</script>' end",
    "        || '<div id=\"nnJe\" class=\"nn-je\" data-readonly=\"' || l_ro || '\"></div>';",
    'end;'], condition=':P21_ID is not null')
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
p.onload([
    '// شبكة سطور القيد: بحث الحساب بالرمز أو الاسم، مجاميع مباشرة، Enter في آخر سطر يضيف سطراً',
    '(function () {',
    "    var box = document.getElementById('nnJe'); if (!box) return;",
    "    var ro = box.dataset.readonly === 'Y';",
    "    var lines = JSON.parse((document.getElementById('nnJeLines') || {}).textContent || '[]');",
    "    var accts = JSON.parse((document.getElementById('nnJeAccts') || {}).textContent || '[]');",
    '    var names = {}; accts.forEach(function (a) { names[a.a] = a.n; });',
    "    var fmt = function (n) { return (Math.round((n || 0) * 100) / 100).toLocaleString('en-US', {minimumFractionDigits: 2}); };",
    "    var esc = function (s) { return String(s == null ? '' : s).replace(/[&<>\"]/g, function (c) { return {'&':'&amp;','<':'&lt;','>':'&gt;','\"':'&quot;'}[c]; }); };",
    "    var html = '<table class=\"nn-je-table\"><thead><tr><th>#</th><th>الحساب</th><th>مدين</th><th>دائن</th><th>البيان</th>' + (ro ? '' : '<th></th>') + '</tr></thead><tbody></tbody>'",
    "        + '<tfoot><tr><td></td><td>الإجمالي <span class=\"nn-je-diff\"></span></td><td class=\"nn-je-tdr\"></td><td class=\"nn-je-tcr\"></td><td colspan=\"2\"></td></tr></tfoot></table>'",
    "        + (ro ? '' : '<datalist id=\"nnAccts\">' + accts.map(function (a) { return '<option value=\"' + esc(a.a) + '\">' + esc(a.a + ' - ' + a.n) + '</option>'; }).join('') + '</datalist>'",
    "        + '<button type=\"button\" class=\"t-Button t-Button--small nn-je-add\"><span class=\"fa fa-plus\"></span> إضافة سطر</button>');",
    '    box.innerHTML = html;',
    "    var tbody = box.querySelector('tbody');",
    '    function totals() {',
    '        var dr = 0, cr = 0;',
    "        tbody.querySelectorAll('tr').forEach(function (tr) {",
    "            dr += parseFloat(tr.dataset.d || (tr.querySelector('.nn-je-dr') || {}).value || 0) || 0;",
    "            cr += parseFloat(tr.dataset.c || (tr.querySelector('.nn-je-cr') || {}).value || 0) || 0;",
    '        });',
    "        box.querySelector('.nn-je-tdr').textContent = fmt(dr); box.querySelector('.nn-je-tcr').textContent = fmt(cr);",
    "        var diff = Math.round((dr - cr) * 100) / 100, d = box.querySelector('.nn-je-diff');",
    "        d.textContent = diff === 0 ? (dr > 0 ? '✓ متوازن' : '') : '(الفرق ' + fmt(Math.abs(diff)) + ')';",
    "        d.className = 'nn-je-diff ' + (diff === 0 ? 'is-ok' : 'is-bad');",
    '    }',
    '    function addRow(l) {',
    "        l = l || {}; var tr = document.createElement('tr'); var n = tbody.children.length + 1;",
    '        if (ro) {',
    "            tr.dataset.d = l.d || 0; tr.dataset.c = l.c || 0;",
    "            tr.innerHTML = '<td>' + n + '</td><td>' + esc(l.a) + ' - ' + esc(names[l.a] || '') + '</td><td>' + (l.d ? fmt(l.d) : '') + '</td><td>'",
    "                + (l.c ? fmt(l.c) : '') + '</td><td>' + esc(l.t) + '</td>';",
    '        } else {',
    "            tr.innerHTML = '<td class=\"nn-je-no\">' + n + '</td><td><input class=\"nn-je-acc\" list=\"nnAccts\" value=\"' + esc(l.a) + '\" placeholder=\"رمز أو اسم الحساب\">'",
    "                + '<small class=\"nn-je-name\">' + esc(names[l.a] || '') + '</small></td>'",
    "                + '<td><input class=\"nn-je-dr\" type=\"number\" step=\"0.01\" min=\"0\" value=\"' + (l.d || '') + '\"></td>'",
    "                + '<td><input class=\"nn-je-cr\" type=\"number\" step=\"0.01\" min=\"0\" value=\"' + (l.c || '') + '\"></td>'",
    "                + '<td><input class=\"nn-je-txt\" value=\"' + esc(l.t) + '\"></td>'",
    "                + '<td><button type=\"button\" class=\"t-Button t-Button--small t-Button--noUI nn-je-del\" title=\"حذف السطر\"><span class=\"fa fa-trash-o\"></span></button></td>';",
    '        }',
    '        tbody.appendChild(tr); return tr;',
    '    }',
    '    if (lines.length) { lines.forEach(addRow); } else if (!ro) { addRow(); addRow(); }',
    '    totals();',
    '    if (ro) return;',
    "    box.addEventListener('input', function (e) {",
    "        var tr = e.target.closest('tr');",
    "        if (e.target.classList.contains('nn-je-acc')) {",
    "            var v = e.target.value.trim(), hit = names[v] ? v : null;",
    '            if (!hit) { accts.some(function (a) { if (a.n === v) { hit = a.a; return true; } }); if (hit) e.target.value = hit; }',
    "            tr.querySelector('.nn-je-name').textContent = hit ? names[hit] : '';",
    '        }',
    "        if (e.target.classList.contains('nn-je-dr') && e.target.value) tr.querySelector('.nn-je-cr').value = '';",
    "        if (e.target.classList.contains('nn-je-cr') && e.target.value) tr.querySelector('.nn-je-dr').value = '';",
    '        totals();',
    '    });',
    "    box.addEventListener('click', function (e) {",
    "        if (e.target.closest('.nn-je-add')) { addRow().querySelector('.nn-je-acc').focus(); }",
    "        if (e.target.closest('.nn-je-del')) { e.target.closest('tr').remove();",
    "            tbody.querySelectorAll('.nn-je-no').forEach(function (td, i) { td.textContent = i + 1; }); totals(); }",
    '    });',
    "    box.addEventListener('keydown', function (e) {",
    "        if (e.key === 'Enter' && e.target.tagName === 'INPUT') { e.preventDefault();",
    "            var tr = e.target.closest('tr');",
    "            if (!tr.nextElementSibling) addRow().querySelector('.nn-je-acc').focus(); else tr.nextElementSibling.querySelector('.nn-je-acc').focus(); }",
    '    });',
    "    $(document).on('apexbeforepagesubmit', function () {",
    '        var out = [];',
    "        tbody.querySelectorAll('tr').forEach(function (tr) {",
    "            var a = tr.querySelector('.nn-je-acc').value.trim(), d = parseFloat(tr.querySelector('.nn-je-dr').value) || null,",
    "                c = parseFloat(tr.querySelector('.nn-je-cr').value) || null, t = tr.querySelector('.nn-je-txt').value.trim();",
    '            if (a || d || c) out.push({a: a, d: d, c: c, t: t || null});',
    '        });',
    "        $s('P21_LINES', JSON.stringify(out));",
    '    });',
    '})();'])
p.branch(10, 'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:21:P21_ID:&P21_ID.&success_msg=#SUCCESS_MSG#')

# =============================================================== 30) ميزان المراجعة
p = app.page(30, 'Trial Balance', 'TRIAL-BALANCE', 'ميزان المراجعة', scheme=TENANT)
f = p.static('معايير التقرير', 10)
p.date('P30_FROM', f, 10, 'من تاريخ')
p.date('P30_TO', f, 20, 'إلى تاريخ')
p.yesno('P30_ZERO', f, 30, 'إظهار الحسابات الصفرية')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'BEFORE_HEADER', 'Defaults', [
    ":P30_FROM := nvl(:P30_FROM, to_char(trunc(sysdate, 'YYYY'), 'YYYY-MM-DD'));",
    ":P30_TO := nvl(:P30_TO, to_char(sysdate, 'YYYY-MM-DD'));"])
p.dynamic('ميزان المراجعة', 20, [
    "return noona_gl_pkg.trial_balance(to_date(:P30_FROM, 'YYYY-MM-DD'), to_date(:P30_TO, 'YYYY-MM-DD'), nvl(:P30_ZERO, 'N'));"],
    hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

# =============================================================== 31) كشف حساب
p = app.page(31, 'Account Statement', 'STATEMENT', 'كشف حساب', scheme=TENANT)
f = p.static('معايير التقرير', 10)
p.select('P31_ACCOUNT', f, 10, 'الحساب', lov_sql=LEDGER_ACCOUNTS)
p.date('P31_FROM', f, 20, 'من تاريخ')
p.date('P31_TO', f, 30, 'إلى تاريخ')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'BEFORE_HEADER', 'Defaults', [
    ":P31_FROM := nvl(:P31_FROM, to_char(trunc(sysdate, 'YYYY'), 'YYYY-MM-DD'));",
    ":P31_TO := nvl(:P31_TO, to_char(sysdate, 'YYYY-MM-DD'));"])
p.dynamic('كشف الحساب', 20, [
    "return noona_gl_pkg.account_statement(:P31_ACCOUNT, to_date(:P31_FROM, 'YYYY-MM-DD'), to_date(:P31_TO, 'YYYY-MM-DD'));"],
    hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

app.nav_item('لوحة المالية', 1, 'fa-calculator', 10)
gl = app.nav_item('الأستاذ العام', None, 'fa-book', 20)
app.nav_item('القيود اليومية', 20, 'fa-list-alt', 21, parent=gl)
app.nav_item('قيد جديد', 21, 'fa-plus', 22, parent=gl)
app.nav_item('دليل الحسابات', 10, 'fa-sitemap', 23, parent=gl)
app.nav_item('الفترات المحاسبية', 11, 'fa-calendar', 24, parent=gl)
rp = app.nav_item('التقارير', None, 'fa-bar-chart', 30)
app.nav_item('ميزان المراجعة', 30, 'fa-balance-scale', 31, parent=rp)
app.nav_item('كشف حساب', 31, 'fa-file-text-o', 32, parent=rp)

app.finalize()
print('NOONA_FIN built:', len(app.pages), 'pages')
