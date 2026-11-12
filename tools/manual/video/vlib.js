/* NOONA PLUS | تسجيل فيديو الشرح: إدخال حقيقي في الشاشات مع شرح عربي على الشاشة ومؤشر فأرة وإبراز الحقل الحالي.
   const v = await video('noona_platform', outDir, 'name'); await v.login(user, pwd); await v.say('...'); await v.type('#P4_CODE', 'X'); ... await v.done(); */
'use strict';
const fs = require('fs');
const path = require('path');
const { chromium } = require(process.env.PW_PATH);

const W = 1280, H = 720;
const CSS = `
#nnv-cap{position:fixed;inset-inline:0;bottom:18px;margin:0 auto;width:fit-content;max-width:86%;z-index:2147483646;
 background:rgba(11,59,110,.94);color:#fff;font:600 21px/1.6 Cairo,Tahoma,sans-serif;padding:10px 22px;border-radius:12px;
 box-shadow:0 6px 24px rgba(0,0,0,.35);direction:rtl;text-align:center;transition:opacity .25s}
#nnv-cap b{color:#ffd166}
#nnv-step{position:fixed;top:10px;left:50%;transform:translateX(-50%);z-index:2147483646;background:#f59e0b;color:#111;font:700 15px Cairo,Tahoma;
 padding:4px 14px;border-radius:20px;direction:rtl}
#nnv-cur{position:fixed;width:22px;height:22px;border-radius:50%;background:rgba(245,158,11,.55);border:2px solid #b45309;
 z-index:2147483647;pointer-events:none;transform:translate(-50%,-50%);transition:left .45s ease,top .45s ease}
#nnv-cur.clk{animation:nnvclk .35s}
@keyframes nnvclk{0%{box-shadow:0 0 0 0 rgba(245,158,11,.8)}100%{box-shadow:0 0 0 18px rgba(245,158,11,0)}}
.nnv-hl{outline:3px solid #f59e0b!important;outline-offset:2px;border-radius:4px}
#nnv-card{position:fixed;inset:0;z-index:2147483645;background:linear-gradient(135deg,#0b3b6e,#0067c0);color:#fff;display:flex;
 flex-direction:column;align-items:center;justify-content:center;font-family:Cairo,Tahoma;direction:rtl;text-align:center;padding:40px}
#nnv-card h1{font-size:44px;margin:0 0 10px} #nnv-card p{font-size:22px;margin:4px 0;opacity:.95} #nnv-card small{font-size:16px;opacity:.8;margin-top:22px}`;

