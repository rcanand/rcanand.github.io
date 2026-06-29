---
title: Model analysis summary
date: 2026-06-29
tags:
  - ai
  - llm
  - quantization
excerpt: A deep dive into the different parts of the model ids - parameters, quantization, but also architectural stems like MXFP8, NVFP4, MLX, etc. - what they mean and how they interact with each other. Semi-raw analysis from claude code.
---
# Model analysis summary

## What this set of posts is about

Modern LLMs are distributed through several systems - the **Ollama** library, **OpenRouter**'s catalog, and **Artificial Analysis**'s benchmark data - and each model is identified by a string like `gemma4:26b-a4b-it-qat` or `qwen/qwen3.7-max-20260520`. These IDs are dense: every segment (`gemma4`, `26b`, `a4b`, `it`, `qat`, `nvfp4`, `mlx`, `q4_K_M`, `mtp`, `yarn`, ...) is a *stem* that encodes a real architectural or packaging choice - parameter size, quantization scheme, numeric precision, runtime/container, training technique, capability tier, context window, vendor codename, or a release date. Read literally, an ID tells you not just *which* model it is but *how it was built, how it's stored, and what hardware it wants to run on*.

This set of posts decodes those stems end-to-end and then ranks them. Concretely it answers, for every stem you'll encounter across the three systems: **what does it mean**, **what does it do to quality / decode speed (TPS) / first-token latency (TTFT) / size**, **which platforms can run it natively vs emulated**, and **which stems can be combined on a single model and which are mutually exclusive**. The unifying mental model that makes all of this tractable is the three orthogonal axes above - one numeric encoding (Axis A), one runtime (Axis B), any number of build-time techniques (Axis C) - so "can I combine X and Y?" reduces to "are X and Y on different axes?".
## TLDR

**The organizing insight** - every architectural/quant stem belongs to one of three orthogonal axes, which makes combinability mechanical:
- **Axis A - numeric encoding** (pick one per tensor group): all the GGUF `Q*` levels, `F16`/`BF16`/`FP8`/`INT*`, `NVFP4`/`MXFP4`/`MXFP8`
- **Axis B - runtime/container** (pick one): `MLX` (Mac-only) vs GGUF/llama.cpp (everywhere) vs vendor GPU stacks
- **Axis C - build-time technique** (stack any number): `QAT`, `MTP`, MoE/`A22B`, `distill`, `DPO`, `LASER`, `YaRN`, MatFormer `E2B`/`E4B`, abliteration

**Independent rankings** for quality, TPS, TTFT, and disk/RAM size - each given separately because **TTFT and TPS rank differently** (prefill is compute-bound, decode is memory-bandwidth-bound, so quantization buys TPS not TTFT). Per-platform reality table for Mac / Linux / WSL2 / CPU, including which formats are native vs emulated.

**Combination matrix** with a worked answer to your exact examples:
- *QAT + Q4_K_M* → ✅ yes (orthogonal; this is literally what a Gemma QAT GGUF is)
- *NVFP4 + QAT + MLX on Ollama* → partly: NVFP4+QAT ✅, but on a Mac via MLX you get NVFP4's size/bandwidth benefit only, **not** Blackwell's 4x compute speedup (Apple has no FP4 tensor cores) - the full win needs a Blackwell NVIDIA GPU on Linux/WSL
- *NVFP4 + Q4_K_M* → ❌ both Axis A, pick one

**Section 10** of the analysis enumerates the seven factors that flip the rankings (GPU generation, TTFT-vs-TPS objective, context length, task sensitivity, MoE memory, CPU-vs-GPU, Linux-vs-WSL).

---

## How to read these posts

The posts are layered, each one building on the last. Read top-down:

1. **This summary** - [Model analysis summary](/blog/model-analysis-summary/) - the 5-minute orientation: the three-axis model, the independent quality/TPS/TTFT/size rankings, the combination matrix in one line, and the factors that flip the rankings. Start here.
2. **[Model-ID stem analysis](/blog/model-glossary-analysis/)** - the full analysis report. Formalizes the three axes, explains *why* TTFT and TPS rank differently (prefill is compute-bound, decode is memory-bandwidth-bound), gives the per-platform reality table (Mac / Linux / WSL2 / CPU, native vs emulated), ranks each axis on quality / TPS / TTFT / size, provides per-stem reference cards, the full combination matrix, and worked answers to "can I combine QAT + Q4_K_M? NVFP4 + QAT + MLX on Ollama? NVFP4 + Q4_K_M?".
3. **[Model-ID glossary](/blog/model-glossary/)** - the reference: decodes *every* meaningful stem found across the Ollama, OpenRouter, and Artificial Analysis identifiers, grouped by what kind of thing it encodes (families, parameter/MoE notation, the GGUF quant block, NVFP4/MXFP formats, MLX/GGUF runtimes, training techniques, capability suffixes, context windows, version/date conventions, vendor codenames, scraping artifacts). Use this as a dictionary - jump to a stem when an ID doesn't parse.
4. **[Model-ID glossary research notes](/blog/model-glossary-research-notes/)** - the verified-source backing for the glossary: for each stem family (GGUF quants, NVFP4, MX formats, MLX, QAT, MTP, MoE notation, YaRN, distillation, MatFormer, DPO, LASER, reasoning models, abliteration, modality suffixes, date conventions, safety models) a concise summary plus the primary sources.
5. **The runs** - the raw extraction and analysis that produced the inventory. These are the working artifacts; read them only if you want to audit how a count or claim was derived, or re-run the extraction yourself.
   - [Run 01 - Core ID inventory](/blog/model-glossary-run-01/): counts of tags, families, quants, variants, sizes, providers, creators across all three datasets.
   - [Run 02 - Unified stem frequency table](/blog/model-glossary-run-02/): every identifier tokenized, ranked by frequency, plus the special/architectural token counts (`Q4_K_M`, `NVFP4`, `A22B`, ...).
   - [Run 03 - Advanced quant/format/training stems](/blog/model-glossary-run-03/): the Ollama tags carrying NVFP4 / MXFP8 / FP8 / QAT / MTP / MLX / INT4 / INT8.
   - [Run 04 - Codename context resolution](/blog/model-glossary-run-04/): obscure codename tokens (`rnj`, `hy3`, `jt`, `laguna`, `ling`, ...) matched back to their identifier contexts.
   - [Run 05 - Performance & combination research notes](/blog/model-glossary-run-05-perf-notes/): verified findings and sources on the quant ladder, MLX vs llama.cpp, NVFP4/MXFP4/FP8, QAT, and TTFT-vs-TPS fundamentals.
   - [Run 06 - Combination matrix](/blog/model-glossary-run-06-combination-matrix/): the generated axis classification and cross-stem stack/exclude table.
   - [Run 07 - v2 verification](/blog/model-glossary-run-07-verification/): re-researched sources for the four claims the analysis initially hedged (Ollama's MLX backend, FP4 in llama.cpp, Apple Silicon FP4/FP8 hardware, MLX long-context decode).

If you only have a few minutes, read this summary and skim the per-stem reference cards in the analysis. If you're trying to *choose a model tag*, jump to the analysis's combination matrix and worked examples. If a stem in an ID is opaque, look it up in the glossary and trace its sources in the research notes or the relevant run.