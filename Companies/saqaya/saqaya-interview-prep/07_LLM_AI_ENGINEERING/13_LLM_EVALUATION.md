# LLM Evaluation

## 1. The Challenge of LLM Evaluation
Evaluating deterministic software is easy: unit tests assert exact matches. Evaluating LLMs is hard because language is open-ended. If the target answer is "Yes, it is true," and the LLM outputs "Indeed, that is correct," an exact string match fails, but the model performed perfectly.

## 2. Evaluation Methods

### A. Deterministic / Heuristic Evaluation
- **Exact Match:** Only works for strictly constrained classification outputs.
- **Regex/JSON Validation:** Does the output parse as valid JSON? Does it contain specific required substrings?
- **BLEU / ROUGE:** Legacy NLP metrics based on word overlap. *Do not use these for LLMs, as they do not capture semantic meaning.*

### B. LLM-as-a-Judge
Using a highly capable model (like GPT-4) to grade the output of the application.
- **How it works:** You provide GPT-4 with a Rubric, the Input Prompt, the generated Output, and optionally the "Golden Answer". GPT-4 returns a score from 1-5 and a reasoning string.
- **Trade-offs:** Can be expensive and introduces its own biases (e.g., GPT-4 often prefers longer answers, or answers written in a style similar to its own).

### C. Human Evaluation (The Gold Standard)
Blind A/B testing where human annotators rate responses.
- **Trade-offs:** Unscalable, expensive, slow. Used mostly to calibrate the "LLM-as-a-Judge" prompts to ensure the AI judge aligns with human preferences.

## 3. RAG-Specific Evaluation (RAGAS framework)
RAG introduces two distinct points of failure: poor retrieval and poor generation. The RAGAS (Retrieval Augmented Generation Assessment) framework splits evaluation into:
- **Context Precision:** Did we retrieve the right chunks, or mostly noise?
- **Context Recall:** Did we retrieve *all* necessary chunks to answer the question?
- **Faithfulness (Hallucination):** Is the generated answer derived *entirely* from the context?
- **Answer Relevance:** Does the answer actually address the user's question?

## 4. Building an Evaluation Pipeline (TypeScript)
Frameworks like `promptfoo` or Braintrust make this systematic.

**Conceptual TypeScript Evaluator:**
```typescript
import { openai } from '@ai-sdk/openai';
import { generateObject } from 'ai';
import { z } from 'zod';

const EvalSchema = z.object({
  score: z.number().min(1).max(5),
  reasoning: z.string(),
});

async function evaluateOutput(question: string, generatedAnswer: string, goldenAnswer: string) {
  const prompt = `
    You are an expert evaluator. Grade the 'Generated Answer' against the 'Golden Answer'.
    Score 1-5, where 5 is perfectly accurate and helpful.
    
    Question: ${question}
    Golden Answer: ${goldenAnswer}
    Generated Answer: ${generatedAnswer}
  `;

  const { object } = await generateObject({
    model: openai('gpt-4o'),
    schema: EvalSchema,
    prompt: prompt,
    temperature: 0,
  });

  return object;
}
```

## 5. Statistical Significance & A/B Testing
When you upgrade a prompt, you run it over a dataset of 500 examples.
If `Prompt A` scores 82% and `Prompt B` scores 84%, is it a real improvement or random noise?
You must use statistical tests (like a paired t-test) to confirm significance before merging the PR.

---

## Interview Questions

**Q1: You've implemented an "LLM-as-a-Judge" pipeline, but you notice GPT-4 is consistently giving 5/5 scores to terrible, hallucinated answers as long as they are highly detailed. How do you fix this evaluator bias?**
**A:** This is known as "verbosity bias." To fix it:
1. **Calibrate the Rubric:** Update the judge's system prompt to explicitly state: "Penalize verbose answers if they contain any unverified facts. Conciseness is preferred."
2. **Few-Shot the Judge:** Provide the judge with examples of long, bad answers and instruct it to score them as 1/5.
3. **Split the Evaluation:** Don't ask for a single 1-5 score. Break it into binary criteria: "Is it concise? (Y/N)", "Is fact X present? (Y/N)". Then aggregate those booleans into a final score.

**Q2: How do you measure the quality of a RAG application where you do not have human-written "Golden Answers" for the thousands of questions users ask?**
**A:** You use reference-free evaluation metrics, specifically focusing on **Faithfulness** and **Relevance**.
Using an LLM judge, we evaluate real production logs by asking:
1. "Given this retrieved context, does the generated answer contain any information NOT present in the context?" (Faithfulness).
2. "Does the generated answer directly address the user's query without deflecting?" (Relevance).
By tracking these two metrics over time across thousands of requests, we can detect degradation in quality even without golden datasets.