module.exports = async function video(app, outDir, name, opts = {}) {
  fs.mkdirSync(outDir, { recursive: true });
  const browser = await chromium.launch();
  const ctx = await browser.newContext({ viewport: { width: W, height: H }, recordVideo: { dir: outDir, size: { width: W, height: H } } });
  const page = await ctx.newPage();
  page.on('dialog', (d) => d.accept());
  const port = opts.port || process.env.NOONA_PORT || 8090;
  let base = `http://localhost:${port}/ords/r/noonaplus/${app}`;
  let sess = null;
  let step = '';
  let cap = '';
  let cur = { x: W / 2, y: H / 2 };
  const wait = (ms) => page.waitForTimeout(ms);
  const settle = async () => { await page.waitForLoadState('networkidle').catch(() => {}); await wait(500); await ensure(); };

  async function ensure() {
    await page.evaluate(({ css, step, cap, cur }) => {
      if (!document.getElementById('nnv-style')) {
        const s = document.createElement('style'); s.id = 'nnv-style'; s.textContent = css; document.head.appendChild(s);
      }
      let c = document.getElementById('nnv-cur');
      if (!c) { c = document.createElement('div'); c.id = 'nnv-cur'; document.body.appendChild(c); c.style.left = cur.x + 'px'; c.style.top = cur.y + 'px'; }
      let st = document.getElementById('nnv-step');
      if (step) { if (!st) { st = document.createElement('div'); st.id = 'nnv-step'; document.body.appendChild(st); } st.textContent = step; }
      else if (st) st.remove();
      let cp = document.getElementById('nnv-cap');
      if (cap) { if (!cp) { cp = document.createElement('div'); cp.id = 'nnv-cap'; document.body.appendChild(cp); } cp.innerHTML = cap; }
      else if (cp) cp.remove();
    }, { css: CSS, step, cap, cur }).catch(() => {});
  }
  // الشرح: يبقى ظاهراً حتى التالي؛ المدة تقديرية للقراءة
  let shotN = 0;
  async function say(html, ms) {
    cap = html; await ensure();
    // تشخيص: VDBG=<مجلد> يحفظ لقطة عند كل شرح لمعرفة موضع التوقف
    if (process.env.VDBG) await page.screenshot({ path: path.join(process.env.VDBG, String(++shotN).padStart(3, '0') + '.png') }).catch(() => {});
    const words = html.replace(/<[^>]+>/g, '').split(/\s+/).length;
    await wait(Math.round((ms || Math.min(7000, 1400 + words * 330)) * (+process.env.VSPEED || 1)));
  }
  async function setStep(t) { step = t; await ensure(); }
  async function moveTo(loc) {
    await loc.scrollIntoViewIfNeeded().catch(() => {});
    const b = await loc.boundingBox();
    if (!b) return;
    cur = { x: b.x + b.width / 2, y: b.y + b.height / 2 };
    await page.evaluate((c) => { const e = document.getElementById('nnv-cur'); if (e) { e.style.left = c.x + 'px'; e.style.top = c.y + 'px'; } }, cur);
    await wait(500);
  }
  async function hl(loc, on) {
    await loc.evaluate((e, on) => { (e.closest('.t-Form-fieldContainer') || e).classList.toggle('nnv-hl', on); }, on).catch(() => {});
  }
  async function pulse() {
    await page.evaluate(() => { const e = document.getElementById('nnv-cur'); if (e) { e.classList.remove('clk'); void e.offsetWidth; e.classList.add('clk'); } });
  }
  const L = (sel) => (typeof sel === 'string' ? page.locator(sel).first() : sel);
  async function type(sel, value, note) {
    const loc = L(sel);
    if (note) { cap = note; await ensure(); }
    await moveTo(loc); await hl(loc, true); await pulse();
    await loc.click(); await loc.fill('');
    await page.keyboard.type(String(value), { delay: opts.typeDelay || 45 });
    await wait(350); await hl(loc, false);
  }
  async function select(sel, label, note) {
    const loc = L(sel);
    if (note) { cap = note; await ensure(); }
    await moveTo(loc); await hl(loc, true); await pulse();
    const opt = await loc.evaluate((s, lab) => { const ex = lab.charAt(0) === '='; const o = [...s.options].find((x) => (ex ? x.textContent.trim() === lab.slice(1) : x.textContent.trim().includes(lab))); return o ? o.value : null; }, label);
    if (opt !== null) await loc.selectOption(opt);
    await wait(700); await hl(loc, false);
  }
  async function click(target, note, navigates) {
    const loc = typeof target === 'string' && !/^[#.\[]|^text=|^a|^button/.test(target)
      ? page.getByRole('button', { name: target, exact: true }).or(page.getByRole('link', { name: target, exact: true })).first() : L(target);
    if (note) { cap = note; await ensure(); }
    await moveTo(loc); await hl(loc, true); await pulse(); await wait(350);
    await loc.click();
    if (navigates !== false) await settle(); else await wait(800);
  }
  async function go(alias, qs = '') { await page.goto(`${base}/${alias.toLowerCase()}?session=${sess}${qs}`); await settle(); }
  async function login(user, pwd, note) {
    await page.goto(base + '/home'); await settle();
    if (note) await say(note);
    await type('#P9999_USERNAME', user);
    await type('#P9999_PASSWORD', pwd);
    await click(page.getByRole('button').filter({ hasText: /Sign In|تسجيل الدخول|دخول/ }).first());
    await page.waitForURL(/session=\d+/, { timeout: 20000 }).catch(() => {});
    await settle();
    sess = new URL(page.url()).searchParams.get('session');
    if (!page.url().includes(`/${app}/`)) { await page.goto(`${base}/home?session=${sess}`); await settle(); }
  }
  // الانتقال عبر عنصر في القائمة الجانبية (روابطه تحمل checksum)
  async function nav(text) {
    const href = await page.evaluate((t) => { try { apex.jQuery('#t_TreeNav').treeView('expandAll'); } catch (e) { /* القائمة مطوية */ }
      const a = [...document.querySelectorAll('#t_TreeNav a')].find((x) => x.textContent.trim() === t); return a ? a.href : null; }, text);
    // ERR_ABORTED يحدث إن كانت الصفحة السابقة ما زالت تعيد التوجيه: ننتظر ونعيد المحاولة مرة
    if (href) { await page.goto(href).catch(async () => { await settle(); await page.goto(href); }); await settle(); }
  }
  async function switchApp(newApp) { base = `http://localhost:${port}/ords/r/noonaplus/${newApp}`; await page.goto(`${base}/home?session=${sess}`); await settle(); }
  async function logout() { cap = ''; step = ''; await ctx.clearCookies(); }
  async function card(title, lines, ms = 4500, small = '') {
    await page.evaluate(({ css, title, lines, small }) => {
      if (!document.getElementById('nnv-style')) { const s = document.createElement('style'); s.id = 'nnv-style'; s.textContent = css; document.head.appendChild(s); }
      const c = document.createElement('div'); c.id = 'nnv-card';
      c.innerHTML = '<h1>' + title + '</h1>' + lines.map((l) => '<p>' + l + '</p>').join('') + (small ? '<small>' + small + '</small>' : '');
      document.body.appendChild(c);
    }, { css: CSS, title, lines, small });
    await wait(ms);
    await page.evaluate(() => { const c = document.getElementById('nnv-card'); if (c) c.remove(); });
  }
  // قراءة رسالة النتيجة؛ تعاد المحاولة إن كانت الصفحة ما زالت تنتقل بعد الحفظ
  async function alerts() {
    for (let i = 0; i < 3; i++) {
      try { return ((await page.locator('#t_Alert_Notification, #t_Alert_Success').allInnerTexts()).join(' | ')).replace(/\s+/g, ' ').slice(0, 200); }
      catch (e) { await page.waitForLoadState('networkidle').catch(() => {}); await wait(800); }
    }
    await ensure();
    return '';
  }
  async function done() {
    const vp = await page.video().path();
    await ctx.close(); await browser.close();
    const dst = path.join(outDir, name + '.webm');
    fs.renameSync(vp, dst);
    return dst;
  }
  return { page, say, setStep, type, select, click, go, nav, login, switchApp, logout, card, alerts, wait, settle, done, get sess() { return sess; } };
};
