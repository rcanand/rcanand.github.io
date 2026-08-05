---
title: Model-ID stem analysis - quality / speed / size rankings and combinability
date: 2026-06-29
tags:
  - ai
  - llm
  - quantization
  - ai-generated
excerpt: Analysis of the architectural and quantization stems in model identifiers, ranking them on quality, speed (TTFT and TPS), and size across Mac, Linux, and WSL2 - plus a combination matrix of what stacks and what is mutually exclusive.
---

# Model-ID Stem Analysis: quality / speed / size rankings and combinability

A companion to [Model-ID glossary](/blog/model-glossary/). This report analyzes the
**architectural and quantization stems** (`Q4_K_M`, `Q8_0`, `NVFP4`, `MXFP8`, `BF16`, `FP8`,
`MLX`, `QAT`, `MTP`, MoE active-params, `distill`, `YaRN`, `LASER`, MatFormer, etc.) and ranks them on:

- **Quality** - generation quality, instruction following, reasoning/math/code fidelity.
- **Speed** - **TTFT** (time to first token = prefill latency) and **TPS** (tokens/sec = decode
  throughput). These two move *differently*, which is why some rankings split.
- **Size** - on disk and in RAM/VRAM.
- across **Mac (Apple Silicon)**, **Linux (NVIDIA)**, and **WSL2 (NVIDIA)**.

Plus a **combination matrix**: which stems stack and which are mutually exclusive (e.g. *can I
have QAT with Q4_K_M? NVFP4 with QAT and MLX on Ollama?*).

