-- =============================================================================
-- NOONA PLUS ERP | سجل نقاط نهاية REST v1 (عامة على المنصة) - قابل لإعادة التشغيل
--   لكل نقطة: الطريقة والمسار والصلاحية المطلوبة من دور عميل API، ووجوب Idempotency-Key للعمليات المالية.
--   تعطيل نقطة: IS_ACTIVE = 'N' (ترجع 404 وتختفي من OpenAPI).
-- =============================================================================
SET DEFINE OFF
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO api_endpoint e
  USING (SELECT 'API' mdl, 'GET' m, '/ping' p, NULL perm, 'ping' h, 'N' idem FROM dual
         UNION ALL SELECT 'SAL', 'GET',  '/customers',              'AR_CUSTOMER.VIEW',  'customers', 'N' FROM dual
         UNION ALL SELECT 'SAL', 'GET',  '/customers/{id}',         'AR_CUSTOMER.VIEW',  'customers', 'N' FROM dual
         UNION ALL SELECT 'SAL', 'POST', '/customers',              'AR_CUSTOMER.CREATE', 'customers', 'N' FROM dual
         UNION ALL SELECT 'PUR', 'GET',  '/suppliers',              'AP_SUPPLIER.VIEW',  'suppliers', 'N' FROM dual
         UNION ALL SELECT 'PUR', 'GET',  '/suppliers/{id}',         'AP_SUPPLIER.VIEW',  'suppliers', 'N' FROM dual
         UNION ALL SELECT 'PUR', 'POST', '/suppliers',              'AP_SUPPLIER.CREATE', 'suppliers', 'N' FROM dual
         UNION ALL SELECT 'INV', 'GET',  '/items',                  'INV_ITEM.VIEW',     'items', 'N' FROM dual
         UNION ALL SELECT 'INV', 'GET',  '/items/{id}',             'INV_ITEM.VIEW',     'items', 'N' FROM dual
         UNION ALL SELECT 'INV', 'POST', '/items',                  'INV_ITEM.CREATE',   'items', 'N' FROM dual
         UNION ALL SELECT 'SAL', 'GET',  '/sales-invoices',         'SAL_INVOICE.VIEW',  'sales-invoices', 'N' FROM dual
         UNION ALL SELECT 'SAL', 'GET',  '/sales-invoices/{id}',    'SAL_INVOICE.VIEW',  'sales-invoices', 'N' FROM dual
         UNION ALL SELECT 'SAL', 'POST', '/sales-invoices',         'SAL_INVOICE.CREATE', 'sales-invoices', 'Y' FROM dual
         UNION ALL SELECT 'SAL', 'POST', '/receipts',               'AR_RECEIPT.CREATE', 'receipts', 'Y' FROM dual
         UNION ALL SELECT 'PUR', 'GET',  '/purchase-invoices',      'AP_INVOICE.VIEW',   'purchase-invoices', 'N' FROM dual
         UNION ALL SELECT 'PUR', 'POST', '/purchase-invoices',      'AP_INVOICE.CREATE', 'purchase-invoices', 'Y' FROM dual
         UNION ALL SELECT 'GL',  'GET',  '/accounts',               'GL_ACCOUNT.VIEW',   'accounts', 'N' FROM dual
         UNION ALL SELECT 'GL',  'GET',  '/trial-balance',          'GL_JOURNAL.VIEW',   'trial-balance', 'N' FROM dual
         UNION ALL SELECT 'RE',  'GET',  '/units',                  'RE_UNIT.VIEW',      'units', 'N' FROM dual
         UNION ALL SELECT 'SAL', 'POST', '/orders',                 'SAL_INVOICE.CREATE', 'orders', 'N' FROM dual
         UNION ALL SELECT 'API', 'GET',  '/webhooks',               'API_WEBHOOK_SUBSCRIPTION.VIEW',   'webhooks', 'N' FROM dual
         UNION ALL SELECT 'API', 'POST', '/webhooks',               'API_WEBHOOK_SUBSCRIPTION.CREATE', 'webhooks', 'N' FROM dual
         UNION ALL SELECT 'API', 'POST', '/webhooks/{id}',          'API_WEBHOOK_SUBSCRIPTION.UPDATE', 'webhooks', 'N' FROM dual
         UNION ALL SELECT 'API', 'DELETE', '/webhooks/{id}',        'API_WEBHOOK_SUBSCRIPTION.UPDATE', 'webhooks', 'N' FROM dual) x
     ON (e.api_version = 'v1' AND e.http_method = x.m AND e.path_template = x.p)
   WHEN MATCHED THEN UPDATE SET e.permission_code = x.perm, e.handler_api = x.h, e.requires_idempotency = x.idem, e.module_code = x.mdl
   WHEN NOT MATCHED THEN INSERT (module_code, api_version, http_method, path_template, permission_code, handler_api, requires_idempotency, is_active)
        VALUES (x.mdl, 'v1', x.m, x.p, x.perm, x.h, x.idem, 'Y');
  MERGE INTO api_integration i
  USING (SELECT 'SMS_GATEWAY' code, 'SMS' typ, 'بوابة الرسائل النصية' name_ar, 'SMS gateway' name_en FROM dual
         UNION ALL SELECT 'WHATSAPP_GATEWAY', 'WHATSAPP', 'واتساب للأعمال', 'WhatsApp Business' FROM dual) x
     ON (i.code = x.code)
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, provider_name, integration_type, direction, auth_method, handles_pii,
                                 idempotency_strategy, status_code)
        VALUES (NULL, x.code, x.name_ar, x.name_en, 'Generic REST', x.typ, 'OUTBOUND', 'API_KEY', 'Y', 'معرف الرسالة في الصندوق الصادر', 'ACTIVE');
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
