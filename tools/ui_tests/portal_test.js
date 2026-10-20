// اختبار واجهة البوابة بمتصفح آلي (Playwright) على APEX فعلي عبر ORDS
// التشغيل: PW_PATH=<playwright module> SP=<output dir> node tools/ui_tests/portal_test.js
// يفترض: ORDS على localhost:8090، workspace noonaplus، مستخدمو APEX: NOONA و ADMIN بكلمات المرور أدناه (تطوير فقط)
const { chromium } = require(process.env.PW_PATH);
const SP = process.env.SP;
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1400, height: 1000 }, locale: 'ar' });
  const log = (m) => console.log(m);
  async function press(locator) { await locator.click(); await page.waitForTimeout(2500); await page.waitForLoadState('networkidle'); }
  const alertText = async () => ((await page.locator('#t_Alert_Notification, #t_Alert_Success, .t-Alert-body').allInnerTexts()).join(' ') || '').replace(/\s+/g, ' ').slice(0, 220);
  const base = 'http://localhost:8090/ords/r/noonaplus/noona_portal';
  async function login(user, pwd) {
    await page.goto(base + '/home');
    await page.fill('#P9999_USERNAME', user);
    await page.fill('#P9999_PASSWORD', pwd);
    await Promise.all([page.waitForLoadState('networkidle'), page.click('button[id$="LOGIN"], #B' + '')]).catch(()=>{});
  }
  // 1) non-NOONA account
  await page.goto(base + '/home');
  await page.fill('#P9999_USERNAME', 'NOONA'); await page.fill('#P9999_PASSWORD', 'Noona#2026x');
  await press(page.getByRole('button').filter({ hasText: /Sign In|تسجيل/ }).first());
  log('NOONA login msg: ' + await alertText());
  await page.screenshot({ path: SP + '/shots/1_login_rejected.png' });
  // 2) ADMIN
  await page.fill('#P9999_USERNAME', 'ADMIN'); await page.fill('#P9999_PASSWORD', 'Admin#2026x');
  await press(page.getByRole('button').filter({ hasText: /Sign In|تسجيل/ }).first());
  log('After login URL: ' + page.url());
  log('Errors on home: ' + (await page.locator('.t-Alert--danger, .a-Notification--error, #t_Alert_Notification').count()));
  await page.screenshot({ path: SP + '/shots/2_home.png', fullPage: true });
  const regions = await page.locator('.t-Region-title').allInnerTexts(); log('Regions: ' + regions.join(' | '));
  const taskLinks = page.locator('a[href*="p2_task_id"], a[href*="P2_TASK_ID"]');
  log('Task links: ' + await taskLinks.count());
  // 3) open first task, reject without comment
  await press(taskLinks.first());
  log('Task page URL: ' + page.url());
  await page.screenshot({ path: SP + '/shots/3_task.png', fullPage: true });
  await press(page.getByRole('button', { name: 'رفض' }));
  log('Reject w/o comment: ' + await alertText());
  await page.screenshot({ path: SP + '/shots/4_reject_needs_reason.png', fullPage: true });
  // 4) approve with comment
  await page.fill('#P2_COMMENTS', 'موافق - اختبار آلي');
  await press(page.getByRole('button', { name: 'اعتماد' }));
  log('After approve URL: ' + page.url());
  log('Success msg: ' + await alertText());
  log('Task links now: ' + await page.locator('a[href*="p2_task_id"], a[href*="P2_TASK_ID"]').count());
  await page.screenshot({ path: SP + '/shots/5_after_approve.png', fullPage: true });
  // 5) switch company page
  await page.goto(page.url().replace('/home?', '/company?'));
  await page.waitForLoadState('networkidle');
  log('Company page options: ' + (await page.locator('#P3_COMPANY_ID option').allInnerTexts()).join(' | '));
  await page.screenshot({ path: SP + '/shots/6_company.png', fullPage: true });
  await browser.close();
})().catch(e => { console.error('SCRIPT ERROR', e.message); process.exit(1); });
