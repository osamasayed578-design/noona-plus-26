/* NOONA PLUS | مراجعة الإدخال الآلية لكل الشاشات.
   يدخل كل تطبيق، ويفتح كل شاشة في القائمة وأول سجل من كل قائمة، ثم في كل منطقة إدخال: يملأ الحقول الفارغة بقيم معقولة
   (نص، رقم، تاريخ، قائمة، بريد، جوال) ويضغط زر الحفظ أو الإضافة، ويصنف النتيجة:
     ok        رسالة نجاح أو انتقال سليم
     rejected  رفض واضح بالعربية (تحقق) - سلوك صحيح
     technical خطأ تقني ظاهر للمستخدم (ORA-/PLS-/خطأ غير متوقع/نص إنجليزي) أو خطأ JavaScript أو HTTP 5xx
   لا يضغط أزرار الحذف والإلغاء والإقفال والعكس والتعطيل وكلمات المرور.
   المخرجات: <out>/entry.json و<out>/entry.html
   PW_PATH=... NOONA_PWD_ADMIN=... NOONA_PWD_PLATFORM=... node tools/ux_audit/entry.js <out> [alias ...] */
'use strict';
const fs = require('fs');
const path = require('path');
const { chromium } = require(process.env.PW_PATH);

const BASE = process.env.NOONA_URL || 'http://localhost:8090/ords/r/noonaplus';
const OUT = process.argv[2] || 'entry-out';
const ONLY = process.argv.slice(3);
const APPS = [
  ['noona_admin', 'إدارة المؤسسة', 'ADMIN'], ['noona_platform', 'لوحة المنصة', 'PLATFORM'], ['noona_portal', 'البوابة', 'ADMIN'],
  ['noona_fin', 'المالية', 'ADMIN'], ['noona_doc', 'المستندات والمراسلات', 'ADMIN'], ['noona_scm', 'سلسلة الإمداد', 'ADMIN'],
  ['noona_pos', 'المبيعات ونقاط البيع', 'ADMIN'], ['noona_mfg', 'التصنيع', 'ADMIN'], ['noona_hr', 'الموارد البشرية والرواتب', 'ADMIN'],
  ['noona_prj', 'العقارات والضيافة والمشروعات', 'ADMIN'], ['noona_his', 'المستشفيات والمراكز الطبية', 'ADMIN'],
  ['noona_bi', 'مركز التقارير', 'ADMIN'], ['noona_auto', 'مراكز خدمة السيارات', 'ADMIN'],
].filter((a) => !ONLY.length || ONLY.includes(a[0]));
const PWD = { ADMIN: process.env.NOONA_PWD_ADMIN, PLATFORM: process.env.NOONA_PWD_PLATFORM };
// أزرار لا تضغط: تغير بيانات لا رجعة فيها أو تخرج من الجلسة
const DANGER = /حذف|إلغاء|الغاء|إقفال|اقفال|عكس|تعطيل|إيقاف|ايقاف|إنهاء|انهاء|كلمة المرور|خروج|إعادة تعيين|استعادة|رفض|حظر|تجميد|شطب|مسح|Delete|Cancel|Close|Reverse|Logout|Reset/i;
const TECH = /ORA-\d|PLS-\d|error occurred|Error during|unexpected|Internal Server|خطأ غير متوقع|NOONA-INS-|ERR-\d/i;

const today = new Date().toISOString().slice(0, 10);

async function login(browser, user) {
  const ctx = await browser.newContext({ viewport: { width: 1366, height: 860 } });
  const page = await ctx.newPage();
  page.on('dialog', (d) => d.accept().catch(() => {}));                 // تأكيدات الحفظ تقبل
  await page.goto(`${BASE}/noona_master/home`); await page.waitForLoadState('networkidle').catch(() => {});
  await page.fill('#P9999_USERNAME', user); await page.fill('#P9999_PASSWORD', PWD[user]);
  await page.getByRole('button').filter({ hasText: /Sign In|تسجيل الدخول|دخول/ }).first().click();
  await page.waitForURL((u) => /session=\d+/.test(u.href) && !/\/login/.test(u.pathname), { timeout: 30000 });
  return { ctx, page, sess: new URL(page.url()).searchParams.get('session') };
}

