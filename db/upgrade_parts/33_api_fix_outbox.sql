PROMPT ========== أحداث سير العمل الداخلية في الصندوق الصادر ليست للموزع (إعادة ما علم خطأ)
BEGIN
  NOONA_CORE_PKG.begin_system;
  UPDATE api_outbox SET status_code = 'PENDING', attempts = 0, last_error = NULL
   WHERE status_code = 'DEAD' AND last_error = 'Destination not found'
     AND destination NOT LIKE 'WEBHOOK:%' AND destination NOT LIKE 'SMS:%' AND destination NOT LIKE 'WHATSAPP:%';
  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' internal outbox rows restored');
  NOONA_CORE_PKG.end_system;
  COMMIT;
END;
/
