/* NOONA PLUS | فحص تجربة المستخدم الآلي لكل الشاشات.
   يدخل كل تطبيق، يفتح كل عنصر في القائمة الجانبية وأول سجل من كل قائمة (الشاشات الفرعية)، ويفحص:
     إمكانية الوصول (axe-core: WCAG 2.1 AA)، النصوص الإنجليزية الظاهرة، العرض على الجوال (تمرير أفقي، أهداف لمس صغيرة)،
     أخطاء JavaScript والطلبات الفاشلة، زمن التحميل، وعدد الأزرار الرئيسية.
   المخرجات: <out>/report.json و<out>/report.html
   PW_PATH=... NOONA_PWD_ADMIN=... NOONA_PWD_PLATFORM=... node tools/ux_audit/audit.js <out> [alias ...] */
'use strict';
const fs = require('fs');
const path = require('path');
const { chromium } = require(process.env.PW_PATH);

const BASE = process.env.NOONA_URL || 'http://localhost:8090/ords/r/noonaplus';
const OUT = process.argv[2] || 'ux-out';
const ONLY = process.argv.slice(3);
const AXE = fs.readFileSync(path.join(__dirname, 'node_modules', 'axe-core', 'axe.min.js'), 'utf8');
const APPS = [
  ['noona_master', 'الدخول الموحد والأنظمة', 'ADMIN'], ['noona_portal', 'البوابة', 'ADMIN'], ['noona_admin', 'إدارة المؤسسة', 'ADMIN'],
  ['noona_platform', 'لوحة المنصة', 'PLATFORM'], ['noona_fin', 'المالية', 'ADMIN'], ['noona_doc', 'المستندات والمراسلات', 'ADMIN'],
  ['noona_scm', 'سلسلة الإمداد', 'ADMIN'], ['noona_pos', 'المبيعات ونقاط البيع', 'ADMIN'], ['noona_mfg', 'التصنيع', 'ADMIN'],
  ['noona_hr', 'الموارد البشرية والرواتب', 'ADMIN'], ['noona_prj', 'العقارات والضيافة والمشروعات', 'ADMIN'],
  ['noona_his', 'المستشفيات والمراكز الطبية', 'ADMIN'], ['noona_bi', 'مركز التقارير', 'ADMIN'], ['noona_auto', 'مراكز خدمة السيارات', 'ADMIN'],
].filter((a) => !ONLY.length || ONLY.includes(a[0]));
const PWD = { ADMIN: process.env.NOONA_PWD_ADMIN, PLATFORM: process.env.NOONA_PWD_PLATFORM };
const SLOW_MS = 2500;

// كلمات ورموز إنجليزية مقبولة في واجهة عربية (أسماء علامات، اختصارات قياسية، رموز)
const ALLOW = /^(NOONA[\w &]*|PLUS|ERP|SAR|AED|USD|EGP|VAT|API|CSV|PDF|XML|JSON|OEM|ICD-?10|IBAN|WPS|QR|KPI|ZATCA|OpenAPI|Webhooks?|SMS|Apple Pay|STC Pay|mada|Visa|Mastercard|Release [\d.]+|Enter|Esc|F\d+|HH24:MI|mm\/dd\/yyyy|YYYY[-\/]MM[-\/]DD|URL|IP|ID|MRN|CR|PWS|POS|BOM|MRP|SKU|UOM|PCS|KG|ECG|CBC|CT|MRI|BP|SpO2|RR|ER|ICU|OR|TB|GL|AR|AP|WhatsApp|Booking|Postman|Swagger|Bearer|HMAC|SHA-256|UBL|PIH|ICV|UUID|TLV|IFRS|IAS|Gmail|Outlook|Google|Microsoft|Oracle|APEX|ORDS)$/i;

