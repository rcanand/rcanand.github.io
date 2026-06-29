---
title: Model glossary run 07 - v2 verification
date: 2026-06-29
tags:
  - ai
  - llm
  - quantization
excerpt: "Run 07 of the model-ID glossary analysis - re-researches the four hedged claims in the analysis report (Ollama MLX backend, FP4 in llama.cpp, Apple Silicon FP4/FP8 hardware, MLX long-context decode) with sources."
---

# v2 verification: resolving the hedged claims in the analysis report

Each item below was a place in [Model-ID glossary analysis](/blog/model-glossary-analysis/) where I hedged (knowledge-cutoff
uncertainty / "in this dataset's world"). Re-researched here with sources, so v2 can state them
as fact. Findings as of the environment date (June 2026).

## 1. Ollama MLX backend + NVFP4 on Apple Silicon  (CONFIRMED, real)
- Ollama **0.19 preview, released 2026-03-30**, rebuilds the Mac inference stack on Apple's MLX
  framework; **keeps llama.cpp for Linux/Windows**. Official announcement on the Ollama blog.
- Ollama uses **NVFP4** on Apple Silicon for 4-bit; on **M5 / M5 Pro / M5 Max** it uses the new
  **GPU Neural Accelerators** to speed up **both TTFT and decode**.
- Measured (M5 Max, Qwen3.5-35B-A3B, NVFP4): prefill 1,154 -> 1,810 tok/s, decode 58 -> 112 tok/s
  (~+57% / ~+93%); int4 path even higher (1,851 prefill / 134 decode). Preview needs a Mac with
  >32 GB unified memory.
- Sources:
  - Ollama blog - Ollama is now powered by MLX on Apple Silicon (preview): https://ollama.com/blog/mlx
  - MacRumors - Ollama now runs faster on Macs thanks to MLX: https://www.macrumors.com/2026/03/31/ollama-now-runs-faster-apple-silicon-macs/
  - andrew.ooo - Ollama 0.19 MLX review (2x faster): https://andrew.ooo/posts/ollama-mlx-apple-silicon-review/
  - RunAIHome - Ollama MLX on Apple Silicon 2026: https://runaihome.com/blog/ollama-mlx-apple-silicon-2026/
  - QUASA - Ollama full MLX support, 2x + NVIDIA-quality 4-bit: https://quasa.io/media/ollama-just-got-blazing-fast-on-macs-full-mlx-support-brings-2-speedups-and-nvidia-quality-4-bit-inference
  - Sebastian Gingter - Ollama goes MLX: https://gingter.org/2026/04/23/ollama-goes-mlx/

## 2. FP4 in llama.cpp  (CONFIRMED)
- **NVFP4** merged into llama.cpp (`GGML_TYPE_NVFP4 = 40`) via PRs late Mar-Apr 2026; CUDA dp4a /
  MMQ / SYCL / Vulkan kernels in mainline, **Blackwell-native tensor-core dispatch** in PR #22196.
  Older NVIDIA cards run FP4 but only get the **memory savings** (no tensor-core acceleration).
- **MXFP4** (OCP variant) is in ik_llama.cpp (gguf-py constants merged Nov 2025, kernels since).
- Sources:
  - llama.cpp PR #19769 - add NVFP4 quantization type: https://github.com/ggml-org/llama.cpp/pull/19769
  - InsiderLLM - FP4 just landed in llama.cpp (NVFP4 vs MXFP4): https://insiderllm.com/guides/fp4-inference-llamacpp-nvfp4-mxfp4/
  - NVIDIA Dev Forums - llama.cpp native MXFP4 for Blackwell PR: https://forums.developer.nvidia.com/t/llama-cpp-experimental-native-mxfp4-support-for-blackwell-pr/355639
  - llama.cpp Discussion #22498 - MXFP6 to improve NVFP4: https://github.com/ggml-org/llama.cpp/discussions/22498

