# eLearning Standards: SCORM, xAPI, and LTI

To build interoperable eLearning systems, understanding the acronym soup of industry standards is non-negotiable. These standards dictate how content communicates with the LMS.

## 1. SCORM (Sharable Content Object Reference Model)
The legacy standard, still heavily used. It allows authoring tools (Articulate, Captivate) to export a `.zip` file that works in any LMS.
- **How it works:** The LMS unzips the file, serves the HTML/JS, and provides an API object via JavaScript (`window.API_1484_11`). The SCORM content calls methods on this object to report progress.
- **Versions:** SCORM 1.2 (Most common, limited to simple status: pass/fail/completed) and SCORM 2004 (More complex, supports sequencing and detailed interactions).
- **The Data Model (cmi):** Standardized variables.
  - `cmi.core.lesson_status` (passed, failed, completed, incomplete)
  - `cmi.core.score.raw` (numeric score)
  - `cmi.suspend_data` (a string where the course saves arbitrary state to resume later).
- **Limitations:** Only works inside a web browser, requires a persistent connection to the LMS, easily spoofed (since it's all client-side JS), doesn't handle modern apps or offline learning.

## 2. xAPI (Experience API / Tin Can)
Designed to solve SCORM's limitations. Tracks learning everywhere, not just in the LMS.
- **How it works:** Generates JSON statements based on the `[Actor] [Verb] [Object]` structure and sends them via REST API to a Learning Record Store (LRS).
- **Example Statement:**
  ```json
  {
    "actor": { "mbox": "mailto:jane@example.com", "name": "Jane Doe" },
    "verb": { "id": "http://adlnet.gov/expapi/verbs/completed", "display": { "en-US": "completed" } },
    "object": { "id": "http://example.com/courses/leadership", "definition": { "name": { "en-US": "Leadership 101" } } },
    "result": { "score": { "scaled": 0.85 }, "success": true }
  }
  ```
- **LRS (Learning Record Store):** A specialized database (can be standalone or inside an LMS) that validates and stores xAPI statements.
- **Advantages:** Works offline (app syncs statements later), works in mobile apps, VR, simulators, tracks micro-interactions (e.g., "Jane pressed pause on Video X"), highly secure (server-to-server auth).

## 3. LTI (Learning Tools Interoperability)
Connects an LMS to external, third-party learning tools securely without building custom integrations.
- **How it works:** It acts as a secure single-sign-on (SSO) and context-passing mechanism. (e.g., Canvas LMS linking to a Zoom meeting or a Pearson Math Lab).
- **LTI Advantage (v1.3):** Uses OAuth2 and OpenID Connect.
- **Deep Linking:** Allows an instructor to browse the external tool's catalog from within the LMS and embed a specific quiz or module.
- **Assignment and Grade Services (AGS):** Allows the external tool to securely pass the final grade back into the LMS gradebook.

## 4. cmi5
The bridge between SCORM and xAPI. 
xAPI is too flexible (you can track anything), making it hard for an LMS to know what "completed the course" means. cmi5 defines specific rules for using xAPI within a traditional LMS context (packaging, launch, and defined verbs like `Launched`, `Passed`, `Failed`).

## Summary Comparison
| Standard | Best For | Architecture | Client/Server |
|----------|----------|--------------|---------------|
| **SCORM** | Legacy compliance, traditional web modules | JS API, Zip files | Strictly Client-side |
| **xAPI** | Mobile, VR, off-platform learning, granular analytics | REST API, JSON | Client or Server-side |
| **LTI** | Integrating SaaS tools, external grading engines | OAuth2, OIDC | Server-to-Server |

## Interview Questions
**Q: A client wants to build a mobile app where users can download courses, take them on a plane (offline), and have progress sync when they reconnect. Which standard do you choose?**
*A: I would use xAPI. SCORM fundamentally requires a continuous browser session and JS API provided by the LMS; it breaks offline. With xAPI, the mobile app can locally queue the JSON statements (Actor Verb Object) as the user interacts offline, and then batch POST them to the LRS when the internet connection is restored.*

**Q: We are integrating a third-party virtual lab environment into our LMS. We don't want users to create new accounts on the third-party site, and we need the lab score to appear in our LMS. How do we architect this?**
*A: We should implement LTI 1.3 Advantage. When the user clicks the lab link, our LMS acts as the identity provider, sending an OIDC launch request to the external tool with the user context. The user is seamlessly authenticated. Once they complete the lab, the external tool uses the LTI Assignment and Grade Services (AGS) API to post the numeric score directly back to our LMS gradebook.*
