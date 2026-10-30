/* NOONA PLUS | الفيديوهات الشاملة (الفيديو المطول): جولة على كل شاشات الموديول بشرح عربي من كتالوج الاستخدام.
   لكل شاشة: الغرض منها، ثم إبراز الحقول والأعمدة والأزرار واحداً واحداً بشرحها، ثم خطوات الإدخال والملاحظات والشاشات البديلة.
   الشاشات التي لها مشهد إدخال حقيقي (المرتجعات) تنفذ من returns.js بدلاً من العرض فقط.
   python3 tools/manual/video2/export_specs.py specs.json
   PW_PATH=... NOONA_PWD_ADMIN=... NOONA_PWD_PLATFORM=... node tools/manual/video2/tour.js specs.json m02 <outDir> [n]
   n: رقم الفيديو في السلسلة (للبطاقة)؛ ONLY=shot1,shot2 لتجربة شاشات محددة */
'use strict';
const fs = require('fs');
const path = require('path');
const video = require('../video/vlib.js');
const scenes = require('./returns.js');

const [specFile, key, out, num] = process.argv.slice(2);
const MOD = JSON.parse(fs.readFileSync(specFile, 'utf8'))[key];
const ONLY = (process.env.ONLY || '').split(',').filter(Boolean);
const PWD = { ADMIN: process.env.NOONA_PWD_ADMIN, PLATFORM: process.env.NOONA_PWD_PLATFORM };
const MAX_FIELDS = +(process.env.MAX_FIELDS || 8), MAX_BUTTONS = +(process.env.MAX_BUTTONS || 5);
const strip = (s) => String(s || '').replace(/<[^>]+>/g, '').trim();
const norm = (s) => strip(s).replace(/\s+/g, ' ').replace(/[*:]$/, '').trim();

