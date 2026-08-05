---
title: Model glossary run 04 - Codename context resolution
date: 2026-06-29
tags:
  - ai
  - llm
  - reference
  - ai-generated
excerpt: Run 04 of the model-ID glossary analysis - resolves context for obscure codename tokens (rnj, hy3, jt, rsnsft, laguna, ling, etc.) by matching them against identifier strings across all three datasets.
---

# Run 04 - Context resolution for obscure codename tokens

Source code: `model_glossary_run_04_codenames.py`  
Raw output: `model_glossary_run_04_output.txt`

## Code

```python
import json, re
DATA=".../data"
strings=[]
oll=json.load(open(f"{DATA}/ollama_models.json"))['models']
for mdl in oll:
    strings.append(("ollama-family", mdl.get('family','')))
orr=json.load(open(f"{DATA}/openrouter_models.json"))['data']
for m in orr:
    if m.get('id'): strings.append(("or-id", m['id']))
aa=json.load(open(f"{DATA}/artificialanalysis_benchmark_data.json"))['data']
for m in aa:
    if m.get('slug'): strings.append(("aa-slug", m['slug']))
    if m.get('name'): strings.append(("aa-name", m['name']))

# obscure / candidate-codename tokens to resolve via context
targets=['rnj','hy3','jt','rsnsft','speciale','x1','owl','tars','midm','kat','trinity','n2','mk1',
         'laguna','seed','ling','ring','nova','step','saba','hanami','motif','muse','spark',
         'nanbeige','longcat','doubao','apriel','apertus','pareto','virtuoso','tri','terminus']
for t in targets:
    matches=sorted(set(s for k,s in strings if re.search(r'(?i)\b'+re.escape(t)+r'\b', s) or t in s.lower()))[:4]
    print(f"{t:12s} -> {matches}")
```

## Output

```
rnj          -> ['essentialai/rnj-1-instruct', 'rnj-1']
hy3          -> ['Hy3-preview (Non-reasoning)', 'Hy3-preview (Reasoning)', 'hy3', 'hy3-non-reasoning']
jt           -> ['JT-35B-Flash', 'JT-MINI', 'jt-35b-flash', 'jt-mini']
rsnsft       -> ['midm-250-pro-rsnsft']
speciale     -> ['DeepSeek V3.2 Speciale', 'deepseek-v3-2-speciale']
x1           -> ['sao10k/l3.1-70b-hanami-x1']
owl          -> ['openrouter/owl-alpha']
tars         -> ['bytedance/ui-tars-1.5-7b']
midm         -> ['midm-250-pro-rsnsft']
kat          -> ['KAT Coder Pro V2', 'KAT-Coder-Pro V1', 'kat-coder-pro-v1', 'kat-coder-pro-v2']
trinity      -> ['Trinity Large Thinking', 'arcee-ai/trinity-large-thinking', 'arcee-ai/trinity-mini', 'trinity-large-thinking']
n2           -> ['Qwen2 Instruct 72B', 'Qwen2.5 Coder Instruct 32B', 'Qwen2.5 Coder Instruct 7B ', 'Qwen2.5 Instruct 32B']
mk1          -> ['perceptron/perceptron-mk1']
laguna       -> ['laguna-xs.2', 'poolside/laguna-m.1:free', 'poolside/laguna-xs.2:free']
seed         -> ['Doubao Seed Code', 'HyperCLOVA X SEED Think (32B)', 'Seed-OSS-36B-Instruct', 'bytedance-seed/seed-1.6']
ling         -> ['Ling 2.6 Flash', 'Ling-1T', 'Ling-2.6-1T', 'Ling-flash-2.0']
ring         -> ['Ring-1T', 'Ring-2.6-1T', 'Ring-flash-2.0', 'inclusionai/ring-2.6-1t']
nova         -> ['Nova 2.0 Lite (Non-reasoning)', 'Nova 2.0 Lite (high)', 'Nova 2.0 Lite (low)', 'Nova 2.0 Lite (medium)']
step         -> ['Step 3.5 Flash', 'Step 3.5 Flash 2603', 'Step 3.7 Flash', 'Step3 VL 10B']
saba         -> ['Mistral Saba', 'mistral-saba', 'mistralai/mistral-saba']
hanami       -> ['sao10k/l3.1-70b-hanami-x1']
motif        -> ['Motif-2-12.7B-Reasoning', 'motif-2-12-7b']
muse         -> ['Muse Spark', 'muse-spark']
spark        -> ['Muse Spark', 'muse-spark']
nanbeige     -> ['Nanbeige4.1-3B', 'nanbeige4-1-3b']
longcat      -> ['LongCat Flash Lite', 'longcat-flash-lite']
doubao       -> ['Doubao Seed Code', 'doubao-seed-code']
apriel       -> ['Apriel-v1.5-15B-Thinker', 'Apriel-v1.6-15B-Thinker', 'apriel-v1-5-15b-thinker', 'apriel-v1-6-15b-thinker']
apertus      -> ['Apertus 70B Instruct', 'Apertus 8B Instruct', 'apertus-70b-instruct', 'apertus-8b-instruct']
pareto       -> ['openrouter/pareto-code']
virtuoso     -> ['arcee-ai/virtuoso-large']
tri          -> ['Tri-21B-Think', 'Tri-21B-think Preview', 'Trinity Large Thinking', 'arcee-ai/trinity-large-thinking']
terminus     -> ['DeepSeek V3.1 Terminus (Non-reasoning)', 'DeepSeek V3.1 Terminus (Reasoning)', 'deepseek-v3-1-terminus', 'deepseek-v3-1-terminus-reasoning']
```
