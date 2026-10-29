/* تقرير HTML عربي لنتائج الفحص: ملخص، المشكلات حسب النوع مع التوصية، التطبيقات، وتفاصيل كل شاشة. */
'use strict';
const esc = (s) => String(s == null ? '' : s).replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const SEV = { critical: ['حرجة', 4], serious: ['عالية', 3], moderate: ['متوسطة', 2], minor: ['منخفضة', 1] };
// شرح كل نوع وتوصيته (أنواع axe غير المذكورة تأخذ نص axe)
const KIND = {
  error: ['خطأ عند فتح الشاشة', 'إصلاح الخطأ في عملية تحميل الصفحة'],
  access: ['الشاشة لا تفتح للمستخدم', 'مراجعة الصلاحية أو الرابط'],
  js: ['أخطاء JavaScript أو طلبات فاشلة', 'تتبع الخطأ في وحدة JS أو العملية التي أرجعت الخطأ'],
  english: ['نصوص إنجليزية في واجهة عربية', 'ترجمة التسمية أو جعلها «عربي (English)» للمصطلح الفني'],
  'mobile-overflow': ['تمرير أفقي على الجوال', 'جعل العنصر العريض قابلاً للالتفاف أو داخل حاوية تمرير خاصة به'],
  'mobile-touch': ['أهداف لمس صغيرة على الجوال', 'حد أدنى 24×24 (ويفضل 44×44) للأزرار والروابط'],
  slow: ['تحميل بطيء', 'فهرسة الاستعلام أو تقسيم المنطقة أو التحميل الكسول'],
  hot: ['أكثر من زر رئيسي', 'زر رئيسي واحد لكل منطقة عمل حتى يتضح الإجراء الأهم'],
  'a11y:color-contrast': ['تباين ألوان ضعيف', 'تباين 4.5:1 للنص العادي و3:1 للكبير'],
  'a11y:label': ['حقول بلا تسمية', 'ربط كل حقل بتسمية أو aria-label'],
  'a11y:button-name': ['أزرار بلا اسم', 'نص للزر أو aria-label (خاصة أزرار الأيقونات)'],
  'a11y:link-name': ['روابط بلا اسم', 'نص للرابط أو aria-label'],
  'a11y:select-name': ['قوائم منسدلة بلا تسمية', 'ربط القائمة بتسمية'],
  'a11y:image-alt': ['صور بلا نص بديل', 'إضافة alt'],
  'a11y:empty-table-header': ['رؤوس جداول فارغة', 'نص لرأس العمود أو إخفاؤه للقارئ'],
  'a11y:aria-allowed-attr': ['خصائص ARIA غير صحيحة', 'تصحيح الخاصية حسب الدور'],
  'a11y:duplicate-id': ['معرفات مكررة', 'معرف فريد لكل عنصر'],
  'a11y:nested-interactive': ['عناصر تفاعلية متداخلة', 'عدم وضع زر داخل رابط أو العكس'],
  'a11y:list': ['قوائم بتركيب غير صحيح', 'عناصر li مباشرة داخل ul/ol'],
  'a11y:listitem': ['عناصر قائمة خارج قائمة', 'وضع li داخل ul/ol'],
  'a11y:scrollable-region-focusable': ['منطقة تمرير لا تصلها لوحة المفاتيح', 'tabindex=0 للحاوية القابلة للتمرير'],
  'a11y:td-headers-attr': ['خلايا جدول بمراجع رؤوس خاطئة', 'تصحيح headers'],
  'a11y:th-has-data-cells': ['رأس عمود بلا بيانات', 'مراجعة تركيب الجدول'],
  'a11y:frame-title': ['إطار بلا عنوان', 'title للإطار'],
  'a11y:html-has-lang': ['الصفحة بلا لغة', 'lang="ar"'],
  'a11y:document-title': ['الصفحة بلا عنوان', 'عنوان الصفحة'],
  'a11y:aria-required-children': ['دور ARIA ينقصه عناصر', 'تصحيح التركيب'],
  'a11y:aria-input-field-name': ['حقل ARIA بلا اسم', 'aria-label'],
};
const kname = (k, msg) => (KIND[k] ? KIND[k][0] : msg.replace(/\s*\(\d+\)$/, ''));