(async () => {
  const screens = [];
  MOD.sections.forEach((sec, si) => sec.screens.forEach((s) => { if (!ONLY.length || ONLY.includes(s.shot)) screens.push({ ...s, sec: sec.title, si }); }));
  const first = screens[0];
  const v = await video(first.app, out, 'tour_' + key);
  const { page } = v;
  let user = null, app = first.app;
  const log = (m) => console.log(m);

  async function loginAs(u, a) {
    if (user) await v.logout();
    if (a !== app) { app = a; }
    await page.goto(`http://localhost:8090/ords/r/noonaplus/${a}/home`).catch(() => {});
    await v.login(u, PWD[u], user ? 'دخول بمستخدم ' + (u === 'PLATFORM' ? '<b>مشغل المنصة</b>' : '<b>مسؤول المؤسسة</b>') : null);
    user = u;
  }

  // ---------------------------------------------------------------- عناصر الشاشة القابلة للشرح
  async function fieldsOf() {
    return page.evaluate((max) => {
      const vis = (e) => { const r = e.getBoundingClientRect(); return r.width > 0 && r.height > 0 && getComputedStyle(e).visibility !== 'hidden'; };
      const out = [];
      document.querySelectorAll('.t-Form-fieldContainer').forEach((c, i) => {
        if (out.length >= max || !vis(c) || c.closest('.ui-dialog')) return;
        const lab = c.querySelector('.t-Form-label, label'); if (!lab) return;
        const t = lab.textContent.replace(/\s+/g, ' ').trim(); if (!t) return;
        const sel = c.querySelector('select'), ta = c.querySelector('textarea'), cb = c.querySelector('input[type=checkbox], input[type=radio]');
        const dt = c.querySelector('a-date-picker, .apex-item-datepicker'), num = c.querySelector('input.number_field, input[inputmode=decimal]');
        const fu = c.querySelector('input[type=file], .apex-item-filedrop');
        let kind = 'نص';
        if (sel) kind = 'قائمة: ' + [...sel.options].map((o) => o.text.trim()).filter((x) => x && !/^-/.test(x)).slice(0, 4).join('، ') + (sel.options.length > 5 ? '…' : '');
        else if (dt) kind = 'تاريخ'; else if (ta) kind = 'نص متعدد الأسطر'; else if (cb) kind = 'اختيار'; else if (num) kind = 'رقم'; else if (fu) kind = 'ملف مرفق';
        c.dataset.nnvF = i;
        out.push({ i, t, req: c.classList.contains('is-required') || !!c.querySelector('[required]'), kind });
      });
      return out;
    }, MAX_FIELDS);
  }
  async function columnsOf() {
    return page.evaluate(() => [...document.querySelectorAll('.a-IRR-headerLabel, .a-GV-headerLabel, table.nn-rpt thead th, table.nn-td-table thead th')]
      .map((e) => e.textContent.replace(/\s+/g, ' ').trim()).filter((t) => t && t !== 'فتح').slice(0, 10));
  }
  async function buttonsOf() {
    return page.evaluate((max) => {
      const vis = (e) => { const r = e.getBoundingClientRect(); return r.width > 0 && r.height > 0; };
      const seen = new Set(), out = [];
      document.querySelectorAll('.t-Body-content button.t-Button, .t-Body-content a.t-Button').forEach((b, i) => {
        const t = b.textContent.replace(/\s+/g, ' ').trim();
        if (out.length >= max || !t || seen.has(t) || !vis(b) || b.closest('.a-IRR-toolbar, .a-IRR-controls, .ui-dialog, .t-Header, table')) return;
        seen.add(t); b.dataset.nnvB = i; out.push({ i, t, hot: b.classList.contains('t-Button--hot') });
      });
      return out;
    }, MAX_BUTTONS);
  }
  async function mark(sel, on) {
    await page.evaluate(({ sel, on }) => { const e = document.querySelector(sel); if (!e) return;
      e.classList.toggle('nnv-hl', on); if (on) e.scrollIntoView({ block: 'center', behavior: 'smooth' });
      const c = document.getElementById('nnv-cur'), r = e.getBoundingClientRect();
      if (on && c) { c.style.left = (r.left + Math.min(r.width / 2, 60)) + 'px'; c.style.top = (r.top + r.height / 2) + 'px'; } }, { sel, on }).catch(() => {});
  }
  const descOf = (map, t) => { if (!map) return null; if (map[t]) return map[t]; const k = Object.keys(map).find((x) => norm(x) === norm(t) || t.includes(norm(x))); return k ? map[k] : null; };

  async function explain(s) {
    const dfields = s.doc_fields ? Object.fromEntries(s.doc_fields) : null;
    // الحقول
    const fs_ = await fieldsOf();
    if (fs_.length) {
      await v.say(`حقول الشاشة (${fs_.length}${fs_.length >= MAX_FIELDS ? '+' : ''}): نمر عليها بالترتيب`, 2200);
      for (const f of fs_) {
        await mark(`[data-nnv-f="${f.i}"]`, true);
        const d = descOf(s.fields, f.t) || descOf(dfields, f.t);
        await v.say(`<b>${f.t}</b>${f.req ? ' <small>(إلزامي)</small>' : ''}: ${d || f.kind}`);
        await mark(`[data-nnv-f="${f.i}"]`, false);
      }
    } else if (s.doc_fields) {
      for (const [n, d] of s.doc_fields.slice(0, MAX_FIELDS)) await v.say(`<b>${n}</b>: ${d}`);
    }
    // الأعمدة
    const cols = await columnsOf();
    if (cols.length) {
      await page.evaluate(() => { const t = document.querySelector('.a-IRR-table, .a-GV-table, table.nn-rpt, table.nn-td-table'); if (t) t.scrollIntoView({ block: 'center', behavior: 'smooth' }); });
      await v.say(`<b>الأعمدة</b>: ${cols.join('، ')}`, 4200);
      const link = page.locator('.a-IRR-table td a').first();
      if (await link.count()) {
        await link.evaluate((e) => { e.classList.add('nnv-hl'); }).catch(() => {});
        await v.say('النقر على رابط السطر يفتح السجل للعرض أو التعديل؛ وشريط البحث والتصفية والتصدير أعلى القائمة', 3600);
        await link.evaluate((e) => { e.classList.remove('nnv-hl'); }).catch(() => {});
      }
    }
    // الأزرار
    const bs = await buttonsOf();
    for (const b of bs) {
      await mark(`[data-nnv-b="${b.i}"]`, true);
      const d = descOf(s.buttons, b.t);
      await v.say(`زر <b>${b.t}</b>${d ? ': ' + d : b.hot ? ': الإجراء الرئيسي للشاشة' : ''}`, d ? undefined : 2400);
      await mark(`[data-nnv-b="${b.i}"]`, false);
    }
    // الخطوات والملاحظات والبدائل
    if (s.steps && s.steps.length) for (const [i, st] of s.steps.entries()) await v.say(`<b>الخطوة ${i + 1}</b>: ${st}`);
    for (const n of s.notes || []) await v.say(`<b>ملاحظة</b>: ${n}`);
    for (const a of s.alt || []) await v.say(`<b>بديل</b>: ${a}`);
    await page.evaluate(() => window.scrollTo({ top: 0, behavior: 'smooth' })).catch(() => {});
  }

  async function open(s) {
    if (s.app !== app) {
      if (!user) { app = s.app; } else { app = s.app; await v.switchApp(s.app); }
    }
    if (s.via) {
      await v.go(s.via.from, s.via.qs || '');
      const loc = s.via.click.startsWith('text=') ? page.locator(s.via.click).first() : page.locator(s.via.click).first();
      if (await loc.count()) await v.click(loc, 'نفتح سجلاً من القائمة');
    } else {
      await v.go(s.alias, s.qs || '');
    }
    for (const a of s.actions || []) {
      if (a.eval) { await Promise.all([page.waitForNavigation({ timeout: 6000 }).catch(() => {}), page.evaluate(a.eval).catch(() => {})]); }
      if (a.click) await page.locator(a.click).first().click({ timeout: 5000 }).catch(() => {});
      if (a.fill) await page.fill(a.fill, a.value).catch(() => {});
      if (a.select) await page.selectOption(a.select, a.value).catch(() => {});
      await v.wait(a.wait || 600);
    }
    await v.settle();
  }

  // ---------------------------------------------------------------- التسجيل
  await page.goto(`http://localhost:8090/ords/r/noonaplus/${first.app}/home`).catch(() => {}); await v.settle();
  await v.card(MOD.title, [MOD.subtitle, `جولة شاملة على كل الشاشات (${screens.length} شاشة) بشرح كل حقل وزر`],
    5500, `الفيديو المطول ${num || ''} · شرح تفصيلي بالعربية · نونا بلس`);
  for (const t of MOD.intro || []) { /* المقدمة تعرض بعد الدخول */ }
  const u0 = MOD.apps[first.app] || 'ADMIN';
  await loginAs(u0, first.app);
  for (const t of MOD.intro || []) await v.say(t, Math.min(9000, 2500 + strip(t).split(/\s+/).length * 300));

  let lastSec = -1, n = 0;
  for (const s of screens) {
    n++;
    try {
      const u = MOD.apps[s.app] || 'ADMIN';
      if (u !== user) await loginAs(u, s.app);
      if (s.si !== lastSec) {
        lastSec = s.si;
        await v.setStep(s.sec);
        await v.say(`<b>${s.sec}</b>`, 2200);
      }
      const title = s.title || (s.menu || '').split('←').pop().trim() || s.alias;
      await v.setStep(`${n}/${screens.length} · ${title}`);
      if (scenes[s.shot]) {
        log(`${n} ${s.shot}: مشهد إدخال حقيقي`);
        await scenes[s.shot](v, s, { open, explain });
        continue;
      }
      await open(s);
      await v.say(`<b>${title}</b>${s.menu ? ' <small>(' + s.menu + ')</small>' : ''}`, 2600);
      await v.say(s.purpose);
      await explain(s);
      log(`${n} ${s.shot} ok`);
    } catch (e) {
      log(`${n} ${s.shot} ERR ${e.message.split('\n')[0]}`);
    }
  }
  await v.setStep('');
  await v.card('انتهى شرح ' + MOD.title.split(':')[0], ['كل شاشات الموديول بحقولها وأزرارها وخطوات إدخالها',
    'الكتالوج المكتوب بالصور: apex/_manual/out'], 5000, 'نونا بلس');
  log('saved ' + await v.done());
})().catch((e) => { console.error('ERR', e.message); process.exit(1); });
