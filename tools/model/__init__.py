"""NOONA PLUS unified data model - one file per canonical package (01..30)."""
import importlib

# ملفات النموذج حسب السجل الموحد للحزم الثلاثين
MODEL_FILES = [
    'm06_reference', 'm01_platform', 'm02_security', 'm03_workflow', 'm04_dms', 'm05_correspondence',
    'm25_localization', 'm07_gl', 'm08_ar', 'm09_ap', 'm10_cash', 'm11_inventory', 'm12_procurement',
    'm13_sales', 'm14_assets', 'm15_projects', 'm16_real_estate', 'm17_property', 'm18_maintenance',
    'm19_hr', 'm20_payroll', 'm21_manufacturing', 'm22_bi', 'm23_api', 'm24_ai', 'm26_qa',
    'm27_migration', 'm28_pilot', 'm29_deployment', 'm30_operations', 'm31_healthcare', 'm32_auto_service', 'm33_transport',
]

# ترتيب التثبيت (يعتمد على الاعتماديات لا على رقم الحزمة)
INSTALL_ORDER = [
    'REF', 'PLT', 'SEC', 'WF', 'DMS', 'COR', 'LOC', 'GL', 'AR', 'AP', 'CSH', 'INV', 'PUR', 'SAL', 'FA',
    'PRJ', 'RE', 'PRP', 'MNT', 'HR', 'PAY', 'MFG', 'HIS', 'AUT', 'TRN', 'BI', 'API', 'AI', 'QA', 'MIG', 'PIL', 'DEP', 'OPS',
]


def load_all():
    for f in MODEL_FILES:
        importlib.import_module(f'model.{f}')
