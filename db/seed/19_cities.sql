-- =============================================================================
-- NOONA PLUS ERP | المدن الرئيسية لدول حزم التوطين (السعودية، الإمارات، البحرين، عُمان، قطر، الكويت، مصر، السودان)
--   عامة على المنصة؛ قابلة لإعادة التشغيل (MERGE بالدولة والرمز). مدن إضافية من البيانات المرجعية.
-- =============================================================================
SET DEFINE OFF
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO ref_city t
  USING (SELECT 'SA' c, 'RUH' k, 'الرياض' a, 'Riyadh' e FROM dual
         UNION ALL SELECT 'SA' c, 'JED' k, 'جدة' a, 'Jeddah' e FROM dual
         UNION ALL SELECT 'SA' c, 'MKK' k, 'مكة المكرمة' a, 'Makkah' e FROM dual
         UNION ALL SELECT 'SA' c, 'MED' k, 'المدينة المنورة' a, 'Madinah' e FROM dual
         UNION ALL SELECT 'SA' c, 'DMM' k, 'الدمام' a, 'Dammam' e FROM dual
         UNION ALL SELECT 'SA' c, 'KHB' k, 'الخبر' a, 'Khobar' e FROM dual
         UNION ALL SELECT 'SA' c, 'DHA' k, 'الظهران' a, 'Dhahran' e FROM dual
         UNION ALL SELECT 'SA' c, 'TIF' k, 'الطائف' a, 'Taif' e FROM dual
         UNION ALL SELECT 'SA' c, 'TBK' k, 'تبوك' a, 'Tabuk' e FROM dual
         UNION ALL SELECT 'SA' c, 'ABH' k, 'أبها' a, 'Abha' e FROM dual
         UNION ALL SELECT 'SA' c, 'KMT' k, 'خميس مشيط' a, 'Khamis Mushait' e FROM dual
         UNION ALL SELECT 'SA' c, 'BUR' k, 'بريدة' a, 'Buraidah' e FROM dual
         UNION ALL SELECT 'SA' c, 'UNZ' k, 'عنيزة' a, 'Unaizah' e FROM dual
         UNION ALL SELECT 'SA' c, 'HAS' k, 'الأحساء' a, 'Al Ahsa' e FROM dual
         UNION ALL SELECT 'SA' c, 'QTF' k, 'القطيف' a, 'Qatif' e FROM dual
         UNION ALL SELECT 'SA' c, 'JUB' k, 'الجبيل' a, 'Jubail' e FROM dual
         UNION ALL SELECT 'SA' c, 'HBT' k, 'حفر الباطن' a, 'Hafr Al Batin' e FROM dual
         UNION ALL SELECT 'SA' c, 'HAL' k, 'حائل' a, 'Hail' e FROM dual
         UNION ALL SELECT 'SA' c, 'JZN' k, 'جازان' a, 'Jazan' e FROM dual
         UNION ALL SELECT 'SA' c, 'NJR' k, 'نجران' a, 'Najran' e FROM dual
         UNION ALL SELECT 'SA' c, 'YNB' k, 'ينبع' a, 'Yanbu' e FROM dual
         UNION ALL SELECT 'SA' c, 'ARR' k, 'عرعر' a, 'Arar' e FROM dual
         UNION ALL SELECT 'SA' c, 'SKK' k, 'سكاكا' a, 'Sakaka' e FROM dual
         UNION ALL SELECT 'SA' c, 'BAH' k, 'الباحة' a, 'Al Baha' e FROM dual
         UNION ALL SELECT 'AE' c, 'AUH' k, 'أبوظبي' a, 'Abu Dhabi' e FROM dual
         UNION ALL SELECT 'AE' c, 'DXB' k, 'دبي' a, 'Dubai' e FROM dual
         UNION ALL SELECT 'AE' c, 'SHJ' k, 'الشارقة' a, 'Sharjah' e FROM dual
         UNION ALL SELECT 'AE' c, 'AJM' k, 'عجمان' a, 'Ajman' e FROM dual
         UNION ALL SELECT 'AE' c, 'RAK' k, 'رأس الخيمة' a, 'Ras Al Khaimah' e FROM dual
         UNION ALL SELECT 'AE' c, 'FUJ' k, 'الفجيرة' a, 'Fujairah' e FROM dual
         UNION ALL SELECT 'AE' c, 'UAQ' k, 'أم القيوين' a, 'Umm Al Quwain' e FROM dual
         UNION ALL SELECT 'AE' c, 'AIN' k, 'العين' a, 'Al Ain' e FROM dual
         UNION ALL SELECT 'BH' c, 'MNM' k, 'المنامة' a, 'Manama' e FROM dual
         UNION ALL SELECT 'BH' c, 'MUH' k, 'المحرق' a, 'Muharraq' e FROM dual
         UNION ALL SELECT 'BH' c, 'RIF' k, 'الرفاع' a, 'Riffa' e FROM dual
         UNION ALL SELECT 'BH' c, 'HMD' k, 'مدينة حمد' a, 'Hamad Town' e FROM dual
         UNION ALL SELECT 'BH' c, 'ISA' k, 'مدينة عيسى' a, 'Isa Town' e FROM dual
         UNION ALL SELECT 'OM' c, 'MCT' k, 'مسقط' a, 'Muscat' e FROM dual
         UNION ALL SELECT 'OM' c, 'SLL' k, 'صلالة' a, 'Salalah' e FROM dual
         UNION ALL SELECT 'OM' c, 'SOH' k, 'صحار' a, 'Sohar' e FROM dual
         UNION ALL SELECT 'OM' c, 'NIZ' k, 'نزوى' a, 'Nizwa' e FROM dual
         UNION ALL SELECT 'OM' c, 'SUR' k, 'صور' a, 'Sur' e FROM dual
         UNION ALL SELECT 'OM' c, 'BRK' k, 'بركاء' a, 'Barka' e FROM dual
         UNION ALL SELECT 'QA' c, 'DOH' k, 'الدوحة' a, 'Doha' e FROM dual
         UNION ALL SELECT 'QA' c, 'RAY' k, 'الريان' a, 'Al Rayyan' e FROM dual
         UNION ALL SELECT 'QA' c, 'WAK' k, 'الوكرة' a, 'Al Wakrah' e FROM dual
         UNION ALL SELECT 'QA' c, 'KHR' k, 'الخور' a, 'Al Khor' e FROM dual
         UNION ALL SELECT 'QA' c, 'UMS' k, 'أم صلال' a, 'Umm Salal' e FROM dual
         UNION ALL SELECT 'KW' c, 'KWI' k, 'مدينة الكويت' a, 'Kuwait City' e FROM dual
         UNION ALL SELECT 'KW' c, 'HAW' k, 'حولي' a, 'Hawalli' e FROM dual
         UNION ALL SELECT 'KW' c, 'FAR' k, 'الفروانية' a, 'Farwaniya' e FROM dual
         UNION ALL SELECT 'KW' c, 'AHM' k, 'الأحمدي' a, 'Ahmadi' e FROM dual
         UNION ALL SELECT 'KW' c, 'JAH' k, 'الجهراء' a, 'Jahra' e FROM dual
         UNION ALL SELECT 'KW' c, 'MUB' k, 'مبارك الكبير' a, 'Mubarak Al Kabeer' e FROM dual
         UNION ALL SELECT 'EG' c, 'CAI' k, 'القاهرة' a, 'Cairo' e FROM dual
         UNION ALL SELECT 'EG' c, 'GIZ' k, 'الجيزة' a, 'Giza' e FROM dual
         UNION ALL SELECT 'EG' c, 'ALX' k, 'الإسكندرية' a, 'Alexandria' e FROM dual
         UNION ALL SELECT 'EG' c, 'PSD' k, 'بورسعيد' a, 'Port Said' e FROM dual
         UNION ALL SELECT 'EG' c, 'SUZ' k, 'السويس' a, 'Suez' e FROM dual
         UNION ALL SELECT 'EG' c, 'ISM' k, 'الإسماعيلية' a, 'Ismailia' e FROM dual
         UNION ALL SELECT 'EG' c, 'MNS' k, 'المنصورة' a, 'Mansoura' e FROM dual
         UNION ALL SELECT 'EG' c, 'TNT' k, 'طنطا' a, 'Tanta' e FROM dual
         UNION ALL SELECT 'EG' c, 'ZAG' k, 'الزقازيق' a, 'Zagazig' e FROM dual
         UNION ALL SELECT 'EG' c, 'ASY' k, 'أسيوط' a, 'Asyut' e FROM dual
         UNION ALL SELECT 'EG' c, 'LXR' k, 'الأقصر' a, 'Luxor' e FROM dual
         UNION ALL SELECT 'EG' c, 'ASW' k, 'أسوان' a, 'Aswan' e FROM dual
         UNION ALL SELECT 'EG' c, 'HRG' k, 'الغردقة' a, 'Hurghada' e FROM dual
         UNION ALL SELECT 'EG' c, 'SSH' k, 'شرم الشيخ' a, 'Sharm El Sheikh' e FROM dual
         UNION ALL SELECT 'SD' c, 'KRT' k, 'الخرطوم' a, 'Khartoum' e FROM dual
         UNION ALL SELECT 'SD' c, 'OMD' k, 'أم درمان' a, 'Omdurman' e FROM dual
         UNION ALL SELECT 'SD' c, 'KHN' k, 'الخرطوم بحري' a, 'Khartoum North' e FROM dual
         UNION ALL SELECT 'SD' c, 'PZU' k, 'بورتسودان' a, 'Port Sudan' e FROM dual
         UNION ALL SELECT 'SD' c, 'WMD' k, 'ود مدني' a, 'Wad Madani' e FROM dual
         UNION ALL SELECT 'SD' c, 'KSL' k, 'كسلا' a, 'Kassala' e FROM dual
         UNION ALL SELECT 'SD' c, 'ELO' k, 'الأبيض' a, 'El Obeid' e FROM dual
         UNION ALL SELECT 'SD' c, 'ATB' k, 'عطبرة' a, 'Atbara' e FROM dual) s
     ON (t.country_code = s.c AND t.code = s.k)
   WHEN NOT MATCHED THEN INSERT (code, name_ar, name_en, country_code, level_code, is_active)
        VALUES (s.k, s.a, s.e, s.c, 'CITY', 'Y');
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
