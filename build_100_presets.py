import re

with open('lib/core/services/animation_presets_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

categories = ['basic', 'shake', 'light', 'glitch', 'threeD', 'motion', 'retro', 'cinematic']

existing_ids = set()
existing_names = set()

# Parse existing items
blocks = re.findall(r'AnimationPresetModel\(([\s\S]*?)\),', text)
for b in blocks:
    m_id = re.search(r"id:\s*['\"]([^'\"]+)['\"]", b)
    m_name = re.search(r"name:\s*['\"]([^'\"]+)['\"]", b)
    if m_id: existing_ids.add(m_id.group(1))
    if m_name: existing_names.add(m_name.group(1))

print(f'Starting with {len(existing_ids)} existing presets.')

# Deficit counts:
# basic: 70 -> needs 30
# shake: 30 -> needs 70
# light: 70 -> needs 30
# glitch: 70 -> needs 30
# threeD: 60 -> needs 40
# motion: 60 -> needs 40
# retro: 60 -> needs 40
# cinematic: 100 -> needs 0 (already 100!)
# Plus trending curator: 100 curated from top presets!

# Let's craft the exact unique presets needed for each category
# with distinctive technical descriptions and real character.

