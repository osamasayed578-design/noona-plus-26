prompt --application/pages/page_00042
begin
--   Manifest
--     PAGE: 00042
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>127
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>42
,p_name=>'Voucher'
,p_alias=>'VOUCHER'
,p_step_title=>'سند'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'// شبكة السطور: بحث الحساب بالرمز أو الاسم، مركز التكلفة، مجاميع مباشرة، Enter في آخر سطر يضيف سطراً',
'(function () {',
'    var box = document.getElementById(''nnJe''); if (!box) return;',
'    var ro = box.dataset.readonly === ''Y'', je = box.dataset.kind !== ''CV'', item = box.dataset.item;',
'    var data = function (id) { var el = document.getElementById(id); try { return JSON.parse(el ? el.textContent : ''[]'') || []; } catch (e) { return []; } };',
'    var lines = data(''nnJeLines''), accts = data(''nnJeAccts''), ccs = data(''nnJeCcs'');',
'    var names = {}, rules = {}, ccName = {};',
'    accts.forEach(function (a) { names[a.a] = a.n; rules[a.a] = a.r; });',
'    ccs.forEach(function (c) { ccName[c.id] = c.n; });',
'    var fmt = function (n) { return (Math.round((n || 0) * 100) / 100).toLocaleString(''en-US'', {minimumFractionDigits: 2}); };',
'    var esc = function (s) { return String(s == null ? '''' : s).replace(/[&<>"]/g, function (c) { return {''&'':''&amp;'',''<'':''&lt;'',''>'':''&gt;'',''"'':''&quot;''}[c]; }); };',
'    var ccOpts = function (v) { return ''<option value="">-</option>'' + ccs.map(function (c) {',
'        return ''<option value="'' + c.id + ''"'' + (String(c.id) === String(v || '''') ? '' selected'' : '''') + ''>'' + esc(c.n) + ''</option>''; }).join(''''); };',
'    var amtHead = je ? ''<th>مدين</th><th>دائن</th>'' : ''<th>المبلغ</th>'';',
'    var html = ''<table class="nn-je-table"><thead><tr><th>#</th><th>الحساب</th>'' + amtHead + ''<th>مركز التكلفة</th><th>البيان</th>'' + (ro ? '''' : ''<th></th>'') + ''</tr></thead><tbody></tbody>''',
'        + ''<tfoot><tr><td></td><td>الإجمالي <span class="nn-je-diff"></span></td>'' + (je ? ''<td class="nn-je-tdr"></td><td class="nn-je-tcr"></td>'' : ''<td class="nn-je-tdr"></td>'')',
'        + ''<td colspan="'' + (ro ? 2 : 3) + ''"></td></tr></tfoot></table>''',
'        + (ro ? '''' : ''<datalist id="nnAccts">'' + accts.map(function (a) { return ''<option value="'' + esc(a.a) + ''">'' + esc(a.a + '' - '' + a.n) + ''</option>''; }).join('''') + ''</datalist>''',
'        + ''<button type="button" class="t-Button t-Button--small nn-je-add"><span class="fa fa-plus" aria-hidden="true"></span> إضافة سطر</button>'');',
'    box.innerHTML = html;',
'    var tbody = box.querySelector(''tbody'');',
'    var num = function (tr, cls, key) { var el = tr.querySelector(cls); return parseFloat(el ? el.value : tr.dataset[key]) || 0; };',
'    function totals() {',
'        var dr = 0, cr = 0;',
'        tbody.querySelectorAll(''tr'').forEach(function (tr) {',
'            if (je) { dr += num(tr, ''.nn-je-dr'', ''d''); cr += num(tr, ''.nn-je-cr'', ''c''); } else { dr += num(tr, ''.nn-je-amt'', ''m''); }',
'            if (!ro) {',
'                var a = tr.querySelector(''.nn-je-acc'').value.trim(), cc = tr.querySelector(''.nn-je-cc'');',
'                cc.classList.toggle(''is-required'', rules[a] === ''REQUIRED'' && !cc.value);',
'                cc.disabled = rules[a] === ''FORBIDDEN''; if (cc.disabled) cc.value = '''';',
'            }',
'        });',
'        box.querySelector(''.nn-je-tdr'').textContent = fmt(dr);',
'        var d = box.querySelector(''.nn-je-diff'');',
'        if (je) {',
'            box.querySelector(''.nn-je-tcr'').textContent = fmt(cr);',
'            var diff = Math.round((dr - cr) * 100) / 100;',
'            d.textContent = diff === 0 ? (dr > 0 ? ''✓ متوازن'' : '''') : ''(الفرق '' + fmt(Math.abs(diff)) + '')'';',
'            d.className = ''nn-je-diff '' + (diff === 0 ? ''is-ok'' : ''is-bad'');',
'        }',
'        var t = document.getElementById(''nnCvTotal''); if (t) t.textContent = fmt(dr);',
'    }',
'    function addRow(l) {',
'        l = l || {}; var tr = document.createElement(''tr''); var n = tbody.children.length + 1;',
'        if (ro) {',
'            tr.dataset.d = l.d || 0; tr.dataset.c = l.c || 0; tr.dataset.m = l.m || 0;',
'            tr.innerHTML = ''<td>'' + n + ''</td><td>'' + esc(l.a) + '' - '' + esc(names[l.a] || '''') + ''</td>''',
'                + (je ? ''<td>'' + (l.d ? fmt(l.d) : '''') + ''</td><td>'' + (l.c ? fmt(l.c) : '''') + ''</td>'' : ''<td>'' + fmt(l.m) + ''</td>'')',
'                + ''<td>'' + esc(ccName[l.cc] || '''') + ''</td><td>'' + esc(l.t) + ''</td>'';',
'        } else {',
'            var amt = je ? ''<td><input class="nn-je-dr" type="number" step="0.01" min="0" value="'' + (l.d || '''') + ''" aria-label="مدين"></td>''',
'                         + ''<td><input class="nn-je-cr" type="number" step="0.01" min="0" value="'' + (l.c || '''') + ''" aria-label="دائن"></td>''',
'                         : ''<td><input class="nn-je-amt" type="number" step="0.01" min="0" value="'' + (l.m || '''') + ''" aria-label="المبلغ"></td>'';',
'            tr.innerHTML = ''<td class="nn-je-no">'' + n + ''</td><td><input class="nn-je-acc" list="nnAccts" value="'' + esc(l.a) + ''" placeholder="رمز أو اسم الحساب" aria-label="الحساب">''',
'                + ''<small class="nn-je-name">'' + esc(names[l.a] || '''') + ''</small></td>'' + amt',
'                + ''<td><select class="nn-je-cc" aria-label="مركز التكلفة">'' + ccOpts(l.cc) + ''</select></td>''',
'                + ''<td><input class="nn-je-txt" value="'' + esc(l.t) + ''" aria-label="البيان"></td>''',
'                + ''<td><button type="button" class="t-Button t-Button--small t-Button--noUI nn-je-del" title="حذف السطر"><span class="fa fa-trash-o" aria-hidden="true"></span></button></td>'';',
'        }',
'        tbody.appendChild(tr); return tr;',
'    }',
'    if (lines.length) { lines.forEach(addRow); } else if (!ro) { addRow(); if (je) addRow(); }',
'    totals();',
'    if (ro) return;',
'    box.addEventListener(''input'', function (e) {',
'        var tr = e.target.closest(''tr''); if (!tr) return;',
'        if (e.target.classList.contains(''nn-je-acc'')) {',
'            var v = e.target.value.trim(), hit = names[v] ? v : null;',
'            if (!hit) { accts.some(function (a) { if (a.n === v) { hit = a.a; return true; } }); if (hit) e.target.value = hit; }',
'            tr.querySelector(''.nn-je-name'').textContent = hit ? names[hit] : '''';',
'        }',
'        if (e.target.classList.contains(''nn-je-dr'') && e.target.value) tr.querySelector(''.nn-je-cr'').value = '''';',
'        if (e.target.classList.contains(''nn-je-cr'') && e.target.value) tr.querySelector(''.nn-je-dr'').value = '''';',
'        totals();',
'    });',
'    box.addEventListener(''change'', totals);',
'    box.addEventListener(''click'', function (e) {',
'        if (e.target.closest(''.nn-je-add'')) { addRow().querySelector(''.nn-je-acc'').focus(); }',
'        if (e.target.closest(''.nn-je-del'')) { e.target.closest(''tr'').remove();',
'            tbody.querySelectorAll(''.nn-je-no'').forEach(function (td, i) { td.textContent = i + 1; }); totals(); }',
'    });',
'    box.addEventListener(''keydown'', function (e) {',
'        if (e.key === ''Enter'' && e.target.tagName === ''INPUT'') { e.preventDefault();',
'            var tr = e.target.closest(''tr'');',
'            if (!tr.nextElementSibling) addRow().querySelector(''.nn-je-acc'').focus(); else tr.nextElementSibling.querySelector(''.nn-je-acc'').focus(); }',
'    });',
'    $(document).on(''apexbeforepagesubmit'', function () {',
'        var out = [];',
'        tbody.querySelectorAll(''tr'').forEach(function (tr) {',
'            var a = tr.querySelector(''.nn-je-acc'').value.trim(), t = tr.querySelector(''.nn-je-txt'').value.trim(),',
'                cc = parseInt(tr.querySelector(''.nn-je-cc'').value, 10) || null;',
'            if (je) {',
'                var d = parseFloat(tr.querySelector(''.nn-je-dr'').value) || null, c = parseFloat(tr.querySelector(''.nn-je-cr'').value) || null;',
'                if (a || d || c) out.push({a: a, d: d, c: c, cc: cc, t: t || null});',
'            } else {',
'                var m = parseFloat(tr.querySelector(''.nn-je-amt'').value) || null;',
'                if (a || m) out.push({a: a, m: m, cc: cc, t: t || null});',
'            }',
'        });',
'        $s(item, JSON.stringify(out));',
'    });',
'})();'))
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000224)
,p_plug_name=>'ملخص السند'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P42_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_csh_pkg.voucher_header(:P42_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000225)
,p_plug_name=>'بيانات السند'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P42_ID is null or :P42_STATUS = ''DRAFT'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000226)
,p_name=>'P42_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820266000000225)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000227)
,p_name=>'P42_STATUS'
,p_item_sequence=>2
,p_item_plug_id=>wwv_flow_imp.id(91820266000000225)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000228)
,p_name=>'P42_TYPE'
,p_item_sequence=>3
,p_item_plug_id=>wwv_flow_imp.id(91820266000000225)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000229)
,p_name=>'P42_LINES'
,p_item_sequence=>4
,p_item_plug_id=>wwv_flow_imp.id(91820266000000225)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000230)
,p_name=>'P42_DATE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000225)
,p_prompt=>'التاريخ'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000231)
,p_name=>'P42_PLACE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000225)
,p_prompt=>'الصندوق / الحساب البنكي'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select ''صندوق: '' || name_ar d, ''BOX:'' || id r from csh_cash_box where company_id = noona_gl_pkg.company and status_code = ''ACTIVE'' union all select ''بنك: '' || name_ar || '' '' || account_no_masked, ''BANK:'' || id from csh_bank_account where company_id = noona_gl_pkg.company and status_code = ''ACTIVE'' order by 2 desc, 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000232)
,p_name=>'P42_CHANNEL'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000225)
,p_prompt=>'طريقة الدفع (للبنك)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:تحويل بنكي;BANK_TRANSFER,شيك;CHEQUE,بطاقة;CARD,محفظة إلكترونية;WALLET,بوابة دفع;GATEWAY,خصم مباشر;DIRECT_DEBIT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000233)
,p_name=>'P42_PARTY'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000225)
,p_prompt=>'الطرف (استلمنا من / صرفنا إلى)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000234)
,p_name=>'P42_REF'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820266000000225)
,p_prompt=>'المرجع (رقم الشيك أو الحوالة)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000235)
,p_name=>'P42_DESC'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820266000000225)
,p_prompt=>'البيان (وذلك عن)'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>2
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000236)
,p_name=>'P42_RATE'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820266000000225)
,p_prompt=>'سعر الصرف (لحساب بعملة أجنبية)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000237)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load Voucher'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P42_ID is not null then',
'    select status_code, txn_type, to_char(doc_date, ''YYYY-MM-DD''),',
'           case when cash_box_id is not null then ''BOX:'' || cash_box_id else ''BANK:'' || bank_account_id end,',
'           channel, counterparty_name, external_reference, description, exchange_rate',
'      into :P42_STATUS, :P42_TYPE, :P42_DATE, :P42_PLACE, :P42_CHANNEL, :P42_PARTY, :P42_REF, :P42_DESC, :P42_RATE',
'      from csh_transaction where id = :P42_ID and company_id = noona_gl_pkg.company;',
'else',
'    :P42_TYPE := case when :P42_TYPE in (''RECEIPT'', ''PAYMENT'', ''EXPENSE'') then :P42_TYPE else ''RECEIPT'' end;',
'    :P42_DATE := nvl(:P42_DATE, to_char(sysdate, ''YYYY-MM-DD''));',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820266000000237
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000238)
,p_plug_name=>'تفاصيل السند'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_ro varchar2(1) := case when :P42_ID is null or :P42_STATUS = ''DRAFT'' then ''N'' else ''Y'' end;',
'begin',
'    return ''<script type="application/json" id="nnJeLines">'' || replace(nvl(:P42_LINES, noona_csh_pkg.lines_json(:P42_ID)), ''</'', ''<\/'') || ''</script>''',
'        || case when l_ro = ''N'' then ''<script type="application/json" id="nnJeAccts">''',
'                || replace(noona_csh_pkg.accounts_json(:P42_TYPE), ''</'', ''<\/'') || ''</script>'' end',
'        || ''<script type="application/json" id="nnJeCcs">'' || replace(noona_gl_pkg.cost_centers_json, ''</'', ''<\/'') || ''</script>''',
'        || ''<div id="nnJe" class="nn-je" data-kind="CV" data-item="P42_LINES" data-readonly="'' || l_ro || ''"></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000239)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000238)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
,p_button_condition=>':P42_ID is null or :P42_STATUS = ''DRAFT'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000240)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820266000000238)
,p_button_name=>'SUBMIT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ وإرسال للاعتماد'
,p_button_position=>'NEXT'
,p_button_condition=>':P42_ID is null or :P42_STATUS = ''DRAFT'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000241)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Voucher'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P42_ID := noona_csh_pkg.save_voucher(',
'    p_id => :P42_ID, p_type => :P42_TYPE, p_date => to_date(:P42_DATE, ''YYYY-MM-DD''),',
'    p_box_id => case when :P42_PLACE like ''BOX:%'' then to_number(substr(:P42_PLACE, 5)) end,',
'    p_bank_id => case when :P42_PLACE like ''BANK:%'' then to_number(substr(:P42_PLACE, 6)) end,',
'    p_channel => :P42_CHANNEL, p_party => :P42_PARTY, p_description => :P42_DESC, p_reference => :P42_REF,',
'    p_lines => :P42_LINES, p_rate => :P42_RATE);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000239)
,p_process_success_message=>'تم حفظ السند'
,p_internal_uid=>91820266000000241
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000242)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Submit Voucher'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P42_ID := noona_csh_pkg.save_voucher(',
'    p_id => :P42_ID, p_type => :P42_TYPE, p_date => to_date(:P42_DATE, ''YYYY-MM-DD''),',
'    p_box_id => case when :P42_PLACE like ''BOX:%'' then to_number(substr(:P42_PLACE, 5)) end,',
'    p_bank_id => case when :P42_PLACE like ''BANK:%'' then to_number(substr(:P42_PLACE, 6)) end,',
'    p_channel => :P42_CHANNEL, p_party => :P42_PARTY, p_description => :P42_DESC, p_reference => :P42_REF,',
'    p_lines => :P42_LINES, p_rate => :P42_RATE);',
'noona_csh_pkg.submit_voucher(:P42_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000240)
,p_process_success_message=>'تم إرسال السند للاعتماد'
,p_internal_uid=>91820266000000242
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000243)
,p_plug_name=>'الإجراءات'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P42_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000244)
,p_name=>'P42_REASON'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000243)
,p_prompt=>'الملاحظة أو السبب (إلزامي للرفض والعكس)'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>2
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000245)
,p_name=>'P42_REV_DATE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000243)
,p_prompt=>'تاريخ العكس'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000246)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000243)
,p_button_name=>'APPROVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'اعتماد وترحيل'
,p_button_position=>'NEXT'
,p_button_condition=>':P42_STATUS = ''SUBMITTED'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000247)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820266000000243)
,p_button_name=>'REJECT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رفض وإعادة للمنشئ'
,p_button_position=>'NEXT'
,p_button_condition=>':P42_STATUS = ''SUBMITTED'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000248)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820266000000243)
,p_button_name=>'REVERSE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'عكس السند'
,p_button_position=>'NEXT'
,p_button_condition=>':P42_STATUS = ''SETTLED'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000249)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820266000000243)
,p_button_name=>'CANCEL_VOUCHER'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء المسودة'
,p_button_position=>'NEXT'
,p_button_condition=>':P42_STATUS = ''DRAFT'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000250)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(91820266000000243)
,p_button_name=>'PRINT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'طباعة السند'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:43:&SESSION.::&DEBUG.:RP,43:P43_ID:&P42_ID.'
,p_button_condition=>':P42_STATUS in (''SETTLED'', ''REVERSED'', ''SUBMITTED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000251)
,p_button_sequence=>60
,p_button_plug_id=>wwv_flow_imp.id(91820266000000243)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:41:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000252)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Approve'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_csh_pkg.approve_voucher(:P42_ID, :P42_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000246)
,p_process_success_message=>'تم اعتماد السند وترحيل قيده'
,p_internal_uid=>91820266000000252
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000253)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reject'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_csh_pkg.reject_voucher(:P42_ID, :P42_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000247)
,p_process_success_message=>'تم رفض السند وإعادته للمنشئ'
,p_internal_uid=>91820266000000253
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000254)
,p_process_sequence=>60
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reverse'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_csh_pkg.reverse_voucher(:P42_ID, nvl(to_date(:P42_REV_DATE, ''YYYY-MM-DD''), trunc(sysdate)), :P42_REASON);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000248)
,p_process_success_message=>'تم عكس السند بقيد مقابل مرحل'
,p_internal_uid=>91820266000000254
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000255)
,p_process_sequence=>70
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_csh_pkg.cancel_voucher(:P42_ID, :P42_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000249)
,p_process_success_message=>'تم إلغاء المسودة'
,p_internal_uid=>91820266000000255
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000256)
,p_branch_action=>'f?p=&APP_ID.:42:&SESSION.::&DEBUG.:42:P42_ID:&P42_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
