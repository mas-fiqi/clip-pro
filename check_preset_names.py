import re

with open('lib/core/services/animation_presets_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

matches = re.findall(r"id:\s*['\"]([^'\"]+)['\"]\s*,\s*name:\s*['\"]([^'\"]+)['\"]", text)
print(f"Total presets in data: {len(matches)}")
for pid, pname in matches[:20]:
    print(f"  {pid}: {pname}")

