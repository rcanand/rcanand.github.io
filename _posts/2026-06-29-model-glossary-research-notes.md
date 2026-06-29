---
title: Model-ID glossary research notes
date: 2026-06-29
tags:
  - ai
  - llm
  - reference
excerpt: "Verified findings and source URLs collected as encountered during research for the model-ID glossary - covering GGUF quantization, NVFP4/MX formats, MLX, QAT, MTP, MoE notation, YaRN, distillation, MatFormer, DPO, LASER, reasoning models, abliteration, modality suffixes, and date conventions."
---

# Web research notes for model-ID stems

Verified findings + source URLs collected as encountered. Feeds the final glossary
at [Model-ID glossary](/blog/model-glossary/).

## GGUF quantization (Q4_K_M family)
- GGUF = file format used by llama.cpp / Ollama. Naming pattern `Q<bits>_<type>[_<size>]`.
- `Q4` = 4 bits per weight (nominal). `K` = "K-quants": super-block structure (blocks of 256
  weights split into sub-blocks), with quantized per-sub-block scales/mins for better bit
  allocation. Effective bpw is higher than nominal (Q4_K_M ~4.5 bpw).
- `_S`/`_M`/`_L` = small/medium/large mixes: how many tensors get bumped to higher precision.
  S = most aggressive, L = highest quality/size. M is the common sweet spot.
- Legacy `_0`/`_1` (Q4_0, Q4_1, Q5_0, Q5_1, Q8_0): older "round-to-nearest" block quant.
  `_0` = scale only; `_1` = scale + min offset (asymmetric), slightly better/larger.
- Sources:
  - llama.cpp quantize README: https://github.com/ggml-org/llama.cpp/blob/master/tools/quantize/README.md
  - "Which Quantization Should I Use?" arXiv: https://arxiv.org/html/2601.14277v1
  - Kaitchup, K-Quants/I-Quants/Legacy: https://kaitchup.substack.com/p/choosing-a-gguf-model-k-quants-i
  - llama.cpp discussion #2094: https://github.com/ggml-org/llama.cpp/discussions/2094
  - PromptQuorum Q4_K_M vs Q4_0 vs Q8_0: https://www.promptquorum.com/local-llms/llm-quantization-explained
  - APXML GGUF format: https://apxml.com/courses/practical-llm-quantization/chapter-5-quantization-formats-tooling/gguf-format

