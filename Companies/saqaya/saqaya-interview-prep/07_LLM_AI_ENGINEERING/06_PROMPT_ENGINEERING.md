# Prompt Engineering & Optimization

## 1. Prompt Design Principles
- **Be Specific & Direct:** Avoid polite filler. Tell the model exactly what to do.
- **Give the Model Time to Think:** Ask the model to explain its reasoning *before* giving the final answer.
- **Use Delimiters:** Clearly separate instructions from data using XML tags (`<data>...</data>`), triple quotes (`"""`), or markdown.
- **Format Output:** Provide templates or structural examples of the desired output.

## 2. Advanced Techniques

### Few-Shot Prompting
**What:** Providing 1 to N examples of the input-output pairs in the prompt.
**Why:** It acts as "in-context learning", conditioning the model to output a specific style, format, or logic without fine-tuning weights.
**Example:**
```text
Classify the sentiment of the text.
Text: I love this!
Label: Positive

Text: This is terrible.
Label: Negative

Text: The food was okay but cold.
Label: 
```

### Chain-of-Thought (CoT)
**What:** Prompting the model to generate intermediate reasoning steps.
**Why:** LLMs generate text one token at a time. They cannot "backtrack" if they make a logic error early on. By forcing them to write out the steps, you expand their "working memory" and compute time for that specific problem.
**How:** Append "Let's think step by step." to the prompt, or structure the output schema to include a `reasoning` field before the `final_answer` field.

### System Prompts
**What:** The foundational instructions given to the model (in the `system` role).
**Best Practices:**
1. Define the persona/role ("You are an expert Python engineer...").
2. Define the core task.
3. List explicit rules/constraints ("NEVER output markdown formatting. DO NOT apologize.").
4. Define the output format.

## 3. Retrieval-Augmented Generation (RAG)
**What:** Augmenting the prompt with relevant, retrieved context from an external knowledge base.
**Why:** LLMs have static training cutoffs and hallucinate when asked about proprietary or recent data.
**How:**
1. User asks question.
2. Embed the question into a vector.
3. Search a Vector Database (Pinecone, Qdrant) for the top-k most similar text chunks.
4. Inject those chunks into the prompt.
5. Prompt: *"Answer the user's question using ONLY the following context. Context: [retrieved_chunks] Question: [user_question]"*

## 4. Prompt Composition & Templates
In production, prompts are not static strings. They are templates populated dynamically.

**Python Example using Jinja2 / Langchain:**
```python
from langchain.prompts import PromptTemplate

template = """
You are a helpful assistant.
Answer the question based on the context.

Context: {context}

Question: {question}
"""

prompt = PromptTemplate(
    input_variables=["context", "question"],
    template=template
)

final_prompt = prompt.format(
    context="The CEO of Saqaya is John Doe.", 
    question="Who is the CEO?"
)
```

## 5. Prompt Optimization (Automatic)
Frameworks like **DSPy** compile and optimize prompts automatically. Instead of hand-tweaking prompts, you define the pipeline and provide a dataset of inputs and desired outputs. The framework tests variations of the prompt (or few-shot examples) and selects the one that maximizes your evaluation metric.

---

## Interview Questions

**Q1: An LLM is failing to perform a complex math calculation consistently. How do you improve the prompt?**
**A:** I would implement Chain-of-Thought prompting. Rather than asking for the final answer directly, I'd instruct the model: "Break down the calculation step-by-step. Show your work for each intermediate calculation. Finally, output the answer in a <final_answer> tag." If that still fails, the task might exceed the model's intrinsic arithmetic capabilities, and I would route the math calculation to an external tool (like a Python REPL or Calculator tool) via Function Calling, letting the LLM construct the equation and execute it externally.

**Q2: How do you prevent an LLM from hallucinating information not present in the RAG context?**
**A:** 
1. **Strict Prompting:** "Answer ONLY using the provided context. If the answer is not contained in the context, output exactly 'I do not know.' Do not rely on your internal knowledge."
2. **Post-generation verification:** Run a secondary, smaller LLM prompt that checks: "Does this answer exist entirely within this context document? Yes/No."
3. **Citation enforcement:** Require the model to output exact quote citations from the context for every claim it makes. If it can't cite it, it can't say it.
