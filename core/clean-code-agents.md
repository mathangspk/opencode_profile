# Clean Code Principles for AI Agent Development

This document adapts the principles from *Clean Code* by Robert C. Martin for AI Agent development, where source code interacts with LLMs, manages state, and calls external tools.

---

## 1. Meaningful Names
In AI Agent development, variable and function names are not only for developers but are also passed into LLM context (e.g., tool descriptions).

* **Intention-Revealing Names:** A variable, function, or class name should answer: what it exists for, what it does, and how it is used.
  * *AI Application:* Instead of `prompt1`, `res`, use `systemInstructionPrompt`, `llmParsedResponse`.
* **Avoid Disinformation:** Do not leave misleading clues that obscure the meaning of the code.
* **Pronounceable and Searchable Names:** Use words that are readable for easy team communication and source code searching. Avoid excessive abbreviations like `genymdhms`.

## 2. Functions and Tools for Agents
The "Tools" you provide to an AI Agent are essentially functions. Better functions mean fewer agent hallucinations when calling them.

* **Functions Should Be Small:** The first rule of functions is that they should be small, and the second rule is that they should be *even smaller*.
* **Do One Thing:** A function should do one thing, do it well, and do it only.
  * *AI Application:* A Tool given to an Agent should not both search the web and write to a database. Split into two separate tools so the LLM can reason and call them accurately.
* **Minimize Arguments:** The ideal number of arguments for a function is zero, then one, then two. Avoid functions with three or more arguments.
  * *AI Application:* The fewer input parameters a Tool has, the less likely the LLM will pass incorrect or missing parameters.
* **No Side Effects:** A function should not promise to do one thing but implicitly do something else (like modifying global state). This is critical to keep the Agent's reasoning chain intact.

## 3. Managing Boundaries with LLM APIs
Your code will constantly communicate with third-party APIs (OpenAI, Anthropic, LangChain, etc.).

* **Use Third-Party Code Safely:** Instead of passing interfaces or objects from third parties throughout the system, hide them.
  * *AI Application:* Create a Wrapper class (e.g., `LLMService`) to encapsulate API calls. When the API changes or you switch from OpenAI to Gemini, you only need to change this boundary.
* **Learning Tests:** Instead of experimenting with third-party APIs in production code, write tests to verify your understanding of how the API works. This is extremely useful for testing new prompts with LLMs.

## 4. Objects and Data Structures
* **Data Transfer Objects (DTOs):** Pure data structures (public variables only, no methods) are very useful when communicating with APIs or parsing messages.
  * *AI Application:* When the LLM returns JSON, map it immediately into a DTO to ensure data consistency before processing subsequent logic.
* **Law of Demeter:** A module should not know about the internal structure of the objects it manipulates ("Don't talk to strangers"). Avoid long chained calls (Train Wrecks) like `agent.getMemory().getHistory().clear()`.

## 5. Error Handling
AI Agents operate in highly unpredictable environments (LLM timeouts, API errors, malformed outputs).

* **Use Exceptions Instead of Return Codes:** Error codes clutter source code because the caller must always remember to check for errors immediately after calling a function. Exceptions separate the main logic flow from error handling.
* **Provide Context with Exceptions:** Include enough information in Exceptions to identify the source and location of the error.
  * *AI Application:* When the LLM returns malformed output, the Exception should contain the Prompt sent and the Response received for easy debugging.
* **Don't Return Null:** Returning `null` creates excessive null-checking boilerplate and risks `NullPointerException`. Throw an Exception or return a "Special Case" object (e.g., an empty list).
* **Don't Pass Null:** Passing `null` into a function is terrible. Treat the presence of `null` in an argument list as a sign of a bug.

## 6. Classes and Emergence
* **Single Responsibility Principle (SRP):** A class should have only one reason to change.
  * *AI Application:* Do not combine LLM API connection, memory storage, and prompt processing in the same Class. Separate them.
* **No Duplication (DRY):** Duplication is the main enemy of a well-designed system, introducing unnecessary risk and complexity.
* **The Boy Scout Rule:** Always leave the code (or campsite) cleaner than you found it. If every team member consistently does this, code will never rot.

## 7. Unit Tests
Even though LLM outputs are non-deterministic, you must maintain discipline in testing your Agent's logic code.

* **Keep Tests Clean:** Test code is no less important than production code. If tests are messy, you will spend excessive time maintaining them and eventually abandon testing. Unit tests are what keep production code flexible and maintainable.
* **Independent and Fast:** Tests must not depend on each other and must run fast.
  * *AI Application:* Mock LLM API calls in Unit Tests to ensure tests run in milliseconds instead of tens of seconds waiting for the network.

---
*In summary, view your Agent as an author writing a clear and coherent story. Clean code is not just code that runs—it is code that shows the author's care for those who will read and maintain it afterward.*