// يملأ الحقول الظاهرة الفارغة داخل منطقة؛ يعيد عدد الحقول المملوءة
async function fillRegion(page, regionId) {
  return page.evaluate(({ regionId, today }) => {
    const root = document.getElementById(regionId);
    if (!root) return 0;
    const vis = (e) => { const r = e.getBoundingClientRect(); const s = getComputedStyle(e); return r.width > 0 && r.height > 0 && s.visibility !== 'hidden' && s.display !== 'none'; };
    let n = 0;
    const label = (e) => { const c = e.closest('.t-Form-fieldContainer'); return c ? (c.querySelector('label') || {}).textContent || '' : ''; };
    const setv = (e, v) => {
      const item = e.id && window.apex && apex.item ? apex.item(e.id.replace(/_input$/, '')) : null;
      try { if (item && item.node) item.setValue(v); else e.value = v; } catch (x) { e.value = v; }
      e.dispatchEvent(new Event('change', { bubbles: true })); n++;
    };
    root.querySelectorAll('input, select, textarea').forEach((e) => {
      if (!vis(e) || e.disabled || e.readOnly || e.closest('.a-IRR, .a-GV, .a-IG, .nn-mail, .ui-dialog')) return;
      const t = (e.type || '').toLowerCase(), l = label(e);
      if (['hidden', 'checkbox', 'radio', 'file', 'button', 'submit', 'search', 'password'].includes(t)) return;
      if (e.tagName === 'SELECT') {
        if (e.value) return;
        const o = [...e.options].find((x) => x.value && x.value !== '%null%');
        if (o) setv(e, o.value);
        return;
      }
      if (e.value) return;
      if (e.closest('.apex-item-group--popup-lov, .a-PopupLOV') || e.classList.contains('popup_lov')) return;
      if (e.closest('a-date-picker, .apex-item-datepicker, .apex-item-datepicker-jet') || /_input$/.test(e.id) && /date|تاريخ|من|إلى|حتى|يسري/.test(l + e.id)) { setv(e, today); return; }
      if (/HH:MI|الساعة|الدخول|الخروج|وقت/.test(l) && e.maxLength > 0 && e.maxLength <= 8) { setv(e, /إلى|الخروج|نهاية/.test(l) ? '10:00' : '08:00'); return; }
      if (e.tagName === 'TEXTAREA') { setv(e, 'إدخال تجريبي للمراجعة'); return; }
      if (t === 'email' || /بريد|email/i.test(l)) { setv(e, 'review' + Date.now() % 100000 + '@example.com'); return; }
      if (t === 'number' || e.classList.contains('number_field') || e.inputMode === 'decimal' || /مبلغ|سعر|كمية|عدد|نسبة|قيمة|رصيد|راتب|حد|مدة|أيام|ساعات|تكلفة/.test(l)) { setv(e, '10'); return; }
      if (/جوال|هاتف|phone|mobile/i.test(l)) { setv(e, '0551234567'); return; }
      if (/آيبان|iban/i.test(l)) { setv(e, 'SA0380000000608010167519'); return; }
      if (/هوية|إقامة|سجل تجاري|ضريبي/.test(l)) return;                 // أرقام رسمية لها تحقق خاص: تترك
      if (/رمز|كود|code/i.test(l)) { setv(e, 'RV' + (Date.now() % 100000)); return; }
      setv(e, 'مراجعة ' + (Date.now() % 10000));
    });
    return n;
  }, { regionId, today });
}

