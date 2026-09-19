# SAQAYA Technical Interview Guide

This document outlines the expected technical interview format for SAQAYA, focusing on how to demonstrate expertise in TypeScript, Python, LLMs, and production infrastructure.

## 1. Expected Technical Interview Format

Given SAQAYA's AI-native focus, expect the technical interviews to be highly practical and aligned with modern development practices.
- **Pair Programming / AI-Assisted Coding**: They might provide an environment with Copilot/Cursor and evaluate *how* you use AI to write code faster, while testing your ability to review and correct the AI's output.
- **System Design Deep Dive**: A whiteboard or architecture diagram session focusing on building scalable AI backends.
- **Code Review / Architecture Critique**: Reviewing a poorly structured monolithic application and discussing how to refactor it for scale and testability.

## 2. Likely Coding Challenges

### Challenge A: LLM Provider Abstraction (Python or TS)
**Task**: Write a unified client that can route requests to either OpenAI or Anthropic, handling standard errors, retries, and returning a normalized response.
**What to demonstrate**:
- Interfaces/Abstract Base Classes (TypeScript `interface` or Python `ABC`).
- Robust error handling (catching rate limits, timeouts).
- Decorators or middleware for logging execution time and token count.

### Challenge B: Async Data Processing Pipeline
**Task**: Fetch data from an external API, process it (perhaps simulate passing it through an LLM for summarization), and save it to a database, handling concurrency limits.
**What to demonstrate**:
- `asyncio` in Python or `Promise.all` / `p-limit` in TypeScript.
- Batching requests to avoid overwhelming the external API.
- Graceful degradation if a batch fails.

## 3. System Design Expectations

**Scenario**: Design the backend architecture for a highly concurrent LLM application (e.g., an AI tutor for eLearning).
**Key Components to Include**:
- **API Gateway**: Rate limiting, auth, request routing.
- **Asynchronous Workers**: LLM calls are slow. Use a message queue (SQS, RabbitMQ, Celery, BullMQ) to handle processing in the background and use WebSockets or Polling to notify the frontend.
- **Caching Layer**: Redis for semantic caching (using vector embeddings of queries to return cached responses for similar queries) or exact match caching.
- **Vector Database**: Pinecone/Weaviate for RAG (Retrieval-Augmented Generation) context.
- **Telemetry**: Datadog/Prometheus for tracing request paths across microservices.

## 4. How to Demonstrate Production Experience

- **Talk about failure modes**: Whenever you propose a solution, immediately state how it could fail and how you mitigate that. *"I'd use Redis for caching, but if Redis goes down, the application should degrade gracefully and query the DB directly, though latency will increase."*
- **Mention tooling**: Throw in standard tools naturally: Terraform for infrastructure, GitHub Actions for CI/CD, Sentry for error tracking, DataDog for observability.
- **Focus on security**: Discuss managing API keys securely (Vault, AWS Secrets Manager), sanitizing inputs (especially for prompt injection), and implementing rate limiting.

## 5. How to Demonstrate LLM Expertise

- **Go beyond the basics**: Don't just talk about `openai.chat.completions.create`. Discuss structured outputs (JSON mode, function calling/tool use).
- **Prompt Engineering**: Mention techniques like few-shot prompting, chain-of-thought, and prompt versioning.
- **RAG Architecture**: Discuss chunking strategies, embedding models, and hybrid search (keyword + semantic).
- **Cost & Latency Optimization**: Discuss prompt caching, using smaller models (e.g., Claude 3 Haiku or GPT-4o-mini) for simple classification tasks, and reserving heavy models for complex reasoning.
