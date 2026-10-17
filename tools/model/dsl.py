"""
NOONA PLUS - Data Model DSL
===========================
المصدر الوحيد للحقيقة (Single Source of Truth) لتصميم قاعدة البيانات.
كل ملفات DDL و ERD و Data Dictionary تولد آلياً من تعريفات هذا النموذج
عبر tools/generate.py، لذلك لا تعدل ملفات db/ddl أو docs يدوياً.

صيغة سطر العمود داخل cols:
    COLUMN_NAME  TYPE  [NN] [U] [>TABLE[.COL]] [D=default] [IN:A,B,C] [PII] [@SRC]  | الوصف العربي

الأنواع: ID INT NUM AMT QTY RATE PCT DATE TS YN CLOB BLOB JSON RAW16 CODE NAME TXT
         CUR CTRY LANG USR HASH Vn (VARCHAR2(n CHAR))
"""
import re

MODULES = []
TABLES = {}

TYPE_MAP = {
    'ID': 'NUMBER(19)',
    'INT': 'NUMBER(10)',
    'NUM': 'NUMBER',
    'AMT': 'NUMBER(24,6)',
    'QTY': 'NUMBER(24,6)',
    'RATE': 'NUMBER(28,12)',
    'PCT': 'NUMBER(9,6)',
    'DATE': 'DATE',
    'TS': 'TIMESTAMP(6) WITH LOCAL TIME ZONE',
    'YN': 'CHAR(1 CHAR)',
    'CLOB': 'CLOB',
    'BLOB': 'BLOB',
    'JSON': 'CLOB',
    'RAW16': 'RAW(16)',
    'CODE': 'VARCHAR2(30 CHAR)',
    'NAME': 'VARCHAR2(200 CHAR)',
    'TXT': 'VARCHAR2(4000 CHAR)',
    'CUR': 'VARCHAR2(3 CHAR)',
    'CTRY': 'VARCHAR2(2 CHAR)',
    'LANG': 'VARCHAR2(10 CHAR)',
    'USR': 'VARCHAR2(128 CHAR)',
    'HASH': 'VARCHAR2(128 CHAR)',
}

LOGICAL = {
    'ID': 'معرف', 'INT': 'عدد صحيح', 'NUM': 'رقم', 'AMT': 'مبلغ', 'QTY': 'كمية', 'RATE': 'سعر/معدل',
    'PCT': 'نسبة', 'DATE': 'تاريخ', 'TS': 'طابع زمني', 'YN': 'منطقي Y/N', 'CLOB': 'نص طويل',
    'BLOB': 'ثنائي', 'JSON': 'JSON', 'RAW16': 'GUID', 'CODE': 'رمز', 'NAME': 'اسم', 'TXT': 'نص',
    'CUR': 'رمز عملة ISO', 'CTRY': 'رمز دولة ISO', 'LANG': 'رمز لغة', 'USR': 'اسم مستخدم', 'HASH': 'Hash',
}

AUTO_FK = {
    'CUR': ('REF_CURRENCY', 'CURRENCY_CODE'),
    'CTRY': ('REF_COUNTRY', 'COUNTRY_CODE'),
    'LANG': ('REF_LANGUAGE', 'LANGUAGE_CODE'),
}

SCOPES = {
    'G': 'منصة عامة Platform Global (بدون TENANT_ID)',
    'TO': 'منصة أو مؤسسة (TENANT_ID اختياري: فارغ = قيمة منصة افتراضية)',
    'T': 'مملوك للمؤسسة Tenant-Owned',
    'C': 'مملوك للشركة Company-Owned',
}

CONF_LEVELS = ['PUBLIC', 'INTERNAL', 'CONFIDENTIAL', 'SECRET', 'HIGHLY_RESTRICTED']


class Column:
    def __init__(self, name, ltype, desc='', nullable=True, default=None, fk=None,
                 check_in=None, pii=False, src='USER', unique=False, auto=False):
        self.name = name
        self.ltype = ltype
        self.desc = desc
        self.nullable = nullable
        self.default = default
        self.fk = fk            # (table, col)
        self.check_in = check_in
        self.pii = pii
        self.src = src
        self.unique = unique
        self.auto = auto
        m = re.fullmatch(r'V(\d+)', ltype)
        if m:
            self.otype = f'VARCHAR2({m.group(1)} CHAR)'
            self.logical = 'نص'
        elif ltype in TYPE_MAP:
            self.otype = TYPE_MAP[ltype]
            self.logical = LOGICAL[ltype]
        else:
            raise ValueError(f'Unknown type {ltype} for column {name}')
        if ltype in AUTO_FK and fk is None:
            self.fk = AUTO_FK[ltype]


class Module:
    def __init__(self, no, code, ar, en, pkg, purpose=''):
        self.no = no
        self.code = code
        self.ar = ar
        self.en = en
        self.pkg = pkg
        self.purpose = purpose
        self.tables = []
        MODULES.append(self)

    @property
    def file_stem(self):
        return f'p{self.no:02d}_{self.code.lower()}'


_current = {'module': None}


