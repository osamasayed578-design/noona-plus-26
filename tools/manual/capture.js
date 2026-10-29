/* NOONA PLUS | التقاط شاشات تطبيق APEX لكتالوج الاستخدام
   لكل صفحة: صورة الشاشة، المناطق، الحقول (التسمية والنوع والإلزام وأمثلة القيم)، الأزرار، أعمدة التقارير التفاعلية، والقائمة الجانبية.
   الاستخدام:
     PW_PATH=<playwright> node tools/manual/capture.js <spec.json> <outDir>
   spec.json: {"app":"noona_admin","user":"ADMIN","pwd":"...","port":8090,"pages":[{"alias":"COMPANIES"},
               {"alias":"COMPANY","via":{"from":"COMPANIES","click":".a-IRR-table td a"},"shot":"COMPANY-EDIT"},
               {"alias":"X","qs":"&p1_x=1","actions":[{"click":"[data-a=SAVE]"},{"wait":800}]}]} */
'use strict';
const fs = require('fs');
const path = require('path');
const { chromium } = require(process.env.PW_PATH);

const spec = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
const out = process.argv[3];
fs.mkdirSync(path.join(out, 'img'), { recursive: true });

function extract() {
  const clean = (s) => (s || '').replace(/\s+/g, ' ').trim();
  const visible = (e) => !!(e && (e.offsetWidth || e.offsetHeight || e.getClientRects().length));
  const regions = [];
  document.querySelectorAll('.t-Region, .t-IRR-region, .t-Form--stretchInputs').forEach((r) => {
    const t = r.querySelector(':scope > .t-Region-header .t-Region-title, :scope .t-Region-title');
    if (t && visible(r) && clean(t.textContent) && !regions.includes(clean(t.textContent))) regions.push(clean(t.textContent));
  });
  const items = [];
  document.querySelectorAll('.t-Form-fieldContainer').forEach((c) => {
    if (!visible(c)) return;
    const lab = c.querySelector('.t-Form-label, label');
    const label = clean(lab && lab.textContent).replace(/\s*\(?مطلوب\)?$/, '');
    if (!label) return;
    let type = 'نص';
    const sel = c.querySelector('select');
    let options = [];
    if (c.querySelector('.apex-item-datepicker, a-date-picker, .apex-item-datepicker-jet, input[type=date]')) type = 'تاريخ';
    else if (sel) { type = 'قائمة اختيار'; options = Array.from(sel.options).map((o) => clean(o.textContent)).filter((x) => x && !/^- /.test(x)).slice(0, 8); }
    else if (c.querySelector('.apex-item-checkbox, input[type=checkbox]')) { type = 'اختيار متعدد';
      options = Array.from(c.querySelectorAll('.apex-item-option label')).map((l) => clean(l.textContent)).slice(0, 8); }
    else if (c.querySelector('textarea')) type = 'نص متعدد الأسطر';
    else if (c.querySelector('input[type=password]')) type = 'كلمة مرور';
    else if (c.querySelector('input[type=file], .apex-item-filedrop')) type = 'ملف';
    else if (c.querySelector('.apex-item-number, input[inputmode=decimal], input.number_field')) type = 'رقم';
    else if (c.querySelector('.display_only, .apex-item-display-only')) type = 'عرض فقط';
    const required = c.classList.contains('is-required') || !!c.querySelector('[required], .is-required');
    const help = clean((c.querySelector('.t-Form-inlineHelp, .t-Form-helpText') || {}).textContent);
    const inp = c.querySelector('input:not([type=hidden]), select, textarea');
    items.push({ label, type, required, options, help, value: inp && inp.type !== 'password' ? clean(inp.value).slice(0, 60) : '' });
  });
  const buttons = [];
  document.querySelectorAll('button.t-Button, a.t-Button').forEach((b) => {
    const t = clean(b.textContent);
    if (t && visible(b) && !b.closest('.a-IRR-toolbar, .a-IRR-dialog, .t-Header, .ui-dialog') && !buttons.includes(t)) buttons.push(t);
  });
  const reports = [];
  document.querySelectorAll('.a-IRR').forEach((r) => {
    const cols = Array.from(r.querySelectorAll('.a-IRR-header .a-IRR-headerLabel, .a-IRR-header a, th.a-IRR-header')).map((h) => clean(h.textContent))
      .filter((x, i, a) => x && a.indexOf(x) === i);
    const reg = r.closest('.t-Region, .t-IRR-region');
    const title = clean(reg && (reg.querySelector('.t-Region-title') || {}).textContent);
    reports.push({ title, columns: cols, rows: r.querySelectorAll('.a-IRR-table tr').length - 1 });
  });
  const nav = Array.from(document.querySelectorAll('#t_TreeNav .a-TreeView-label, #t_TreeNav .a-TreeView-content a')).map((n) => clean(n.textContent))
    .filter((x, i, a) => x && a.indexOf(x) === i);
  const title = clean(document.title);
  const errors = Array.from(document.querySelectorAll('#t_Alert_Notification .t-Alert-body, .a-Notification-item')).map((e) => clean(e.textContent));
  return { title, regions, items, buttons, reports, nav, errors };
}

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1400, height: 900 } });
  const jsErrors = [];
  page.on('pageerror', (e) => jsErrors.push(e.message));
  page.on('dialog', (d) => (d.type() === 'beforeunload' ? d.accept() : d.dismiss()));
  const base = `http://localhost:${spec.port || 8090}/ords/r/noonaplus/${spec.app}`;
  const settle = async () => { await page.waitForTimeout(900); await page.waitForLoadState('networkidle').catch(() => {}); };
  await page.goto(base + '/home'); await settle();
  if (await page.locator('#P9999_USERNAME').count()) {
    if (spec.loginShot) await page.screenshot({ path: path.join(out, 'img', spec.loginShot + '.png') });
    await page.fill('#P9999_USERNAME', spec.user); await page.fill('#P9999_PASSWORD', spec.pwd);
    await page.getByRole('button').filter({ hasText: /Sign In|تسجيل الدخول|دخول/ }).first().click(); await settle();
  }
  const sess = new URL(page.url()).searchParams.get('session');
  if (!page.url().includes(`/${spec.app}/`)) { await page.goto(`${base}/home?session=${sess}`); await settle(); }
  const go = async (alias, qs = '') => { await page.goto(`${base}/${alias.toLowerCase()}?session=${sess}${qs}`); await settle(); };
  const result = { app: spec.app, pages: [] };
  for (const p of spec.pages) {
    const name = p.shot || p.alias;
    try {
      jsErrors.length = 0;
      if (p.via) {
        await go(p.via.from, p.via.qs || '');
        await page.locator(p.via.click).first().click(); await settle();
      } else {
        await go(p.alias, p.qs || '');
      }
      for (const a of p.actions || []) {
        if (a.click) { await page.locator(a.click).first().click({ timeout: 5000 }).catch(() => {}); }
        if (a.fill) { await page.fill(a.fill, a.value).catch(() => {}); }
        if (a.select) { await page.selectOption(a.select, a.value).catch(() => {}); }
        if (a.eval) { await page.evaluate(a.eval).catch(() => {}); }
        await page.waitForTimeout(a.wait || 600);
      }
      await settle();
      const info = await page.evaluate(extract);
      const h = await page.evaluate(() => document.documentElement.scrollHeight);
      await page.screenshot({ path: path.join(out, 'img', name + '.png'), fullPage: h <= (p.maxHeight || 2600),
                              clip: h > (p.maxHeight || 2600) ? { x: 0, y: 0, width: 1400, height: p.maxHeight || 2600 } : undefined });
      result.pages.push({ alias: p.alias, shot: name, url: page.url().replace(/session=\d+/, ''), ...info, jsErrors: jsErrors.slice() });
      console.log('ok   ' + name + ' | ' + info.title + ' | items ' + info.items.length + (info.errors.length ? ' | ERR ' + info.errors[0] : ''));
    } catch (e) {
      console.log('FAIL ' + name + ' ' + e.message.split('\n')[0]);
      result.pages.push({ alias: p.alias, shot: null, error: e.message.split('\n')[0] });
    }
  }
  fs.writeFileSync(path.join(out, spec.app + '.json'), JSON.stringify(result, null, 1));
  await browser.close();
})().catch((e) => { console.error('ERR', e.message); process.exit(1); });
