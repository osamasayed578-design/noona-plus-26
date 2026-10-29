"""كتالوج مركز التقارير الموحد: كل تقارير الوحدات (التطبيق والصفحة ورمز التقرير داخل مركز تقارير الوحدة).
الاستخدام: python3 tools/bi_catalog.py  ->  db/seed/14_reports_catalog.sql
عند إضافة تقرير في أي تطبيق أضفه هنا وأعد التوليد؛ يظهر في مركز التقارير متى اشتركت المؤسسة في وحدته وللمستخدم صلاحيته.
"""
import os

ROOT = os.path.join(os.path.dirname(__file__), '..')

# (الرمز، الوحدة، النوع، التطبيق، الصفحة، رقم الصفحة لمسح مرشحاتها أو None، عنصر الاختيار، القيمة، الصلاحية، الأيقونة، الاسم، English، الوصف)
F, O, M, R, A = 'FINANCIAL', 'OPERATIONAL', 'MANAGEMENT', 'REGULATORY', 'ANALYTICAL'
GL, FA_ = 'GL_JOURNAL.VIEW', 'FA_ASSET.VIEW'
CATALOG = [
    # ---------------------------------------------------------------- المحاسبة العامة (NOONA_FIN)
    ('GL_TB', 'GL', F, 'NOONA_FIN', 'TRIAL-BALANCE', None, None, None, GL, 'fa-balance-scale', 'ميزان المراجعة', 'Trial balance',
     'أرصدة الحسابات الافتتاحية والحركة والختامية لفترة، بمستويات الدليل ومركز التكلفة'),
    ('GL_STMT', 'GL', F, 'NOONA_FIN', 'STATEMENT', 31, None, None, GL, 'fa-file-text-o', 'كشف حساب', 'Account statement',
     'حركة حساب بالتفصيل والرصيد التراكمي مع الوصول للقيد ومستند المصدر'),
    ('GL_IS', 'GL', F, 'NOONA_FIN', 'INCOME-STATEMENT', None, None, None, GL, 'fa-line-chart', 'قائمة الدخل', 'Income statement',
     'الإيرادات والمصروفات وصافي الربح أو الخسارة للفترة'),
    ('GL_BS', 'GL', F, 'NOONA_FIN', 'BALANCE-SHEET', None, None, None, GL, 'fa-columns', 'الميزانية العمومية', 'Balance sheet',
     'الأصول والخصوم وحقوق الملكية في تاريخ'),
    ('GL_CF', 'GL', F, 'NOONA_FIN', 'CASH-FLOW', None, None, None, GL, 'fa-exchange', 'قائمة التدفقات النقدية', 'Cash flow statement',
     'التدفقات من الأنشطة التشغيلية والاستثمارية والتمويلية'),
    ('GL_EQ', 'GL', F, 'NOONA_FIN', 'EQUITY-CHANGES', None, None, None, GL, 'fa-pie-chart', 'التغيرات في حقوق الملكية', 'Changes in equity',
     'حركة رأس المال والاحتياطيات والأرباح المبقاة'),
    ('GL_CMP', 'GL', A, 'NOONA_FIN', 'INCOME-COMPARE', None, None, None, GL, 'fa-bar-chart', 'مقارنة الفترات', 'Period comparison',
     'قائمة الدخل لفترتين جنباً إلى جنب بالفرق ونسبته'),
    ('GL_RATIOS', 'GL', A, 'NOONA_FIN', 'RATIOS', None, None, None, GL, 'fa-percent', 'النسب المالية', 'Financial ratios',
     'السيولة والربحية والمديونية والنشاط'),
    ('GL_ANALYSIS', 'GL', A, 'NOONA_FIN', 'ANALYSIS', None, None, None, GL, 'fa-area-chart', 'تحليل الإيرادات والمصروفات', 'Revenue & expense analysis',
     'توزيع الإيرادات والمصروفات حسب الحساب ومركز التكلفة والشهر'),
    ('GL_LEDGER', 'GL', F, 'NOONA_FIN', 'GENERAL-LEDGER', None, None, None, GL, 'fa-book', 'دفتر الأستاذ', 'General ledger',
     'حركة كل الحسابات مجمعة حسب الحساب لفترة'),
    ('GL_JREG', 'GL', O, 'NOONA_FIN', 'JOURNAL-REGISTER', 36, None, None, GL, 'fa-list-ol', 'يومية القيود', 'Journal register',
     'كل القيود بسطورها بالتسلسل لفترة'),
    ('GL_JTYPE', 'GL', O, 'NOONA_FIN', 'JOURNALS-BY-TYPE', None, None, None, GL, 'fa-tags', 'القيود حسب النوع', 'Journals by type',
     'عدد ومبالغ القيود لكل نوع قيد ومصدر'),
    ('GL_CONTROLS', 'GL', M, 'NOONA_FIN', 'CONTROLS', None, None, None, GL, 'fa-shield', 'الرقابة والتسويات', 'Controls & reconciliations',
     'مطابقة الوحدات الفرعية مع الأستاذ واستثناءات الترحيل والقيود غير المتوازنة'),
    ('GL_AUDIT', 'GL', R, 'NOONA_FIN', 'FIN-AUDIT', None, None, None, GL, 'fa-history', 'سجل التدقيق المالي', 'Financial audit trail',
     'من أنشأ وعدل ورحل وعكس كل قيد ومتى'),
    # ---------------------------------------------------------------- النقدية والبنوك
    ('CSH_BOOK', 'CSH', F, 'NOONA_FIN', 'CASH-BOOK', None, None, None, 'CSH_CASH_BOX.VIEW', 'fa-money', 'دفتر الصندوق والبنك', 'Cash & bank book',
     'حركة الصندوق أو الحساب البنكي والرصيد التراكمي بعملته'),
    # ---------------------------------------------------------------- الأصول الثابتة
    ('FA_REGISTER', 'FA', F, 'NOONA_FIN', 'ASSET-REPORTS', 66, 'P66_REPORT', 'REGISTER', FA_, 'fa-cubes', 'سجل الأصول', 'Asset register',
     'كل الأصول بالتكلفة ومجمع الإهلاك والقيمة الدفترية والموقع'),
    ('FA_ROLL', 'FA', F, 'NOONA_FIN', 'ASSET-REPORTS', 66, 'P66_REPORT', 'ROLL', FA_, 'fa-refresh', 'حركة الأصول ومطابقة الأستاذ', 'Asset roll-forward',
     'الرصيد الافتتاحي والإضافات والاستبعادات والإهلاك ومطابقتها مع حسابات الأستاذ'),
    ('FA_DISPOSALS', 'FA', F, 'NOONA_FIN', 'ASSET-REPORTS', 66, 'P66_REPORT', 'DISPOSALS', FA_, 'fa-recycle', 'الاستبعادات وأرباحها وخسائرها', 'Disposals gain/loss',
     'البيع والتخريد بالمتحصلات والقيمة الدفترية والربح أو الخسارة'),
    ('FA_DISPOSED', 'FA', O, 'NOONA_FIN', 'ASSET-REPORTS', 66, 'P66_REPORT', 'DISPOSED', FA_, 'fa-archive', 'الأصول المستبعدة', 'Disposed assets',
     'الأصول التي خرجت من الخدمة وتاريخ وسبب استبعادها'),
    # ---------------------------------------------------------------- الضرائب والفوترة الإلكترونية (NOONA_FIN)
    ('TAX_REGISTER', 'LOC', R, 'NOONA_FIN', 'TAX-REGISTER', 74, None, None, 'LOC_TAX_RETURN.VIEW', 'fa-list', 'السجل الضريبي', 'Tax register',
     'كل المستندات الضريبية من الوحدات (مبيعات، نقاط بيع، مشتريات، مستشفى، فنادق، مستخلصات، أصول) بالأساس والضريبة والطبيعة'),
    ('TAX_RETURNS', 'LOC', R, 'NOONA_FIN', 'TAX-RETURNS', None, None, None, 'LOC_TAX_RETURN.VIEW', 'fa-file-text-o', 'الإقرارات الضريبية', 'Tax returns',
     'إقرارات ضريبة القيمة المضافة والاستقطاع بخاناتها وحالاتها (اعتماد، تقديم، سداد)'),
    ('TAX_WHT', 'LOC', R, 'NOONA_FIN', 'TAX-WHT', 75, None, None, 'LOC_WITHHOLDING_CERT.VIEW', 'fa-scissors', 'ضريبة الاستقطاع وشهاداتها', 'Withholding tax',
     'شهادات الاستقطاع للفترة ومدفوعات الموردين غير المقيمين دون شهادة'),
    ('TAX_EINV', 'LOC', M, 'NOONA_FIN', 'EINVOICING', None, None, None, 'LOC_EINVOICE_SUBMISSION.VIEW', 'fa-qrcode', 'الفوترة الإلكترونية', 'E-invoicing',
     'إرسالات الفواتير للهيئة: المعتمدة والمبلغة والمرفوضة والمعلقة وأسبابها'),
    # ---------------------------------------------------------------- المخزون (NOONA_SCM)
    ('INV_STOCK', 'INV', O, 'NOONA_SCM', 'REPORTS', 50, 'P50_REPORT', 'STOCK', 'INV_ITEM.VIEW', 'fa-cubes', 'أرصدة المخزون وقيمته', 'Stock on hand & value',
     'الكمية والتكلفة والقيمة لكل صنف ومستودع وفئة'),
    ('INV_CARD', 'INV', O, 'NOONA_SCM', 'REPORTS', 50, 'P50_REPORT', 'CARD', 'INV_ITEM.VIEW', 'fa-id-card-o', 'بطاقة صنف', 'Item card',
     'حركة الصنف التفصيلية الوارد والصادر والرصيد'),
    ('INV_EXPIRY', 'INV', O, 'NOONA_SCM', 'REPORTS', 50, 'P50_REPORT', 'EXPIRY', 'INV_ITEM.VIEW', 'fa-hourglass-half', 'الدفعات المنتهية والقريبة الانتهاء', 'Expiring batches',
     'الأدوية والمواد ذات الصلاحية حسب الدفعة والأيام المتبقية'),
    ('INV_REORDER', 'INV', M, 'NOONA_SCM', 'REPORTS', 50, 'P50_REPORT', 'REORDER', 'INV_ITEM.VIEW', 'fa-exclamation-triangle', 'الأصناف تحت حد الطلب', 'Below reorder level',
     'الأصناف التي يجب طلبها والكمية المقترحة'),
    ('INV_FIT', 'INV', O, 'NOONA_SCM', 'REPORTS', 50, 'P50_REPORT', 'FIT', 'INV_ITEM.VIEW', 'fa-car', 'قطع الغيار حسب المركبة', 'Parts by vehicle',
     'البحث عن قطع الغيار المناسبة للماركة والطراز وسنة الصنع'),
    # ---------------------------------------------------------------- المشتريات والموردون
    ('PUR_REG', 'PUR', O, 'NOONA_SCM', 'REPORTS', 50, 'P50_REPORT', 'PREG', 'AP_SUPPLIER.VIEW', 'fa-shopping-basket', 'سجل المشتريات', 'Purchases register',
     'فواتير المشتريات والمرتجعات بالصافي والضريبة لفترة'),
    ('PUR_ITEM', 'PUR', A, 'NOONA_SCM', 'REPORTS', 50, 'P50_REPORT', 'PITEM', 'AP_SUPPLIER.VIEW', 'fa-th-list', 'المشتريات حسب الصنف', 'Purchases by item',
     'الكميات والقيم ومتوسط السعر لكل صنف وفئة'),
    ('PUR_STMT', 'PUR', F, 'NOONA_SCM', 'REPORTS', 50, 'P50_REPORT', 'SSTMT', 'AP_SUPPLIER.VIEW', 'fa-file-text-o', 'كشف حساب مورد', 'Supplier statement',
     'الفواتير والسداد والرصيد المستحق للمورد'),
    ('PUR_AGING', 'PUR', F, 'NOONA_SCM', 'REPORTS', 50, 'P50_REPORT', 'AGING', 'AP_SUPPLIER.VIEW', 'fa-clock-o', 'أعمار ديون الموردين', 'Payables aging',
     'المستحق للموردين موزعاً على فترات التأخير'),
    # ---------------------------------------------------------------- المبيعات ونقاط البيع (NOONA_POS)
    ('SAL_REG', 'SAL', O, 'NOONA_POS', 'REPORTS', 50, 'P50_REPORT', 'SREG', 'SAL_INVOICE.VIEW', 'fa-shopping-cart', 'سجل المبيعات ومجمل الربح', 'Sales register',
     'الفواتير والمرتجعات بالصافي والضريبة والتكلفة ومجمل الربح'),
    ('SAL_ITEM', 'SAL', A, 'NOONA_POS', 'REPORTS', 50, 'P50_REPORT', 'SITEM', 'SAL_INVOICE.VIEW', 'fa-th-list', 'المبيعات والربحية حسب الصنف', 'Sales by item',
     'الكميات والإيراد والتكلفة والربح لكل صنف وفئة'),
    ('SAL_POS', 'SAL', O, 'NOONA_POS', 'REPORTS', 50, 'P50_REPORT', 'POSR', 'POS_SALE.VIEW', 'fa-desktop', 'مبيعات نقاط البيع والورديات', 'POS sales & shifts',
     'المبيعات لكل نقطة بيع ووردية وطريقة دفع والفروقات'),
    ('SAL_STMT', 'SAL', F, 'NOONA_POS', 'REPORTS', 50, 'P50_REPORT', 'CSTMT', 'SAL_INVOICE.VIEW', 'fa-file-text-o', 'كشف حساب عميل', 'Customer statement',
     'الفواتير والتحصيل والرصيد المستحق على العميل'),
    ('SAL_AGING', 'SAL', F, 'NOONA_POS', 'REPORTS', 50, 'P50_REPORT', 'AGING', 'SAL_INVOICE.VIEW', 'fa-clock-o', 'أعمار ديون العملاء', 'Receivables aging',
     'المستحق على العملاء موزعاً على فترات التأخير'),
    ('RST_DASH', 'SAL', M, 'NOONA_POS', 'RESTAURANT-DASHBOARD', 64, None, None, 'RST_ORDER.VIEW', 'fa-cutlery', 'لوحة مبيعات المطعم', 'Restaurant sales',
     'مبيعات المطعم حسب نوع الطلب والصنف والنادل والساعة'),
    # ---------------------------------------------------------------- الموارد البشرية (NOONA_HR)
    ('HR_HEADCOUNT', 'HR', M, 'NOONA_HR', 'REPORTS', 60, 'P60_REPORT', 'HEADCOUNT', 'HR_EMPLOYEE.VIEW', 'fa-users', 'القوى العاملة ونسبة التوطين', 'Headcount & Saudization',
     'عدد الموظفين حسب الإدارة والجنسية ونسبة التوطين'),
    ('HR_LEAVES', 'HR', O, 'NOONA_HR', 'REPORTS', 60, 'P60_REPORT', 'LEAVES', 'HR_EMPLOYEE.VIEW', 'fa-plane', 'أرصدة الإجازات', 'Leave balances',
     'المستحق والمستخدم والمتبقي من الإجازات لكل موظف'),
    ('HR_ATTENDANCE', 'HR', O, 'NOONA_HR', 'REPORTS', 60, 'P60_REPORT', 'ATTENDANCE', 'HR_EMPLOYEE.VIEW', 'fa-calendar-check-o', 'الحضور الشهري', 'Monthly attendance',
     'أيام الحضور والغياب والتأخير والإضافي للشهر'),
    ('HR_EXPIRING', 'HR', R, 'NOONA_HR', 'REPORTS', 60, 'P60_REPORT', 'EXPIRING', 'HR_EMPLOYEE.VIEW', 'fa-id-badge', 'الهويات والعقود القريبة الانتهاء', 'Expiring IDs & contracts',
     'الإقامات والجوازات والعقود التي تنتهي خلال 90 يوماً'),
    # ---------------------------------------------------------------- الرواتب
    ('PAY_REGISTER', 'PAY', F, 'NOONA_HR', 'REPORTS', 60, 'P60_REPORT', 'REGISTER', 'PAY_RUN.VIEW', 'fa-list-alt', 'مسير الرواتب', 'Payroll register',
     'تفاصيل رواتب الموظفين في تشغيل: الاستحقاقات والخصومات والصافي'),
    ('PAY_ELEMENTS', 'PAY', F, 'NOONA_HR', 'REPORTS', 60, 'P60_REPORT', 'ELEMENTS', 'PAY_RUN.VIEW', 'fa-th', 'ملخص عناصر الرواتب', 'Payroll elements summary',
     'إجمالي كل عنصر استحقاق وخصم في التشغيل'),
    ('PAY_GOSI', 'PAY', R, 'NOONA_HR', 'REPORTS', 60, 'P60_REPORT', 'GOSI', 'PAY_RUN.VIEW', 'fa-university', 'تقرير التأمينات الاجتماعية', 'GOSI report',
     'اشتراكات الموظف والمنشأة حسب الأجر الخاضع'),
    ('PAY_CC', 'PAY', M, 'NOONA_HR', 'REPORTS', 60, 'P60_REPORT', 'CC', 'PAY_RUN.VIEW', 'fa-sitemap', 'تكلفة الرواتب حسب مركز التكلفة', 'Payroll cost by cost center',
     'توزيع تكلفة الرواتب على مراكز التكلفة والإدارات'),
    ('PAY_EOS', 'PAY', F, 'NOONA_HR', 'REPORTS', 60, 'P60_REPORT', 'EOS', 'PAY_RUN.VIEW', 'fa-handshake-o', 'التزام مكافأة نهاية الخدمة', 'End of service liability',
     'المكافأة المستحقة لكل موظف في تاريخ حسب نظام العمل'),
    ('PAY_LOANS', 'PAY', O, 'NOONA_HR', 'REPORTS', 60, 'P60_REPORT', 'LOANS', 'PAY_RUN.VIEW', 'fa-credit-card', 'السلف القائمة', 'Outstanding loans',
     'السلف والأقساط المسددة والمتبقية لكل موظف'),
    # ---------------------------------------------------------------- بيع الوحدات وإدارة الأملاك (NOONA_PRJ)
    ('RE_AVAILABILITY', 'RE', O, 'NOONA_PRJ', 'UNIT-SALES', None, None, None, 'RE_SALE_CONTRACT.VIEW', 'fa-th-large', 'توفر الوحدات ومؤشرات البيع', 'Unit availability',
     'شبكة وحدات البيع بحالتها (متاحة، محجوزة، مباعة) وسعرها، والمبيعات والتحصيل والأقساط المتأخرة'),
    ('RE_COLLECTIONS', 'RE', F, 'NOONA_PRJ', 'UNIT-COLLECTIONS', 34, None, None, 'RE_SALE_CONTRACT.VIEW', 'fa-money', 'أقساط عقود البيع المستحقة والمتأخرة', 'Installment collections',
     'الأقساط المستحقة في فترة والمتأخرة بأيام التأخير والمتبقي، وعمولات الوسطاء'),
    ('RE_SALES', 'RE', M, 'NOONA_PRJ', 'UNIT-REPORTS', 36, None, None, 'RE_SALE_CONTRACT.VIEW', 'fa-line-chart', 'مبيعات الوحدات حسب العقار', 'Unit sales by property',
     'عدد الوحدات المباعة ومساحتها وقيمتها ومتوسط سعر المتر والخصومات والمحصل، والتسليمات'),
    ('PRP_RENT_ROLL', 'PRP', O, 'NOONA_PRJ', 'LEASES', 43, None, None, 'PRP_LEASE.VIEW', 'fa-list-alt', 'قائمة الإيجارات (Rent Roll)', 'Rent roll',
     'كل وحدة تأجير بمستأجرها وعقدها ونهايته وإيجارها السنوي، والوحدات الشاغرة'),
    ('PRP_LEASING', 'PRP', M, 'NOONA_PRJ', 'LEASING', None, None, None, 'PRP_LEASE.VIEW', 'fa-pie-chart', 'الإشغال والإيجارات المتأخرة والعقود المنتهية', 'Occupancy & arrears',
     'نسبة الإشغال لكل عقار، الإيجارات المتأخرة بأيامها، العقود التي تنتهي خلال 60 يوماً'),
    ('PRP_OWNERS', 'PRP', F, 'NOONA_PRJ', 'PROPERTY-OWNERS', None, None, None, 'PRP_OWNER_STATEMENT.VIEW', 'fa-handshake-o', 'كشوف حسابات الملاك', 'Owner statements',
     'المحصل لكل مالك وأتعاب الإدارة والمصروفات والصافي المحول'),
    # ---------------------------------------------------------------- الضيافة والأملاك (NOONA_PRJ)
    ('HSP_INHOUSE', 'PRP', O, 'NOONA_PRJ', 'HOTEL-REPORTS', 28, 'P28_REPORT', 'INHOUSE', 'HSP_RESERVATION.VIEW', 'fa-bed', 'النزلاء المقيمون', 'In-house guests',
     'النزلاء الحاليون بالغرف وتاريخ المغادرة والرصيد'),
    ('HSP_OCC', 'PRP', M, 'NOONA_PRJ', 'HOTEL-REPORTS', 28, 'P28_REPORT', 'OCC', 'HSP_RESERVATION.VIEW', 'fa-line-chart', 'الإشغال والإيراد اليومي', 'Occupancy, ADR & RevPAR',
     'نسبة الإشغال ومتوسط سعر الغرفة والإيراد لكل غرفة متاحة يومياً'),
    ('HSP_ARRIVALS', 'PRP', O, 'NOONA_PRJ', 'HOTEL-REPORTS', 28, 'P28_REPORT', 'ARRIVALS', 'HSP_RESERVATION.VIEW', 'fa-sign-in', 'الوصول والمغادرة القادمة', 'Arrivals & departures',
     'الحجوزات الواصلة والنزلاء المغادرون في الأيام القادمة'),
    ('HSP_CITY', 'PRP', F, 'NOONA_PRJ', 'HOTEL-REPORTS', 28, 'P28_REPORT', 'CITY', 'HSP_RESERVATION.VIEW', 'fa-building-o', 'حسابات الشركات المحولة', 'City ledger',
     'المبالغ المحولة على حسابات الشركات من كشوف النزلاء'),
    # ---------------------------------------------------------------- المشروعات والمقاولات (NOONA_PRJ)
    ('PRJ_PORTFOLIO', 'PRJ', M, 'NOONA_PRJ', 'PROJECT-REPORTS', 90, 'P90_REPORT', 'PORTFOLIO', 'PRJ_PROJECT.VIEW', 'fa-briefcase', 'محفظة المشروعات والربحية', 'Project portfolio & profitability',
     'قيمة العقود والموازنة والتكلفة الفعلية والمفوتر والمحصل والربح والهامش لكل مشروع'),
    ('PRJ_CLAIMS', 'PRJ', F, 'NOONA_PRJ', 'PROJECT-REPORTS', 90, 'P90_REPORT', 'CLAIMS', 'PRJ_PROGRESS_CLAIM.VIEW', 'fa-file-text-o', 'سجل المستخلصات', 'Progress claims register',
     'مستخلصات العملاء ومقاولي الباطن المعتمدة بالمحتجز واسترداد المقدم والضريبة والصافي'),
    ('PRJ_RETENTION', 'PRJ', F, 'NOONA_PRJ', 'PROJECT-REPORTS', 90, 'P90_REPORT', 'RETENTION', 'PRJ_PROGRESS_CLAIM.VIEW', 'fa-lock', 'المحتجزات والدفعات المقدمة', 'Retentions & advances',
     'المحتجز لدى العملاء ولمقاولي الباطن والدفعات المقدمة غير المستردة وموعد الإفراج'),
    ('PRJ_COSTS', 'PRJ', M, 'NOONA_PRJ', 'PROJECT-REPORTS', 90, 'P90_REPORT', 'COSTS', 'PRJ_COST_LINE.VIEW', 'fa-money', 'تكاليف المشروعات حسب النوع', 'Project costs by type',
     'المواد والعمالة والمعدات ومقاولو الباطن والمصروفات لكل مشروع في فترة'),
    ('PRJ_UNITS', 'PRJ', A, 'NOONA_PRJ', 'PROJECT-REPORTS', 90, 'P90_REPORT', 'UNITS', 'PRJ_PROJECT.VIEW', 'fa-building', 'توزيع تكلفة التطوير على الوحدات', 'Development cost per unit',
     'نصيب كل وحدة من تكلفة مشروع التطوير العقاري بالمساحة أو السعر والهامش المتوقع'),
    # ---------------------------------------------------------------- الصيانة
    ('MNT_PERF', 'MNT', M, 'NOONA_PRJ', 'MAINT-REPORTS', 75, None, None, 'MNT_REQUEST.VIEW', 'fa-wrench', 'أداء الصيانة', 'Maintenance performance',
     'البلاغات وزمن الإنجاز والالتزام بالمهلة والتكلفة والتقييم حسب نوع العطل'),
    # ---------------------------------------------------------------- التصنيع (NOONA_MFG)
    ('MFG_ORDERS', 'MFG', O, 'NOONA_MFG', 'REPORTS', 50, 'P50_REPORT', 'ORDERS', 'MFG_PRODUCTION_ORDER.VIEW', 'fa-list-alt', 'سجل أوامر الإنتاج', 'Production orders register',
     'أوامر الإنتاج بالكميات والإنجاز والتكلفة والحالة'),
    ('MFG_WIP', 'MFG', F, 'NOONA_MFG', 'REPORTS', 50, 'P50_REPORT', 'WIP', 'MFG_PRODUCTION_ORDER.VIEW', 'fa-cogs', 'الإنتاج تحت التشغيل', 'Work in process',
     'قيمة الإنتاج تحت التشغيل ومطابقتها مع الأستاذ'),
    ('MFG_VAR', 'MFG', F, 'NOONA_MFG', 'REPORTS', 50, 'P50_REPORT', 'VAR', 'MFG_PRODUCTION_ORDER.VIEW', 'fa-random', 'انحرافات تكاليف الإنتاج', 'Production variances',
     'انحرافات المواد والعمالة والتحميل بين المعياري والفعلي'),
    ('MFG_USAGE', 'MFG', O, 'NOONA_MFG', 'REPORTS', 50, 'P50_REPORT', 'USAGE', 'MFG_PRODUCTION_ORDER.VIEW', 'fa-flask', 'استهلاك الخامات', 'Material usage',
     'الخامات المصروفة والمرتجعة وقيمتها لفترة'),
    ('MFG_SUMMARY', 'MFG', M, 'NOONA_MFG', 'REPORTS', 50, 'P50_REPORT', 'SUMMARY', 'MFG_PRODUCTION_ORDER.VIEW', 'fa-industry', 'ملخص الإنتاج حسب المنتج', 'Production by product',
     'الكميات المنتجة والهالك وتكلفة الوحدة لكل منتج'),
    ('MFG_UTIL', 'MFG', M, 'NOONA_MFG', 'REPORTS', 50, 'P50_REPORT', 'UTIL', 'MFG_PRODUCTION_ORDER.VIEW', 'fa-tachometer', 'استغلال مراكز العمل وكفاءتها', 'Work center utilization',
     'الساعات المتاحة والمستخدمة والكفاءة لكل مركز عمل'),
    ('MFG_LOAD', 'MFG', M, 'NOONA_MFG', 'REPORTS', 50, 'P50_REPORT', 'LOAD', 'MFG_PRODUCTION_ORDER.VIEW', 'fa-tasks', 'أحمال مراكز العمل', 'Capacity load',
     'الحمل المخطط مقابل الطاقة لكل يوم في الأيام القادمة'),
    ('MFG_TREE', 'MFG', A, 'NOONA_MFG', 'REPORTS', 50, 'P50_REPORT', 'TREE', 'MFG_PRODUCTION_ORDER.VIEW', 'fa-sitemap', 'شجرة قائمة المواد والتكلفة', 'BOM tree & rolled cost',
     'مكونات المنتج متعددة المستويات وتكلفتها المجمعة'),
    ('MFG_USED', 'MFG', A, 'NOONA_MFG', 'REPORTS', 50, 'P50_REPORT', 'USED', 'MFG_PRODUCTION_ORDER.VIEW', 'fa-search', 'أين يستخدم الصنف', 'Where used',
     'المنتجات وقوائم المواد التي يدخل فيها الصنف'),
    ('MFG_MRP', 'MFG', M, 'NOONA_MFG', 'REPORTS', 50, 'P50_REPORT', 'MRP', 'MFG_PRODUCTION_ORDER.VIEW', 'fa-calendar', 'تخطيط احتياجات المواد', 'MRP',
     'صافي احتياجات الخامات والكميات المقترح شراؤها أو إنتاجها'),
    ('MFG_QC', 'MFG', R, 'NOONA_MFG', 'REPORTS', 50, 'P50_REPORT', 'QC', 'MFG_PRODUCTION_ORDER.VIEW', 'fa-check-square-o', 'فحوصات الجودة', 'Quality inspections',
     'الكميات المفحوصة والمقبولة والمرفوضة ونسبة القبول'),
    # ---------------------------------------------------------------- المستشفى (NOONA_HIS)
    ('HIS_REV', 'HIS', F, 'NOONA_HIS', 'REPORTS', 70, 'P70_REPORT', 'REV', 'HIS_INVOICE.VIEW', 'fa-hospital-o', 'الإيرادات حسب القسم والجهة والطبيب', 'Revenue by department, payer & doctor',
     'إيرادات الزيارات بحصة المريض وحصة الجهة لكل قسم وطبيب'),
    ('HIS_CLAIM', 'HIS', F, 'NOONA_HIS', 'REPORTS', 70, 'P70_REPORT', 'CLAIM', 'HIS_INVOICE.VIEW', 'fa-file-text-o', 'كشف مطالبة جهة', 'Payer claim statement',
     'المطالبات المستحقة على شركة تأمين أو جهة متعاقدة لفترة'),
    ('HIS_CLAIMS', 'HIS', O, 'NOONA_HIS', 'CLAIMS', 71, None, None, 'HIS_CLAIM_BATCH.VIEW', 'fa-files-o', 'دفعات مطالبات التأمين', 'Claim batches',
     'دفعات المطالبات والمقبول والمرفوض والمسدد لكل جهة'),
    ('HIS_COMM', 'HIS', F, 'NOONA_HIS', 'COMMISSIONS', 73, None, None, 'HIS_COMMISSION.VIEW', 'fa-user-md', 'عمولات الأطباء', 'Doctor commissions',
     'نسبة كل طبيب من الإيراد المحصل والتسويات'),
    # ---------------------------------------------------------------- المستندات (NOONA_DOC)
    ('DMS_EXPIRING', 'DMS', R, 'NOONA_DOC', 'EXPIRING', None, None, None, 'DMS_DOCUMENT.VIEW', 'fa-hourglass-end', 'المستندات المنتهية والقريبة الانتهاء', 'Expiring documents',
     'السجلات والتراخيص والشهادات التي انتهت أو تقترب من الانتهاء'),
    ('DMS_ACCESS', 'DMS', R, 'NOONA_DOC', 'ACCESS-LOG', None, None, None, 'DMS_DOCUMENT.VIEW', 'fa-eye', 'سجل الوصول للمستندات', 'Document access log',
     'من فتح أو نزل أو عدل كل مستند ومتى'),
    # ---------------------------------------------------------------- مراكز خدمة السيارات (NOONA_AUTO)
    ('AUT_SUMMARY', 'AUT', F, 'NOONA_AUTO', 'REPORTS', 12, 'P12_KIND', 'SUMMARY', 'AUT_JOB_CARD.EXPORT', 'fa-calendar', 'إجمالي عمليات مركز الخدمة', 'Service center operations',
     'الخدمات وقطع الغيار والضريبة والإجمالي ومجمل الربح يومياً لفترة'),
    ('AUT_SERVICES', 'AUT', O, 'NOONA_AUTO', 'REPORTS', 12, 'P12_KIND', 'SERVICES', 'AUT_JOB_CARD.EXPORT', 'fa-wrench', 'تقرير الخدمات المنفذة', 'Services performed',
     'كل خدمة منفذة بالأمر واللوحة والفني ومدة العمل والصافي'),
    ('AUT_PARTS', 'AUT', F, 'NOONA_AUTO', 'REPORTS', 12, 'P12_KIND', 'PARTS', 'AUT_JOB_CARD.EXPORT', 'fa-cogs', 'تقرير مبيعات قطع الغيار', 'Spare parts sales',
     'القطع المباعة بالكمية والسعر والتكلفة والربح'),
    ('AUT_TOP_SERVICES', 'AUT', A, 'NOONA_AUTO', 'REPORTS', 12, 'P12_KIND', 'TOP_SERVICES', 'AUT_JOB_CARD.EXPORT', 'fa-trophy', 'أكثر الخدمات طلباً', 'Most requested services',
     'ترتيب الخدمات بعدد الطلبات والإيراد لشهر أو فترة أو سنة'),
    ('AUT_TOP_PARTS', 'AUT', A, 'NOONA_AUTO', 'REPORTS', 12, 'P12_KIND', 'TOP_PARTS', 'AUT_JOB_CARD.EXPORT', 'fa-star', 'أكثر قطع الغيار مبيعاً', 'Best selling parts',
     'ترتيب القطع بالكمية أو القيمة مع الهامش لشهر أو فترة أو سنة'),
    ('AUT_TECHNICIANS', 'AUT', M, 'NOONA_AUTO', 'REPORTS', 12, 'P12_KIND', 'TECHNICIANS', 'AUT_JOB_CARD.EXPORT', 'fa-user', 'إنتاجية الفنيين وعمولاتهم', 'Technician productivity',
     'الخدمات وساعات العمل والإيراد والعمولة لكل فني'),
    ('AUT_STAY', 'AUT', O, 'NOONA_AUTO', 'REPORTS', 12, 'P12_KIND', 'STAY', 'AUT_JOB_CARD.EXPORT', 'fa-clock-o', 'مدة بقاء المركبات', 'Vehicle stay time',
     'ساعات بقاء كل مركبة والالتزام بموعد التسليم'),
    ('AUT_INSURANCE', 'AUT', F, 'NOONA_AUTO', 'REPORTS', 12, 'P12_KIND', 'INSURANCE', 'AUT_JOB_CARD.EXPORT', 'fa-shield', 'مطالبات شركات التأمين', 'Insurance claims',
     'المطالب به والمعتمد وتحمل العملاء وحالة المطالبات لكل شركة'),
    ('AUT_APPOINTMENTS', 'AUT', O, 'NOONA_AUTO', 'REPORTS', 12, 'P12_KIND', 'APPOINTMENTS', 'AUT_JOB_CARD.EXPORT', 'fa-calendar-check-o', 'الحجوزات ونسبة الحضور', 'Appointments',
     'الحجوزات حسب المصدر والحالة ونسبة الحضور'),
    ('AUT_DUE', 'AUT', O, 'NOONA_AUTO', 'REPORTS', 12, 'P12_KIND', 'DUE', 'AUT_JOB_CARD.EXPORT', 'fa-bell', 'الخدمات والتأمين والاستمارات المستحقة', 'Due services & renewals',
     'المركبات المستحقة للخدمة الدورية أو تجديد التأمين والاستمارة'),
    ('AUT_MAKES', 'AUT', A, 'NOONA_AUTO', 'REPORTS', 12, 'P12_KIND', 'MAKES', 'AUT_JOB_CARD.EXPORT', 'fa-car', 'العمليات حسب الشركة المصنعة', 'By vehicle make',
     'الأوامر والإيراد ومتوسط الأمر لكل شركة مصنعة وطراز'),
    ('AUT_VEHICLES', 'AUT', M, 'NOONA_AUTO', 'REPORTS', 12, 'P12_KIND', 'VEHICLES', 'AUT_JOB_CARD.EXPORT', 'fa-users', 'أعلى المركبات والعملاء إنفاقاً', 'Top vehicles & customers',
     'الزيارات والإنفاق لكل مركبة وعميل'),
]


