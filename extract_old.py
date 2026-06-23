import json

with open('D:/STARTUP/GARDA/aplikasi/garda/transcript_lensa_natrium.txt', encoding='utf-8') as f:
    line = f.read().strip()

obj = json.loads(line[line.find('{'):])
for call in obj.get('tool_calls', []):
    if 'ReplacementContent' in call.get('args', {}):
        code = call['args']['ReplacementContent']
        if isinstance(code, str) and code.startswith('"') and code.endswith('"'):
            code = json.loads(code)
        
        with open('D:/STARTUP/GARDA/aplikasi/garda/lib/app/modules/lensa_natrium/views/lensa_natrium_view.dart', 'w', encoding='utf-8') as out:
            out.write(code)

    if 'TargetContent' in call.get('args', {}):
        code = call['args']['TargetContent']
        if isinstance(code, str) and code.startswith('"') and code.endswith('"'):
            code = json.loads(code)
        
        # also write the controller from the other snippet if we can find it, 
        # but let's just make sure we extract TargetContent for old view just in case.
        with open('D:/STARTUP/GARDA/aplikasi/garda/lensa_old_view_target.dart', 'w', encoding='utf-8') as out:
            out.write(code)
