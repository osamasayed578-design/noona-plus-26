"""أدوات مشتركة لملفات الكتالوج."""
LIST = '.a-IRR-table td a'


def nav(text, wait=2500):
    """إجراء التقاط: الانتقال عبر عنصر في القائمة الجانبية (روابطه تحمل checksum الصفحة)."""
    return {'eval': "(() => { try { apex.jQuery('#t_TreeNav').treeView('expandAll'); } catch (e) {} const a = [...document.querySelectorAll('#t_TreeNav a')].find((x) => x.textContent.trim() === '"
                    + text + "'); if (a) location.href = a.href; })()", 'wait': wait}


def click_text(text, wait=2500):
    """النقر على رابط أو زر بنصه الكامل."""
    return {'eval': "(() => { const a = [...document.querySelectorAll('a, button')].find((x) => x.textContent.trim() === '"
                    + text + "'); if (a) a.click(); })()", 'wait': wait}
