---
title: Model glossary run 05 - Performance & combination research notes
date: 2026-06-29
tags:
  - ai
  - llm
  - quantization
excerpt: "Run 05 of the model-ID glossary analysis - verified findings and source links on the GGUF quant ladder, MLX vs llama.cpp, NVFP4/MXFP4/FP8, QAT, TTFT vs TPS, and orthogonal build-time techniques."
---

# Performance & combination research notes (for [Model-ID glossary analysis](/blog/model-glossary-analysis/))

Verified findings + links collected as encountered. These feed the analysis report.
All numbers are indicative ranges from public benchmarks (mostly 2026), not guarantees;
hardware, model, context length, and runtime version move them substantially.

## GGUF quant ladder (quality / speed / size) - llama.cpp / Ollama
- Quality retention vs FP16 (approx): Q4_K_M ~92-95%; Q5_K_M ~+1.5% over Q4_K_M; Q6_K ~+2%;
  Q8_0 ~+3% (near-lossless). Perplexity gap Q4_K_M->Q8_0 ~8%; task accuracy drop 1-5%
  (HumanEval/GSM8K).
- Speed (TPS) is INVERSE to bits because decode is memory-bandwidth bound: lower bits = less
  data moved per token = higher tok/s. RTX 4090 Llama-3.2-8B: Q4_K_M 112 tok/s vs Q8_0 83 tok/s
  (+35%). CPU 12 threads: Q4_K_M 14.2 vs Q5_K_M 8.5 vs Q8_0 6.8 tok/s.
- Size on disk ~= bits/weight x params. 7B: FP16 ~13.5 GB -> Q4_K_M ~4.1 GB. VRAM/RAM ~= disk +
  KV cache + overhead. RTX 4090 Q4_K_M 5.8 GB vs Q8_0 9.1 GB.
- Sources:
  - Markaicode Ollama quant benchmark: https://markaicode.com/benchmarks/ollama-quantization-benchmark/
  - Markaicode Ollama CPU benchmark: https://markaicode.com/benchmarks/tool-cpu-benchmark/
  - dasroot GGUF quality vs speed on consumer GPUs: https://dasroot.net/posts/2026/02/gguf-quantization-quality-speed-consumer-gpus/
  - Vucense GGUF Q4_K_M vs Q8_0 vs F16: https://vucense.com/dev-corner/gguf-quantization-explained-q4-k-m-vs-q8-0-vs-f16-2026/
  - WillItRunAI Q4_K_M vs Q5_K_M vs Q8 guide: https://willitrunai.com/blog/quantization-guide-gguf-explained
  - RunAIHome Q4/Q5/Q6/Q8 quality loss: https://runaihome.com/blog/quantization-q4-q5-q6-q8-quality-loss-2026/

## MLX vs llama.cpp/GGUF on Apple Silicon (Mac only)
- MLX ~1.4-1.8x faster than raw llama.cpp for decode (TPS); "3x faster than Ollama" is mostly
  Ollama overhead. MLX edge grows at long context (KV cache stays in unified memory).
- TTFT/prefill: llama.cpp (Metal + Flash Attention) is often FASTER at TTFT than MLX. At short
  prompts GGUF can beat MLX on combined effective tok/s; at 30K+ context MLX decode can be ~50%
  slower than llama.cpp w/ Flash Attention (varies by version).
- MLX is Apple-silicon-only. GGUF is cross-platform.
- Sources:
  - Towards AI MLX 3x faster until 40K: https://pub.towardsai.net/apples-mlx-runs-local-llms-3x-faster-than-llama-cpp-until-your-context-hits-40k-715ec441afbb
  - Medium Benchmarking MLX vs llama.cpp (Kunar): https://medium.com/@andreask_75652/benchmarking-apples-mlx-vs-llama-cpp-bbbebdc18416
  - Ante Kapetanovic Ollama vs llama.cpp vs MLX Qwen3.5: https://antekapetanovic.com/blog/qwen3.5-apple-silicon-benchmark/
  - Contra Collective llama.cpp vs MLX vs Ollama vs vLLM: https://contracollective.com/blog/llama-cpp-vs-mlx-ollama-vllm-apple-silicon-2026
  - yage.ai MLX vs llama.cpp + why Ollama switched: https://yage.ai/share/mlx-apple-silicon-en-20260331.html
  - Starmorph Apple Silicon LLM inference guide: https://blog.starmorph.com/blog/apple-silicon-llm-inference-optimization-guide
  - llama.cpp Apple Silicon perf discussion #4167: https://github.com/ggml-org/llama.cpp/discussions/4167

## NVFP4 / MXFP4 / FP8 / BF16 (GPU compute formats)
- Hardware: NVFP4 + MXFP4 + FP6 are NATIVE on NVIDIA Blackwell (5th-gen tensor cores); FP8 native
  on Hopper+; on Ampere FP8/FP4 are emulated (slow). => these are GPU-only, effectively
  Linux/WSL with a recent NVIDIA GPU. Not Apple/Metal, not CPU.
- NVFP4 vs MXFP4: NVFP4 block-16 + E4M3 scale + FP32 global scale (finer) vs MXFP4 block-32 +
  E8M0 (power-of-two) scale. NVFP4 ~88% lower quant error than MXFP4; on AIME'24 NVFP4 scored
  ~2% above FP8. Best practice: NVFP4 weights + FP8/BF16 attention (mixed), not pure FP4.
- Throughput stair on Blackwell: FP4 ~4x, FP8 ~2x, BF16 ~1x. RTX PRO 6000 NVFP4 ~6-8k tok/s,
  ~1.7-2x A100; NVFP4 also gives fastest TTFT on Blackwell.
