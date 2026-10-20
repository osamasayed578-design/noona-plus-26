# يطبق مصادقة نونا بلس المخصصة (noona_authenticate) على تطبيقات APEX مصدرة سبق ربطها بـ NOONA Auth
# الاستخدام: python3 tools/apex_auth_patch.py apex/NOONA_MASTER/f115 apex/NOONA_PORTAL/f119
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from apexgen import noona_auth_scheme

REL = 'application/shared_components/security/authentications/oracle_apex_accounts.sql'


def patch(app_dir):
    path = os.path.join(app_dir, REL)
    s = open(path, encoding='utf-8').read()
    if "p_scheme_type=>'NATIVE_CUSTOM'" in s:
        print(f'{app_dir}: already custom')
        return
    open(path, 'w', encoding='utf-8').write(noona_auth_scheme(s))
    print(f'{app_dir}: NOONA custom authentication applied')


if __name__ == '__main__':
    for d in sys.argv[1:]:
        patch(d)
