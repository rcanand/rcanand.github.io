---
title: Model glossary run 01 - Core ID inventory
date: 2026-06-29
tags:
  - ai
  - llm
  - reference
  - ai-generated
excerpt: Run 01 of the model-ID glossary analysis - extracts and counts identifier strings, families, quantization labels, variants, parameter sizes, and providers across the Ollama, OpenRouter, and Artificial Analysis datasets.
---

# Run 01 - Core ID inventory across the three sources

Source code: `model_glossary_run_01_extract.py`  
Raw output: `model_glossary_run_01_output.txt`

## Code

```python
import json, re
from collections import Counter
DATA=".../data"

# ---- OLLAMA ----
oll=json.load(open(f"{DATA}/ollama_models.json"))['models']
fulltags=set(); quants=set(); variants=set(); params=set(); families=set(); tagsuffixes=set()
for mdl in oll:
    families.add(mdl.get('family',''))
    for key in ('tags','detailed_tags'):
        for t in mdl.get(key,[]):
            if t.get('full_tag'): fulltags.add(t['full_tag'])
            if t.get('quantization'): quants.add(t['quantization'])
            if t.get('variant'): variants.add(t['variant'])
            if t.get('parameters'): params.add(t['parameters'])
            if t.get('tag'): tagsuffixes.add(t['tag'])

# ---- OPENROUTER ----
orr=json.load(open(f"{DATA}/openrouter_models.json"))['data']
or_ids=set(); canon=set(); hf=set(); providers=set()
for m in orr:
    if m.get('id'): or_ids.add(m['id']); providers.add(m['id'].split('/')[0])
    if m.get('canonical_slug'): canon.add(m['canonical_slug'])
    if m.get('hugging_face_id'): hf.add(m['hugging_face_id'])

# ---- AA ----
aa=json.load(open(f"{DATA}/artificialanalysis_benchmark_data.json"))['data']
slugs=set(); names=set(); creators=set()
for m in aa:
    if m.get('slug'): slugs.add(m['slug'])
    if m.get('name'): names.add(m['name'])
    c=m.get('model_creator')
    if isinstance(c,dict): creators.add(c.get('name') or c.get('slug') or str(c))
    elif c: creators.add(str(c))

print("== COUNTS ==")
print(f"ollama: models={len(oll)} fulltags={len(fulltags)} families={len(families)} quants={len(quants)} variants={len(variants)} params={len(params)} tagsuffixes={len(tagsuffixes)}")
print(f"openrouter: ids={len(or_ids)} canonical={len(canon)} hf_ids={len(hf)} providers={len(providers)}")
print(f"AA: slugs={len(slugs)} names={len(names)} creators={len(creators)}")
print()
print("== OLLAMA QUANTIZATIONS (structured field) ==")
print(sorted(quants))
print("== OLLAMA VARIANTS ==")
print(sorted(variants))
print("== OLLAMA PARAMETERS ==")
print(sorted(params))
print("== OLLAMA FAMILIES ==")
print(sorted(families))
print("== OPENROUTER PROVIDER PREFIXES ==")
print(sorted(providers))
print("== AA MODEL CREATORS ==")
print(sorted(creators))
```

## Output

