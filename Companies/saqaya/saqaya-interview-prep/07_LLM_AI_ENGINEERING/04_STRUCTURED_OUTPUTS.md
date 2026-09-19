# Structured Outputs & Validation

## 1. Why Structured Outputs?
LLMs naturally output unstructured text. In software engineering, systems communicate via structured data (JSON, SQL, GraphQL). To integrate LLMs into software systems (e.g., extracting user data, deciding application state, querying databases), we must force them to output structured data predictably.

## 2. Mechanisms for Structured Outputs

### A. Prompting (JSON Mode)
- **How:** Add "Output ONLY valid JSON" to the prompt. Providers like OpenAI offer a `response_format: { type: "json_object" }` parameter.
- **Trade-offs:** It guarantees the output is parseable JSON, but it **does not** guarantee that the JSON matches your specific schema (e.g., missing keys, wrong types).

### B. Function Calling / Tools
- **How:** Pass a JSON Schema in the `tools` array. The model understands it can "call a function" and outputs a JSON string that matches the arguments.
- **Trade-offs:** Highly reliable. However, until recently, it was still probabilistic and could occasionally hallucinate fields.

### C. Constrained Decoding (OpenAI Strict Mode / Outlines)
- **What:** The holy grail of structured output.
- **How it works internally:** During token generation, the inference engine builds a Finite State Machine (FSM) or regex mask from your JSON schema. Before generating the next token, it masks the logits (probabilities) of any token that would violate the schema (setting their probability to 0). E.g., if the schema expects a boolean, the model is mathematically forced to output "true" or "false" and cannot output "maybe".
- **Usage:** OpenAI's `strict: true` in structured outputs. Open-source libraries like `Outlines` or `Guidance` for self-hosted models.

## 3. Pydantic Models for LLM Output (Python)
Pydantic is the standard for defining data schemas in Python. Combined with libraries like `instructor` or native OpenAI SDK beta features, it makes structured generation trivial.

**Python Example using OpenAI native Pydantic support:**
```python
from pydantic import BaseModel
from openai import OpenAI

client = OpenAI()

# 1. Define the desired structure
class UserExtraction(BaseModel):
    name: str
    age: int
    is_customer: bool
    tags: list[str]

def extract_user_info(text: str) -> UserExtraction:
    completion = client.beta.chat.completions.parse(
        model="gpt-4o-2024-08-06",
        messages=[
            {"role": "system", "content": "Extract the user information."},
            {"role": "user", "content": text},
        ],
        response_format=UserExtraction, # Magic happens here
    )
    
    # Returns a validated Pydantic object, not a dict/string
    return completion.choices[0].message.parsed 

# Usage
user = extract_user_info("John is a 34 year old frequent shopper. He likes shoes.")
print(user.name) # John
```

## 4. Zod Schemas for LLM Output (TypeScript)
Zod is the equivalent schema definition library in the TypeScript ecosystem. Vercel's AI SDK makes this incredibly seamless.

**TypeScript Example using Vercel AI SDK:**
```typescript
import { generateObject } from 'ai';
import { openai } from '@ai-sdk/openai';
import { z } from 'zod';

// 1. Define schema
const UserSchema = z.object({
  name: z.string(),
  age: z.number(),
  isCustomer: z.boolean(),
  tags: z.array(z.string()).describe("List of interests"), // Descriptions act as prompt hints!
});

async function extractUser(text: string) {
  const { object } = await generateObject({
    model: openai('gpt-4o'),
    schema: UserSchema,
    prompt: `Extract data from: ${text}`,
  });
  
  // object is fully typed as { name: string, age: number, ... }
  return object; 
}
```

## 5. Output Parsing & Error Recovery
When NOT using strict constrained decoding, models can fail to generate valid JSON.
**Recovery Strategy (LLM Self-Correction):**
1. Attempt to parse the JSON (`json.loads()`).
2. If `JSONDecodeError` or `ValidationError` (schema mismatch) occurs, catch it.
3. Append the error message to the message history: *"You output invalid JSON. Error: [error details]. Please correct it."*
4. Retry the LLM call.

**Python Retrying Parser Example:**
```python
import json
from pydantic import BaseModel, ValidationError

def robust_extraction(prompt: str, max_retries=3):
    messages = [{"role": "user", "content": prompt}]
    
    for attempt in range(max_retries):
        response = call_llm(messages) # your generic LLM call
        try:
            parsed_dict = json.loads(response)
            validated_obj = MySchema(**parsed_dict)
            return validated_obj
        except (json.JSONDecodeError, ValidationError) as e:
            print(f"Attempt {attempt+1} failed. Retrying...")
            messages.append({"role": "assistant", "content": response})
            messages.append({"role": "user", "content": f"Failed to parse or validate schema. Error: {str(e)}. Fix the JSON."})
            
    raise Exception("Failed to generate valid structured output after retries.")
```

---

## Interview Questions

**Q1: You define a complex nested JSON schema for an LLM to generate, but it consistently misses fields deeply nested in arrays. How do you fix this?**
**A:** 
1. **Use Constrained Decoding:** If on OpenAI, upgrade to `gpt-4o-2024-08-06` and set `strict: true`. This solves it mathematically.
2. **Schema Simplification:** LLMs struggle with deeply nested logic. Flatten the schema where possible.
3. **Chain of Thought in Schema:** Add a `reasoning` or `chain_of_thought` string field *at the top* of the schema. This forces the model to think step-by-step *before* generating the nested arrays, vastly improving accuracy.
4. **Field Descriptions:** Ensure every field in the Pydantic/Zod model has a detailed `.describe()` or `Field(description=...)`. These descriptions are injected into the prompt and help the model understand the exact intent of the field.

**Q2: What is the difference between JSON Mode and Structured Outputs (Function Calling)?**
**A:** JSON mode merely instructs the model to ensure the output string is syntactically valid JSON. It does not enforce any specific keys or types. You must provide the schema in the text prompt, and the model might ignore it. Structured Outputs via Function Calling pass the JSON schema to a specialized endpoint that the model has been explicitly fine-tuned to adhere to. With modern APIs, Function Calling uses constrained decoding to guarantee 100% adherence to the provided schema keys and types. Function Calling is far superior for production engineering.
