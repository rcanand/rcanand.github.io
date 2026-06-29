---
title: Model glossary run 03 - Advanced quant/format/training stems
date: 2026-06-29
tags:
  - ai
  - llm
  - reference
excerpt: "Run 03 of the model-ID glossary analysis - lists Ollama tags carrying advanced quantization, format, and training stems (NVFP4, MXFP8, FP8, QAT, MTP, MLX, INT4, INT8)."
---

# Run 03 - Ollama tags carrying advanced quant/format/training stems

Source code: `model_glossary_run_03_advanced_quant.py`  
Raw output: `model_glossary_run_03_output.txt`

## Code

```python
import json
DATA=".../data"
oll=json.load(open(f"{DATA}/ollama_models.json"))['models']
hits=set()
for mdl in oll:
    for key in ('tags','detailed_tags'):
        for t in mdl.get(key,[]):
            ft=t.get('full_tag','')
            up=ft.upper()
            if any(s in up for s in ('NVFP','MXFP','FP8','QAT','MTP','MLX','INT4','INT8')):
                hits.add(ft)
print("Ollama full_tags carrying advanced quant / format / training stems:")
for x in sorted(hits):
    print(" ", x)
```

## Output

```
Ollama full_tags carrying advanced quant / format / training stems:
  embeddinggemma:300m-qat-q4_0
  embeddinggemma:300m-qat-q8_0
  gemma3:12b-it-qat
  gemma3:1b-it-qat
  gemma3:270m-it-qat
  gemma3:27b-it-qat
  gemma3:4b-it-qat
  gemma4:12b-it-qat
  gemma4:12b-mlx
  gemma4:12b-mlx-bf16
  gemma4:12b-mxfp8
  gemma4:12b-nvfp4
  gemma4:26b-a4b-it-qat
  gemma4:26b-mlx
  gemma4:26b-mlx-bf16
  gemma4:26b-mxfp8
  gemma4:26b-nvfp4
  gemma4:31b-coding-mtp-bf16
  gemma4:31b-it-qat
  gemma4:31b-mlx
  gemma4:31b-mlx-bf16
  gemma4:31b-mxfp8
  gemma4:31b-nvfp4
  gemma4:e2b-it-qat
  gemma4:e2b-mlx
  gemma4:e2b-mlx-bf16
  gemma4:e2b-mxfp8
  gemma4:e2b-nvfp4
  gemma4:e4b-it-qat
  gemma4:e4b-mlx
  gemma4:e4b-mlx-bf16
  gemma4:e4b-mxfp8
  gemma4:e4b-nvfp4
  laguna-xs.2:mlx-bf16
  laguna-xs.2:mxfp8
  laguna-xs.2:nvfp4
  qwen3.5:0.8b-mlx
  qwen3.5:0.8b-mlx-bf16
  qwen3.5:0.8b-mxfp8
  qwen3.5:0.8b-nvfp4
  qwen3.5:27b-coding-mxfp8
  qwen3.5:27b-coding-nvfp4
  qwen3.5:27b-int4
  qwen3.5:27b-int8
  qwen3.5:27b-mlx
  qwen3.5:27b-mlx-bf16
  qwen3.5:27b-mxfp8
  qwen3.5:27b-nvfp4
  qwen3.5:2b-mlx
  qwen3.5:2b-mlx-bf16
  qwen3.5:2b-mxfp8
  qwen3.5:2b-nvfp4
  qwen3.5:35b-a3b-coding-mxfp8
  qwen3.5:35b-a3b-coding-nvfp4
  qwen3.5:35b-a3b-int4
  qwen3.5:35b-a3b-int8
  qwen3.5:35b-a3b-mlx-bf16
  qwen3.5:35b-a3b-mxfp8
  qwen3.5:35b-a3b-nvfp4
  qwen3.5:35b-mlx
  qwen3.5:4b-mlx
  qwen3.5:4b-mlx-bf16
  qwen3.5:4b-mxfp8
  qwen3.5:4b-nvfp4
  qwen3.5:9b-mlx
  qwen3.5:9b-mlx-bf16
  qwen3.5:9b-mxfp8
  qwen3.5:9b-nvfp4
  qwen3.6:27b-coding-mxfp8
  qwen3.6:27b-coding-nvfp4
  qwen3.6:27b-mlx
  qwen3.6:27b-mlx-bf16
  qwen3.6:27b-mtp-bf16
  qwen3.6:27b-mtp-q4_K_M
  qwen3.6:27b-mtp-q8_0
  qwen3.6:27b-mxfp8
  qwen3.6:27b-nvfp4
  qwen3.6:35b-a3b-coding-mxfp8
  qwen3.6:35b-a3b-coding-nvfp4
  qwen3.6:35b-a3b-mlx-bf16
  qwen3.6:35b-a3b-mtp-bf16
  qwen3.6:35b-a3b-mtp-q4_K_M
  qwen3.6:35b-a3b-mtp-q8_0
  qwen3.6:35b-a3b-mxfp8
  qwen3.6:35b-a3b-nvfp4
  qwen3.6:35b-mlx
```
