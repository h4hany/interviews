# LLM Fundamentals

## 1. Transformer Architecture
### What
The Transformer is a deep learning architecture based entirely on attention mechanisms, dispensing with recurrence and convolutions entirely. Introduced in the paper "Attention Is All You Need" (2017).

### Why
Pre-transformer models (RNNs/LSTMs) processed data sequentially, causing bottlenecks in training and difficulty maintaining long-range dependencies. Transformers allow for parallel processing of sequence data and direct modeling of dependencies regardless of distance.

### How it Works Internally
- **Encoder-Decoder Structure (Original):** The original transformer had an encoder (processing input) and decoder (generating output). Modern LLMs (like GPT) are typically decoder-only.
- **Self-Attention:** Computes a representation of a sequence by relating different positions of the same sequence.
- **Feed-Forward Networks (FFN):** Applied to each position separately and identically.
- **Layer Normalization & Residual Connections:** Stabilizes training and allows for very deep networks.

### Trade-offs & Failure Modes
- **Trade-offs:** O(N^2) time and memory complexity with respect to sequence length, requiring massive compute for long context windows.
- **Failure Modes:** Attention dilution in very long contexts (the "lost in the middle" phenomenon).

## 2. Attention Mechanism (Self-Attention)
### What
The mechanism by which the model decides how much "focus" or "weight" to give to other words in the input sequence when encoding a specific word.

### How it Works Internally
- **Query (Q), Key (K), Value (V):** Each token is linearly projected into Q, K, and V vectors.
- **Scaled Dot-Product:** Attention = Softmax((Q * K^T) / sqrt(d_k)) * V
- **Multi-Head Attention:** Running multiple attention mechanisms in parallel, allowing the model to jointly attend to information from different representation subspaces.

## 3. Tokenization
### What
The process of converting raw text into discrete chunks (tokens) that the model can ingest.

### Why
Models operate on numbers, not text. We need a consistent mapping from text chunks to integer IDs.

### Types
- **BPE (Byte Pair Encoding):** Merges the most frequent pairs of bytes/characters. Used by OpenAI.
- **WordPiece:** Similar to BPE but maximizes the likelihood of the training data. Used by BERT.
- **SentencePiece:** Treats input as a raw stream (including spaces) and uses BPE or Unigram.

### Trade-offs & Failure Modes
- **Trade-offs:** Vocabulary size vs. sequence length. Larger vocab = shorter sequences (less compute) but larger embedding matrix (more memory).
- **Failure Modes:** Poor tokenization of numbers, code, or non-English languages can severely degrade performance. E.g., spelling tasks fail because the model doesn't see individual letters.

## 4. Context Windows
### What
The maximum number of tokens a model can process in a single request (input + output).

### Why
Limited by the O(N^2) memory scaling of the self-attention mechanism, though modern techniques like FlashAttention, RingAttention, and RoPE (Rotary Position Embeddings) scaling have pushed limits from 2k (GPT-3) to 1M+ (Gemini 1.5).

### Failure Modes
- "Lost in the middle": Models often recall information at the start and end of a long context better than the middle.

## 5. Temperature, Top-p, Top-k
### What
Parameters controlling the randomness/creativity of the generation process during decoding.
- **Temperature (T):** Scales the logits before softmax. T=0 makes it deterministic (greedy). T>1 flattens the distribution (more random). T<1 sharpens it.
- **Top-k:** Samples only from the top K most likely next tokens.
- **Top-p (Nucleus Sampling):** Samples from the smallest set of tokens whose cumulative probability exceeds P.

### When to use
- **Deterministic output (Coding, Extraction, Classification):** Temp = 0, Top-p = 0.1
- **Creative output (Brainstorming, Copywriting):** Temp = 0.7-1.0, Top-p = 0.9

## 6. Embeddings
### What
Dense vector representations of text where similar meanings are close together in vector space.

### When to use
RAG (Retrieval-Augmented Generation), semantic search, clustering, classification.

## 7. Fine-tuning vs Prompting
- **Prompting/RAG:** Giving the model instructions/context at inference time. Fast, cheap to setup, uses context window. Best for knowledge injection.
- **Fine-tuning (SFT/LoRA):** Changing model weights. Expensive, requires datasets. Best for changing model *behavior*, tone, or syntax (e.g., forcing JSON output structure, teaching a new domain-specific language syntax).

## 8. Hallucinations
### What
When the model generates factually incorrect, nonsensical, or ungrounded information that sounds plausible.

### Why
Models are trained to predict the next token, not to verify truth. If a token sequence is statistically probable in its training distribution, it will generate it.

### Mitigation
- RAG (grounding in retrieved facts)
- System prompts instructing the model to say "I don't know"
- Temperature = 0
- Self-correction/Verification chains

## 9. Model Evaluation
### What
Measuring LLM performance is fundamentally hard because text generation is open-ended.
### Techniques
- **Exact Match / F1:** Only for strict QA or extraction.
- **LLM-as-a-Judge:** Using a stronger model (GPT-4) to grade a weaker model's output based on a rubric.
- **Benchmarks:** MMLU (knowledge), HumanEval (coding), GSM8k (math).

---

## Interview Questions

**Q1: Explain the "Lost in the Middle" phenomenon and how you design systems to mitigate it.**
**A:** "Lost in the Middle" refers to an LLM's tendency to accurately recall information placed at the beginning or end of its context window while degrading in performance for information located in the middle. This occurs because training data typically places the most salient information at the start or end of documents.
*Mitigations:*
1. **Prompt structure:** Place the most critical instructions/context at the very end of the prompt (closest to generation).
2. **RAG chunking:** Keep context windows smaller by only injecting highly relevant top-k chunks.
3. **Re-ranking:** Use a cross-encoder to re-rank retrieved documents and place the absolute most relevant ones at the beginning and end of the injected context.

**Q2: We need an LLM to output valid SQL queries for our database. Should we fine-tune a model or use few-shot prompting?**
**A:** Start with few-shot prompting combined with RAG (to retrieve the relevant database schema). Prompting is faster to iterate and cheaper. You provide the schema + 5-10 examples of Natural Language -> SQL mappings.
If the SQL dialect is highly proprietary, or the model consistently fails on complex joins despite few-shotting, *then* consider fine-tuning (using LoRA) on a curated dataset of a few thousand query pairs to teach the model the specific *syntax and behavior* required.

**Q3: How would you debug an issue where an LLM is occasionally returning invalid JSON despite being prompted for JSON?**
**A:**
1. Check the temperature. Ensure T=0 for structured tasks.
2. Ensure the prompt explicitly says "Output ONLY valid JSON and nothing else" and provide an example schema.
3. Switch to provider-native features: OpenAI's JSON mode or Structured Outputs (which uses constrained decoding at the logits level to guarantee schema adherence).
4. Implement an application-level retry loop with error feedback (catching the JSON parse error and sending it back to the LLM to fix).