> Figures below are drawn from published 2026 benchmarks (linked inline and in the
> [Bibliography](#bibliography)). Absolute throughput and the exact ordering depend on the model,
> context length, batch size, GPU generation, and runtime version; where the order flips, the
> governing factor is called out.

---

## Contents

- [Model-ID Stem Analysis: quality / speed / size rankings and combinability](#model-id-stem-analysis-quality--speed--size-rankings-and-combinability)
    - [Contents](#contents)
    - [1. The one idea that makes this tractable: three orthogonal axes](#1-the-one-idea-that-makes-this-tractable-three-orthogonal-axes)
    - [2. Why TTFT and TPS rank differently](#2-why-ttft-and-tps-rank-differently)
    - [3. Platform reality: what can even run where](#3-platform-reality-what-can-even-run-where)
    - [4. Axis A - numeric encodings ranked](#4-axis-a---numeric-encodings-ranked)
        - [4.1 Quality (best → worst)](#41-quality-best--worst)
        - [4.2 TPS / decode throughput (fastest → slowest)](#42-tps--decode-throughput-fastest--slowest)
        - [4.3 TTFT (best → worst)](#43-ttft-best--worst)
        - [4.4 Size on disk and in RAM (smallest → largest)](#44-size-on-disk-and-in-ram-smallest--largest)
    - [5. Axis B - runtime / container: MLX vs GGUF](#5-axis-b---runtime--container-mlx-vs-gguf)
    - [6. Axis C - build-time techniques ranked](#6-axis-c---build-time-techniques-ranked)
    - [7. Per-stem reference cards](#7-per-stem-reference-cards)
        - [Numeric encodings (Axis A)](#numeric-encodings-axis-a)
        - [Runtime (Axis B)](#runtime-axis-b)
        - [Build-time techniques (Axis C)](#build-time-techniques-axis-c)
    - [8. Combination matrix: what stacks and what is mutually exclusive](#8-combination-matrix-what-stacks-and-what-is-mutually-exclusive)
    - [9. Worked answers to the example questions](#9-worked-answers-to-the-example-questions)
    - [10. Where the ranking depends on other factors](#10-where-the-ranking-depends-on-other-factors)
    - [Verification pass (v2)](#verification-pass-v2)
        - [Sources added in this verification pass](#sources-added-in-this-verification-pass)
    - [Bibliography](#bibliography)
        - [GGUF quant performance \& quality](#gguf-quant-performance--quality)
        - [MLX vs llama.cpp / Apple Silicon](#mlx-vs-llamacpp--apple-silicon)
        - [NVFP4 / MXFP / FP8 / Blackwell](#nvfp4--mxfp--fp8--blackwell)
        - [QAT and combination](#qat-and-combination)
        - [TTFT / TPS / prefill-decode fundamentals](#ttft--tps--prefill-decode-fundamentals)
        - [Architectural techniques (MoE / MTP / distill / YaRN / MatFormer / LASER)](#architectural-techniques-moe--mtp--distill--yarn--matformer--laser)

---

## 1. The one idea that makes this tractable: three orthogonal axes

Every stem in a model tag belongs to exactly one of three independent axes. You pick **one value
from Axis A and one from Axis B, and stack any number from Axis C**:

| Axis                        | What it is                                 | Pick how many                    | Stems                                                                                                                                                                                       |
| --------------------------- | ------------------------------------------ | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **A. Numeric encoding**     | how the weights are stored (bits + scheme) | **exactly one** per tensor group | `F16`/`FP16`, `BF16`, `FP8`, `INT8`/`INT4`, `Q8_0`, `Q6_K`, `Q5_K_M`/`Q5_K_S`/`Q5_0`/`Q5_1`, `Q4_K_M`/`Q4_K_S`/`Q4_0`/`Q4_1`, `Q3_K_L`/`Q3_K_M`/`Q3_K_S`, `Q2_K`, `NVFP4`, `MXFP4`, `MXFP8` |
| **B. Runtime / container**  | what executes the weights                  | **exactly one** at run time      | `MLX` (Apple), GGUF/llama.cpp (cross-platform), vendor GPU stacks (TensorRT/vLLM)                                                                                                           |
| **C. Build-time technique** | how the model was trained/derived          | **any number**                   | `QAT`, `MTP`, MoE/`A22B`, `distill`, `DPO`, `LASER`, `YaRN`/`gradient`, MatFormer (`E2B`/`E4B`), abliteration/`uncensored`                                                                  |

The single most common confusion - "can I combine `Q4_K_M` and `NVFP4`?" - dissolves here: both
are **Axis A**, so **no**, you choose one. But `QAT` (Axis C) + `Q4_K_M` (Axis A) + GGUF (Axis B)?
**Yes** - that is exactly what a Gemma QAT GGUF is.
([Google Gemma 4 QAT](https://blog.google/innovation-and-ai/technology/developers-tools/quantization-aware-training-gemma-4/),
[Ollama goes MLX](https://gingter.org/2026/04/23/ollama-goes-mlx/))

---

## 2. Why TTFT and TPS rank differently

- **Prefill** (reading your prompt, producing the first token) is **compute-bound** - big
  matrix-matrix multiplies, high arithmetic intensity. It sets **TTFT**.
- **Decode** (each subsequent token) is **memory-bandwidth-bound** - matrix-vector ops that
  repeatedly stream the weights and a growing KV cache. It sets **TPS**.

Consequence: **quantization mainly buys TPS, not TTFT**, because it shrinks bytes moved per token
during the bandwidth-bound decode phase; it does little for the compute-bound prefill. A format
can therefore *win on TPS and lose on TTFT* (this is exactly the MLX-vs-llama.cpp story below).
([Towards Data Science - prefill compute-bound, decode memory-bound](https://towardsdatascience.com/prefill-is-compute-bound-decode-is-memory-bound-why-your-gpu-shouldnt-do-both/),
[Redis - Prefill vs Decode](https://redis.io/blog/prefill-vs-decode/),
[Why LLM inference is memory-bound](https://medium.com/@arjunravi726/why-llm-inference-is-memory-bound-not-compute-bound-ba59c48739e0))

Rules of thumb used throughout:
- **Disk size ≈ bits-per-weight × parameters.** RAM/VRAM ≈ disk + KV cache + runtime overhead.
- **Lower bits ⇒ smaller + faster decode (higher TPS), at some quality cost.**
- **TTFT** is governed far more by **runtime, batching, Flash-Attention, and GPU compute** than by
  the weight format.

---

## 3. Platform reality: what can even run where

Before ranking, note that some Axis-A/Axis-B choices simply don't exist on some platforms. Native
= dedicated hardware path (fast); emulated = upcast/dequantize in software (works, not fast).

| Stem                            | Mac (Apple Silicon)                                                                                                                                                        | Linux (NVIDIA)                                          | WSL2 (NVIDIA)                | Pure CPU   |
| ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- | ---------------------------- | ---------- |
| GGUF `Q2_K…Q8_0`, `F16`         | Native (Metal)                                                                                                                                                             | Native (CUDA)                                           | Native (CUDA)                | Yes        |
| `BF16`                          | Yes (Metal/CPU)                                                                                                                                                            | Native                                                  | Native                       | Yes (slow) |
| `FP8`                           | **Native on M5/A19 GPU Neural Accelerators**; emulated on M1-M4                                                                                                            | Native on **Hopper+**                                   | Native on **Hopper+**        | No         |
| `NVFP4`                         | Ollama 0.19 MLX backend; on **M5** the GPU Neural Accelerators accelerate the matmul (native FP8/INT4 paths); no dedicated NVFP4 tensor unit; M1-M4 storage/bandwidth only | **Native only on Blackwell**; emulated on Hopper/Ampere | **Native only on Blackwell** | No         |
| `MXFP4` / `MXFP8`               | **M5** GPU Neural Accelerators (native FP8/INT4); M1-M4 emulated                                                                                                           | Native on Blackwell-class; else emulated                | Native on Blackwell-class    | No         |
| `MLX` (runtime)                 | **Apple-silicon only**                                                                                                                                                     | N/A                                                     | N/A                          | N/A        |
| GGUF runtime (llama.cpp/Ollama) | Yes                                                                                                                                                                        | Yes                                                     | Yes                          | Yes        |

Key platform facts:
- **MLX is Mac-only.** There is no MLX on Linux or WSL. ([ml-explore/mlx](https://github.com/ml-explore/mlx))
- **NVFP4/MXFP4 are Blackwell-native on NVIDIA.** On Hopper/Ampere they are emulated; FP8 needs
  Hopper+. NVFP4 is merged in llama.cpp (`GGML_TYPE_NVFP4 = 40`, kernels landed late Mar-Apr 2026;
  Blackwell tensor-core dispatch in PR #22196); non-Blackwell NVIDIA cards get the memory savings
  only. MXFP4 (OCP variant) lives in ik_llama.cpp.
  ([NVIDIA Introducing NVFP4](https://developer.nvidia.com/blog/introducing-nvfp4-for-efficient-and-accurate-low-precision-inference/),
  [Spheron FP4 on Blackwell](https://www.spheron.network/blog/fp4-quantization-blackwell-gpu-cost/),
  [llama.cpp PR #19769 (NVFP4)](https://github.com/ggml-org/llama.cpp/pull/19769),
  [InsiderLLM FP4 in llama.cpp](https://insiderllm.com/guides/fp4-inference-llamacpp-nvfp4-mxfp4/))
- **On Apple Silicon, low precision is real on M5, emulated before it.** Ollama 0.19 (preview,
  released 2026-03-30) rebuilds the Mac stack on Apple's MLX framework and uses NVFP4 for 4-bit,
  while keeping llama.cpp for Linux/Windows. **M5 / M5 Pro / M5 Max (and A19) GPUs add GPU Neural
  Accelerators** - matrix units that natively run **FP8 and INT4** - so on M5 the 4-bit path is a
  genuine compute win (Ollama measured ~2x: e.g. M5 Max + Qwen3.5-35B-A3B NVFP4, prefill
  1,154→1,810 tok/s, decode 58→112 tok/s), not just a bandwidth win. There is still no Apple
  equivalent of NVIDIA's dedicated NVFP4 tensor unit, and on **M1-M4** (no matrix accelerators)
  the FP4/FP8 benefit is storage/bandwidth only.
  ([Ollama blog - now powered by MLX](https://ollama.com/blog/mlx),
  [MacRumors - Ollama faster on Macs](https://www.macrumors.com/2026/03/31/ollama-now-runs-faster-apple-silicon-macs/),
  [Apple ML Research - LLMs with MLX on M5](https://machinelearning.apple.com/research/exploring-llms-mlx-m5),
  [tzakharko - A19/M5 Neural Accelerators benchmark](https://tzakharko.github.io/apple-neural-accelerators-benchmark/))
- **Linux vs WSL2:** with NVIDIA GPU passthrough, WSL2 CUDA compute is near-native; the practical
  gaps are slightly higher model-load/disk-I/O latency and occasional driver/VRAM-reporting
  quirks. **Compute-bound TTFT and decode TPS are within a few percent of bare Linux**; treat
  them as equivalent for ranking, with WSL2 a touch behind on cold-start/load and on very large
  models near the VRAM limit.
- **Pure CPU** (any OS): only GGUF int/float formats; lower bits help most because CPU memory
  bandwidth is the binding constraint. ([Markaicode CPU benchmark](https://markaicode.com/benchmarks/tool-cpu-benchmark/))

---

## 4. Axis A - numeric encodings ranked

All else equal (same model, same runtime). "Quality" = closeness to FP16 baseline.

### 4.1 Quality (best → worst)

```
F16/BF16  ≈  Q8_0  >  Q6_K  >  Q5_K_M > Q5_K_S  >  Q4_K_M > Q4_K_S  >  Q4_0/Q4_1
          >  Q3_K_L > Q3_K_M > Q3_K_S  >  Q2_K
```

- `Q8_0` is effectively lossless; `Q6_K` ~+2% over Q4_K_M baseline, `Q5_K_M` ~+1.5%, and `Q4_K_M`
  retains ~92-95% of FP16 quality - the standard "sweet spot." Below Q4, quality degrades fast,
  and `Q2_K` is noticeably worse (use only when nothing else fits).
  ([RunAIHome Q4/Q5/Q6/Q8 quality loss](https://runaihome.com/blog/quantization-q4-q5-q6-q8-quality-loss-2026/),
  [WillItRunAI quant guide](https://willitrunai.com/blog/quantization-guide-gguf-explained))
- **k-quant (`_K_`) beats legacy (`_0`/`_1`) at equal bit-width** because of the super-block
  scale structure; within a level, `_M` > `_S` (more tensors kept at higher precision).
  `_1` ≥ `_0` (asymmetric: scale + min). ([llama.cpp discussion #2094](https://github.com/ggml-org/llama.cpp/discussions/2094))
- **FP4 family for quality:** `NVFP4` > `MXFP4` at the same 4 bits (~88% lower quantization error;
  block-16 + FP8 scale vs block-32 + power-of-two scale). NVFP4 can match/slightly beat FP8 on
  some reasoning tasks **when paired with FP8/BF16 attention** (mixed precision), not as pure FP4.
  ([Edge-AI-Vision NVFP4 impact](https://www.edge-ai-vision.com/2025/10/nvidia-blackwell-the-impact-of-nvfp4-for-llm-inference/),
  [iFactory FP4 vs FP8 vs FP16](https://ifactoryapp.com/sap-integration/on-prem-ai/fp4-vs-fp8-vs-fp16-llm-inference))
- Rough quality placement of the GPU formats among the GGUF ladder: `BF16 ≈ FP16 > FP8 ≈ Q8_0 >
  Q6_K > NVFP4 ≳ Q5_K_M ≳ MXFP8(4-bit-ish use) ≳ Q4_K_M > MXFP4`. (NVFP4 lands near a high-quality
  4-5 bit GGUF; MXFP4 near a plain 4-bit.)

### 4.2 TPS / decode throughput (fastest → slowest)

On a **Blackwell GPU**, FP4 has dedicated 4x-throughput tensor cores, so:

```
NVFP4 ≈ MXFP4  >  FP8/MXFP8  >  BF16/F16        (Blackwell: ~4x / ~2x / ~1x stair)
```

On hardware **without an FP4 tensor unit** (non-Blackwell NVIDIA, CPU, and pre-M5 Apple) decode is
purely bandwidth-bound and TPS tracks **fewer bits = faster**:

```
Q2_K > Q3_K_* > Q4_0/Q4_K_S > Q4_K_M > Q5_K_* > Q6_K > Q8_0 > F16/BF16
```

The fuller picture on **Apple Metal** (correcting a too-broad statement that earlier lumped all
Apple GPUs in as "no FP4 tensor cores, bandwidth-only"): **M5 / A19 GPUs add GPU Neural
Accelerators that execute FP8 and INT4 natively**, so on M5-class Macs low-bit decode gets a real
compute speedup (not just a bandwidth win), and the order above understates how fast 4-bit/8-bit
run there. Apple still has **no dedicated NVFP4 unit** like Blackwell's, so NVFP4 *specifically*
leans on those native FP8/INT4 paths plus memory savings; **M1-M4** Macs have no matrix
accelerators at all and remain purely bandwidth-bound as the ladder shows.
([Apple ML Research - LLMs with MLX on M5](https://machinelearning.apple.com/research/exploring-llms-mlx-m5),
[tzakharko - A19/M5 Neural Accelerators benchmark](https://tzakharko.github.io/apple-neural-accelerators-benchmark/))

Example magnitudes: RTX 4090, Llama-3.2-8B - `Q4_K_M` 112 tok/s vs `Q8_0` 83 tok/s (+35%); CPU
12-thread - `Q4_K_M` 14.2 vs `Q5_K_M` 8.5 vs `Q8_0` 6.8 tok/s.
([Markaicode Ollama quant benchmark](https://markaicode.com/benchmarks/ollama-quantization-benchmark/),
[dasroot GGUF quality vs speed](https://dasroot.net/posts/2026/02/gguf-quantization-quality-speed-consumer-gpus/))

### 4.3 TTFT (best → worst)

Weight format has **second-order** effect on TTFT (prefill is compute-bound). The first-order
levers are GPU compute class and runtime. That said:
- On **Blackwell**, `NVFP4`/`FP8` also give the **best TTFT** because the prefill matmuls run on
  the faster low-precision tensor cores. ([Edge-AI-Vision](https://www.edge-ai-vision.com/2025/10/nvidia-blackwell-the-impact-of-nvfp4-for-llm-inference/))
- On **Mac/CPU/non-Blackwell**, TTFT is roughly **format-insensitive**; a lower-bit model is not
  meaningfully faster to first token, and can even be marginally slower if it must dequantize.

### 4.4 Size on disk and in RAM (smallest → largest)

Tracks bits-per-weight directly:

```
Q2_K(~2.6) < Q3_K_S/M/L(~3.4) < NVFP4/MXFP4(~4.0-4.25) < Q4_0/Q4_K_S(~4.3) < Q4_K_M(~4.5)
< Q5_K_*(~5.5) < Q6_K(~6.5) < MXFP8/FP8(~8) ≈ Q8_0(~8.5) < BF16/F16(16)
```

7B reference: FP16 ~13.5 GB → `Q4_K_M` ~4.1 GB → `Q2_K` ~2.8 GB. **RAM/VRAM ≈ disk + KV cache +
overhead** (RTX 4090: `Q4_K_M` 5.8 GB resident vs `Q8_0` 9.1 GB). On Apple unified memory, "RAM"
*is* the budget for both weights and KV cache.
([Vucense GGUF sizes](https://vucense.com/dev-corner/gguf-quantization-explained-q4-k-m-vs-q8-0-vs-f16-2026/))

---

## 5. Axis B - runtime / container: MLX vs GGUF

Same weights, different engine. **Mac only** (the only platform where you actually choose).

| Metric                  | MLX                                                                                                                                                                                       | GGUF (llama.cpp / Ollama)        | Who wins                                        |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------- | ----------------------------------------------- |
| Decode TPS              | ~1.4-1.8x raw llama.cpp; bigger lead at long context (KV stays in unified memory)                                                                                                         | baseline                         | **MLX** for sustained generation                |
| TTFT / prefill          | often slower                                                                                                                                                                              | faster (Metal + Flash-Attention) | **GGUF** for short prompts / snappy first token |
| Long context (30K+)     | KV-cache-efficient, but decode runs ~50% slower than llama.cpp+FlashAttn because MLX's attention kernel is not yet IO-aware (FlashAttention-style); an open mlx-lm issue tracks adding it | strong with Flash-Attention      | **GGUF at long context**                        |
| Ecosystem & portability | Apple-only; needs MLX conversion                                                                                                                                                          | universal GGUF; runs everywhere  | **GGUF**                                        |
| Quantization scheme     | MLX's own (e.g. 4-bit MLX, `mlx-bf16`)                                                                                                                                                    | GGUF `Q*`/`F16`                  | n/a (different schemes)                         |

Net: on a Mac, **MLX for max TPS on long generations; GGUF/Ollama for best TTFT, portability, and
the widest model selection**. Ollama's overhead means "MLX is 3x faster" claims are mostly
Ollama-vs-MLX, not llama.cpp-vs-MLX.
([Towards AI MLX vs llama.cpp](https://pub.towardsai.net/apples-mlx-runs-local-llms-3x-faster-than-llama-cpp-until-your-context-hits-40k-715ec441afbb),
[Ante Kapetanovic Qwen3.5 Apple Silicon](https://antekapetanovic.com/blog/qwen3.5-apple-silicon-benchmark/),
[yage.ai MLX vs llama.cpp](https://yage.ai/share/mlx-apple-silicon-en-20260331.html),
[Contra Collective GGUF vs MLX](https://contracollective.com/blog/gguf-vs-mlx-quantization-formats-apple-silicon-2026))

---

## 6. Axis C - build-time techniques ranked

These travel **with the weights** and are largely **platform-independent**. They do not change
the numeric format; they change quality, or (for MoE/MTP) the speed/size math.

| Stem                      | Quality effect                                                        | TPS effect                                                | TTFT effect   | Size effect                                   | Notes                                              |
| ------------------------- | --------------------------------------------------------------------- | --------------------------------------------------------- | ------------- | --------------------------------------------- | -------------------------------------------------- |
| `QAT`                     | **+** (recovers up to ~70% of quant loss; +1-3% GPQA/MMLU-Pro vs PTQ) | none (same format)                                        | none          | none                                          | makes a low-bit model behave like a higher-bit one |
| `MTP`                     | neutral                                                               | **++** (~1.8x via speculative decode, runtime-permitting) | slight +      | tiny (extra head)                             | needs runtime support to realize the speedup       |
| MoE / `A22B`              | high quality per active-FLOP                                          | **++** (decode runs at *active* params, e.g. 22B)         | +             | **−−** (RAM/disk = *total* params, e.g. 235B) | great speed/quality, heavy memory                  |
| `distill`                 | slight − vs teacher, big + vs same-size base                          | + (smaller student)                                       | +             | + (smaller)                                   | how small reasoning models get R1-like skills      |
| `DPO`                     | + (alignment/preference)                                              | none                                                      | none          | none                                          | post-training preference alignment                 |
| `LASER`                   | + on targeted tasks (can also regress)                                | tiny + (low-rank)                                         | none          | tiny −                                        | SVD rank-reduction on select layers                |
| `YaRN`/`gradient`         | neutral at short ctx; enables long ctx                                | − at long ctx (more KV)                                   | − at long ctx | KV cache grows                                | context-window extension                           |
| MatFormer `E2B`/`E4B`     | E4B > E2B                                                             | E2B faster                                                | E2B faster    | stored > effective (PLE)                      | pick a nested submodel size                        |
| `uncensored`/abliteration | removes refusals; may slightly dent benchmark quality                 | none                                                      | none          | none                                          | behavior change, not size                          |

Sources: [Unsloth QAT](https://unsloth.ai/docs/blog/quantization-aware-training-qat),
[NVIDIA QAT accuracy recovery](https://developer.nvidia.com/blog/how-quantization-aware-training-enables-low-precision-accuracy-recovery/),
[Sebastian Raschka MTP](https://sebastianraschka.com/llm-architecture-gallery/mtp/),
[Qwen3 Technical Report (MoE)](https://arxiv.org/html/2505.09388v1),
[EmergentMind DeepSeek-R1 distilled](https://www.emergentmind.com/topics/deepseek-r1-distilled-models),
[YaRN (arXiv)](https://arxiv.org/abs/2309.00071),
[HF MatFormer in Gemma 3n](https://huggingface.co/blog/rishiraj/matformer-in-gemma-3n),
[LASER (arXiv)](https://arxiv.org/abs/2312.13558).

---

## 7. Per-stem reference cards

Compact card per stem: Axis, quality, TPS, TTFT, size, best platform(s).

### Numeric encodings (Axis A)
- **`F16`/`FP16`** - 16-bit float. Quality: baseline (100%). TPS: slowest. TTFT: neutral. Size:
  largest (16 bpw). Platform: all. Use as the quality reference / for further quantization.
- **`BF16`** - 16-bit, FP32 exponent range. Quality ≈ FP16, more training-stable. Size 16 bpw.
  Platform: all (native on modern GPU; `mlx-bf16` on Mac).
- **`FP8`** (E4M3/E5M2) - 8-bit float. Quality ≈ Q8_0. TPS ~2x BF16 on Hopper/Blackwell. Size
  ~8 bpw. Platform: NVIDIA Hopper+ (Linux/WSL); emulated elsewhere.
- **`Q8_0`** - 8-bit GGUF. Quality near-lossless (~103% of Q4_K_M). TPS slow-ish. Size ~8.5 bpw.
  Platform: all. Use when you have memory and want max fidelity locally.
- **`Q6_K`** - 6-bit k-quant. Quality ~102%. Good high-fidelity/size compromise. Platform: all.
- **`Q5_K_M` / `Q5_K_S`** - 5-bit k-quant (`_M` keeps more high-precision tensors). Quality ~101.5%.
  Recommended for code/math when you have 12GB+. Platform: all.
- **`Q5_0` / `Q5_1`** - legacy 5-bit (`_1` asymmetric, slightly better). Superseded by `Q5_K_*`.
- **`Q4_K_M`** - 4-bit k-quant, **the default sweet spot**: ~92-95% quality, ~4.5 bpw, big TPS
  win. Platform: all. The single best "just give me one" choice for local.
- **`Q4_K_S`** - smaller/slightly lower-quality Q4 k-quant. Platform: all.
- **`Q4_0` / `Q4_1`** - legacy 4-bit; **the canonical QAT export target** (Gemma QAT = Q4_0).
  Quality below Q4_K_M at equal bits unless QAT'd. Platform: all.
- **`Q3_K_L/M/S`** - 3-bit k-quant; visible quality loss; for tight memory. Platform: all.
- **`Q2_K`** - 2-bit; largest quality hit; last resort to fit. Platform: all.
- **`NVFP4`** - NVIDIA 4-bit float, block-16 + FP8 scale. Quality best-in-class for 4-bit
  (~near FP8 with mixed attention). TPS/TTFT: **fastest on Blackwell** (4x stair); emulated
  elsewhere. Size ~4 bpw. Platform: **Blackwell GPU** natively; Mac via MLX backend (bandwidth
  win only).
- **`MXFP4`** - OCP 4-bit float, block-32 + power-of-two scale. Quality below NVFP4. Speed like
  NVFP4 on supporting HW. Size ~4 bpw. Platform: Blackwell-class.
- **`MXFP8`** - OCP 8-bit microscaling (E4M3/E5M2). Quality ≈ FP8. Size ~8 bpw. Platform:
  Hopper/Blackwell-class; emulated elsewhere.
- **`INT8` / `INT4`** - uniform integer quant. Simpler than k-quants; INT8 ≈ Q8 quality, INT4
  below k-quant Q4 unless QAT'd. Platform: broad (TensorRT/vendor stacks, some GGUF).

### Runtime (Axis B)
- **`MLX`** - Apple-silicon runtime. Best sustained TPS on Mac, weaker TTFT, Apple-only. See §5.

### Build-time techniques (Axis C)
- **`QAT`**, **`MTP`**, **MoE/`A22B`**, **`distill`**, **`DPO`**, **`LASER`**, **`YaRN`/`gradient`**,
  **MatFormer `E2B`/`E4B`**, **abliteration** - see the table in §6.

---

## 8. Combination matrix: what stacks and what is mutually exclusive

Legend: ✅ stacks · ❌ mutually exclusive · ➖ same axis, pick one · ⚠️ works but platform/notes apply.

|                                    | GGUF `Q*` | `NVFP4`/`MXFP*` | `FP8` | `BF16`/`F16` | `MLX` runtime  | `QAT` | `MTP` | MoE | `distill`/`DPO`/`LASER`/`YaRN` |
| ---------------------------------- | --------- | --------------- | ----- | ------------ | -------------- | ----- | ----- | --- | ------------------------------ |
| **GGUF `Q*`**                      | ➖         | ➖               | ➖     | ➖            | ⚠️¹             | ✅     | ✅     | ✅   | ✅                              |
| **`NVFP4`/`MXFP*`**                | ➖         | ➖               | ⚠️²    | ⚠️²           | ⚠️³             | ✅     | ✅     | ✅   | ✅                              |
| **`FP8`**                          | ➖         | ⚠️²              | ➖     | ⚠️²           | ❌⁴             | ✅     | ✅     | ✅   | ✅                              |
| **`BF16`/`F16`**                   | ➖         | ⚠️²              | ⚠️²    | ➖            | ✅ (`mlx-bf16`) | ✅     | ✅     | ✅   | ✅                              |
| **`MLX` runtime**                  | ⚠️¹        | ⚠️³              | ❌⁴    | ✅            | —              | ✅     | ✅     | ✅   | ✅                              |
| **`QAT`**                          | ✅         | ✅               | ✅     | ✅            | ✅              | —     | ✅     | ✅   | ✅                              |
| **`MTP`**                          | ✅         | ✅               | ✅     | ✅            | ✅              | ✅     | —     | ✅   | ✅                              |
| **MoE**                            | ✅         | ✅               | ✅     | ✅            | ✅              | ✅     | ✅     | —   | ✅                              |
| **`distill`/`DPO`/`LASER`/`YaRN`** | ✅         | ✅               | ✅     | ✅            | ✅              | ✅     | ✅     | ✅   | ✅ (mutually stackable)         |

Footnotes:
1. **GGUF `Q*` + MLX:** different *quant schemes*. MLX doesn't run a `Q4_K_M` GGUF; it uses its
   own 4-bit MLX quant. So "Q4_K_M on MLX" is not a thing - convert the model to MLX quant
   instead. (GGUF runs on llama.cpp/Ollama; MLX runs MLX-format weights.)
2. **Mixing two numeric formats in one model is normal at the *boundary* level**, not the tensor
   level: e.g. **NVFP4 weights + FP8 or BF16 attention/KV** is a recommended Blackwell config.
   You still pick one format *per tensor group*; you don't double-encode a tensor.
3. **NVFP4/MXFP* + MLX:** ✅ via the Ollama 0.19 MLX backend. On **M5-class** Macs the GPU Neural
   Accelerators run the 4-bit matmul natively (FP8/INT4 paths), so it is a real compute win
   (~2x in Ollama's tests), though there is no Apple equivalent of NVIDIA's dedicated NVFP4
   tensor unit. On **M1-M4** the benefit is size/bandwidth only.
4. **FP8 + MLX:** ✅ on **M5/A19** GPUs, whose Neural Accelerators execute FP8 natively; on
   **M1-M4** FP8 is emulated. (Separately, NVIDIA's Hopper/Blackwell FP8 tensor-core path is its
   own track.)

**The governing rule:** one Axis-A encoding (per tensor group) + one Axis-B runtime + any stack of
Axis-C techniques. Everything labeled ➖ or ❌ above is an attempt to pick two from an axis that
only allows one, or to run a format on a runtime that can't execute it.

---

## 9. Worked answers to the example questions

- **"Can I have QAT with Q4_K_M?"** ✅ Yes. QAT (Axis C) is orthogonal to the format. You QAT-train
  the model, then export to a GGUF quant. In practice Google ships QAT as **Q4_0**; exporting the
  same QAT checkpoint to **Q4_K_M** is fine and slightly higher quality than Q4_0. Net: near-FP16
  quality at 4-bit size/speed. ([Google Gemma 4 QAT](https://blog.google/innovation-and-ai/technology/developers-tools/quantization-aware-training-gemma-4/),
  [Unsloth QAT](https://unsloth.ai/docs/blog/quantization-aware-training-qat))

- **"Can I have NVFP4 with QAT and MLX on Ollama?"** Partly.
  - **NVFP4 + QAT:** ✅ - QAT (quant-aware distillation) specifically exists to recover NVFP4
    accuracy. ([QAD for NVFP4, arXiv](https://arxiv.org/pdf/2601.20088))
  - **+ MLX on Ollama:** ✅ - Ollama 0.19 (preview, 2026-03-30) runs NVFP4 weights through its MLX
    backend on Apple Silicon. On **M5 / M5 Pro / M5 Max** the GPU Neural Accelerators speed up both
    TTFT and decode (Ollama: M5 Max + Qwen3.5-35B-A3B NVFP4, prefill 1,154→1,810 tok/s, decode
    58→112 tok/s, ~2x). It is not a byte-for-byte match to Blackwell - Apple has no dedicated NVFP4
    tensor unit, and on **M1-M4** the gain is memory/bandwidth only - but on M5 it is a real compute
    win, and a **Blackwell NVIDIA GPU on Linux/WSL** remains the fastest NVFP4 path overall.
    ([Ollama blog - now powered by MLX](https://ollama.com/blog/mlx),
    [Apple ML Research - LLMs with MLX on M5](https://machinelearning.apple.com/research/exploring-llms-mlx-m5),
    [Spheron FP4 on Blackwell](https://www.spheron.network/blog/fp4-quantization-blackwell-gpu-cost/))
  - **NVFP4 + MXFP8 + Q4_K_M together?** ❌ - all Axis A; pick one encoding for the weights.

- **"Best single choice with no other info?"** `Q4_K_M` GGUF (cross-platform, ~92-95% quality,
  big TPS/size win). Add **QAT** if a QAT checkpoint exists. On a Mac doing long generations,
  consider the **MLX** build of the same model for higher TPS. On a **Blackwell** box, prefer
  **NVFP4 (weights) + FP8/BF16 attention** for the best speed at near-FP8 quality.

---

## 10. Where the ranking depends on other factors

The order is **not** universal; these factors flip it:

1. **GPU generation (biggest flip).** FP4/FP8 are *fastest* on NVIDIA Blackwell/Hopper; on
   **Apple M5/A19** the GPU Neural Accelerators run FP8/INT4 natively (real win), while Ampere,
   CPU, and **pre-M5 Apple** emulate them. On hardware without a matching low-precision unit, a
   GGUF `Q4_K_M` out-runs an "emulated NVFP4." So "is NVFP4 faster than Q4_K_M?" = **yes on
   Blackwell and (with M5 Neural Accelerators) on M5 Macs, often no on older hardware.**
2. **TTFT vs TPS objective.** If you optimize first-token latency (chat snappiness), runtime +
   Flash-Attention + compute class dominate, and format barely matters - GGUF/llama.cpp often
   beats MLX. If you optimize sustained throughput (long generations, batch), lower bits + MLX +
   MTP win. ([prefill vs decode](https://towardsdatascience.com/prefill-is-compute-bound-decode-is-memory-bound-why-your-gpu-shouldnt-do-both/))
3. **Context length.** Long context inflates the KV cache, shifting the bottleneck and rewarding
   KV-cache-efficient runtimes (MLX unified memory) and KV quantization; `YaRN` is required to go
   long at all but costs decode speed there. MLX's long-context advantage also narrows and then
   reverses past ~30-40K, where its decode runs ~50% slower than llama.cpp + Flash-Attention,
   because MLX's attention kernel is not yet IO-aware (FlashAttention-style); an open mlx-lm issue
   tracks adding it. ([mlx-lm issue #763](https://github.com/ml-explore/mlx-lm/issues/763))
4. **Task sensitivity.** Math/code/reasoning lose more from aggressive quant than chat/summarize.
   For those, step up from `Q4_K_M` to `Q5_K_M`/`Q6_K`, or add **QAT**. ([RunAIHome quality loss](https://runaihome.com/blog/quantization-q4-q5-q6-q8-quality-loss-2026/))
5. **Memory headroom vs model size.** MoE flips the size/speed intuition: a 235B-A22B MoE decodes
   at ~22B speed but needs ~235B of RAM/VRAM - fast *if it fits*, unusable if it doesn't. On
   memory-tight machines a dense `Q4_K_M` may beat an MoE you can't load.
6. **CPU vs GPU.** On CPU, everything is bandwidth-bound, so the lowest-bit k-quant that meets your
   quality bar maximizes TPS; FP8/FP4/MLX are irrelevant (no path).
7. **Linux vs WSL2.** Compute parity within a few percent; WSL2 trails mainly on cold model-load /
   disk I/O and at the very top of the VRAM range. Not enough to change format/quant choice.

---

## Verification pass (v2)

This revision re-checked, against current (mid-2026) sources, the four claims that the first
version stated tentatively. The earlier hedging came from a model knowledge cutoff that predated
these releases; each is now confirmed (or corrected) by primary/independent sources. Only the
sections affected by these four items were changed from v1; the rest of the document is unchanged.

| #   | Claim re-verified                                                         | Verdict                   | What changed vs v1                                                                                                                                                                                                 |
| --- | ------------------------------------------------------------------------- | ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1   | Ollama has an MLX backend that uses NVFP4 on Apple Silicon                | **Confirmed**             | Ollama 0.19 preview (2026-03-30) rebuilt the Mac stack on MLX, uses NVFP4, keeps llama.cpp for Linux/Windows; stated as fact (no "in this dataset's world").                                                       |
| 2   | FP4 (NVFP4/MXFP4) landed in llama.cpp                                     | **Confirmed**             | NVFP4 merged (`GGML_TYPE_NVFP4=40`), Blackwell tensor-core dispatch in PR #22196; non-Blackwell gets memory savings only; MXFP4 in ik_llama.cpp.                                                                   |
| 3   | "Apple GPUs lack FP4 tensor cores ⇒ bandwidth-only"                       | **Corrected**             | M5/A19 GPUs add **GPU Neural Accelerators** with native **FP8/INT4** matmul, so on M5 the 4-bit path is a real compute win (~2x in Ollama's tests). No dedicated NVFP4 unit; M1-M4 remain emulated/bandwidth-only. |
| 4   | MLX long-context decode falls ~50% behind llama.cpp ("version-dependent") | **Confirmed, with cause** | Documented root cause: MLX's attention kernel is not yet IO-aware (FlashAttention-style); open mlx-lm issue #763 tracks it. Replaced the vague hedge with the mechanism.                                           |

How the pass was run: targeted web searches for each item (Ollama 0.19 release notes + blog,
llama.cpp NVFP4/MXFP4 PRs, Apple M5 GPU Neural Accelerator documentation, and MLX long-context
benchmarks/issues), cross-checking a primary source (vendor blog, GitHub PR/issue, or Apple ML
Research) against at least one independent benchmark or write-up before changing the text. Sources for the
re-verified facts are cited inline in the affected sections and listed below.

### Sources added in this verification pass
- [Ollama blog - now powered by MLX on Apple Silicon (preview)](https://ollama.com/blog/mlx)
- [MacRumors - Ollama now runs faster on Macs thanks to MLX](https://www.macrumors.com/2026/03/31/ollama-now-runs-faster-apple-silicon-macs/)
- [andrew.ooo - Ollama 0.19 MLX review (2x faster on Apple Silicon)](https://andrew.ooo/posts/ollama-mlx-apple-silicon-review/)
- [RunAIHome - Ollama MLX on Apple Silicon in 2026](https://runaihome.com/blog/ollama-mlx-apple-silicon-2026/)
- [QUASA - Ollama full MLX support: 2x speedups + NVIDIA-quality 4-bit](https://quasa.io/media/ollama-just-got-blazing-fast-on-macs-full-mlx-support-brings-2-speedups-and-nvidia-quality-4-bit-inference)
- [llama.cpp PR #19769 - add NVFP4 quantization type](https://github.com/ggml-org/llama.cpp/pull/19769)
- [NVIDIA Dev Forums - llama.cpp native MXFP4 for Blackwell PR](https://forums.developer.nvidia.com/t/llama-cpp-experimental-native-mxfp4-support-for-blackwell-pr/355639)
- [llama.cpp Discussion #22498 - MXFP6 to improve NVFP4](https://github.com/ggml-org/llama.cpp/discussions/22498)
- [Apple ML Research - Exploring LLMs with MLX and the M5 GPU Neural Accelerators](https://machinelearning.apple.com/research/exploring-llms-mlx-m5)
- [tzakharko - Investigating the GPU Neural Accelerators on A19/M5](https://tzakharko.github.io/apple-neural-accelerators-benchmark/)
- [TechBoards - Apple A19/M5 GPU Neural Accelerators](https://techboards.net/threads/apple-a19-m5-gpu-neural-accelerators.5297/)
- [Skorppio - Apple M5 Max vs NVIDIA DGX Spark LLM benchmark](https://skorppio.com/blog/apple-m5-max-vs-nvidia-ai-deep-dive)
- [arXiv - Orion: Characterizing Apple's Neural Engine for LLM training and inference](https://arxiv.org/pdf/2603.06728)
- [mlx-lm Issue #763 - long-context token generation ~50% lower than llama.cpp](https://github.com/ml-explore/mlx-lm/issues/763)

---

## Bibliography

### GGUF quant performance & quality
- [Ollama Quantization Benchmark: q4_K_M vs q8_0 vs q5_K_M Throughput (Markaicode)](https://markaicode.com/benchmarks/ollama-quantization-benchmark/)
- [Ollama CPU Benchmark: Tokens per Second by Quantization (Markaicode)](https://markaicode.com/benchmarks/tool-cpu-benchmark/)
- [GGUF Quantization: Quality vs Speed on Consumer GPUs (dasroot)](https://dasroot.net/posts/2026/02/gguf-quantization-quality-speed-consumer-gpus/)
- [GGUF Quantization Explained: Q4_K_M vs Q8_0 vs F16 (Vucense)](https://vucense.com/dev-corner/gguf-quantization-explained-q4-k-m-vs-q8-0-vs-f16-2026/)
- [Q4_K_M vs Q5_K_M vs Q8 - Which GGUF Quantization? (WillItRunAI)](https://willitrunai.com/blog/quantization-guide-gguf-explained)
- [Q4 vs Q5 vs Q6 vs Q8: Real Quality Loss Numbers (RunAIHome)](https://runaihome.com/blog/quantization-q4-q5-q6-q8-quality-loss-2026/)
- [Ollama Quantization Explained: Q4 vs Q5 vs Q8 (ML Journey)](https://mljourney.com/ollama-quantization-explained-q4-vs-q5-vs-q8-and-how-to-choose/)
- [Ollama Model Quantization Guide: GGUF & Accuracy Loss (BetterLink/Easton)](https://eastondev.com/blog/en/posts/ai/20260422-ollama-gguf-quantization/)
- [Difference in quantization methods - llama.cpp Discussion #2094](https://github.com/ggml-org/llama.cpp/discussions/2094)

### MLX vs llama.cpp / Apple Silicon
- [Apple's MLX Runs Local LLMs 3x Faster Than llama.cpp - Until 40K Context (Towards AI)](https://pub.towardsai.net/apples-mlx-runs-local-llms-3x-faster-than-llama-cpp-until-your-context-hits-40k-715ec441afbb)
- [Benchmarking Apple's MLX vs. llama.cpp (Andreas Kunar, Medium)](https://medium.com/@andreask_75652/benchmarking-apples-mlx-vs-llama-cpp-bbbebdc18416)
- [Ollama vs llama.cpp vs MLX with Qwen3.5 35B on Apple Silicon (Ante Kapetanovic)](https://antekapetanovic.com/blog/qwen3.5-apple-silicon-benchmark/)
- [llama.cpp vs MLX vs Ollama vs vLLM: Apple Silicon 2026 (Contra Collective)](https://contracollective.com/blog/llama-cpp-vs-mlx-ollama-vllm-apple-silicon-2026)
- [MLX vs llama.cpp on Apple Silicon, M5 Neural Accelerators, why Ollama switched (yage.ai)](https://yage.ai/share/mlx-apple-silicon-en-20260331.html)
- [Apple Silicon LLM Inference Optimization Guide (Starmorph)](https://blog.starmorph.com/blog/apple-silicon-llm-inference-optimization-guide)
- [Performance of llama.cpp on Apple Silicon M-series - Discussion #4167](https://github.com/ggml-org/llama.cpp/discussions/4167)
- [GGUF vs MLX Quantization Formats on Apple Silicon (Contra Collective)](https://contracollective.com/blog/gguf-vs-mlx-quantization-formats-apple-silicon-2026)
- [GGUF vs MLX: A Deep Dive Into LLM Model Formats (ThinkSmart)](https://thinksmart.life/research/posts/gguf-vs-mlx-deep-dive/)
- [Ollama Goes MLX (Sebastian Gingter)](https://gingter.org/2026/04/23/ollama-goes-mlx/)
- [ml-explore/mlx (GitHub)](https://github.com/ml-explore/mlx)

### NVFP4 / MXFP / FP8 / Blackwell
- [Introducing NVFP4 for Efficient and Accurate Low-Precision Inference (NVIDIA)](https://developer.nvidia.com/blog/introducing-nvfp4-for-efficient-and-accurate-low-precision-inference/)
- [NVIDIA Blackwell: The Impact of NVFP4 For LLM Inference (Edge AI and Vision)](https://www.edge-ai-vision.com/2025/10/nvidia-blackwell-the-impact-of-nvfp4-for-llm-inference/)
- [FP4 Quantization on Blackwell GPUs: Throughput, Cost, When It's Worth It (Spheron)](https://www.spheron.network/blog/fp4-quantization-blackwell-gpu-cost/)
- [FP4 vs FP8 vs FP16 LLM Inference: Quality and Speed Tradeoffs (iFactory)](https://ifactoryapp.com/sap-integration/on-prem-ai/fp4-vs-fp8-vs-fp16-llm-inference)
- [Microbenchmarking NVIDIA's Blackwell Architecture (arXiv)](https://arxiv.org/pdf/2512.02189)
- [FP8 Training Infrastructure (Introl)](https://introl.com/blog/fp8-training-infrastructure-next-generation-precision-guide)
- [FP4 Just Landed in llama.cpp: NVFP4 vs MXFP4 (InsiderLLM)](https://insiderllm.com/guides/fp4-inference-llamacpp-nvfp4-mxfp4/)
- [Ollama Quantization (DeepWiki)](https://deepwiki.com/ollama/ollama/4.6-quantization)

### QAT and combination
- [Gemma 4 with quantization-aware training (Google)](https://blog.google/innovation-and-ai/technology/developers-tools/quantization-aware-training-gemma-4/)
- [Quantization-Aware Training (QAT) (Unsloth)](https://unsloth.ai/docs/blog/quantization-aware-training-qat)
- [Quantization-Aware Training for LLMs with PyTorch (PyTorch)](https://pytorch.org/blog/quantization-aware-training/)
- [How Quantization-Aware Training Enables Low-Precision Accuracy Recovery (NVIDIA)](https://developer.nvidia.com/blog/how-quantization-aware-training-enables-low-precision-accuracy-recovery/)
- [Quantization-Aware Distillation for NVFP4 Inference Accuracy Recovery (arXiv)](https://arxiv.org/pdf/2601.20088)
- [NeMo Framework QAT for Llama2 SFT (NVIDIA)](https://docs.nvidia.com/nemo-framework/user-guide/24.07/playbooks/qat.html)

### TTFT / TPS / prefill-decode fundamentals
- [Prefill Is Compute-Bound, Decode Is Memory-Bound (Towards Data Science)](https://towardsdatascience.com/prefill-is-compute-bound-decode-is-memory-bound-why-your-gpu-shouldnt-do-both/)
- [Prefill vs Decode: LLM Inference Phases Explained (Redis)](https://redis.io/blog/prefill-vs-decode/)
- [Prefill-decode disaggregation (BentoML LLM Inference Handbook)](https://bentoml.com/llm/inference-optimization/prefill-decode-disaggregation)
- [Why LLM Inference Is Memory-Bound (Not Compute-Bound) (Medium)](https://medium.com/@arjunravi726/why-llm-inference-is-memory-bound-not-compute-bound-ba59c48739e0)

### Architectural techniques (MoE / MTP / distill / YaRN / MatFormer / LASER)
- [Qwen3 Technical Report - MoE / A22B (arXiv)](https://arxiv.org/html/2505.09388v1)
- [Multi-Token Prediction (MTP) (Sebastian Raschka)](https://sebastianraschka.com/llm-architecture-gallery/mtp/)
- [DeepSeek-R1 Distilled Models Overview (EmergentMind)](https://www.emergentmind.com/topics/deepseek-r1-distilled-models)
- [YaRN: Efficient Context Window Extension (arXiv)](https://arxiv.org/abs/2309.00071)
- [Understanding Gemma 3n: MatFormer (Hugging Face)](https://huggingface.co/blog/rishiraj/matformer-in-gemma-3n)
- [The Truth is in There: LASER (arXiv)](https://arxiv.org/abs/2312.13558)
