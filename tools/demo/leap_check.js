/* NOONA PLUS | فحص مسار عرض المعرض (LEAP): ينفذ كل نقرة في المسار الثابت ويحفظ لقطة لكل خطوة ويبلغ عن أي خطأ.
   يشغل بعد db/demo/demo_leap_prep.sql وقبل كل عرض:
   PW_PATH=playwright NOONA_PORT=8091 DST_USER=DST_ADMIN DST_PWD=... RYD_USER=RYD_ADMIN RYD_PWD=... node tools/demo/leap_check.js <مجلد اللقطات>
   VIDEO=1 يسجل المسار فيديو (webm) في المجلد نفسه. الخروج بغير صفر عند أي خطوة فاشلة. */
'use strict';
const fs = require('fs');
const path = require('path');
const { chromium } = require(process.env.PW_PATH || 'playwright');
const out = process.argv[2] || 'leap_shots';
const port = process.env.NOONA_PORT || 8080;
const root = `${process.env.NOONA_URL || 'http://localhost:' + port}/ords/r/noonaplus`;
const MOBILE = { width: 390, height: 844 }, DESK = { width: 1366, height: 768 };
let n = 0, bad = 0;

(async () => {
  fs.mkdirSync(out, { recursive: true });
  const browser = await chromium.launch();
  const ctx = await browser.newContext({ viewport: DESK, locale: 'ar-SA', permissions: ['geolocation'], geolocation: { latitude: 24.7136, longitude: 46.6753 },
    ...(process.env.VIDEO ? { recordVideo: { dir: out, size: DESK } } : {}) });
  const page = await ctx.newPage();
  page.on('dialog', (d) => d.accept());
  let sess = null;
  const settle = async () => { await page.waitForLoadState('networkidle').catch(() => {}); await page.waitForTimeout(700); };
  const errOf = async () => page.evaluate(() => {
    const t = [...document.querySelectorAll('.t-Alert--danger .t-Alert-body, #t_Alert_Notification .t-Alert-body')].map((e) => e.innerText.trim()).join(' | ');
    const m = (document.body ? document.body.innerText : '').match(/(ORA-\d{5}[^\n]{0,100}|حدث خطأ[^\n]{0,80})/);
    return t || (m ? m[0] : '');
  });
  const okMsg = async () => (await page.locator('#t_Alert_Success').allInnerTexts()).join(' ').replace(/\s+/g, ' ').slice(0, 110);
  async function step(title, fn) {
    n++;
    let err = '';
    try { await fn(); await settle(); err = await errOf(); } catch (e) { err = 'EXC ' + e.message.split('\n')[0].slice(0, 140); }
    await page.screenshot({ path: path.join(out, String(n).padStart(2, '0') + '.png') }).catch(() => {});
    if (err) bad++;
    console.log(`${err ? 'FAIL' : 'ok  '} ${String(n).padStart(2, '0')} ${title}${err ? ' -> ' + err.replace(/\s+/g, ' ') : ''}`);
  }
  const login = async (u, p) => {
    await ctx.clearCookies();
    await page.goto(`${root}/noona_master/home`); await settle();
    await page.fill('#P9999_USERNAME', u); await page.fill('#P9999_PASSWORD', p);
    await page.getByRole('button').filter({ hasText: /Sign In|تسجيل الدخول|دخول/ }).first().click();
    await page.waitForURL(/session=\d+/, { timeout: 20000 }); await settle();
    sess = new URL(page.url()).searchParams.get('session');
  };
  const go = (app, alias, qs = '') => page.goto(`${root}/${app}/${alias}?session=${sess}${qs}`);
  const press = (name) => page.getByRole('button', { name, exact: true }).click();

  // ===================================================== 1) المندوب على الجوال
  await step('دخول مسؤول شركة التوزيع والأنظمة المشترك فيها', () => login(process.env.DST_USER, process.env.DST_PWD));
  await page.setViewportSize(MOBILE);
  await step('المندوب: خطة اليوم على الجوال', () => go('noona_dst', 'home'));
  await step('فتح زيارة أول محل في خط السير', async () => { await page.locator('.nn-dst-stop .nn-dst-go').first().click(); });
  await step('تسجيل الحضور بالموقع (GPS)', async () => { await page.click('.nn-dst-checkin'); await page.waitForTimeout(2500); });
  await step('اختيار الأصناف من مخزون السيارة', async () => {
    const plus = page.locator('[data-item="P2_LINES"] .nn-dst-item:visible .nn-dst-plus');
    await plus.first().click(); await plus.first().click(); if (await plus.count() > 1) await plus.nth(1).click();
  });
  await step('البيع نقداً وإصدار الفاتورة', async () => { await page.click('.nn-dst-fill'); await press('إصدار الفاتورة'); });
  console.log('        ' + await okMsg());
  await step('تحصيل بتحويل بنكي برقم الإشعار', async () => {
    await page.selectOption('#P2_CM', 'BANK_TRANSFER'); await page.waitForTimeout(300);
    await page.fill('#P2_CAMT', '50'); await page.fill('#P2_CREF', 'LEAP' + String(Date.now()).slice(-7)); await page.fill('#P2_CBANK', 'مصرف الراجحي');
    await press('تسجيل التحصيل');
  });
  console.log('        ' + await okMsg());
  await step('إنهاء الزيارة', () => press('إنهاء الزيارة والمغادرة'));
  await step('معاينة تسوية نهاية اليوم', () => go('noona_dst', 'end-of-day'));

  // ===================================================== 2) المحاسب والمدير
  await page.setViewportSize(DESK);
  await step('المحاسب: التحصيلات بانتظار التأكيد', () => go('noona_dst', 'collections'));
  await step('تأكيد التحويل (يرحل للبنك ويخفض رصيد المحل)', async () => {
    await page.locator('.a-IRR-table tr', { hasText: 'LEAP' }).first().locator('a').first().click(); await settle(); await press('تأكيد وترحيل');
  });
  console.log('        ' + await okMsg());
  await step('الفاتورة في المبيعات', () => go('noona_pos', 'invoices'));
  await step('القيد المحاسبي التلقائي (يومية القيود)', () => go('noona_fin', 'journal-register'));
  await step('ميزان المراجعة', () => go('noona_fin', 'trial-balance'));
  await step('خريطة المحلات', async () => { await go('noona_dst', 'map'); await page.waitForTimeout(2500); });
  await step('أداء المندوبين', () => go('noona_dst', 'performance'));
  await step('لوحة المدير (مركز الإدارة)', () => go('noona_hub', 'home'));
  await step('التنبؤ النقدي 90 يوماً', () => go('noona_hub', 'forecast'));
  await step('تنبيهات الإنذار المبكر', () => go('noona_hub', 'alerts'));
  await step('التحليلات', () => go('noona_bi', 'analytics'));

  // ===================================================== 3) الشركة القابضة
  if (process.env.RYD_USER) {
    await step('دخول مسؤول المجموعة القابضة', () => login(process.env.RYD_USER, process.env.RYD_PWD));
    await step('مجموعات التجميع', () => go('noona_fin', 'consolidation-groups'));
    await step('القوائم المالية الموحدة', () => go('noona_fin', 'consolidated'));
  }
  if (process.env.VIDEO) { const v = await page.video().path(); await ctx.close(); fs.renameSync(v, path.join(out, 'leap_demo.webm')); }
  await browser.close();
  console.log(`LEAP ${bad ? 'FAILED' : 'READY'}: ${n} خطوة، ${bad} فشل`);
  process.exit(bad ? 1 : 0);
})().catch((e) => { console.error('FAIL', e.message); process.exit(1); });