module.exports = function report(results) {
  const all = results.flatMap((r) => r.issues.map((i) => ({ ...i, r })));
  const byKind = {};
  all.forEach((i) => { const g = byKind[i.k] || (byKind[i.k] = { k: i.k, sev: i.sev, name: kname(i.k, i.msg), rec: (KIND[i.k] || [])[1] || i.msg, screens: new Set(), n: 0 });
    g.screens.add(i.r.app + i.r.label); g.n++; if ((SEV[i.sev] || [0, 0])[1] > (SEV[g.sev] || [0, 0])[1]) g.sev = i.sev; });
  const kinds = Object.values(byKind).sort((a, b) => (SEV[b.sev] || [0, 0])[1] - (SEV[a.sev] || [0, 0])[1] || b.screens.size - a.screens.size);
  const cnt = (s) => all.filter((i) => i.sev === s).length;
  const withIssues = results.filter((r) => r.issues.length).length;
  const avg = results.length ? results.reduce((a, r) => a + (r.ms || 0), 0) / results.length / 1000 : 0;
  // درجة الشاشة: 100 ناقص أوزان المشكلات
  const score = (r) => Math.max(0, 100 - r.issues.reduce((a, i) => a + [0, 2, 5, 10, 20][(SEV[i.sev] || [0, 1])[1]], 0));
  const apps = {};
  results.forEach((r) => { const a = apps[r.app] || (apps[r.app] = { name: r.appName, n: 0, bad: 0, s: 0, crit: 0 }); a.n++; a.s += score(r);
    if (r.issues.length) a.bad++; a.crit += r.issues.filter((i) => i.sev === 'critical' || i.sev === 'serious').length; });
  const total = results.length ? Math.round(results.reduce((a, r) => a + score(r), 0) / results.length) : 0;
  const pill = (s) => `<span class="sev s-${esc(s)}">${esc((SEV[s] || [s])[0])}</span>`;

  return `<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>تقرير تجربة المستخدم</title><style>
:root{--bg:#f4f6fa;--card:#fff;--ink:#16202c;--mut:#5b6675;--line:#e3e7ee;--pri:#0b5cad;--crit:#b3261e;--ser:#c2410c;--mod:#a16207;--min:#4b5563;--ok:#15803d}
@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){--bg:#0f141b;--card:#171e27;--ink:#e6ebf2;--mut:#9aa6b5;--line:#2a3441;--pri:#5aa2f0;--crit:#f2867d;--ser:#f59e5b;--mod:#e7c35a;--min:#a3acb9;--ok:#5fd38b}}
:root[data-theme="dark"]{--bg:#0f141b;--card:#171e27;--ink:#e6ebf2;--mut:#9aa6b5;--line:#2a3441;--pri:#5aa2f0;--crit:#f2867d;--ser:#f59e5b;--mod:#e7c35a;--min:#a3acb9;--ok:#5fd38b}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font:15px/1.6 "Segoe UI",Tahoma,"Noto Sans Arabic",sans-serif}
main{max-width:1180px;margin:0 auto;padding:24px 16px 60px}h1{font-size:26px;margin:0 0 4px}h2{font-size:19px;margin:34px 0 12px}
.sub{color:var(--mut);margin:0 0 20px}.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:12px}
.card{background:var(--card);border:1px solid var(--line);border-radius:12px;padding:14px 16px}.card b{display:block;font-size:26px}.card span{color:var(--mut);font-size:13px}
table{width:100%;border-collapse:collapse;background:var(--card);border:1px solid var(--line);border-radius:12px;overflow:hidden}
th,td{padding:9px 10px;border-bottom:1px solid var(--line);text-align:right;vertical-align:top}th{font-size:13px;color:var(--mut);font-weight:600;background:color-mix(in srgb,var(--line) 35%,var(--card))}
.wrap{overflow-x:auto}.sev{display:inline-block;padding:1px 8px;border-radius:20px;font-size:12px;font-weight:600;border:1px solid currentColor;white-space:nowrap}
.s-critical{color:var(--crit)}.s-serious{color:var(--ser)}.s-moderate{color:var(--mod)}.s-minor{color:var(--min)}
.bar{height:8px;border-radius:6px;background:var(--line);overflow:hidden;min-width:80px}.bar i{display:block;height:100%;background:var(--ok)}
details{background:var(--card);border:1px solid var(--line);border-radius:10px;margin:6px 0}summary{cursor:pointer;padding:9px 12px;display:flex;gap:10px;align-items:center;flex-wrap:wrap}
summary .t{flex:1;min-width:180px}.issue{padding:6px 14px;border-top:1px dashed var(--line);font-size:14px}.issue small{display:block;color:var(--mut);direction:ltr;text-align:left;word-break:break-word}
.score{font-weight:700}.mut{color:var(--mut)}code{font-size:12px}
</style></head><body><main>
<h1>تقرير تجربة المستخدم - نونا بلس</h1>
<p class="sub">فحص آلي لكل الشاشات: إمكانية الوصول (WCAG 2.1 AA)، العربية، الجوال، الأخطاء، الأداء · ${esc(new Date().toISOString().slice(0, 16).replace('T', ' '))}</p>
<div class="cards">
<div class="card"><b>${total}</b><span>الدرجة العامة من 100</span></div>
<div class="card"><b>${results.length}</b><span>شاشة فُحصت</span></div>
<div class="card"><b>${withIssues}</b><span>شاشة بها ملاحظات</span></div>
<div class="card"><b style="color:var(--crit)">${cnt('critical')}</b><span>ملاحظة حرجة</span></div>
<div class="card"><b style="color:var(--ser)">${cnt('serious')}</b><span>ملاحظة عالية</span></div>
<div class="card"><b>${avg.toFixed(1)} ث</b><span>متوسط زمن التحميل</span></div>
</div>
<h2>الملاحظات حسب النوع</h2>
<div class="wrap"><table><thead><tr><th>الملاحظة</th><th>الخطورة</th><th>عدد الشاشات</th><th>التوصية</th></tr></thead><tbody>
${kinds.map((g) => `<tr><td>${esc(g.name)}<br><code class="mut">${esc(g.k)}</code></td><td>${pill(g.sev)}</td><td>${g.screens.size}</td><td>${esc(g.rec)}</td></tr>`).join('')}
</tbody></table></div>
<h2>التطبيقات</h2>
<div class="wrap"><table><thead><tr><th>التطبيق</th><th>الشاشات</th><th>بها ملاحظات</th><th>حرجة/عالية</th><th>الدرجة</th></tr></thead><tbody>
${Object.values(apps).map((a) => { const s = Math.round(a.s / a.n); return `<tr><td>${esc(a.name)}</td><td>${a.n}</td><td>${a.bad}</td><td>${a.crit}</td>
<td><div style="display:flex;gap:8px;align-items:center"><span class="score">${s}</span><div class="bar" style="flex:1"><i style="width:${s}%"></i></div></div></td></tr>`; }).join('')}
</tbody></table></div>
<h2>تفاصيل الشاشات</h2>
${results.filter((r) => r.issues.length).sort((a, b) => score(a) - score(b)).map((r) => `<details><summary><span class="score">${score(r)}</span>
<span class="t"><b>${esc(r.appName)}</b> ← ${esc(r.label)} <span class="mut">${esc(r.title && r.title !== r.label ? '(' + r.title + ')' : '')}</span></span>
<span class="mut">${(r.ms / 1000).toFixed(1)} ث</span></summary>
${r.issues.sort((a, b) => (SEV[b.sev] || [0, 0])[1] - (SEV[a.sev] || [0, 0])[1]).map((i) => `<div class="issue">${pill(i.sev)} ${esc(i.msg)}${i.detail ? `<small>${esc(i.detail)}</small>` : ''}</div>`).join('')}
<div class="issue mut"><small>${esc(r.url)}</small></div></details>`).join('')}
<p class="mut">الشاشات بلا ملاحظات: ${results.length - withIssues}. الفحص الآلي يكشف ما يمكن قياسه؛ وضوح المهام وسهولتها تقاس مع مستخدمين حقيقيين.</p>
</main></body></html>`;
};