## 3. Apple Silicon FP4/FP8 hardware  (CORRECTION to my earlier claim)
- My earlier "Apple GPUs lack FP4 tensor cores, so it's storage/bandwidth only" was **outdated**.
- **M5 / A19 GPUs add "GPU Neural Accelerators"** (matrix units, Apple's analog of tensor cores),
  reachable via Metal 4 / MLX. They **natively support FP8 and INT4 at full throughput** (prior
  M-series emulated low precision). Up to ~4x TTFT speedup vs M4 on matmul-heavy LLM prefill.
- Nuance that stays true: there is **no Apple equivalent of NVIDIA's dedicated NVFP4 tensor-core
  path**. NVFP4 specifically is an NVIDIA Blackwell format; on Mac the win comes from (a) memory/
  bandwidth and (b) M5 Neural Accelerators running the matmuls in their native low-precision modes.
  Pre-M5 Macs (M1-M4): no matrix accelerators -> low precision emulated -> mainly memory/bandwidth.
- Sources:
  - Apple ML Research - Exploring LLMs with MLX and the M5 GPU Neural Accelerators: https://machinelearning.apple.com/research/exploring-llms-mlx-m5
  - tzakharko - Investigating the GPU Neural Accelerators on A19/M5: https://tzakharko.github.io/apple-neural-accelerators-benchmark/
  - TechBoards - Apple A19/M5 GPU Neural Accelerators: https://techboards.net/threads/apple-a19-m5-gpu-neural-accelerators.5297/
  - Skorppio - Apple M5 Max vs NVIDIA DGX Spark LLM benchmark: https://skorppio.com/blog/apple-m5-max-vs-nvidia-ai-deep-dive
  - arXiv - Orion: Characterizing Apple's Neural Engine for LLM: https://arxiv.org/pdf/2603.06728

## 4. MLX long-context decode vs llama.cpp  (CONFIRMED, with concrete cause)
- At **30K+ context, MLX decode is ~50% slower than llama.cpp with Flash Attention** (M3 Ultra
  community testing). Root cause is documented, not vague: **MLX's attention kernel is not fully
  IO-aware (FlashAttention-style)**; there is an open mlx-lm issue requesting it. So the crossover
  is a real, current limitation, expected to narrow if/when MLX gains IO-aware attention.
- Sources:
  - mlx-lm Issue #763 - token generation on long context ~50% lower than llama.cpp: https://github.com/ml-explore/mlx-lm/issues/763
  - Towards AI - MLX 3x faster than llama.cpp until 40K context: https://pub.towardsai.net/apples-mlx-runs-local-llms-3x-faster-than-llama-cpp-until-your-context-hits-40k-715ec441afbb
  - yage.ai - MLX vs llama.cpp, M5 Neural Accelerators, why Ollama switched: https://yage.ai/share/mlx-apple-silicon-en-20260331.html

## Net edits for v2 (only inside the previously-hedged sections)
- Methodology note (intro): drop "indicative... not guarantees / can't vouch" tone; keep the
  factual "absolute numbers/ordering depend on hardware, context, batch, GPU gen, runtime."
- Section 3 platform table + bullets: state Ollama 0.19 MLX backend + NVFP4 as fact; correct the
  Apple low-precision cells to reflect M5 Neural Accelerators (native FP8/INT4) vs pre-M5 emulation.
- Section 5 table long-context row + Section 10 factor 3: replace "(version-dependent)" with the
  documented cause (MLX lacks IO-aware FlashAttention; ~50% slower decode at 30K+).
- Section 8 footnote 3 + Section 9 worked answer: drop "in this dataset's world"; state the
  Ollama 0.19 / M5 facts directly.
- Section 4.2 (added on request): the line "everything else ... no FP4 tensor cores ... bandwidth
  only" lumped all Apple GPUs together. Added a clarifying paragraph: M5/A19 run FP8/INT4 natively
  (real compute win), no dedicated NVFP4 unit, M1-M4 bandwidth-only. The bare "no FP4 tensor cores"
  remains literally true (Apple has no FP4-specific unit even on M5) but needed the fuller picture.
- Added a new "Verification pass (v2)" section before the Bibliography summarizing items 1-4 and
  the added Section 4.2 clarification, with method and the sources added this pass.