async function regionsWithButtons(page) {
  return page.evaluate((dangerSrc) => {
    const danger = new RegExp(dangerSrc, 'i');
    const vis = (e) => { const r = e.getBoundingClientRect(); const s = getComputedStyle(e); return r.width > 0 && r.height > 0 && s.visibility !== 'hidden' && s.display !== 'none'; };
    const out = [];
    document.querySelectorAll('.t-Region[id], .t-ButtonRegion[id]').forEach((reg) => {
      if (!vis(reg) || reg.querySelector('.t-Region[id]')) return;                  // أعمق منطقة فقط
      const inputs = [...reg.querySelectorAll('input:not([type=hidden]), select, textarea')].filter(vis).filter((e) => !e.closest('.a-IRR, .a-IG'));
      if (!inputs.length) return;
      const btn = [...reg.querySelectorAll('button.t-Button, a.t-Button')].filter(vis)
        .find((b) => !danger.test(b.innerText + ' ' + (b.title || '')) && /حفظ|إضافة|اضافة|إنشاء|تسجيل|اعتماد|إرسال|ارسال|تنفيذ|إصدار|تحديث|نقل|تحويل|ربط|تشغيل|احتساب|حساب|فتح|Save|Create|Add/i.test(b.innerText));
      if (btn) out.push({ reg: reg.id, title: ((reg.querySelector('.t-Region-title') || {}).textContent || '').trim().slice(0, 60),
        btnId: btn.id || null, btn: btn.innerText.trim().slice(0, 40), inputs: inputs.length });
    });
    return out;
  }, DANGER.source);
}

async function outcome(page, errs) {
  const texts = await page.locator('#t_Alert_Notification, #t_Alert_Success, .a-Notification, .t-Form-error, .apex-page-error, .t-Alert--danger')
    .allInnerTexts().catch(() => []);
  const body = await page.locator('body').innerText().catch(() => '');
  const msg = texts.join(' | ').replace(/\s+/g, ' ').trim();
  const err500 = errs.filter((e) => /HTTP 5/.test(e));
  const js = errs.filter((e) => /^JS:/.test(e));
  if (TECH.test(msg) || TECH.test(body.slice(0, 3000)) || err500.length) return { k: 'technical', msg: (msg || body.match(/.{0,80}(ORA-\d+|PLS-\d+|error occurred|Error during).{0,160}/i)?.[0] || err500.join(' ')).slice(0, 300) };
  if (js.length) return { k: 'technical', msg: js.join(' · ').slice(0, 300) };
  if (/[A-Za-z]{4,}/.test(msg.replace(/ORA|APEX|NOONA[-\w]*|Error Message|Success Message|[\w.+-]+@[\w.-]+|\b[A-Z]{2,5}-[\w-]+/g, '')) && !/[؀-ۿ]/.test(msg))
    return { k: 'english', msg: msg.slice(0, 300) };
  if (/نجاح|تم |تمت|حُفظ|سُجل|أُضيف|Success/.test(msg)) return { k: 'ok', msg: msg.slice(0, 200) };
  if (msg) return { k: 'rejected', msg: msg.slice(0, 300) };
  return { k: 'ok', msg: '(لا رسالة؛ انتقال أو تحديث)' };
}

