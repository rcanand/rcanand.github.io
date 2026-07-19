---
title: My AI stack
date: 2026-06-19
tags: [ai, updates]
excerpt: "AI keeps changing, and the best model, agent, tool, etc. are ever changing - this post retains my current AI and software toolchain, with a log of updates to it over time."
---
This article is a living document - captures a snapshot of my current toolset, and occasionally updates on why I changed it.

- AI chat
	- grok 4.5 chat at grok.com (use "Expert" to ensure grok 4.5 or latest)
	- [huggingchat](https://huggingface.co/chat/) with inference providers, or run huggingchat [locally](https://github.com/huggingface/chat-ui) with local models
- Primary terminal AI harness (for anything involving local file system, coding or otherwise): [Pi](https://pi.dev)
- Hosted AI provider: openrouter
- Local AI provider: ollama
- AI model: (* indicates no vision/image input)
	- simplest to hardest tasks
		- Qwen3.6 27B
		- Deepseek-v4-Flash * 
		- Minimax M3
		- GLM 5.2 * 
		- Grok 4.5
		- Kimi K3
	- Alternates
		- Nemotron 3 Ultra *
		- Gemma 4 (for local)
- NotebookLM - For deep research and different "views"
- Grok - For the pulse of the internet AI chats (with X data) and also for a frank uncensored response on many things.
- Gemini - For web index data and Google properties
- Hermes agent and OpenClaw, but always in a VM - High agency agents
- **[Asta](https://asta.allen.ai/)** - Ai2. Literature-discovery agent over Semantic Scholar.

Software stack (highly optimized for AI):
- OS - Mac
- Mac VM in Mac - Lume (from cua)
- Terminal - iTerm2
- IDE - VSCodium (with telemetry off)
- Python - uv, pydantic v2, FastAPI, basedpyright
- data - Files - json, markdown with file system conventions, or if needed, DB - sqlite
- Native app - Pyside 6 for Qt
- Web frontend - vanilla html/css/js
- **[Obsidian](https://obsidian.md/)** - Personal vault, daily notes, frameworks.

## Past luminaries
- Claude - As of today (2026-06-19), Claude and Claude Code are a mess - since Opus 4.8, the entire experience with Claude and Claude Code went south, then there was the Fable debacle, and even before that the "no subscription access, even at 200$ per month to best model" - the sota model edge is already being held by a sliver. I think they just gave it away with all the recent choices - both technical and business. Still use it rarely when other things dont work, but there are better options for most things.
- ChatGPT - Was a favorite for a long time. They went off alignment several months back - heard they are better now, am checking them out, but no reason really to go back - cheaper models are as good if not better for most use cases.