def lit(v):
    return 'NULL' if v is None else str(v) if isinstance(v, int) else "'" + str(v).replace("'", "''") + "'"


rows = []
for n, (code, mdl, typ, app, page, pno, item, val, perm, icon, ar, en, dsc) in enumerate(CATALOG, start=1):
    rows.append('SELECT ' + ', '.join(lit(x) for x in (code, mdl, typ, app, page, pno, item, val, perm, icon, ar, en, dsc)) + f', {n * 10} FROM dual')
# الصف الأول يسمي الأعمدة
names = 'code module_code report_type app_alias page_alias page_no param_item param_value permission_code icon_class name_ar name_en dsc'.split()
first = 'SELECT ' + ', '.join(f'{v} {k}' for v, k in zip(
    [lit(x) for x in CATALOG[0]], names)) + ', 10 sort_order FROM dual'
sql = f"""-- =============================================================================
-- NOONA PLUS ERP | كتالوج مركز التقارير الموحد (TENANT_ID = NULL) - مولد من tools/bi_catalog.py (لا تعدله يدوياً)
--   كل تقرير: الوحدة، التطبيق والصفحة، رمز التقرير داخل مركز تقارير الوحدة، والصلاحية المطلوبة
--   التقارير التي حذفت من الكتالوج تصبح RETIRED ولا تظهر
-- =============================================================================
SET DEFINE OFF
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO bi_report r
  USING ({first}
         UNION ALL {(chr(10) + '         UNION ALL ').join(rows[1:])}) x
     ON (r.tenant_id IS NULL AND r.code = x.code AND r.version_no = 1)
   WHEN MATCHED THEN UPDATE SET r.module_code = x.module_code, r.report_type = x.report_type, r.app_alias = x.app_alias,
        r.page_alias = x.page_alias, r.page_no = x.page_no, r.param_item = x.param_item, r.param_value = x.param_value,
        r.permission_code = x.permission_code, r.icon_class = x.icon_class, r.name_ar = x.name_ar, r.name_en = x.name_en,
        r.description = x.dsc, r.sort_order = x.sort_order, r.status_code = 'PUBLISHED'
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, description, module_code, report_type, version_no, app_alias, page_alias,
                                 page_no, param_item, param_value, permission_code, icon_class, sort_order, output_formats, status_code)
        VALUES (NULL, x.code, x.name_ar, x.name_en, x.dsc, x.module_code, x.report_type, 1, x.app_alias, x.page_alias,
                x.page_no, x.param_item, x.param_value, x.permission_code, x.icon_class, x.sort_order, 'HTML,PRINT', 'PUBLISHED');
  UPDATE bi_report SET status_code = 'RETIRED'
   WHERE tenant_id IS NULL AND app_alias IS NOT NULL AND status_code = 'PUBLISHED'
     AND code NOT IN ({', '.join(lit(c[0]) for c in CATALOG)});
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  ROLLBACK;
  RAISE;
END;
/
"""
open(os.path.join(ROOT, 'db/seed/14_reports_catalog.sql'), 'w', encoding='utf-8').write(sql)
print('reports catalog:', len(CATALOG), 'reports')