def module(no, code, ar, en, pkg, purpose=''):
    m = Module(no, code, ar, en, pkg, purpose)
    _current['module'] = m
    return m


class Table:
    def __init__(self, name, ar, en, scope, purpose, sens, append, ret, area):
        self.name = name
        self.ar = ar
        self.en = en
        self.scope = scope
        self.purpose = purpose
        self.sens = sens
        self.append = append
        self.ret = ret
        self.area = area
        self.module = _current['module']
        self.cols = []
        self.uks = []
        self.ixs = []
        self.checks = []
        self.fks = []
        self.nuks = []          # unique only when last column is NOT NULL (function-based unique index)
        self.needs_tenant_uk = False

    def col(self, name):
        for c in self.cols:
            if c.name == name:
                return c
        return None

    @property
    def has_tenant(self):
        return self.scope in ('T', 'C', 'TO')


def _parse_col(line):
    if '|' in line:
        spec, desc = line.split('|', 1)
        desc = desc.strip()
    else:
        spec, desc = line, ''
    toks = spec.split()
    name, ltype = toks[0], toks[1]
    kw = dict(nullable=True, default=None, fk=None, check_in=None, pii=False, src='USER', unique=False)
    for t in toks[2:]:
        if t == 'NN':
            kw['nullable'] = False
        elif t == 'U':
            kw['unique'] = True
        elif t == 'PII':
            kw['pii'] = True
        elif t.startswith('>'):
            ref = t[1:]
            if '.' in ref:
                kw['fk'] = tuple(ref.split('.', 1))
            else:
                kw['fk'] = (ref, 'ID')
        elif t.startswith('D='):
            kw['default'] = t[2:].replace('~', ' ')
        elif t.startswith('IN:'):
            kw['check_in'] = t[3:].split(',')
        elif t.startswith('@'):
            kw['src'] = t[1:]
        else:
            raise ValueError(f'Bad token {t!r} in {line!r}')
    return Column(name, ltype, desc, **kw)


