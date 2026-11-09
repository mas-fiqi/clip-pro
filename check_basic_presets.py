import re

with open('lib/core/services/animation_presets_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Find basic presets
m = re.findall(r"id:\s*['\"]([^'\"]+)['\"]\s*,\s*name:\s*['\"]([^'\"]+)['\"][\s\S]*?category:\s*AnimationCategory\.basic", text)
print(f"Total basic in data: {len(m)}")
for pid, pname in m[:25]:
    print(f"  {pid}: {pname}")

