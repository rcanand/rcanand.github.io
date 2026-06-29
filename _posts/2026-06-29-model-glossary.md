---
title: Model-ID glossary - every part in model identifiers
date: 2026-06-29
tags:
  - ai
  - llm
  - reference
excerpt: "A reference that decodes every meaningful stem found in model identifiers across Artificial Analysis, Ollama, and OpenRouter - parameter sizes, quantization/precision formats, runtimes, build-time techniques, capability suffixes, context windows, and vendor codenames."
---

# Model-ID Glossary: every "part" in the model identifiers across Artificial Analysis, Ollama, and OpenRouter

A reference that decodes every meaningful stem found in the model identifiers inside three
datasets:

- `artificialanalysis_benchmark_data.json` - Artificial Analysis benchmark catalog (the `slug`
  and `name` fields; the `id` field is an opaque UUID and is ignored).
- `ollama_models.json` - the Ollama library (the `full_tag` field of every `tags` /
  `detailed_tags` entry, e.g. `qwen3.6:35b-a3b-mtp-q4_K_M`, plus the structured
  `family` / `quantization` / `variant` / `parameters` fields).
- `openrouter_models.json` - the OpenRouter catalog (the `id`, `canonical_slug`, and
  `hugging_face_id` fields, e.g. `qwen/qwen3.7-max-20260520`).