## NVFP4
- NVIDIA 4-bit float format (Blackwell). Element type E2M1 (1 sign, 2 exp, 1 mantissa).
  Block size 16 with an E4M3 FP8 per-block scale + optional FP32 outer scale. Smaller block
  (16 vs MXFP4's 32) -> less quant error. ~3.5x smaller than FP16, <1% accuracy loss; 2x FP8 throughput.
- Sources:
  - NVIDIA blog Introducing NVFP4: https://developer.nvidia.com/blog/introducing-nvfp4-for-efficient-and-accurate-low-precision-inference/
  - NVIDIA blog NVFP4 training: https://developer.nvidia.com/blog/nvfp4-trains-with-precision-of-16-bit-and-speed-and-efficiency-of-4-bit/
  - ZeroEntropy NVFP4: https://www.zeroentropy.dev/concepts/nvfp4/
  - Verda NVFP4 explained: https://verda.com/blog/nvfp4-nvidia-blackwell-intro
  - Red Hat Developer NVFP4: https://developers.redhat.com/articles/2026/02/04/accelerating-large-language-models-nvfp4-quantization

## MX formats (MXFP8 / MXFP4)
- MX = "Microscaling", an Open Compute Project (OCP) standard. Block-wise quant, block size 32,
  shared scale per block. Name = MX + element type + bits. MXFP4 = E2M1; MXFP8 = E4M3 or E5M2.
- Sources:
  - OCP MX v1.0 spec: https://www.opencompute.org/documents/ocp-microscaling-formats-mx-v1-0-spec-final-pdf
  - AMD Quark Microscaling docs: https://quark.docs.amd.com/latest/onnx/tutorial_microscaling_quantization.html
  - FPRox OCP MX scaling formats: https://fprox.substack.com/p/ocp-mx-scaling-formats
  - EmergentMind MX standard: https://www.emergentmind.com/topics/microscaling-mx-standard
  - Block floating point (Wikipedia): https://en.wikipedia.org/wiki/Block_floating_point

## MLX
- Apple's array/ML framework for Apple silicon (unified memory, lazy eval, NumPy-like). MLX
  weights in an Ollama tag = model packaged for Apple's MLX runtime. "MLX" ~ "ML explore"
  (team is ml-explore); no officially expanded acronym.
- Sources:
  - GitHub ml-explore/mlx: https://github.com/ml-explore/mlx
  - Apple Open Source MLX: https://opensource.apple.com/projects/mlx/
  - MLX framework site: https://mlx-framework.org/
  - WWDC25 Get started with MLX: https://developer.apple.com/videos/play/wwdc2025/315/

## QAT (Quantization-Aware Training)
- Simulates low-precision math during training so the model learns to compensate for quant
  error; yields higher quality than post-training quantization (PTQ) at the same bit width.
  Gemma QAT checkpoints run near-FP16 quality at ~4-bit memory.
- Sources:
  - Google Developers Blog Gemma 3 QAT: https://developers.googleblog.com/en/gemma-3-quantized-aware-trained-state-of-the-art-ai-to-consumer-gpus/
  - Google blog Gemma 4 QAT: https://blog.google/innovation-and-ai/technology/developers-tools/quantization-aware-training-gemma-4/
  - Gemma docs QAT colab: https://gemma-llm.readthedocs.io/en/latest/colab_quantization_aware_training.html

## MTP (Multi-Token Prediction)
- Training objective + inference trick: extra heads predict t+2, t+3... Used as a speculative-
  decoding draft module at inference (DeepSeek-V3, Qwen3-Next) for ~1.8x speedup.
- Sources:
  - Sebastian Raschka MTP: https://sebastianraschka.com/llm-architecture-gallery/mtp/
  - DeepSeek Explained 4 (Medium): https://medium.com/data-science-collective/deepseek-explained-4-multi-token-prediction-33f11fe2b868
  - NVIDIA Megatron-Bridge MTP docs: https://docs.nvidia.com/nemo/megatron-bridge/latest/training/multi-token-prediction.html
  - DeepSeek-V3 hardware arXiv: https://arxiv.org/pdf/2505.09343

## Float / integer precision formats
- FP16 = 1 sign / 5 exp / 10 mantissa. BF16 = 1/8/7 (FP32 exponent range, less precision; good
  for training, no loss scaling). FP8 = E4M3 or E5M2. INT8/INT4 = uniform integer quant.
  Compression vs FP32: 2x (16-bit) to 8x (4-bit).
- Sources:
  - Exxact What is FP64/FP32/FP16: https://www.exxactcorp.com/blog/hpc/what-is-fp64-fp32-fp16
  - RunPod FP16/BF16/FP8 mixed precision: https://www.runpod.io/articles/guides/fp16-bf16-fp8-mixed-precision-speed-up-my-model-training
  - Luminary Understanding ML numerical formats: https://luminary.blog/techs/numbers-in-machine-learning/
  - Towards AI LLM quantization FP32/FP16/BF16/INT8: https://pub.towardsai.net/understanding-llm-quantization-why-fp32-fp16-bf16-and-int8-matter-for-modern-ai-systems-076ea6eb9ca6

## MoE + active-parameter notation (A22B, 8x7b, 16E/128E)
- MoE = mixture of experts; router activates top-k experts per token. `235B-A22B` = 235B total
  params, 22B Active per forward pass. `8x7b` (Mixtral) = 8 experts of ~7B. `16E`/`128E`
  (Llama 4) = number of experts. `A3B` etc = active billions.
- Sources:
  - Qwen3 Technical Report arXiv: https://arxiv.org/html/2505.09388v1
  - OpenRouter Qwen3-235B-A22B: https://openrouter.ai/qwen/qwen3-235b-a22b-2507
  - EmergentMind Qwen3-235B-A22B: https://www.emergentmind.com/topics/qwen3-235b-a22b
  - HF Llama-4-Scout-17B-16E: https://huggingface.co/meta-llama/Llama-4-Scout-17B-16E
  - HF Llama-4-Maverick-17B-128E-Instruct: https://huggingface.co/meta-llama/Llama-4-Maverick-17B-128E-Instruct
  - Meta Llama 4 herd blog: https://ai.meta.com/blog/llama-4-multimodal-intelligence/

## YaRN (context extension; also "gradient")
- YaRN = "Yet another RoPE extensioN" - piecewise NTK-by-parts frequency scaling of RoPE +
  attention temperature; extends context with <0.1% extra training. (llama3-gradient = similarly
  context-extended Llama 3.)
- Sources:
  - YaRN arXiv abstract: https://arxiv.org/abs/2309.00071
  - YaRN PDF: https://arxiv.org/pdf/2309.00071
  - EleutherAI YaRN: https://www.eleuther.ai/papers-blog/yarn-efficient-context-window-extension-of-large-language-models
  - EmergentMind YaRN: https://www.emergentmind.com/topics/yarn-yet-another-rope-extension-method

## Distillation (distill)
- Train a small "student" to mimic a large "teacher"; e.g. DeepSeek-R1-Distill-Qwen/Llama
  transfer R1 reasoning into smaller bases via 800k R1-generated examples.
- Sources:
  - EmergentMind DeepSeek-R1 distilled: https://www.emergentmind.com/topics/deepseek-r1-distilled-models
  - IBM DeepSeek-R1 distilled on watsonx: https://www.ibm.com/new/announcements/deepseek-r1-distilled-models-now-available-on-watsonx-ai
  - AnalyticsVidhya distilled R1: https://www.analyticsvidhya.com/blog/2025/02/distilled-deepseek-r1-model/

## Gemma 3n / 4 MatFormer (E2B, E4B, PLE)
- `E2B`/`E4B` = ~2B/~4B Effective params. MatFormer = Matryoshka transformer: a big model with
  nested smaller submodels (E4B contains E2B). PLE = Per-Layer Embeddings -> total weights >
  effective params.
- Sources:
  - Google Developers Blog Gemma 3n guide: https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/
  - Google AI Gemma 3n overview: https://ai.google.dev/gemma/docs/gemma-3n
  - HF MatFormer in Gemma 3n: https://huggingface.co/blog/rishiraj/matformer-in-gemma-3n
  - Alan Dao Gemma 4 E2B PLE notes: https://alandao.net/posts/gemma-4-e2b-per-layer-embeddings-ple-research-notes/

## DPO and instruct/base/chat/it suffixes
- Base = raw pretrained LM (no instruction following). Instruct = instruction-tuned. `it` =
  instruction-tuned (Gemma's label). Chat = multi-turn / RLHF dialogue. DPO = Direct Preference
  Optimization, RLHF-free preference alignment (suffix on some community tunes).
- Sources:
  - HF Preference tuning with DPO: https://huggingface.co/blog/pref-tuning
  - DPO paper explained (Tyler Romero): https://www.tylerromero.com/posts/2024-04-dpo/
  - Red Hat how to navigate LLM model names: https://developers.redhat.com/articles/2025/04/03/how-navigate-llm-model-names
  - Alex Ewerlof base vs instruct vs thinking: https://blog.alexewerlof.com/p/base-models-vs-instruct-models
  - Medium base/instruct/chat architectures: https://medium.com/@yashwanths_29644/llm-finetuning-series-05-llm-architectures-base-instruct-and-chat-models-a6219c39c362

## LASER (laser stem)
- LASER = LAyer-SElective Rank-Reduction: replace selected weight matrices with low-rank
  (SVD) approximations after training; can improve reasoning. Used by cognitivecomputations
  (Dolphin) laser tunes.
- Sources:
  - LASER arXiv: https://arxiv.org/abs/2312.13558
  - LASER project page: https://pratyushasharma.github.io/laser/
  - laserRMT (cognitivecomputations): https://github.com/cognitivecomputations/laserRMT
  - Microsoft Research LASER brief: https://www.microsoft.com/en-us/research/quarterly-brief/jan-2024-brief/articles/improving-reasoning-in-language-models-with-laser-layer-selective-rank-reduction/

## gpt-oss / OSS + reasoning effort
- OSS = open-weight (Apache-2.0) OpenAI models. Reasoning effort tiers low/medium/high (set in
  system prompt); newer GPT-5.x in the AA data also expose "minimal" and "xhigh" tiers.
- Sources:
  - OpenAI Introducing gpt-oss: https://openai.com/index/introducing-gpt-oss/
  - gpt-oss model card arXiv: https://arxiv.org/pdf/2508.10925
  - OpenAI open models: https://openai.com/open-models/

## Thinking / reasoning models (thinking, think, reasoning, qwq)
- Reasoning / "thinking" models are trained (often via RL) to emit chain-of-thought (often in
  <think>...</think>) before the answer. QwQ = "Qwen with Questions" reasoning series.
- Sources:
  - Sebastian Raschka Understanding Reasoning LLMs: https://magazine.sebastianraschka.com/p/understanding-reasoning-llms
  - NVIDIA CoT prompting glossary: https://www.nvidia.com/en-us/glossary/cot-prompting/
  - Qwen QwQ-32B blog: https://qwenlm.github.io/blog/qwq-32b/
  - QwQ GitHub: https://github.com/QwenLM/QwQ

## Uncensored / abliterated
- "uncensored" = community fine-tune with safety/refusals stripped. "abliterated" =
  refusal-direction ablation in activation space (representation engineering), weights edited.
- Sources:
  - HF Uncensor any LLM with abliteration: https://huggingface.co/blog/mlabonne/abliteration
  - abliteration.ai What is an abliterated LLM: https://abliteration.ai/abliterated-llm
  - WebDecoy abliterated models explained: https://webdecoy.com/blog/wtf-are-abliterated-models-uncensored-llms-explained/

## Modality suffixes (VL, vision, omni, ocr, audio, image, embed)
- VL = Vision-Language (text+image). vision = same. omni = omni-modal (text/image/audio/video
  in+out, speech gen). ocr = optical character recognition tunes. embed/embedding = embedding
  models. guard/guardian/shield/safeguard = safety classifier models.
- Sources:
  - Qwen-VL arXiv: https://arxiv.org/abs/2308.12966
  - Qwen3-VL Technical Report: https://arxiv.org/abs/2511.21631
  - Qwen2.5-Omni HF: https://huggingface.co/Qwen/Qwen2.5-Omni-7B
  - LlamaIndex What is Qwen-VL: https://www.llamaindex.ai/glossary/what-is-qwen-vl

## Date-stamp version convention (YYMM and YYYYMMDD)
- 4-digit suffix = YYMM. e.g. 2407 = Jul 2024, 2501 = Jan 2025, 2507 = Jul 2025 (Mistral, Qwen,
  Magistral, Devstral, Voxtral). 8-digit (openrouter canonical) = YYYYMMDD release date.
- Sources:
  - Mistral changelog: https://docs.mistral.ai/getting-started/changelog
  - Mistral Large 2407 announcement: https://mistral.ai/news/mistral-large-2407/
  - Starmorph LLM model names decoded: https://blog.starmorph.com/blog/llm-model-names-decoded

## Guard / safety classifier models (guard, guardian, shield, safeguard)
- Safety classifier models used as guardrails (classify prompt/response against a risk
  taxonomy). Llama Guard, ShieldGemma, Granite Guardian, gpt-oss-safeguard.
- Sources:
  - EmergentMind Llama Guard 3: https://www.emergentmind.com/topics/llama-guard-3
  - Medium How Llama Guard improves AI safety: https://medium.com/@tahirbalarabe2/%EF%B8%8Fhow-llama-guard-improves-ai-safety-with-llm-based-moderation-73ff34980c5f
