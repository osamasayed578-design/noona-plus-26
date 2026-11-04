// NOONA PLUS 26 | خادم تجريبي متوافق مع OpenAI Chat Completions لاختبار المساعد بلا مفتاح حقيقي
// يختار أداة حسب كلمات السؤال ثم يلخص نتيجتها؛ يسجل كل طلب في requests.log للتحقق من التعليمات والأدوات المرسلة
// التشغيل: node tools/ai_mock/server.js [port]   ثم خدمة APEX من نوع GENERIC_OPENAI عنوانها http://<host>:<port>/v1
const http = require('http');
const fs = require('fs');
const path = require('path');
const PORT = +process.argv[2] || 8099;
const LOG = path.join(__dirname, 'requests.log');
const METRICS = [[/إيراد/, 'REVENUE'], [/مصروف|تكاليف/, 'EXPENSES'], [/ربح/, 'NET_PROFIT'], [/نقد|صندوق|بنك/, 'CASH_BALANCE'],
  [/نقاط البيع|كاشير/, 'POS_SALES'], [/مبيعات|فواتير/, 'SALES_INVOICED'], [/مشتريات/, 'PURCHASES'], [/مخزون/, 'INVENTORY_VALUE'],
  [/رواتب/, 'PAYROLL_COST'], [/إنتاج|تصنيع/, 'PRODUCTION_QTY'], [/زيار|مرضى/, 'HIS_VISITS'], [/سيار|إصلاح/, 'AUT_JOBS']];
function pickMetric(t) { for (const [re, m] of METRICS) if (re.test(t)) return m; return 'REVENUE'; }
function text(c) { return typeof c === 'string' ? c : Array.isArray(c) ? c.map((x) => x.text || '').join(' ') : ''; }
function reply(res, msg, finish) {
  const body = { id: 'mock-' + Date.now(), object: 'chat.completion', created: Math.floor(Date.now() / 1000), model: 'noona-mock',
    choices: [{ index: 0, message: msg, finish_reason: finish }], usage: { prompt_tokens: 120, completion_tokens: 40, total_tokens: 160 } };
  res.writeHead(200, { 'Content-Type': 'application/json' }); res.end(JSON.stringify(body));
}
http.createServer((req, res) => {
  let b = '';
  req.on('data', (c) => { b += c; });
  req.on('end', () => {
    fs.appendFileSync(LOG, new Date().toISOString() + ' ' + req.method + ' ' + req.url + ' ' + b + '\n');
    let r; try { r = JSON.parse(b || '{}'); } catch (e) { res.writeHead(400); res.end('{}'); return; }
    const msgs = r.messages || [];
    const last = msgs[msgs.length - 1] || {};
    const tools = (r.tools || []).map((t) => (t.function || t).name);
    if (last.role === 'tool') {
      const users = msgs.filter((m) => m.role === 'user');
      const q = text((users[users.length - 1] || {}).content);
      reply(res, { role: 'assistant', content: 'بحسب بيانات النظام (' + q.slice(0, 60) + '): ' + text(last.content).slice(0, 600) }, 'stop');
      return;
    }
    const q = text(last.content);
    let call = null;
    if (tools.length) {
      if (/تنبؤ|توقع|القادم/.test(q) && tools.includes('get_forecast')) call = ['get_forecast', { metric: pickMetric(q), periods: 3 }];
      else if (/العام الماضي|السنة الماضية|السنوات|بين السنوات/.test(q) && tools.includes('get_year_comparison')) call = ['get_year_comparison', { metric: pickMetric(q), years: 3 }];
      else if (/غير معتاد|تنبيه|شاذ/.test(q) && tools.includes('get_anomalies')) call = ['get_anomalies', {}];
      else if (/الصفحة|هذه الشاشة/.test(q) && tools.includes('get_page_context')) call = ['get_page_context', {}];
      else if (/مؤشرات|ماذا تعرف/.test(q) && tools.includes('list_metrics')) call = ['list_metrics', {}];
      else if (/شهري|سلسلة|كل شهر/.test(q) && tools.includes('get_series')) call = ['get_series', { metric: pickMetric(q), grain: 'MONTH', months: 6 }];
      else if (tools.includes('get_kpi')) call = ['get_kpi', { metric: pickMetric(q), period: 'THIS_MONTH' }];
    }
    if (call) {
      reply(res, { role: 'assistant', content: null, tool_calls: [{ id: 'call_' + Date.now(), type: 'function',
        function: { name: call[0], arguments: JSON.stringify(call[1]) } }] }, 'tool_calls');
      return;
    }
    reply(res, { role: 'assistant', content: 'مرحباً، أنا مساعد نونا التجريبي. سؤالك: ' + q.slice(0, 200) }, 'stop');
  });
}).listen(PORT, '0.0.0.0', () => console.log('NOONA AI mock on ' + PORT));