- Sources:
  - NVIDIA Introducing NVFP4: https://developer.nvidia.com/blog/introducing-nvfp4-for-efficient-and-accurate-low-precision-inference/
  - Spheron FP4 on Blackwell cost/when worth it: https://www.spheron.network/blog/fp4-quantization-blackwell-gpu-cost/
  - Edge-AI-Vision Blackwell impact of NVFP4: https://www.edge-ai-vision.com/2025/10/nvidia-blackwell-the-impact-of-nvfp4-for-llm-inference/
  - iFactory FP4 vs FP8 vs FP16 quality/speed: https://ifactoryapp.com/sap-integration/on-prem-ai/fp4-vs-fp8-vs-fp16-llm-inference
  - Microbenchmarking Blackwell (arXiv): https://arxiv.org/pdf/2512.02189
  - Introl FP8 training infrastructure: https://introl.com/blog/fp8-training-infrastructure-next-generation-precision-guide

## QAT combination + quality
- QAT is ORTHOGONAL to the numeric format: it fine-tunes while simulating quant, then exports to
  a target format. Gemma 3/4 QAT ships as Q4_0 (the canonical QAT+GGUF combo). QAT recovers up to
  ~70% of lost accuracy, +1-3% on GPQA/MMLU-Pro vs PTQ. QAT also exists for NVFP4 (quant-aware
  distillation) => QAT + NVFP4 valid; QAT + Q4_K_M valid (export to any int quant).
- Sources:
  - Google Gemma 4 QAT: https://blog.google/innovation-and-ai/technology/developers-tools/quantization-aware-training-gemma-4/
  - Unsloth QAT docs: https://unsloth.ai/docs/blog/quantization-aware-training-qat
  - PyTorch QAT for LLMs: https://pytorch.org/blog/quantization-aware-training/
  - NVIDIA QAT low-precision accuracy recovery: https://developer.nvidia.com/blog/how-quantization-aware-training-enables-low-precision-accuracy-recovery/
  - Quantization-Aware Distillation for NVFP4 (arXiv): https://arxiv.org/pdf/2601.20088

## Ollama / llama.cpp / MLX format support (the "can it even run" axis)
- All Ollama models are GGUF; llama.cpp backend recognizes only GGUF. In this dataset's 2026
  world Ollama 0.19 added an MLX backend (Apple Silicon) and NVFP4 as an option on Apple Silicon
  (NVIDIA contributed); FP4 (NVFP4/MXFP4) merged into llama.cpp Mar-Apr 2026.
- Key mental model: numeric format (GGUF Q*, FP8, NVFP4, MXFP4, BF16) is an ENCODING of weights;
  MLX/GGUF are CONTAINERS+RUNTIMES; the GPU arch (Blackwell etc.) determines native vs emulated.
  MLX quant is its own scheme (not GGUF Q4_K_M); MLX-bf16 = bf16 weights in MLX.
- Sources:
  - Ollama Quantization (DeepWiki): https://deepwiki.com/ollama/ollama/4.6-quantization
  - InsiderLLM FP4 in llama.cpp NVFP4 vs MXFP4: https://insiderllm.com/guides/fp4-inference-llamacpp-nvfp4-mxfp4/
  - Gingter Ollama goes MLX: https://gingter.org/2026/04/23/ollama-goes-mlx/
  - Contra Collective GGUF vs MLX quant formats: https://contracollective.com/blog/gguf-vs-mlx-quantization-formats-apple-silicon-2026
  - ThinkSmart GGUF vs MLX deep dive: https://thinksmart.life/research/posts/gguf-vs-mlx-deep-dive/

## TTFT vs TPS fundamentals (why rankings split)
- Prefill = compute-bound, high arithmetic intensity => sets TTFT. Decode = memory-bandwidth
  bound (streams weights + growing KV cache) => sets TPS. Quantization shrinks bytes moved per
  token, so it helps DECODE (TPS) much more than PREFILL (TTFT). Speculative decoding (MTP) and
  bigger batches also target decode.
- => A format can win on TPS but not TTFT (e.g., MLX vs llama.cpp), and quality/speed rank order
  flips with context length, batch size, GPU generation, and task (math/code sensitive to bits).
- Sources:
  - Towards Data Science Prefill compute-bound, decode memory-bound: https://towardsdatascience.com/prefill-is-compute-bound-decode-is-memory-bound-why-your-gpu-shouldnt-do-both/
  - Redis Prefill vs Decode: https://redis.io/blog/prefill-vs-decode/
  - BentoML Prefill-decode disaggregation: https://bentoml.com/llm/inference-optimization/prefill-decode-disaggregation
  - Medium Why LLM inference is memory-bound: https://medium.com/@arjunravi726/why-llm-inference-is-memory-bound-not-compute-bound-ba59c48739e0

## Orthogonal build-time techniques (travel with weights, platform-independent)
- MoE (A22B): compute/TPS scales with ACTIVE params (~22B), RAM/disk scales with TOTAL (~235B).
- MTP: speculative-decoding draft head; ~1.8x decode speedup where runtime supports it; no quality
  loss. (Qwen3-Next, DeepSeek-V3.)
- distill: smaller student => faster+smaller, small quality gap vs teacher.
- QAT/DPO/LASER/abliteration: change weights' quality/behavior, not size or runtime.
- YaRN/gradient: extend context; cost is longer-context compute + KV cache, not base size.
- MatFormer (E2B/E4B): pick a nested submodel size; PLE makes stored size > effective compute.
