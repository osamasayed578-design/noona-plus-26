/* تجهيز خارج التسجيل لفيديو التصنيع: صنف خامة «فلتر زيت» بمخزون (فاتورة مشتريات آجلة)، ومنتج تام «طقم صيانة دورية».
   PW_PATH=... NOONA_VADMIN=... NOONA_VPWD=... node tools/manual/video/prep_mfg.js <outDir> */
'use strict';
const video = require('./vlib.js');
const ADMIN = process.env.NOONA_VADMIN, PWD = process.env.NOONA_VPWD;

(async () => {
  const v = await video('noona_scm', process.argv[2], 'prep_mfg');
  const p = v.page;
  await v.login(ADMIN, PWD);
  async function item(name, type, cat, price) {
    await v.nav('صنف جديد');
    await p.fill('[data-k="name"]', name);
    await p.locator('[data-k="type"]').selectOption({ label: type });
    await p.locator('[data-k="cat"]').selectOption({ label: cat });
    await p.click('.nn-it-gen'); await v.wait(500);
    await p.fill('[data-k="price"]', price);
    await p.click('.nn-it-save'); await p.waitForURL(/p11_id=\d+/, { timeout: 20000 }); await v.settle();
  }
  if (!process.env.PREP_SKIP_ITEMS) {
    await item('فلتر زيت أصلي', 'قطعة غيار', 'قطع غيار السيارات', '45');
    await item('طقم الصيانة الدورية', 'منتج تام مصنع', 'المنتجات التامة', '260');
  }
  await v.nav('فاتورة مشتريات جديدة');
  await p.locator('[data-k="sup"]').selectOption({ index: 0 });
  await p.fill('[data-k="supInv"]', 'GLF-7790');
  await p.locator('[data-k="wh"]').selectOption({ index: 1 });
  await p.fill('.nn-td-find', 'فلتر زيت أصلي'); await p.keyboard.press('Enter'); await v.wait(1500);
  const r = p.locator('.nn-td-table tbody tr').first();
  await r.locator('input').nth(0).fill('50'); await r.locator('input').nth(1).fill('20');
  await p.locator('.nn-doc-save.t-Button--hot').click(); await v.wait(3000); await v.settle();
  console.log('prep purchase: ' + p.url().split('?')[0] + ' ' + await v.alerts());
  await v.done();
})().catch((e) => { console.error('ERR', e.message); process.exit(1); });