function englishIn(text) {
  const t = text.replace(/\s+/g, ' ').trim();
  if (!t || /[؀-ۿ]/.test(t)) return null;            // فيه عربي: ثنائي اللغة مقبول
  if (!/[A-Za-z]{3,}/.test(t)) return null;
  if (/^[\w.+-]+@[\w-]+\.[\w.]+$/.test(t) || /^https?:\/\//.test(t)) return null;
  if (/^[A-Z]{2,5}[-_ ]?\d[\w\-\/]*$/.test(t)) return null;      // رموز: ITM-000001، JV-2026-1
  const words = t.split(/[\s,()\/·|:–-]+/).filter((w) => /[A-Za-z]{2,}/.test(w));
  if (!words.length || words.every((w) => ALLOW.test(w) || /^[A-Z0-9]{2,6}$/.test(w))) return null;
  if (ALLOW.test(t)) return null;
  return t.slice(0, 80);
}

async function scanPage(page, mobile) {
  return page.evaluate(({ mobile }) => {
    const vis = (e) => { const r = e.getBoundingClientRect(); const s = getComputedStyle(e);
      return r.width > 0 && r.height > 0 && s.visibility !== 'hidden' && s.display !== 'none' && !e.closest('[aria-hidden="true"]'); };
    const sel = (e) => (e.id ? '#' + e.id : e.tagName.toLowerCase() + (e.className && typeof e.className === 'string' ? '.' + e.className.trim().split(/\s+/).slice(0, 2).join('.') : ''));
    const r = { texts: [], overflow: 0, wide: [], small: [], hot: 0, title: '' };
    r.title = (document.querySelector('.t-Breadcrumb-label, h1, .t-Region-title') || {}).textContent || document.title;
    if (!mobile) {
      // نصوص الواجهة: العناوين والتسميات والأزرار ورؤوس الأعمدة والعناصر النائبة والخيارات
      const q = 'label, th, button, h1, h2, h3, h4, .t-Region-title, .t-Button-label, .a-IRR-headerLabel, .t-Alert-title, legend, .nn-kpi-label, a.t-Button';
      // شريط التنقل العلوي يعرض اسم المستخدم (بيانات لا تسمية)
      // المحتوى المعلن إنجليزياً (lang="en") مقصود: الشهادات الطبية والمطبوعات الإنجليزية
      document.querySelectorAll(q).forEach((e) => { if (vis(e) && !e.closest('.t-NavigationBar, .t-Header-navBar, [lang^="en"]')) r.texts.push(e.innerText || ''); });
      document.querySelectorAll('input[placeholder], textarea[placeholder]').forEach((e) => { if (vis(e)) r.texts.push(e.placeholder); });
      document.querySelectorAll('select').forEach((s) => { if (vis(s)) [...s.options].slice(0, 15).forEach((o) => r.texts.push(o.text)); });
      // الزر الرئيسي يقاس لكل منطقة عمل: أكبر عدد أزرار مميزة داخل منطقة واحدة (شاشات الإعداد فيها نماذج مستقلة لكل منها زرها)
      const per = new Map();
      [...document.querySelectorAll('.t-Button--hot')].filter((e) => vis(e) && !e.closest('.ui-dialog, .t-Dialog, [role=dialog]')).forEach((e) => {
        const reg = e.closest('.t-Region, .t-ButtonRegion, form') || document.body; per.set(reg, (per.get(reg) || 0) + 1); });
      r.hot = Math.max(0, ...per.values());
    } else {
      const W = window.innerWidth;
      r.overflow = Math.max(0, document.documentElement.scrollWidth - W);
      if (r.overflow > 4) {
        document.querySelectorAll('body *').forEach((e) => {
          if (r.wide.length >= 4 || !vis(e)) return;
          const b = e.getBoundingClientRect();
          if ((b.right > W + 4 || b.left < -4) && !e.closest('.a-IRR-tableContainer, .t-Report-tableWrap, .a-GV, table, [style*="overflow"]')
              && getComputedStyle(e.parentElement || e).overflowX === 'visible') r.wide.push(sel(e) + ' (' + Math.round(b.width) + 'px)');
        });
      }
      // أهداف اللمس أصغر من 24×24 (WCAG 2.5.8)، عدا الروابط داخل النص والجداول
      document.querySelectorAll('a, button, input:not([type=hidden]), select, [role=button]').forEach((e) => {
        // رابط تخطي المحتوى (مخفي حتى التركيز) وحقل الملف المخفي خلف منطقة السحب ليسا أهداف لمس
        if (!vis(e) || e.closest('p, td, li.a-IRR-pagination, .nn-mail-text') || e.id === 't_Body_skipToContent' || e.type === 'file') return;
        const b = e.getBoundingClientRect();
        if (b.width < 24 || b.height < 24) r.small.push(sel(e) + ' ' + Math.round(b.width) + '×' + Math.round(b.height));
      });
    }
    return r;
  }, { mobile });
}

async function axe(page) {
  await page.addScriptTag({ content: AXE });
  return page.evaluate(async () => {
    const res = await window.axe.run(document, { runOnly: { type: 'tag', values: ['wcag2a', 'wcag2aa', 'wcag21aa'] }, resultTypes: ['violations'] });
    return res.violations.map((v) => ({ id: v.id, impact: v.impact, help: v.help, n: v.nodes.length,
      sample: v.nodes.slice(0, 2).map((x) => x.target.join(' ')).join(' | ').slice(0, 160) }));
  }).catch((e) => [{ id: 'axe-error', impact: 'minor', help: String(e).slice(0, 120), n: 1, sample: '' }]);
}

async function login(browser, user) {
  const ctx = await browser.newContext({ viewport: { width: 1366, height: 860 } });
  const page = await ctx.newPage();
  // تنبيه مغادرة صفحة بها تعديلات: يقبل حتى يكمل الانتقال؛ غيره يرفض (لا تنفذ عمليات)
  page.on('dialog', (d) => (d.type() === 'beforeunload' ? d.accept() : d.dismiss()).catch(() => {}));
  await page.goto(`${BASE}/noona_master/home`); await page.waitForLoadState('networkidle').catch(() => {});
  await page.fill('#P9999_USERNAME', user); await page.fill('#P9999_PASSWORD', PWD[user]);
  await page.getByRole('button').filter({ hasText: /Sign In|تسجيل الدخول|دخول/ }).first().click();
  await page.waitForURL((u) => /session=\d+/.test(u.href) && !/\/login/.test(u.pathname), { timeout: 30000 });
  return { ctx, page, sess: new URL(page.url()).searchParams.get('session') };
}

async function auditUrl(page, url, label, app, errs) {
  const rec = { app: app[0], appName: app[1], label, url: url.replace(/[?&]session=\d+/, '').replace(/[?&]cs=[^&]+/, ''), issues: [] };
  errs.length = 0;
  await page.setViewportSize({ width: 1366, height: 860 });
  const t0 = Date.now();
  const resp = await page.goto(url, { timeout: 60000 }).catch((e) => ({ status: () => 0, err: e }));
  await page.waitForLoadState('networkidle', { timeout: 30000 }).catch(() => {});
  rec.ms = Date.now() - t0;
  rec.status = resp && resp.status ? resp.status() : 0;
  if (/\/login|noona_master\/home/.test(page.url()) && app[0] !== 'noona_master') rec.issues.push({ k: 'access', sev: 'serious', msg: 'الشاشة أعادت للدخول أو الصفحة الرئيسية', detail: page.url().split('?')[0] });
  const errBox = await page.locator('#t_Alert_Notification, .a-Notification--error, .apex-page-error').allInnerTexts().catch(() => []);
  if (errBox.join('').match(/خطأ|error|ORA-/i)) rec.issues.push({ k: 'error', sev: 'critical', msg: 'رسالة خطأ عند فتح الشاشة', detail: errBox.join(' ').replace(/\s+/g, ' ').slice(0, 200) });
  const d = await scanPage(page, false);
  rec.title = (d.title || '').replace(/\s+/g, ' ').trim().slice(0, 80);
  const eng = [...new Set(d.texts.map(englishIn).filter(Boolean))];
  if (eng.length) rec.issues.push({ k: 'english', sev: 'moderate', msg: eng.length + ' نص إنجليزي ظاهر في الواجهة', detail: eng.slice(0, 8).join(' · ') });
  if (d.hot > 1) rec.issues.push({ k: 'hot', sev: 'minor', msg: d.hot + ' أزرار رئيسية (مميزة) في منطقة واحدة', detail: 'يفضل زر رئيسي واحد لكل منطقة عمل' });
  if (rec.ms > SLOW_MS) rec.issues.push({ k: 'slow', sev: 'moderate', msg: 'تحميل بطيء ' + (rec.ms / 1000).toFixed(1) + ' ث', detail: '' });
  for (const v of await axe(page)) {
    rec.issues.push({ k: 'a11y:' + v.id, sev: v.impact || 'minor', msg: v.help + ' (' + v.n + ')', detail: v.sample });
  }
  // الجوال
  await page.setViewportSize({ width: 390, height: 844 });
  await page.waitForTimeout(500);
  const m = await scanPage(page, true);
  if (m.overflow > 4) rec.issues.push({ k: 'mobile-overflow', sev: 'serious', msg: 'تمرير أفقي على الجوال بعرض ' + m.overflow + 'px', detail: m.wide.join(' · ') });
  if (m.small.length > 2) rec.issues.push({ k: 'mobile-touch', sev: 'moderate', msg: m.small.length + ' هدف لمس أصغر من 24×24 على الجوال', detail: m.small.slice(0, 5).join(' · ') });
  const jsErr = [...new Set(errs)];
  if (jsErr.length) rec.issues.push({ k: 'js', sev: 'serious', msg: jsErr.length + ' خطأ JavaScript أو طلب فاشل', detail: jsErr.slice(0, 4).join(' · ').slice(0, 300) });
  return rec;
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
    page.removeAllListeners('pageerror'); page.removeAllListeners('console'); page.removeAllListeners('response');
    page.on('pageerror', (e) => errs.push('JS: ' + String(e.message).slice(0, 140)));
    page.on('console', (m) => { if (m.type() === 'error' && !/favicon|ERR_ABORTED|net::/.test(m.text())) errs.push('console: ' + m.text().slice(0, 140)); });
    page.on('response', (r) => { if (r.status() >= 400 && r.url().includes('/ords/') && !/favicon/.test(r.url())) errs.push('HTTP ' + r.status() + ' ' + r.url().split('?')[0].split('/').slice(-2).join('/')); });
    await page.goto(`${BASE}/${app[0]}/home?session=${sess}`); await page.waitForLoadState('networkidle').catch(() => {});
    const nav = await page.evaluate(() => {
      try { apex.jQuery('#t_TreeNav').treeView('expandAll'); } catch (e) { /* لا قائمة */ }
      return [...document.querySelectorAll('#t_TreeNav a[href]')].map((a) => ({ t: a.textContent.trim(), h: a.href }))
        .filter((x) => x.h && !x.h.startsWith('javascript') && !x.h.endsWith('#'));
    });
    const seen = new Set();
    const targets = [{ t: 'الصفحة الرئيسية', h: page.url() }, ...nav].filter((x) => {
      const k = x.h.split('?')[0]; if (seen.has(k)) return false; seen.add(k); return true; });
    console.log(`== ${app[0]}: ${targets.length} screens`);
    for (const t of targets) {
      const rec = await auditUrl(page, t.h, t.t, app, errs);
      results.push(rec);
      console.log(`  ${rec.issues.length ? '!' : '✓'} ${t.t} ${rec.ms}ms ${rec.issues.map((i) => i.k).join(',')}`);
      // الشاشة الفرعية: أول سجل في القائمة
      await page.setViewportSize({ width: 1366, height: 860 });
      await page.goto(t.h).catch(() => {}); await page.waitForLoadState('networkidle').catch(() => {});
      const sub = await page.evaluate(() => { const a = document.querySelector('.a-IRR-table td a[href], .t-Report-report td a[href], table.nn-prj-t td a[href]');
        return a && !a.href.startsWith('javascript') && !/#$/.test(a.getAttribute('href') || '') ? a.href : null; }).catch(() => null);
      const sk = sub && sub.split('?')[0];
      if (sub && !seen.has(sk + '#sub')) {
        seen.add(sk + '#sub');
        const r2 = await auditUrl(page, sub, t.t + ' ← سجل', app, errs);
        results.push(r2);
        console.log(`  ${r2.issues.length ? '!' : '✓'} ${r2.label} ${r2.ms}ms ${r2.issues.map((i) => i.k).join(',')}`);
      }
    }
  }
  await browser.close();
  fs.writeFileSync(path.join(OUT, 'report.json'), JSON.stringify({ at: new Date().toISOString(), results }, null, 1));
  fs.writeFileSync(path.join(OUT, 'report.html'), require('./report.js')(results));
  console.log('screens: ' + results.length + ' | with issues: ' + results.filter((r) => r.issues.length).length);
})().catch((e) => { console.error('ERR', e); process.exit(1); });
