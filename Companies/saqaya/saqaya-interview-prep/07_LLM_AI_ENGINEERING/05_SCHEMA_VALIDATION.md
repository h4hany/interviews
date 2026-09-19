# Schema Validation & Runtime Types

## 1. Why Schema Validation?
When dealing with LLMs, the output is fundamentally untyped string data. Even when using structured outputs (Function Calling/JSON mode), the parsed JSON is just a dictionary of `Any`. 
To safely use this data in a strongly typed application (TypeScript/Python), you must parse and validate it at runtime. This prevents missing key errors, type mismatches (e.g., getting a string `"42"` instead of the integer `42`), and ensures structural integrity.

## 2. Zod (TypeScript) Deep Dive
Zod is the industry standard for runtime type validation in TypeScript. It allows you to declare a schema once, which acts as both the runtime validator and the compile-time type.

### How it works
```typescript
import { z } from 'zod';

// 1. Define the Schema
const ArticleSchema = z.object({
  title: z.string().min(5).max(100),
  author: z.string().optional(),
  tags: z.array(z.string()).min(1),
  status: z.enum(["draft", "published"]),
});

// 2. Extract the TypeScript Type (Compile-time)
type Article = z.infer<typeof ArticleSchema>;

// 3. Parse LLM Output (Runtime)
const llmJsonString = `{"title": "AI Trends", "tags": ["AI", "Tech"], "status": "draft"}`;
const rawData = JSON.parse(llmJsonString);

try {
  // .parse() throws if invalid. .safeParse() returns an object with success/error.
  const article = ArticleSchema.parse(rawData); 
  console.log(article.title); // fully typed
} catch (error) {
  if (error instanceof z.ZodError) {
    console.error("Validation failed:", error.errors);
    // You can format these errors and send them BACK to the LLM to fix!
  }
}
```

## 3. Pydantic (Python) Deep Dive
Pydantic uses Python type annotations to validate data. It is extremely fast (core rewritten in Rust in v2).

### How it works
```python
from pydantic import BaseModel, Field, field_validator, ValidationError
from typing import List, Optional

class Article(BaseModel):
    title: str = Field(..., min_length=5, max_length=100)
    author: Optional[str] = None
    tags: List[str] = Field(..., min_length=1)
    status: str

    # Custom cross-field validation
    @field_validator('status')
    @classmethod
    def check_status(cls, v: str) -> str:
        if v not in ["draft", "published"]:
            raise ValueError('status must be draft or published')
        return v

llm_dict = {"title": "AI Trends", "tags": ["AI"], "status": "draft"}

try:
    article = Article(**llm_dict)
    print(article.title)
except ValidationError as e:
    print(e.json()) # Send this JSON error back to the LLM
```

## 4. LLM Error Recovery Loop
The true power of schema validation with LLMs is the automatic retry loop.

**TypeScript Error Recovery Loop:**
```typescript
async function generateWithRecovery(prompt: string, maxRetries = 3): Promise<Article> {
  let messages = [{ role: "user", content: prompt }];
  
  for (let i = 0; i < maxRetries; i++) {
    const responseText = await callLLM(messages); // your LLM wrapper
    
    try {
      const data = JSON.parse(responseText);
      const result = ArticleSchema.parse(data); // Validate
      return result; // Success!
    } catch (error) {
      if (error instanceof z.ZodError) {
        // Feed the specific schema errors back to the LLM
        messages.push({ role: "assistant", content: responseText });
        messages.push({ 
          role: "user", 
          content: `Validation error: ${error.message}. Please fix the JSON output to conform to the schema.` 
        });
      }
    }
  }
  throw new Error("Failed to generate valid output");
}
```

## 5. Schema Generation (OpenAPI / JSON Schema)
To pass these schemas to the LLM API (for function calling), you need to convert Zod/Pydantic into JSON Schema.
- **Python:** Pydantic does this natively: `Article.model_json_schema()`
- **TypeScript:** Use `zod-to-json-schema` package.

---

## Interview Questions

**Q1: An LLM keeps returning an array of objects instead of a single object, breaking your Pydantic validation. How do you address this?**
**A:** First, catch the Pydantic `ValidationError`. In the `except` block, extract the error message and feed it back to the LLM in a new user message, telling it: "You provided an array, but a single object is required. Error: [validation_error_msg]". 
Second, to prevent it proactively, ensure the prompt explicitly states "Output a single object, NOT an array" and provide a 1-shot example of the correct JSON structure.
Third, ensure the JSON schema passed to the function calling API is strictly defining an object type at the root level.

**Q2: What is the difference between compile-time types (TypeScript Interfaces) and runtime schemas (Zod) in the context of LLMs?**
**A:** A TypeScript Interface `interface User { name: string }` vanishes at compile time. When the application runs, it has no way to check if the LLM actually returned a string for `name`. If the LLM returns `name: 123`, JavaScript will accept it, leading to a crash deeper in the application when you call `.toLowerCase()` on it. Zod schemas execute at *runtime*, explicitly checking the payload byte-by-byte against the rules, and throwing an error immediately at the system boundary before the bad data pollutes the application state.