Every claim about what a stem means was verified by web search; sources are linked inline and
collected in the [Bibliography](#bibliography). Where a stem could not be confidently decoded
even after research, it is listed in
[Stems not confidently decoded](#stems-not-confidently-decoded).

> Scope note: this is a glossary of *identifier parts* (the tokens you get by splitting IDs on
> `/ : - _ .`). It is not a catalog of individual models.

---

## Contents

1. [How a model ID is structured](#1-how-a-model-id-is-structured)
2. [Inventory and method](#2-inventory-and-method)
3. [Categorical dimension: model families (Ollama)](#3-categorical-dimension-model-families-ollama)
4. [Categorical dimension: provider / namespace prefixes (OpenRouter)](#4-categorical-dimension-provider--namespace-prefixes-openrouter)
5. [Categorical dimension: model creators (Artificial Analysis)](#5-categorical-dimension-model-creators-artificial-analysis)
6. [Parameter-size and architecture notation](#6-parameter-size-and-architecture-notation)
7. [Quantization and numeric precision (the GGUF block)](#7-quantization-and-numeric-precision-the-gguf-block)
8. [Advanced block / microscaling formats: NVFP4, MXFP8, MXFP4](#8-advanced-block--microscaling-formats-nvfp4-mxfp8-mxfp4)
9. [Runtime / packaging stems: MLX, GGUF](#9-runtime--packaging-stems-mlx-gguf)
10. [Training / architecture technique stems (rich)](#10-training--architecture-technique-stems-rich)
11. [Capability and variant suffixes](#11-capability-and-variant-suffixes)
12. [Context-window stems](#12-context-window-stems)
13. [Versioning and date-stamp conventions](#13-versioning-and-date-stamp-conventions)
14. [Vendor model-series codenames](#14-vendor-model-series-codenames)
15. [Scraping artifacts (not real stems)](#15-scraping-artifacts-not-real-stems)
16. [Stems not confidently decoded](#16-stems-not-confidently-decoded)
17. [Bibliography](#bibliography)

---

## 1. How a model ID is structured

Each source assembles IDs slightly differently, but they share the same building blocks:
`<namespace>/<family><version>-<size>-<variant/capability>-<quant/format>[-<date>]`.

**Ollama `full_tag`** = `model_name:tag`, where `tag` is a `-`-joined stack of size + variant +
format. Examples:

- `llama3.1:70b` -> family `llama3.1`, size `70b`.
- `gemma3:27b-it-qat` -> size `27b`, `it` (instruction-tuned), `qat` (quantization-aware training).
- `qwen3.6:35b-a3b-mtp-q4_K_M` -> `35b` total, `a3b` active (MoE), `mtp` (multi-token-prediction
  build), `q4_K_M` (GGUF quant).

**OpenRouter `id`** = `<provider>/<model>[:<suffix>]`, with a parallel `canonical_slug` that
usually appends a `YYYYMMDD` date, plus an optional `hugging_face_id`. Examples:

- `anthropic/claude-opus-4.8` / canonical `anthropic/claude-4.8-opus-20260528`.
- `nvidia/nemotron-3-ultra-550b-a55b:free` -> `550b` total, `a55b` active, `:free` tier.
- `qwen/qwen3.7-max-20260520`.

**Artificial Analysis `slug`** = a normalized handle (`gpt-oss-120b-low`), and `name` = the human
label that exposes the reasoning-effort tier in parentheses (`gpt-oss-120b (low)`,
`GPT-5.5 (xhigh)`).

---

## 2. Inventory and method

Counts produced by the extraction (see the run dumps: [run 01](/blog/model-glossary-run-01/), [run 02](/blog/model-glossary-run-02/), [run 03](/blog/model-glossary-run-03/), [run 04](/blog/model-glossary-run-04/), [run 05 - perf notes](/blog/model-glossary-run-05-perf-notes/), [run 06 - combination matrix](/blog/model-glossary-run-06-combination-matrix/), [run 07 - verification](/blog/model-glossary-run-07-verification/)):

| Source | Identifier strings | Notable distinct fields |
|---|---|---|
| Ollama | 7,388 `full_tag`s | 236 families, 13 structured quant labels, 5 variants, 66 param sizes |
| OpenRouter | 337 `id`s | 324 canonical slugs, 149 HF ids, 57 provider prefixes |
| Artificial Analysis | 537 slugs / 537 names | 51 model creators |

Tokenizing every identifier (split on `/ : - _ . ` whitespace) yields ~720 distinct tokens.
The sections below group them by what kind of thing they encode.

---

## 3. Categorical dimension: model families (Ollama)

The Ollama `family` field is a small controlled vocabulary (236 values). These name the model
lineage (base architecture / publisher series). Full list as found:

```
alfred, all-minilm, athene-v2, aya, aya-expanse, bakllava, bespoke-minicheck, bge-large, bge-m3,
codebooga, codegeex4, codegemma, codellama, codeqwen, codestral, codeup, cogito, cogito-2.1,
command-a, command-r, command-r-plus, command-r7b, command-r7b-arabic, dbrx, deepcoder,
deepscaler, deepseek-coder, deepseek-coder-v2, deepseek-llm, deepseek-ocr, deepseek-r1,
deepseek-v2, deepseek-v2.5, deepseek-v3, deepseek-v3.1, deepseek-v3.2, deepseek-v4-flash,
deepseek-v4-pro, devstral, devstral-2, devstral-small-2, dolphin-llama3, dolphin-mistral,
dolphin-mixtral, dolphin-phi, dolphin3, dolphincoder, duckdb-nsql, embeddinggemma, everythinglm,
exaone-deep, exaone3.5, falcon, falcon2, falcon3, firefunction-v2, functiongemma,
gemini-3-flash-preview, gemma, gemma2, gemma3, gemma3n, gemma4, glm-4.6, glm-4.7, glm-4.7-flash,
glm-5, glm-5.1, glm-ocr, glm4, goliath, gpt-oss, gpt-oss-safeguard, granite-code,
granite-embedding, granite3-dense, granite3-guardian, granite3-moe, granite3.1-dense,
granite3.1-moe, granite3.2, granite3.2-vision, granite3.3, granite4, granite4.1,
granite4.1-guardian, hermes3, internlm2, kimi-k2, kimi-k2-thinking, kimi-k2.5, kimi-k2.6,
kimi-k2.7-code, laguna-xs.2, lfm2, lfm2.5, lfm2.5-thinking, llama-guard3, llama-pro, llama2,
llama2-chinese, llama2-uncensored, llama3, llama3-chatqa, llama3-gradient, llama3-groq-tool-use,
llama3.1, llama3.2, llama3.2-vision, llama3.3, llama4, llava, llava-llama3, llava-phi3, magicoder,
magistral, marco-o1, mathstral, medgemma, medgemma1.5, meditron, medllama2, megadolphin,
minicpm-v, minicpm-v4.5, minicpm-v4.6, minimax-m2, minimax-m2.1, minimax-m2.5, minimax-m2.7,
minimax-m3, ministral-3, mistral, mistral-large, mistral-large-3, mistral-medium-3.5,
mistral-nemo, mistral-openorca, mistral-small, mistral-small3.1, mistral-small3.2, mistrallite,
mixtral, moondream, mxbai-embed-large, nemotron, nemotron-3-nano, nemotron-3-super,
nemotron-3-ultra, nemotron-cascade-2, nemotron-mini, nemotron3, neural-chat, nexusraven,
nomic-embed-text, nomic-embed-text-v2-moe, notus, notux, nous-hermes, nous-hermes2,
nous-hermes2-mixtral, nuextract, olmo-3, olmo-3.1, olmo2, open-orca-platypus2, openchat,
opencoder, openhermes, openthinker, orca-mini, orca2, paraphrase-multilingual, phi, phi3, phi3.5,
phi4, phi4-mini, phi4-mini-reasoning, phi4-reasoning, phind-codellama, qwen, qwen2, qwen2-math,
qwen2.5, qwen2.5-coder, qwen2.5vl, qwen3, qwen3-coder, qwen3-coder-next, qwen3-embedding,
qwen3-next, qwen3-vl, qwen3.5, qwen3.6, qwq, r1-1776, reader-lm, reflection, rnj-1, sailor2,
samantha-mistral, shieldgemma, smallthinker, smollm, smollm2, snowflake-arctic-embed,
snowflake-arctic-embed2, solar, solar-pro, sqlcoder, stable-beluga, stable-code, stablelm-zephyr,
stablelm2, starcoder, starcoder2, starling-lm, tinydolphin, tinyllama, translategemma, tulu3,
vicuna, wizard-math, wizard-vicuna, wizard-vicuna-uncensored, wizardcoder, wizardlm,
wizardlm-uncensored, wizardlm2, xwinlm, yarn-llama2, yarn-mistral, yi, yi-coder, zephyr
```

Recurring family stems and what they signal:

- **Publisher base series:** `llama*` (Meta), `gemma*` (Google), `qwen*` (Alibaba),
  `mistral*`/`mixtral`/`ministral`/`codestral`/`devstral`/`magistral` (Mistral),
  `phi*` (Microsoft), `granite*` (IBM), `command*` (Cohere), `deepseek*` (DeepSeek),
  `glm*` (Zhipu / Z.ai), `falcon*` (TII), `olmo*` (AI2), `nemotron*` (NVIDIA),
  `kimi-k2*` (Moonshot), `minimax-m*` (MiniMax), `solar*` (Upstage), `yi*` (01.AI),
  `exaone*` (LG), `internlm*` (Shanghai AI Lab), `smollm*` (HF), `lfm*` (Liquid AI).
- **Community fine-tune lineages:** `dolphin*`, `hermes*`/`openhermes`/`nous-hermes*`,
  `wizard*`, `vicuna`, `zephyr`, `orca*`, `notus`/`notux`, `samantha-*`, `starling-lm`,
  `xwinlm`, `stable-beluga`, `reflection`. These are tunes of a base model (named in this
  glossary's suffix sections) by independent groups.
- **Task-specialized families:** `*coder`/`codellama`/`codegemma`/`codeqwen`/`opencoder`/
  `magicoder`/`sqlcoder`/`duckdb-nsql` (code), `*math`/`mathstral` (math), `*-embed*`/`bge-*`/
  `nomic-embed-*`/`mxbai-embed-large`/`all-minilm`/`paraphrase-multilingual` (embeddings),
  `llava*`/`bakllava`/`moondream`/`minicpm-v`/`*-vision`/`*vl` (vision), `med*` (medical),
  `*guard*`/`shieldgemma`/`*-guardian`/`*safeguard` (safety), `reader-lm`/`nuextract` (extraction).

---

## 4. Categorical dimension: provider / namespace prefixes (OpenRouter)

The token before the first `/` in an OpenRouter `id` is the routing namespace (publisher or
hosting org), 57 distinct values:

```
ai21, aion-labs, allenai, amazon, anthracite-org, anthropic, arcee-ai, baidu, bytedance,
bytedance-seed, cognitivecomputations, cohere, deepcogito, deepseek, essentialai, google, gryphe,
ibm-granite, inception, inclusionai, inflection, kwaipilot, liquid, mancer, meta-llama, microsoft,
minimax, mistralai, moonshotai, morph, nex-agi, nousresearch, nvidia, openai, openrouter,
perceptron, perplexity, poolside, prime-intellect, qwen, rekaai, relace, sao10k, stepfun,
switchpoint, tencent, thedrummer, undi95, upstage, writer, x-ai, xiaomi, z-ai,
~anthropic, ~google, ~moonshotai, ~openai
```

- A leading **`~`** (e.g. `~anthropic/claude-fable-latest`) marks OpenRouter's "floating" /
  alias namespace - a moving pointer (such as `-latest`) rather than a pinned dated build.
- **`openrouter/`** is OpenRouter's own meta-models (`openrouter/fusion`, `openrouter/owl-alpha`,
  `openrouter/pareto-code`, the `auto` router).
- Community/roleplay finetuners appear as namespaces too: `sao10k`, `thedrummer`, `undi95`,
  `gryphe`, `anthracite-org`, `cognitivecomputations`, `mancer`.

---

## 5. Categorical dimension: model creators (Artificial Analysis)

Artificial Analysis stores a normalized `model_creator` (51 values), the organization that
trained the model:

```
AI21 Labs, Alibaba, Allen Institute for AI, Amazon, Anthropic, Arcee AI, Baidu, ByteDance Seed,
China Mobile, Cohere, Databricks, Deep Cogito, DeepSeek, Google, IBM, Inception, InclusionAI,
Kimi, Korea Telecom, KwaiKAT, LG AI Research, Liquid AI, LongCat, MBZUAI Institute of Foundation
Models, Meta, Microsoft, MiniMax, Mistral, Motif Technologies, NVIDIA, Nanbeige, Naver,
Nous Research, OpenAI, OpenBMB, OpenChat, Perplexity, Prime Intellect, Reka AI, Sarvam,
ServiceNow, Snowflake, StepFun, Swiss AI Initiative, TII UAE, Tencent, Trillion Labs, Upstage,
Xiaomi, Z AI, xAI
```

This is the cleanest "who made it" axis across the three datasets; the OpenRouter namespace and
Ollama family stems above are noisier proxies for the same idea.

---

## 6. Parameter-size and architecture notation

### 6.1 Plain parameter counts

- **`<n>b`** = billions of parameters (`7b`, `8b`, `70b`, `405b`, `671b`, `1t` = ~1 trillion).
  Ollama's structured `parameters` field enumerates: `0.5B 0.6B 0.8B 1.1B 1.2B 1.3B 1.5B 1.6B
  1.7B 1.8B 2B 2.4B 2.7B 3B 3.8B 4B 6B 6.7B 7B 7.8B 8B 9B 10B 10.7B 11B 12B 13B 14B 15B 16B 17B
  20B 22B 24B 26B 27B 30B 31B 32B 33B 34B 35B 40B 67B 70B 72B 80B 90B 104B 110B 111B 120B 122B
  123B 128B 132B 141B 180B 235B 236B 397B 405B 480B 671B 675B`.
- **`<n>m`** = millions of parameters (`135m`, `270m`, `350m`, `360m`, `567m`) - small/embedding
  models.

### 6.2 Mixture-of-Experts (MoE) notation

A sparse MoE model has many "expert" sub-networks; a router activates only a few per token, so
**active parameters << total parameters**. The IDs encode this three ways:

- **`<E>x<n>b`** - number of experts x size each. `8x7b` (Mixtral) = 8 experts of ~7B; also
  `8x22b`, `16x17b`, `128x17b`. ([Mixture-of-experts overview](https://arxiv.org/html/2505.09388v1))
- **`<n>E` / `<n>e`** - number of experts. Llama 4 `Scout-17B-16E` (16 experts),
  `Maverick-17B-128E` (128 experts). The `17B` is the active count.
  ([HF Llama-4-Scout-17B-16E](https://huggingface.co/meta-llama/Llama-4-Scout-17B-16E),
  [HF Llama-4-Maverick-17B-128E-Instruct](https://huggingface.co/meta-llama/Llama-4-Maverick-17B-128E-Instruct))
- **`a<n>b`** - **A**ctive billions per forward pass. `qwen3:235b-a22b` = 235B total / 22B active
  (128 experts, top-8 routed). Active stems observed: `a1b a2b a3b a4b a9b a10b a12b a13b a17b
  a22b a35b a47b a55b`. ([OpenRouter Qwen3-235B-A22B](https://openrouter.ai/qwen/qwen3-235b-a22b-2507),
  [Qwen3 Technical Report](https://arxiv.org/html/2505.09388v1),
  [EmergentMind Qwen3-235B-A22B](https://www.emergentmind.com/topics/qwen3-235b-a22b))

`moe` itself appears as a stem (e.g. `granite3-moe`, `nomic-embed-text-v2-moe`); its counterpart
`dense` marks a non-MoE model (`granite3-dense`).

### 6.3 Effective parameters (Matryoshka / MatFormer): `e2b`, `e4b`

Gemma 3n / Gemma 4 nano use `E2B` / `E4B` = **E**ffective ~2B / ~4B parameters. The architecture
is **MatFormer** (Matryoshka Transformer): one model with nested smaller submodels (E4B *contains*
E2B), so you can slice a smaller model out of the larger one. Because of **Per-Layer Embeddings
(PLE)** - large embedding tables used only for lookup - the *total* stored weights exceed the
*effective* compute parameters.

Resources:
- [Google Developers Blog - Introducing Gemma 3n](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/)
- [Google AI - Gemma 3n model overview](https://ai.google.dev/gemma/docs/gemma-3n)
- [Hugging Face - Understanding Gemma 3n: MatFormer](https://huggingface.co/blog/rishiraj/matformer-in-gemma-3n)
- [Alan Dao - Gemma 4 E2B & Per-Layer Embeddings notes](https://alandao.net/posts/gemma-4-e2b-per-layer-embeddings-ple-research-notes/)

---

## 7. Quantization and numeric precision (the GGUF block)

Quantization stores weights in fewer bits to shrink the model and speed up inference. The Ollama
tags carry the **GGUF** scheme used by `llama.cpp`. General pattern: **`Q<bits>_<type>[_<size>]`**.

### 7.1 What each part means

- **`Q`** = quantized (integer block quantization).
- **`<bits>`** = nominal bits per weight (`Q2`=2-bit ... `Q8`=8-bit). Effective bits-per-weight
  is a bit higher because of stored scales (e.g. `Q4_K_M` ~4.5 bpw).
- **`K`** = **k-quants**: a super-block structure (blocks of 256 weights split into sub-blocks)
  with their own quantized scales/mins, so bits are allocated more cleverly than the legacy
  scheme. ([llama.cpp discussion #2094](https://github.com/ggml-org/llama.cpp/discussions/2094))
- **`_S` / `_M` / `_L`** = small / medium / large *mix*: how many tensors get bumped to higher
  precision. `S` = smallest/most-aggressive, `L` = largest/highest-fidelity, `M` = the common
  balanced choice.
- **Legacy `_0` / `_1`** (no `K`): older round-to-nearest block quant. `_0` stores a scale only;
  `_1` stores scale **and** a min offset (asymmetric) - slightly better and slightly larger.
  Seen: `Q4_0 Q4_1 Q5_0 Q5_1 Q8_0`.

### 7.2 Quant labels found (Ollama)

| Label | Bits (nominal) | Notes |
|---|---|---|
| `Q2_K` | 2 | k-quant, smallest, largest quality hit |
| `Q3_K_S` / `Q3_K_M` / `Q3_K_L` | 3 | k-quant, S/M/L mixes |
| `Q4_0` / `Q4_1` | 4 | legacy block quant (`_1` asymmetric) |
| `Q4_K_S` / `Q4_K_M` | 4 | k-quant; **`Q4_K_M` is the common sweet spot** (~4.5 bpw) |
| `Q5_0` / `Q5_1` | 5 | legacy block quant |
| `Q5_K_S` / `Q5_K_M` | 5 | k-quant |
| `Q6_K` | 6 | k-quant, near-lossless |
| `Q8_0` / `Q8` | 8 | 8-bit, effectively lossless for most uses |

### 7.3 Floating-point and integer formats (full precision and low precision)

- **`F16` / `FP16`** = 16-bit float (1 sign / 5 exponent / 10 mantissa). Common "full precision"
  baseline for shipped weights.
- **`BF16`** = bfloat16 (1 / 8 / 7): FP32's exponent range with less mantissa precision; the
  preferred training format because it avoids loss-scaling.
- **`FP8`** = 8-bit float, either `E4M3` or `E5M2`.
- **`INT8` / `INT4`** = uniform integer quantization (equal-width buckets), 8- and 4-bit.

Resources for the GGUF/precision block:
- [llama.cpp - quantize README](https://github.com/ggml-org/llama.cpp/blob/master/tools/quantize/README.md)
- [arXiv - Which Quantization Should I Use? (llama.cpp eval)](https://arxiv.org/html/2601.14277v1)
- [Kaitchup - K-Quants, I-Quants, and Legacy Formats](https://kaitchup.substack.com/p/choosing-a-gguf-model-k-quants-i)
- [PromptQuorum - Q4_K_M vs Q4_0 vs Q8_0](https://www.promptquorum.com/local-llms/llm-quantization-explained)
- [APXML - GGUF File Format Explained](https://apxml.com/courses/practical-llm-quantization/chapter-5-quantization-formats-tooling/gguf-format)
- [Exxact - What is FP64, FP32, FP16](https://www.exxactcorp.com/blog/hpc/what-is-fp64-fp32-fp16)
- [RunPod - FP16/BF16/FP8 mixed precision](https://www.runpod.io/articles/guides/fp16-bf16-fp8-mixed-precision-speed-up-my-model-training)
- [Luminary - Understanding ML Numerical Formats](https://luminary.blog/techs/numbers-in-machine-learning/)
- [Towards AI - Why FP32/FP16/BF16/INT8 matter](https://pub.towardsai.net/understanding-llm-quantization-why-fp32-fp16-bf16-and-int8-matter-for-modern-ai-systems-076ea6eb9ca6)

---

## 8. Advanced block / microscaling formats: NVFP4, MXFP8, MXFP4

These are the newer 4-/8-bit *block-scaled* formats that appear on recent Gemma 4 / Qwen 3.5+ /
Laguna tags (`gemma4:27b-nvfp4`, `qwen3.5:27b-mxfp8`).

### 8.1 NVFP4 (NVIDIA FP4)

NVIDIA's 4-bit float for Blackwell GPUs. Element type **E2M1** (1 sign / 2 exponent / 1 mantissa).
Uses a small **block size of 16** values with an **E4M3 FP8 per-block scale**, plus an optional
FP32 outer scale. The small block (vs MXFP4's 32) reduces quantization error: ~3.5x smaller than
FP16, <1% accuracy loss, ~2x FP8 throughput on Blackwell.

Resources:
- [NVIDIA - Introducing NVFP4 for Efficient, Accurate Low-Precision Inference](https://developer.nvidia.com/blog/introducing-nvfp4-for-efficient-and-accurate-low-precision-inference/)
- [NVIDIA - NVFP4 Trains with 16-bit Precision at 4-bit Speed](https://developer.nvidia.com/blog/nvfp4-trains-with-precision-of-16-bit-and-speed-and-efficiency-of-4-bit/)
- [ZeroEntropy - NVFP4 explainer](https://www.zeroentropy.dev/concepts/nvfp4/)
- [Verda - NVFP4 Explained](https://verda.com/blog/nvfp4-nvidia-blackwell-intro)
- [Red Hat Developer - Accelerating LLMs with NVFP4](https://developers.redhat.com/articles/2026/02/04/accelerating-large-language-models-nvfp4-quantization)

### 8.2 MX formats: MXFP8, MXFP6, MXFP4 (and MXINT8)

**MX = "Microscaling"**, an Open Compute Project (OCP) standard. Block-wise quantization with a
**fixed block size of 32** elements sharing one scale factor. Name = `MX` + element type + bits:
**MXFP4** = E2M1, **MXFP8** = E4M3 or E5M2. (NVFP4 is essentially "MX-style but block-16 with an
FP8 scale".)

Resources:
- [OCP - Microscaling Formats (MX) v1.0 Specification](https://www.opencompute.org/documents/ocp-microscaling-formats-mx-v1-0-spec-final-pdf)
- [AMD Quark - Microscaling (MX) documentation](https://quark.docs.amd.com/latest/onnx/tutorial_microscaling_quantization.html)
- [FPRox - OCP MX Scaling Formats](https://fprox.substack.com/p/ocp-mx-scaling-formats)
- [EmergentMind - Microscaling (MX) Standard](https://www.emergentmind.com/topics/microscaling-mx-standard)
- [Wikipedia - Block floating point](https://en.wikipedia.org/wiki/Block_floating_point)

---

## 9. Runtime / packaging stems: MLX, GGUF

- **`mlx`** - the model is packaged for **Apple MLX**, Apple's array/ML framework for Apple
  silicon (unified memory, lazy evaluation, NumPy-like API). The team is `ml-explore`; "MLX" has
  no officially expanded acronym. An `mlx-bf16` tag = MLX weights kept at bfloat16.
  Resources: [GitHub ml-explore/mlx](https://github.com/ml-explore/mlx),
  [Apple Open Source - MLX](https://opensource.apple.com/projects/mlx/),
  [MLX framework site](https://mlx-framework.org/),
  [WWDC25 - Get started with MLX](https://developer.apple.com/videos/play/wwdc2025/315/).
- **GGUF** - the file/container format that the `Q*`/`F16` Ollama tags imply (successor to GGML).
  Covered by the llama.cpp and APXML links in [§7](#7-quantization-and-numeric-precision-the-gguf-block).

---

## 10. Training / architecture technique stems (rich)

These stems describe *how a model was built or tuned*, each with its own body of literature.

### 10.1 `qat` - Quantization-Aware Training

Simulates low-precision math during the forward pass while training, so the model learns to
compensate for quantization error - giving higher quality than post-training quantization (PTQ)
at the same bit width. Gemma QAT checkpoints reach near-FP16 quality at ~4-bit memory.

- [Google Developers Blog - Gemma 3 QAT](https://developers.googleblog.com/en/gemma-3-quantized-aware-trained-state-of-the-art-ai-to-consumer-gpus/)
- [Google - Gemma 4 with quantization-aware training](https://blog.google/innovation-and-ai/technology/developers-tools/quantization-aware-training-gemma-4/)
- [Gemma docs - QAT colab](https://gemma-llm.readthedocs.io/en/latest/colab_quantization_aware_training.html)

### 10.2 `mtp` - Multi-Token Prediction

A training objective (and inference trick) where extra heads predict tokens t+2, t+3, ... At
inference the MTP head acts as a speculative-decoding draft module (DeepSeek-V3, Qwen3-Next),
giving ~1.8x speedups. In Ollama tags it marks a build that ships the MTP head
(`qwen3.6:27b-mtp-q4_K_M`).

- [Sebastian Raschka - Multi-Token Prediction (MTP)](https://sebastianraschka.com/llm-architecture-gallery/mtp/)
- [DeepSeek Explained 4: Multi-Token Prediction](https://medium.com/data-science-collective/deepseek-explained-4-multi-token-prediction-33f11fe2b868)
- [NVIDIA Megatron-Bridge - Multi-Token Prediction docs](https://docs.nvidia.com/nemo/megatron-bridge/latest/training/multi-token-prediction.html)
- [arXiv - Insights into DeepSeek-V3 (MTP)](https://arxiv.org/pdf/2505.09343)

### 10.3 MoE - Mixture of Experts

Covered in [§6.2](#62-mixture-of-experts-moe-notation). Conditional computation: route each token
to a few of many experts; `dense` is the non-MoE opposite.

### 10.4 `yarn` (and `gradient`) - context-window extension

**YaRN = "Yet another RoPE extensioN"**: piecewise "NTK-by-parts" frequency scaling of Rotary
Position Embeddings plus an attention-softmax temperature, extending context length with <0.1%
extra training. Appears as `yarn-llama2`, `yarn-mistral`. `llama3-gradient` is a similarly
context-extended Llama 3 (by Gradient AI).

- [arXiv - YaRN: Efficient Context Window Extension](https://arxiv.org/abs/2309.00071)
- [arXiv (PDF) - YaRN](https://arxiv.org/pdf/2309.00071)
- [EleutherAI - YaRN](https://www.eleuther.ai/papers-blog/yarn-efficient-context-window-extension-of-large-language-models)
- [EmergentMind - YaRN](https://www.emergentmind.com/topics/yarn-yet-another-rope-extension-method)

### 10.5 `distill` - Knowledge distillation

Train a small "student" to mimic a large "teacher". `deepseek-r1` distilled Qwen/Llama students
inherit R1's chain-of-thought reasoning from ~800k R1-generated examples.

- [EmergentMind - DeepSeek-R1 Distilled Models](https://www.emergentmind.com/topics/deepseek-r1-distilled-models)
- [IBM - DeepSeek-R1 distilled models on watsonx.ai](https://www.ibm.com/new/announcements/deepseek-r1-distilled-models-now-available-on-watsonx-ai)
- [Analytics Vidhya - Distilled DeepSeek-R1](https://www.analyticsvidhya.com/blog/2025/02/distilled-deepseek-r1-model/)

### 10.6 `dpo` - Direct Preference Optimization

An RLHF-free preference-alignment method: directly raises the probability of preferred responses
over dispreferred ones, with no separate reward model or PPO loop. Appears as a suffix on some
community tunes.

- [Hugging Face - Preference Tuning LLMs with DPO](https://huggingface.co/blog/pref-tuning)
- [Tyler Romero - Direct Preference Optimization Explained](https://www.tylerromero.com/posts/2024-04-dpo/)

### 10.7 `laser` - Layer-Selective Rank Reduction

**LASER = LAyer-SElective Rank Reduction**: after training, replace selected weight matrices with
low-rank (SVD) approximations; counterintuitively this can *improve* reasoning. Used by
cognitivecomputations' Dolphin "laser" tunes.

- [arXiv - The Truth is in There (LASER)](https://arxiv.org/abs/2312.13558)
- [LASER project page](https://pratyushasharma.github.io/laser/)
- [GitHub - laserRMT (cognitivecomputations)](https://github.com/cognitivecomputations/laserRMT)
- [Microsoft Research - LASER brief](https://www.microsoft.com/en-us/research/quarterly-brief/jan-2024-brief/articles/improving-reasoning-in-language-models-with-laser-layer-selective-rank-reduction/)

### 10.8 `uncensored` / abliteration

`uncensored` = a fine-tune with safety/refusals removed. The related technique **abliteration**
("ablate" + "obliterate") removes the model's "refusal direction" in activation space via
representation engineering - editing weights rather than prompting around them.

- [Hugging Face - Uncensor any LLM with abliteration](https://huggingface.co/blog/mlabonne/abliteration)
- [abliteration.ai - What is an abliterated LLM?](https://abliteration.ai/abliterated-llm)
- [WebDecoy - What are abliterated models?](https://webdecoy.com/blog/wtf-are-abliterated-models-uncensored-llms-explained/)

---

## 11. Capability and variant suffixes

### 11.1 Post-training / tuning stage

| Stem | Meaning |
|---|---|
| `base` | raw pretrained LM, no instruction following |
| `instruct` | instruction-tuned to follow prompts |
| `it` | instruction-tuned (Gemma's label, same idea as `instruct`) |
| `chat` | tuned for multi-turn dialogue (often RLHF) |
| `text` | base/completion text variant (Ollama `variant`) |
| `code` / `coder` / `coding` | code-specialized |
| `dpo` | preference-aligned (see [§10.6](#106-dpo---direct-preference-optimization)) |

Resources: [Red Hat - How to navigate LLM model names](https://developers.redhat.com/articles/2025/04/03/how-navigate-llm-model-names),
[Alex Ewerlof - Base vs Instruct vs Thinking](https://blog.alexewerlof.com/p/base-models-vs-instruct-models),
[Medium - Base, Instruct, and Chat architectures](https://medium.com/@yashwanths_29644/llm-finetuning-series-05-llm-architectures-base-instruct-and-chat-models-a6219c39c362).

### 11.2 Reasoning

| Stem | Meaning |
|---|---|
| `reasoning` / `thinking` / `think` / `thinker` | model emits chain-of-thought before answering |
| `non` (as in `non-reasoning`) | the same model with thinking disabled |
| `deep` (`exaone-deep`, `deepscaler`) | reasoning-oriented variant |
| `low` / `medium` / `high` | **reasoning-effort tier** (compute vs latency), set in the prompt |
| `minimal` / `xhigh` | extra effort tiers exposed by newer GPT-5.x in the AA `name` field |

`qwq` = "Qwen with Questions" reasoning series. Resources:
[Sebastian Raschka - Understanding Reasoning LLMs](https://magazine.sebastianraschka.com/p/understanding-reasoning-llms),
[NVIDIA - Chain-of-Thought prompting glossary](https://www.nvidia.com/en-us/glossary/cot-prompting/),
[Qwen - QwQ-32B blog](https://qwenlm.github.io/blog/qwq-32b/),
[OpenAI - Introducing gpt-oss (reasoning-effort)](https://openai.com/index/introducing-gpt-oss/),
[gpt-oss model card (arXiv)](https://arxiv.org/pdf/2508.10925).

### 11.3 Modality

| Stem | Meaning |
|---|---|
| `vl` / `vision` | Vision-Language (text + image input) |
| `omni` | omni-modal (text/image/audio/video in, often speech out) |
| `ocr` | optical character recognition / document parsing |
| `audio` / `voxtral` | audio/speech input |
| `image` / `lyria` | image generation / audio generation specialist |
| `embed` / `embedding` | embedding model (vectors, not chat) |
| `reader` / `nuextract` | text extraction / reading |

Resources: [Qwen-VL (arXiv)](https://arxiv.org/abs/2308.12966),
[Qwen3-VL Technical Report (arXiv)](https://arxiv.org/abs/2511.21631),
[Qwen2.5-Omni (HF)](https://huggingface.co/Qwen/Qwen2.5-Omni-7B),
[LlamaIndex - What is Qwen-VL](https://www.llamaindex.ai/glossary/what-is-qwen-vl).

### 11.4 Safety / guardrail

`guard` / `guardian` / `shield` / `safeguard` = safety-classifier models that score prompts and
responses against a risk taxonomy (Llama Guard, ShieldGemma, Granite Guardian, gpt-oss-safeguard).
Resources: [EmergentMind - Llama Guard 3](https://www.emergentmind.com/topics/llama-guard-3),
[Medium - How Llama Guard improves AI safety](https://medium.com/@tahirbalarabe2/%EF%B8%8Fhow-llama-guard-improves-ai-safety-with-llm-based-moderation-73ff34980c5f).

### 11.5 Size / capability tiers (marketing scale)

Ordered roughly small -> large: `nano`, `micro`, `mini`, `xs`, `lite`, `small`, `medium`,
`large`, and the "premium" stems `pro`, `plus`, `max`, `ultra`, `premier`, `super`. These are
relative within a publisher's lineup, not absolute sizes.

### 11.6 Speed / serving variants

`flash`, `fast`, `turbo`, `instant`, `air`, `edge` = latency-optimized serving variants.
`flash-lite` = the cheapest/fastest tier. `scout` / `maverick` are Llama 4 codenames (not generic
size words). `nemo` = Mistral-NeMo (Mistral x NVIDIA collaboration). `next` = a
next-generation/preview architecture (`qwen3-next`, `qwen3-coder-next`).

### 11.7 Lifecycle / availability

`preview`, `exp` / `experimental`, `alpha`, `beta` = pre-release maturity. `latest` = moving
pointer to the newest build. `free` (`:free`) = OpenRouter's free-tier endpoint. `cloud` =
cloud-hosted (vs local) Ollama endpoint. `terminus` / `speciale` = named point-release variants
(DeepSeek). `instant` = Anthropic/AA fast tier.

---

## 12. Context-window stems

Tokens like `4k 8k 16k 32k 64k 128k 200k 256k 1m 1023 1048k` encode the **context window**
(maximum tokens). `128k` = 128,000 tokens; `1m` = ~1,000,000; `1048k` = 1,048,576 (1 Mi). Context
*extension* is done with techniques named in the ID: `yarn` and `gradient`
(see [§10.4](#104-yarn-and-gradient---context-window-extension)).

> Note: `1t` is **not** a context size - it means ~1 trillion *parameters* (`ling-1t`, `ring-1t`,
> `nemotron-3-ultra-...`). Disambiguate by position: a bare `1t`/`671b` near the size slot is
> parameters; a `1m`/`128k` is context.

---

## 13. Versioning and date-stamp conventions

- **`v0 v1 v2 v3 v4`, and dotted `3.1`, `4.8`, `2.5`** = model version numbers.
- **`r1`, `r7b`, `o1`/`o3`/`o4`, `k2`, `m2`/`m3`** = series/generation labels baked into a name
  (DeepSeek R-series, OpenAI o-series, Kimi K2, MiniMax M-series).
- **4-digit `YYMM` date** = release year+month: `2407` = Jul 2024, `2501` = Jan 2025, `2507` =
  Jul 2025 (Mistral, Qwen, Magistral, Devstral, Voxtral, Codestral). Many such stems appear:
  `2024 2025 2402 2407 2409 2411 2501 2502 2503 2505 2506 2507 2508 2509 2512 2603 ...` and
  4-digit `MMDD` forms (`0106 0324 0528 0905 1210 ...`).
- **8-digit `YYYYMMDD`** = full release date in OpenRouter `canonical_slug` (`...-20260528`).
- **Date words** also appear in AA names: `(May 2026)`, `dec`, `june`, `sep`.

Resources: [Mistral - Changelog](https://docs.mistral.ai/getting-started/changelog),
[Mistral - Large 2407 announcement](https://mistral.ai/news/mistral-large-2407/),
[Starmorph - LLM Model Names Decoded](https://blog.starmorph.com/blog/llm-model-names-decoded).

---

## 14. Vendor model-series codenames

These tokens are proprietary product names (not technique stems). Listed with the creator so the
ID parses cleanly:

| Stem(s) | Creator / source | Notes |
|---|---|---|
| `nova` | Amazon | Amazon Nova family |
| `command`, `command-a`, `command-r`, `r7b` | Cohere | Command / Command-R series |
| `nemotron`, `nemo` | NVIDIA / Mistral | NVIDIA Nemotron; Mistral-NeMo |
| `granite` | IBM | Granite series |
| `jamba` | AI21 | SSM-Transformer hybrid |
| `arctic` | Snowflake | Snowflake Arctic |
| `dbrx` | Databricks | |
| `seed`, `doubao`, `ui-tars` | ByteDance | Seed / Doubao / UI-TARS GUI agent |
| `kimi`, `k2` | Moonshot | Kimi K2 |
| `glm` | Z.ai / Zhipu | GLM series |
| `ernie` | Baidu | |
| `hunyuan` | Tencent | |
| `step` | StepFun | |
| `ling`, `ring` | InclusionAI | Ling / Ring (1T MoE) |
| `minimax`, `m2`/`m3` | MiniMax | M-series |
| `exaone` | LG AI Research | |
| `solar` | Upstage | |
| `sonar` | Perplexity | search-grounded |
| `r1-1776` | Perplexity | uncensored DeepSeek-R1 retune (1776 = US bicentennial) |
| `trinity`, `virtuoso` | Arcee AI | |
| `apriel` | ServiceNow | |
| `apertus` | Swiss AI Initiative | |
| `laguna` | Poolside | `m.1`, `xs.2` |
| `mimo` | Xiaomi | |
| `kat` | KwaiKAT (Kuaishou) | KAT-Coder |
| `longcat` | LongCat / Meituan | |
| `nanbeige` | Nanbeige | |
| `motif` | Motif Technologies | |
| `midm` | Korea Telecom (KT) | Mi:dm |
| `hyperclova` | Naver | HyperCLOVA X |
| `palmyra` | Writer | |
| `saba` | Mistral | regional (Arabic/South Asian) model |
| `magnum`, `rocinante`, `cydonia`, `skyfall`, `unslopnemo`, `euryale`, `lunaris`, `mythomax`, `remm`, `hanami` | community RP finetuners (TheDrummer, sao10k, Undi95, Gryphe, anthracite) | roleplay/creative tunes |
| `owl`, `fusion`, `pareto` | OpenRouter | meta/aggregate models |
| `mercury` | Inception | diffusion LLM |
| `perceptron`, `mk1` | Perceptron | |
| `fable`, `opus`, `sonnet`, `haiku` | Anthropic | Claude tiers |
| `grok` | xAI | |
| `gpt`, `chatgpt`, `oss`, `codex`, `o1`/`o3`/`o4`, `4o` | OpenAI | `oss` = open-weight |
| `gemini`, `gemma` | Google | |
| `phi` | Microsoft | |

---

## 15. Scraping artifacts (not real stems)

Some Ollama `full_tag` values were polluted by HTML/CSS during scraping and are **not** model-ID
parts. Excluded from the analysis but listed for transparency:

```
border-bottom:1px, margin-top:12px, padding:16px, font-size:11px, padding-left:20px, padding:7px,
padding:10px, font-size:13px, font-family:-apple-system, font-weight:600, max-width:900px,
border-bottom:2px, font-weight:500, padding:8px
```

Resulting noise tokens (`padding`, `font`, `px`, `margin`, `border`, `weight`, `collapse`,
`align`, `center`, `mailto`, etc.) should be ignored.

---

## 16. Stems not confidently decoded

After web research, these identifier fragments could not be expanded with confidence. They appear
to be proprietary names or undocumented internal tags; no authoritative source was found:

- **`rsnsft`** - in `midm-250-pro-rsnsft` (KT Mi:dm). Plausibly "reasoning SFT" but not confirmed
  by any source; left undecoded.
- **`hy3`** - the `Hy3-preview` model in the AA data; creator/expansion not identified.
- **`jt`** - `JT-35B-Flash` / `JT-MINI` (creator "China Mobile" in AA). The `JT` initials were
  not tied to a documented expansion.
- **`rnj-1`** - EssentialAI `rnj-1-instruct`; "rnj" is an undocumented codename.
- **`x1`** (in `l3.1-70b-hanami-x1`), **`mk1`** (`perceptron-mk1`), **`n2`** (`nex-n2-pro`) -
  internal revision tags with no published meaning beyond "mark 1 / version 2".
- **`speciale`** / **`terminus`** - DeepSeek point-release codenames; descriptive only, no
  technical definition published.
- **`trinity`, `virtuoso`, `owl`, `pareto`, `tars`, `muse`, `spark`, `kat`** - confirmed as
  product codenames (see [§14](#14-vendor-model-series-codenames)) but with no decomposable
  technical meaning.

---

## Bibliography

All web sources encountered, with titles and URLs.

### GGUF / quantization / numeric precision
- [llama.cpp - tools/quantize/README.md](https://github.com/ggml-org/llama.cpp/blob/master/tools/quantize/README.md)
- [Which Quantization Should I Use? A Unified Evaluation of llama.cpp Quantization (arXiv)](https://arxiv.org/html/2601.14277v1)
- [Quantizing Models - llama.cpp (Mintlify)](https://mintlify.com/ggml-org/llama.cpp/models/quantizing-models)
- [llama.cpp - Qwen docs](https://qwen.readthedocs.io/en/latest/quantization/llama.cpp.html)
- [Choosing a GGUF Model: K-Quants, I-Quants, and Legacy Formats (Kaitchup)](https://kaitchup.substack.com/p/choosing-a-gguf-model-k-quants-i)
- [Difference in different quantization methods - llama.cpp Discussion #2094](https://github.com/ggml-org/llama.cpp/discussions/2094)
- [Q4_K_M vs Q4_0 vs Q8_0: LLM Quantization Explained (PromptQuorum)](https://www.promptquorum.com/local-llms/llm-quantization-explained)
- [GGUF File Format Explained (APXML)](https://apxml.com/courses/practical-llm-quantization/chapter-5-quantization-formats-tooling/gguf-format)
- [What is FP64, FP32, FP16? Defining Floating Point (Exxact)](https://www.exxactcorp.com/blog/hpc/what-is-fp64-fp32-fp16)
- [How can FP16, BF16, or FP8 mixed precision speed up training? (RunPod)](https://www.runpod.io/articles/guides/fp16-bf16-fp8-mixed-precision-speed-up-my-model-training)
- [FP8, BF16, and INT8: Low-Precision Formats (Medium / StackGpu)](https://medium.com/@StackGpu/fp8-bf16-and-int8-how-low-precision-formats-are-revolutionizing-deep-learning-throughput-e6c1f3adabc2)
- [Understanding ML Numerical Formats (Luminary)](https://luminary.blog/techs/numbers-in-machine-learning/)
- [Understanding LLM Quantization: FP32, FP16, BF16, INT8 (Towards AI)](https://pub.towardsai.net/understanding-llm-quantization-why-fp32-fp16-bf16-and-int8-matter-for-modern-ai-systems-076ea6eb9ca6)
- [Accuracy Considerations - NVIDIA TensorRT](https://docs.nvidia.com/deeplearning/tensorrt/latest/inference-library/accuracy-considerations.html)

### NVFP4
- [Introducing NVFP4 for Efficient and Accurate Low-Precision Inference (NVIDIA)](https://developer.nvidia.com/blog/introducing-nvfp4-for-efficient-and-accurate-low-precision-inference/)
- [NVFP4 Trains with Precision of 16-Bit and Speed of 4-Bit (NVIDIA)](https://developer.nvidia.com/blog/nvfp4-trains-with-precision-of-16-bit-and-speed-and-efficiency-of-4-bit/)
- [NVFP4: NVIDIA Blackwell microscaling 4-bit float format (ZeroEntropy)](https://www.zeroentropy.dev/concepts/nvfp4/)
- [NVFP4 Explained: How NVIDIA Blackwell Unlocks Low-Precision Floating Point (Verda)](https://verda.com/blog/nvfp4-nvidia-blackwell-intro)
- [Accelerating large language models with NVFP4 quantization (Red Hat Developer)](https://developers.redhat.com/articles/2026/02/04/accelerating-large-language-models-nvfp4-quantization)
- [NVFP4: Same Accuracy with 2.3x Higher Throughput (Medium / B. Marie)](https://medium.com/data-science-collective/nvfp4-same-accuracy-with-2-3x-higher-throughput-for-4-bit-llms-03518ecba108)
- [NVFP4 Quantization (NVIDIA DGX Spark)](https://build.nvidia.com/spark/nvfp4-quantization)

### MX / microscaling formats
- [OCP Microscaling Formats (MX) v1.0 Specification (Open Compute Project)](https://www.opencompute.org/documents/ocp-microscaling-formats-mx-v1-0-spec-final-pdf)
- [Microscaling (MX) - AMD Quark documentation](https://quark.docs.amd.com/latest/onnx/tutorial_microscaling_quantization.html)
- [OCP MX Scaling Formats (FPRox)](https://fprox.substack.com/p/ocp-mx-scaling-formats)
- [Microscaling (MX) Standard (EmergentMind)](https://www.emergentmind.com/topics/microscaling-mx-standard)
- [Block floating point (Wikipedia)](https://en.wikipedia.org/wiki/Block_floating_point)
- [An Empirical Study of Microscaling Formats for Low-Precision LLM Training (PDF)](https://aisystemcodesign.github.io/papers/FP4.pdf)

### Apple MLX
- [ml-explore/mlx (GitHub)](https://github.com/ml-explore/mlx)
- [MLX (Apple Open Source)](https://opensource.apple.com/projects/mlx/)
- [MLX framework site](https://mlx-framework.org/)
- [Get started with MLX for Apple silicon - WWDC25 (Apple Developer)](https://developer.apple.com/videos/play/wwdc2025/315/)
- [Introduction to MLX: Apple's Machine Learning Framework (Medium)](https://medium.com/lolml/introduction-to-mlx-apples-machine-learning-framework-527b81f23fa5)

### QAT
- [Gemma 3 QAT Models: state-of-the-art AI to consumer GPUs (Google Developers Blog)](https://developers.googleblog.com/en/gemma-3-quantized-aware-trained-state-of-the-art-ai-to-consumer-gpus/)
- [Gemma 4 with quantization-aware training (Google)](https://blog.google/innovation-and-ai/technology/developers-tools/quantization-aware-training-gemma-4/)
- [Quantization Aware Training (QAT) - Gemma docs](https://gemma-llm.readthedocs.io/en/latest/colab_quantization_aware_training.html)

### MTP (Multi-Token Prediction)
- [Multi-Token Prediction (MTP) - Sebastian Raschka](https://sebastianraschka.com/llm-architecture-gallery/mtp/)
- [DeepSeek Explained 4: Multi-Token Prediction (Medium)](https://medium.com/data-science-collective/deepseek-explained-4-multi-token-prediction-33f11fe2b868)
- [Multi-Token Prediction (MTP) - NVIDIA Megatron-Bridge docs](https://docs.nvidia.com/nemo/megatron-bridge/latest/training/multi-token-prediction.html)
- [Insights into DeepSeek-V3: Scaling Challenges (arXiv)](https://arxiv.org/pdf/2505.09343)

### MoE / parameter notation
- [Qwen3 235B A22B Instruct 2507 (OpenRouter)](https://openrouter.ai/qwen/qwen3-235b-a22b-2507)
- [Qwen3-235B-A22B Sparse MoE Transformer (EmergentMind)](https://www.emergentmind.com/topics/qwen3-235b-a22b)
- [Qwen3 Technical Report (arXiv)](https://arxiv.org/html/2505.09388v1)
- [meta-llama/Llama-4-Scout-17B-16E (Hugging Face)](https://huggingface.co/meta-llama/Llama-4-Scout-17B-16E)
- [meta-llama/Llama-4-Maverick-17B-128E-Instruct (Hugging Face)](https://huggingface.co/meta-llama/Llama-4-Maverick-17B-128E-Instruct)
- [The Llama 4 herd (Meta AI)](https://ai.meta.com/blog/llama-4-multimodal-intelligence/)

### Effective parameters / MatFormer (Gemma 3n / 4)
- [Introducing Gemma 3n: The developer guide (Google Developers Blog)](https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/)
- [Gemma 3n model overview (Google AI for Developers)](https://ai.google.dev/gemma/docs/gemma-3n)
- [Understanding Gemma 3n: How MatFormer Gives You Many Models in One (Hugging Face)](https://huggingface.co/blog/rishiraj/matformer-in-gemma-3n)
- [Gemma 4 E2B & Per-Layer Embeddings (PLE) - Research Notes (Alan Dao)](https://alandao.net/posts/gemma-4-e2b-per-layer-embeddings-ple-research-notes/)

### YaRN / context extension
- [YaRN: Efficient Context Window Extension of Large Language Models (arXiv abstract)](https://arxiv.org/abs/2309.00071)
- [YaRN (arXiv PDF)](https://arxiv.org/pdf/2309.00071)
- [YaRN: Efficient Context Window Extension (EleutherAI)](https://www.eleuther.ai/papers-blog/yarn-efficient-context-window-extension-of-large-language-models)
- [YaRN: Yet Another RoPE Extension Method (EmergentMind)](https://www.emergentmind.com/topics/yarn-yet-another-rope-extension-method)

### Distillation
- [DeepSeek-R1 Distilled Models Overview (EmergentMind)](https://www.emergentmind.com/topics/deepseek-r1-distilled-models)
- [DeepSeek R1 Distilled Models now available on watsonx.ai (IBM)](https://www.ibm.com/new/announcements/deepseek-r1-distilled-models-now-available-on-watsonx-ai)
- [Building a RAG System with DeepSeek R1 Distilled Model (Analytics Vidhya)](https://www.analyticsvidhya.com/blog/2025/02/distilled-deepseek-r1-model/)

### DPO / base-instruct-chat suffixes
- [Preference Tuning LLMs with Direct Preference Optimization Methods (Hugging Face)](https://huggingface.co/blog/pref-tuning)
- [Direct Preference Optimization Explained In-depth (Tyler Romero)](https://www.tylerromero.com/posts/2024-04-dpo/)
- [How to navigate LLM model names (Red Hat Developer)](https://developers.redhat.com/articles/2025/04/03/how-navigate-llm-model-names)
- [Foundation vs. Instruct vs. Thinking Models (Alex Ewerlof)](https://blog.alexewerlof.com/p/base-models-vs-instruct-models)
- [LLM Architectures: Base, Instruct, and Chat Models (Medium)](https://medium.com/@yashwanths_29644/llm-finetuning-series-05-llm-architectures-base-instruct-and-chat-models-a6219c39c362)
- [What are the Differences Between Instruct, Chat, and Chat-Instruct Models (Tim Wappat)](https://timwappat.info/instruct-chat-llms-what-are-the-differences/)
- [Naming Conventions of LLM Models (TO THE NEW Blog)](https://www.tothenew.com/blog/naming-conventions-of-llm-models/)

### LASER
- [The Truth is in There: Improving Reasoning with Layer-Selective Rank Reduction (arXiv)](https://arxiv.org/abs/2312.13558)
- [LASER: Layer SElective Rank-Reduction (project page)](https://pratyushasharma.github.io/laser/)
- [laserRMT (GitHub, cognitivecomputations)](https://github.com/cognitivecomputations/laserRMT)
- [Improving Reasoning with LASER (Microsoft Research)](https://www.microsoft.com/en-us/research/quarterly-brief/jan-2024-brief/articles/improving-reasoning-in-language-models-with-laser-layer-selective-rank-reduction/)

### Reasoning / thinking models
- [Understanding Reasoning LLMs (Sebastian Raschka)](https://magazine.sebastianraschka.com/p/understanding-reasoning-llms)
- [What is Chain of Thought (CoT) Prompting? (NVIDIA Glossary)](https://www.nvidia.com/en-us/glossary/cot-prompting/)
- [QwQ-32B: Embracing the Power of Reinforcement Learning (Qwen)](https://qwenlm.github.io/blog/qwq-32b/)
- [QwQ (GitHub, QwenLM)](https://github.com/QwenLM/QwQ)
- [Introducing gpt-oss (OpenAI)](https://openai.com/index/introducing-gpt-oss/)
- [gpt-oss-120b & gpt-oss-20b Model Card (arXiv)](https://arxiv.org/pdf/2508.10925)
- [Open models by OpenAI](https://openai.com/open-models/)

### Uncensored / abliteration
- [Uncensor any LLM with abliteration (Hugging Face / mlabonne)](https://huggingface.co/blog/mlabonne/abliteration)
- [What is an abliterated LLM? (abliteration.ai)](https://abliteration.ai/abliterated-llm)
- [WTF Are Abliterated Models? Uncensored LLMs Explained (WebDecoy)](https://webdecoy.com/blog/wtf-are-abliterated-models-uncensored-llms-explained/)

### Modality (VL / Omni)
- [Qwen-VL: A Versatile Vision-Language Model (arXiv)](https://arxiv.org/abs/2308.12966)
- [Qwen3-VL Technical Report (arXiv)](https://arxiv.org/abs/2511.21631)
- [Qwen/Qwen2.5-Omni-7B (Hugging Face)](https://huggingface.co/Qwen/Qwen2.5-Omni-7B)
- [Understanding Qwen VL Multimodal AI Vision Language Model (LlamaIndex)](https://www.llamaindex.ai/glossary/what-is-qwen-vl)

### Safety / guard models
- [Llama Guard 3: Modular Safety Classifier (EmergentMind)](https://www.emergentmind.com/topics/llama-guard-3)
- [How Llama Guard Improves AI Safety with LLM-Based Moderation (Medium)](https://medium.com/@tahirbalarabe2/%EF%B8%8Fhow-llama-guard-improves-ai-safety-with-llm-based-moderation-73ff34980c5f)

### Date / version conventions
- [Changelog (Mistral Docs)](https://docs.mistral.ai/getting-started/changelog)
- [Large Enough - Mistral Large 2407 (Mistral AI)](https://mistral.ai/news/mistral-large-2407/)
- [LLM Model Names Decoded: A Developer's Guide (Starmorph)](https://blog.starmorph.com/blog/llm-model-names-decoded)