def table(name, ar, en, scope='T', mix='', status=None, cols='', uk=(), ix=(), chk=(),
          purpose='', sens='INTERNAL', append=False, ret=None, area=None, codeuk=True, docuk=True, nuk=()):
    if name in TABLES:
        raise ValueError(f'Duplicate table {name}')
    t = Table(name, ar, en, scope, purpose, sens, append, ret, area)
    mixes = mix.split()
    C = t.cols.append

    C(Column('ID', 'ID', 'المفتاح الداخلي الثابت (Identity) - لا يعاد استخدامه', nullable=False, src='SYS', auto=True))
    if 'pub' in mixes:
        C(Column('PUBLIC_ID', 'RAW16', 'معرف عام عشوائي للروابط الخارجية وواجهات API بدل المفتاح الداخلي',
                 nullable=False, default='SYS_GUID()', src='SYS', unique=True, auto=True))
    if scope in ('T', 'C'):
        C(Column('TENANT_ID', 'ID', 'المؤسسة المالكة؛ يملأ من Security Context الموثوق لا من مدخلات المستخدم',
                 nullable=False, fk=('PLT_TENANT', 'ID'), src='CTX', auto=True))
    elif scope == 'TO':
        C(Column('TENANT_ID', 'ID', 'المؤسسة المالكة؛ فارغ = سجل منصة افتراضي متاح للجميع',
                 fk=('PLT_TENANT', 'ID'), src='CTX', auto=True))
    if scope == 'C':
        C(Column('COMPANY_ID', 'ID', 'الشركة (الكيان القانوني) المالكة للسجل', nullable=False,
                 fk=('ORG_COMPANY', 'ID'), src='CTX', auto=True))
    if 'branch' in mixes:
        C(Column('BRANCH_ID', 'ID', 'الفرع', fk=('ORG_BRANCH', 'ID'), auto=True))
    if 'code' in mixes:
        C(Column('CODE', 'V50', 'الرمز الفريد ضمن النطاق', nullable=False, auto=True))
    if 'doc' in mixes:
        C(Column('DOC_NO', 'V50', 'رقم المستند من تسلسل REF_DOC_SEQUENCE (فريد ضمن الشركة)', nullable=False, src='SYS', auto=True))
        C(Column('DOC_DATE', 'DATE', 'تاريخ المستند (تاريخ الأعمال)', nullable=False, default='TRUNC(SYSDATE)', auto=True))
    if 'names' in mixes:
        C(Column('NAME_AR', 'NAME', 'الاسم بالعربية', nullable=False, auto=True))
        C(Column('NAME_EN', 'NAME', 'الاسم بالإنجليزية', auto=True))
    if 'desc' in mixes:
        C(Column('DESCRIPTION', 'TXT', 'الوصف', auto=True))
    if 'src' in mixes:
        C(Column('SOURCE_ENTITY_TYPE', 'V50', 'نوع كيان المصدر من سجل الأنواع REF_ENTITY_TYPE',
                 fk=('REF_ENTITY_TYPE', 'ENTITY_TYPE_CODE'), auto=True))
        C(Column('SOURCE_ENTITY_ID', 'ID', 'معرف كيان المصدر (يتحقق منه خادمياً عبر حزمة الوحدة المالكة)', auto=True))
    if 'cur' in mixes:
        C(Column('CURRENCY_CODE', 'CUR', 'عملة المعاملة', nullable=False, auto=True))
        C(Column('RATE_TYPE_CODE', 'CODE', 'نوع سعر الصرف المستخدم', auto=True))
        C(Column('EXCHANGE_RATE', 'RATE', 'سعر الصرف المثبت وقت المعاملة (لا يتغير بعد الترحيل)', auto=True))
        C(Column('RATE_DATE', 'DATE', 'تاريخ سعر الصرف', auto=True))

    for raw in cols.strip().splitlines():
        raw = raw.strip()
        if not raw or raw.startswith('#'):
            continue
        c = _parse_col(raw)
        if t.col(c.name):
            raise ValueError(f'{name}: duplicate column {c.name}')
        C(c)

    if 'status' in mixes:
        if not status:
            raise ValueError(f'{name}: status mixin needs status=')
        vals = status.split()
        C(Column('STATUS_CODE', 'CODE', 'الحالة ضمن دورة الحياة المعتمدة', nullable=False,
                 default=f"'{vals[0]}'", check_in=vals, src='SYS', auto=True))
    if 'eff' in mixes:
        C(Column('EFFECTIVE_FROM', 'DATE', 'تاريخ بداية السريان', nullable=False, default='TRUNC(SYSDATE)', auto=True))
        C(Column('EFFECTIVE_TO', 'DATE', 'تاريخ نهاية السريان (فارغ = مفتوح)', auto=True))
        t.checks.append('EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= EFFECTIVE_FROM')
    if 'conf' in mixes:
        C(Column('CONFIDENTIALITY_LEVEL', 'CODE', 'درجة السرية؛ لا تمنح الوصول منفردة', nullable=False,
                 default="'INTERNAL'", check_in=CONF_LEVELS, auto=True))
    if 'wf' in mixes:
        C(Column('WF_INSTANCE_ID', 'ID', 'مسار الاعتماد المرتبط', fk=('WF_INSTANCE', 'ID'), src='SYS', auto=True))
    if 'posted' in mixes:
        C(Column('ACCOUNTING_EVENT_ID', 'ID', 'الحدث المحاسبي المولد', fk=('ACE_ACCOUNTING_EVENT', 'ID'), src='SYS', auto=True))
        C(Column('POSTED_AT', 'TS', 'وقت الترحيل؛ يملؤه محرك الترحيل فقط', src='SYS', auto=True))
        C(Column('POSTED_BY', 'USR', 'منفذ الترحيل', src='SYS', auto=True))
    if 'notes' in mixes:
        C(Column('NOTES', 'TXT', 'ملاحظات', auto=True))
    if 'active' in mixes:
        C(Column('IS_ACTIVE', 'YN', 'نشط؟', nullable=False, default="'Y'", auto=True))
    if 'sort' in mixes:
        C(Column('SORT_ORDER', 'INT', 'ترتيب العرض', auto=True))

    if append:
        C(Column('CREATED_BY', 'USR', 'منشئ السجل', nullable=False, src='TRIGGER', auto=True))
        C(Column('CREATED_AT', 'TS', 'وقت الإنشاء UTC', nullable=False, default='SYSTIMESTAMP', src='TRIGGER', auto=True))
    else:
        C(Column('ROW_VERSION', 'INT', 'رقم الإصدار للتحكم في التزامن المتفائل', nullable=False, default='1', src='TRIGGER', auto=True))
        C(Column('CREATED_BY', 'USR', 'منشئ السجل', nullable=False, src='TRIGGER', auto=True))
        C(Column('CREATED_AT', 'TS', 'وقت الإنشاء', nullable=False, default='SYSTIMESTAMP', src='TRIGGER', auto=True))
        C(Column('UPDATED_BY', 'USR', 'آخر من عدل السجل', src='TRIGGER', auto=True))
        C(Column('UPDATED_AT', 'TS', 'وقت آخر تعديل', src='TRIGGER', auto=True))

    tenant_prefix = {'G': [], 'TO': ['TENANT_ID'], 'T': ['TENANT_ID'], 'C': ['TENANT_ID', 'COMPANY_ID']}[scope]
    if 'code' in mixes and codeuk:
        t.uks.append(tuple(tenant_prefix + ['CODE']))
    if 'doc' in mixes and docuk:
        t.uks.append(tuple(tenant_prefix + ['DOC_NO']))
    for c in t.cols:
        if c.unique:
            key = (c.name,) if c.name == 'PUBLIC_ID' or scope == 'G' else tuple(['TENANT_ID', c.name])
            if c.nullable and len(key) > 1:
                t.nuks.append(key)
            else:
                t.uks.append(key)
    for u in nuk:
        t.nuks.append(tuple(u))
    for u in uk:
        t.uks.append(tuple(u))
    for i in ix:
        t.ixs.append(tuple(i))
    for ch in chk:
        t.checks.append(ch)

    t.module.tables.append(t)
    TABLES[name] = t
    return t
