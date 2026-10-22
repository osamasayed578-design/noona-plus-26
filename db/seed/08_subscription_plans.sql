-- =============================================================================
-- NOONA PLUS ERP | باقات الاشتراك الأساسية (بيانات منصة) - قابل لإعادة التشغيل
--   تجربة 14 يوماً، شهري، ربع سنوي، نصف سنوي، سنوي؛ فترة سماح 15 يوماً ثم قراءة فقط 30 يوماً ثم تعليق
-- =============================================================================
DECLARE
  l_ed NUMBER;
  l_pl NUMBER;
BEGIN
  NOONA_CORE_PKG.begin_system;
  SELECT MIN(id) KEEP (DENSE_RANK FIRST ORDER BY DECODE(segment_code, 'BUSINESS', 0, 'STARTER', 1, 2), id) INTO l_ed FROM plt_edition;
  IF l_ed IS NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'لا توجد إصدارات تجارية في كتالوج المنصة (PLT_EDITION)');
  END IF;
  FOR r IN (SELECT 'TRIAL' c, 'تجربة مجانية 14 يوماً' n, 'Free trial (14 days)' e, 'ONE_TIME' cy, 14 td FROM dual
            UNION ALL SELECT 'MONTHLY', 'اشتراك شهري', 'Monthly', 'MONTHLY', NULL FROM dual
            UNION ALL SELECT 'QUARTERLY', 'اشتراك ربع سنوي', 'Quarterly', 'QUARTERLY', NULL FROM dual
            UNION ALL SELECT 'SEMI_ANNUAL', 'اشتراك نصف سنوي', 'Semi-annual', 'SEMI_ANNUAL', NULL FROM dual
            UNION ALL SELECT 'ANNUAL', 'اشتراك سنوي', 'Annual', 'ANNUAL', NULL FROM dual) LOOP
    SELECT MIN(id) INTO l_pl FROM plt_plan WHERE code = r.c;
    IF l_pl IS NULL THEN
      INSERT INTO plt_plan (code, name_ar, name_en, edition_id, billing_cycle, is_active, created_by)
      VALUES (r.c, r.n, r.e, l_ed, r.cy, 'Y', 'SYSTEM')
      RETURNING id INTO l_pl;
    END IF;
    INSERT INTO plt_plan_version (plan_id, version_no, trial_days, grace_days, read_only_days, is_locked, effective_from, status_code, created_by)
    SELECT l_pl, 1, r.td, CASE WHEN r.td IS NULL THEN 15 ELSE 0 END, 30, 'N', DATE '2020-01-01', 'PUBLISHED', 'SYSTEM' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM plt_plan_version WHERE plan_id = l_pl);
  END LOOP;
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