```
== COUNTS ==
ollama: models=236 fulltags=7388 families=236 quants=13 variants=5 params=66 tagsuffixes=4664
openrouter: ids=337 canonical=324 hf_ids=149 providers=57
AA: slugs=537 names=537 creators=51

== OLLAMA QUANTIZATIONS (structured field) ==
['F16', 'FP16', 'INT4', 'INT8', 'Q2_K', 'Q3_K_L', 'Q3_K_M', 'Q3_K_S', 'Q4_K_M', 'Q4_K_S', 'Q5_K_M', 'Q5_K_S', 'Q6_K']
== OLLAMA VARIANTS ==
['base', 'chat', 'code', 'instruct', 'text']
== OLLAMA PARAMETERS ==
['0.5B', '0.6B', '0.8B', '1.1B', '1.2B', '1.3B', '1.5B', '1.6B', '1.7B', '1.8B', '10.7B', '104B', '10B', '110B', '111B', '11B', '120B', '122B', '123B', '128B', '12B', '132B', '13B', '141B', '14B', '15B', '16B', '17B', '180B', '1B', '2.4B', '2.7B', '20B', '22B', '235B', '236B', '24B', '26B', '27B', '2B', '3.8B', '30B', '31B', '32B', '33B', '34B', '35B', '397B', '3B', '405B', '40B', '480B', '4B', '6.7B', '671B', '675B', '67B', '6B', '7.8B', '70B', '72B', '7B', '80B', '8B', '90B', '9B']
== OLLAMA FAMILIES ==
['alfred', 'all-minilm', 'athene-v2', 'aya', 'aya-expanse', 'bakllava', 'bespoke-minicheck', 'bge-large', 'bge-m3', 'codebooga', 'codegeex4', 'codegemma', 'codellama', 'codeqwen', 'codestral', 'codeup', 'cogito', 'cogito-2.1', 'command-a', 'command-r', 'command-r-plus', 'command-r7b', 'command-r7b-arabic', 'dbrx', 'deepcoder', 'deepscaler', 'deepseek-coder', 'deepseek-coder-v2', 'deepseek-llm', 'deepseek-ocr', 'deepseek-r1', 'deepseek-v2', 'deepseek-v2.5', 'deepseek-v3', 'deepseek-v3.1', 'deepseek-v3.2', 'deepseek-v4-flash', 'deepseek-v4-pro', 'devstral', 'devstral-2', 'devstral-small-2', 'dolphin-llama3', 'dolphin-mistral', 'dolphin-mixtral', 'dolphin-phi', 'dolphin3', 'dolphincoder', 'duckdb-nsql', 'embeddinggemma', 'everythinglm', 'exaone-deep', 'exaone3.5', 'falcon', 'falcon2', 'falcon3', 'firefunction-v2', 'functiongemma', 'gemini-3-flash-preview', 'gemma', 'gemma2', 'gemma3', 'gemma3n', 'gemma4', 'glm-4.6', 'glm-4.7', 'glm-4.7-flash', 'glm-5', 'glm-5.1', 'glm-ocr', 'glm4', 'goliath', 'gpt-oss', 'gpt-oss-safeguard', 'granite-code', 'granite-embedding', 'granite3-dense', 'granite3-guardian', 'granite3-moe', 'granite3.1-dense', 'granite3.1-moe', 'granite3.2', 'granite3.2-vision', 'granite3.3', 'granite4', 'granite4.1', 'granite4.1-guardian', 'hermes3', 'internlm2', 'kimi-k2', 'kimi-k2-thinking', 'kimi-k2.5', 'kimi-k2.6', 'kimi-k2.7-code', 'laguna-xs.2', 'lfm2', 'lfm2.5', 'lfm2.5-thinking', 'llama-guard3', 'llama-pro', 'llama2', 'llama2-chinese', 'llama2-uncensored', 'llama3', 'llama3-chatqa', 'llama3-gradient', 'llama3-groq-tool-use', 'llama3.1', 'llama3.2', 'llama3.2-vision', 'llama3.3', 'llama4', 'llava', 'llava-llama3', 'llava-phi3', 'magicoder', 'magistral', 'marco-o1', 'mathstral', 'medgemma', 'medgemma1.5', 'meditron', 'medllama2', 'megadolphin', 'minicpm-v', 'minicpm-v4.5', 'minicpm-v4.6', 'minimax-m2', 'minimax-m2.1', 'minimax-m2.5', 'minimax-m2.7', 'minimax-m3', 'ministral-3', 'mistral', 'mistral-large', 'mistral-large-3', 'mistral-medium-3.5', 'mistral-nemo', 'mistral-openorca', 'mistral-small', 'mistral-small3.1', 'mistral-small3.2', 'mistrallite', 'mixtral', 'moondream', 'mxbai-embed-large', 'nemotron', 'nemotron-3-nano', 'nemotron-3-super', 'nemotron-3-ultra', 'nemotron-cascade-2', 'nemotron-mini', 'nemotron3', 'neural-chat', 'nexusraven', 'nomic-embed-text', 'nomic-embed-text-v2-moe', 'notus', 'notux', 'nous-hermes', 'nous-hermes2', 'nous-hermes2-mixtral', 'nuextract', 'olmo-3', 'olmo-3.1', 'olmo2', 'open-orca-platypus2', 'openchat', 'opencoder', 'openhermes', 'openthinker', 'orca-mini', 'orca2', 'paraphrase-multilingual', 'phi', 'phi3', 'phi3.5', 'phi4', 'phi4-mini', 'phi4-mini-reasoning', 'phi4-reasoning', 'phind-codellama', 'qwen', 'qwen2', 'qwen2-math', 'qwen2.5', 'qwen2.5-coder', 'qwen2.5vl', 'qwen3', 'qwen3-coder', 'qwen3-coder-next', 'qwen3-embedding', 'qwen3-next', 'qwen3-vl', 'qwen3.5', 'qwen3.6', 'qwq', 'r1-1776', 'reader-lm', 'reflection', 'rnj-1', 'sailor2', 'samantha-mistral', 'shieldgemma', 'smallthinker', 'smollm', 'smollm2', 'snowflake-arctic-embed', 'snowflake-arctic-embed2', 'solar', 'solar-pro', 'sqlcoder', 'stable-beluga', 'stable-code', 'stablelm-zephyr', 'stablelm2', 'starcoder', 'starcoder2', 'starling-lm', 'tinydolphin', 'tinyllama', 'translategemma', 'tulu3', 'vicuna', 'wizard-math', 'wizard-vicuna', 'wizard-vicuna-uncensored', 'wizardcoder', 'wizardlm', 'wizardlm-uncensored', 'wizardlm2', 'xwinlm', 'yarn-llama2', 'yarn-mistral', 'yi', 'yi-coder', 'zephyr']
== OPENROUTER PROVIDER PREFIXES ==
['ai21', 'aion-labs', 'allenai', 'amazon', 'anthracite-org', 'anthropic', 'arcee-ai', 'baidu', 'bytedance', 'bytedance-seed', 'cognitivecomputations', 'cohere', 'deepcogito', 'deepseek', 'essentialai', 'google', 'gryphe', 'ibm-granite', 'inception', 'inclusionai', 'inflection', 'kwaipilot', 'liquid', 'mancer', 'meta-llama', 'microsoft', 'minimax', 'mistralai', 'moonshotai', 'morph', 'nex-agi', 'nousresearch', 'nvidia', 'openai', 'openrouter', 'perceptron', 'perplexity', 'poolside', 'prime-intellect', 'qwen', 'rekaai', 'relace', 'sao10k', 'stepfun', 'switchpoint', 'tencent', 'thedrummer', 'undi95', 'upstage', 'writer', 'x-ai', 'xiaomi', 'z-ai', '~anthropic', '~google', '~moonshotai', '~openai']
== AA MODEL CREATORS ==
['AI21 Labs', 'Alibaba', 'Allen Institute for AI', 'Amazon', 'Anthropic', 'Arcee AI', 'Baidu', 'ByteDance Seed', 'China Mobile', 'Cohere', 'Databricks', 'Deep Cogito', 'DeepSeek', 'Google', 'IBM', 'Inception', 'InclusionAI', 'Kimi', 'Korea Telecom', 'KwaiKAT', 'LG AI Research', 'Liquid AI', 'LongCat', 'MBZUAI Institute of Foundation Models', 'Meta', 'Microsoft', 'MiniMax', 'Mistral', 'Motif Technologies', 'NVIDIA', 'Nanbeige', 'Naver', 'Nous Research', 'OpenAI', 'OpenBMB', 'OpenChat', 'Perplexity', 'Prime Intellect', 'Reka AI', 'Sarvam', 'ServiceNow', 'Snowflake', 'StepFun', 'Swiss AI Initiative', 'TII UAE', 'Tencent', 'Trillion Labs', 'Upstage', 'Xiaomi', 'Z AI', 'xAI']
```