(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  const browser = await chromium.launch();
  const results = [];
  const sessions = {};
  for (const app of APPS) {
    const user = app[2];
    if (!sessions[user]) sessions[user] = await login(browser, user);
    const { page, sess } = sessions[user];
    const errs = [];
    page.removeAllListeners('pageerror'); page.removeAllListeners('response');
    page.on('pageerror', (e) => errs.push('JS: ' + String(e.message).slice(0, 140)));
    page.on('response', (r) => { if (r.status() >= 500 && r.url().includes('/ords/')) errs.push('HTTP ' + r.status() + ' ' + r.url().split('?')[0].split('/').slice(-2).join('/')); });
    await page.goto(`${BASE}/${app[0]}/home?session=${sess}`); await page.waitForLoadState('networkidle').catch(() => {});
    const nav = await page.evaluate(() => {
      try { apex.jQuery('#t_TreeNav').treeView('expandAll'); } catch (e) { /* لا قائمة */ }
      return [...document.querySelectorAll('#t_TreeNav a[href]')].map((a) => ({ t: a.textContent.trim(), h: a.href }))
        .filter((x) => x.h && !x.h.startsWith('javascript') && !x.h.endsWith('#'));
    });
    const seen = new Set();
    const targets = [{ t: 'الرئيسية', h: page.url() }, ...nav].filter((x) => { const k = x.h.split('?')[0]; if (seen.has(k)) return false; seen.add(k); return true; });
    console.log(`== ${app[0]}: ${targets.length} screens`);
    const queue = [...targets];
    while (queue.length) {
      const t = queue.shift();
      errs.length = 0;
      await page.goto(t.h, { timeout: 60000 }).catch(() => {}); await page.waitForLoadState('networkidle', { timeout: 30000 }).catch(() => {});
      const open = await outcome(page, errs);
      if (open.k === 'technical' || open.k === 'english') {
        results.push({ app: app[0], appName: app[1], screen: t.t, step: 'فتح الشاشة', ...open });
        console.log(`  ✗ ${t.t}: open ${open.k} ${open.msg.slice(0, 120)}`);
      }
      // أول سجل في القائمة (شاشة التفاصيل)
      if (!t.sub) {
        const sub = await page.evaluate(() => { const a = document.querySelector('.a-IRR-table td a[href], .t-Report-report td a[href]');
          return a && !a.href.startsWith('javascript') && !/#$/.test(a.getAttribute('href') || '') ? a.href : null; }).catch(() => null);
        if (sub && !seen.has(sub.split('?')[0] + '#sub')) { seen.add(sub.split('?')[0] + '#sub'); queue.push({ t: t.t + ' ← سجل', h: sub, sub: true }); }
      }
      const regs = await regionsWithButtons(page);
      for (const r of regs) {
        errs.length = 0;
        await page.goto(t.h, { timeout: 60000 }).catch(() => {}); await page.waitForLoadState('networkidle', { timeout: 30000 }).catch(() => {});
        const filled = await fillRegion(page, r.reg).catch(() => 0);
        await page.waitForTimeout(400);
        const b = r.btnId ? page.locator('#' + r.btnId) : page.locator(`#${r.reg} :is(button,a).t-Button`, { hasText: r.btn }).first();
        if (!(await b.isVisible().catch(() => false))) continue;
        await Promise.all([page.waitForLoadState('networkidle', { timeout: 30000 }).catch(() => {}), b.click({ timeout: 8000 }).catch(() => {})]);
        await page.waitForTimeout(1200);
        await page.waitForLoadState('networkidle', { timeout: 30000 }).catch(() => {});
        const o = await outcome(page, errs);
        results.push({ app: app[0], appName: app[1], screen: t.t, step: (r.title || 'نموذج') + ' ← ' + r.btn, filled, ...o });
        console.log(`  ${o.k === 'ok' ? '✓' : o.k === 'rejected' ? '·' : '✗'} ${t.t} | ${r.title} ← ${r.btn} [${filled}] ${o.k}: ${o.msg.slice(0, 110)}`);
      }
    }
  }
  await browser.close();
  fs.writeFileSync(path.join(OUT, 'entry.json'), JSON.stringify({ at: new Date().toISOString(), results }, null, 1));
  const esc = (s) => String(s || '').replace(/[&<>]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;' })[c]);
  const cnt = (k) => results.filter((r) => r.k === k).length;
  fs.writeFileSync(path.join(OUT, 'entry.html'), `<!doctype html><html lang="ar" dir="rtl"><meta charset="utf-8"><title>مراجعة الإدخال</title>
<style>body{font-family:Tahoma,Arial;margin:20px}table{border-collapse:collapse;width:100%;font-size:13px}td,th{border:1px solid #ddd;padding:5px;vertical-align:top}
.technical,.english{background:#fde8e8}.rejected{background:#fff8e1}.ok{background:#eefbf0}</style>
<h1>مراجعة الإدخال في كل الشاشات</h1><p>نجاح: ${cnt('ok')} · رفض بتحقق واضح: ${cnt('rejected')} · أخطاء تقنية: ${cnt('technical')} · رسائل إنجليزية: ${cnt('english')}</p>
<table><tr><th>النظام</th><th>الشاشة</th><th>الإجراء</th><th>النتيجة</th><th>الرسالة</th></tr>
${results.map((r) => `<tr class="${r.k}"><td>${esc(r.appName)}</td><td>${esc(r.screen)}</td><td>${esc(r.step)}</td><td>${r.k}</td><td>${esc(r.msg)}</td></tr>`).join('\n')}</table></html>`);
  console.log(`done: ${results.length} actions | ok ${cnt('ok')} | rejected ${cnt('rejected')} | technical ${cnt('technical')} | english ${cnt('english')}`);
})().catch((e) => { console.error('ERR', e); process.exit(1); });
