# APIs Interview Questions

## 1. What is an API?

**Answer:**
API (Application Programming Interface) is a set of protocols, tools, and definitions that allows different software applications to communicate with each other.

## 2. What is REST API?

**Answer:**
REST (Representational State Transfer) is an architectural style for designing web services using HTTP methods (GET, POST, PUT, DELETE) and stateless communication.

## 3. What are REST principles?

**Answer:**
- Stateless: Each request contains all information needed
- Client-Server: Separation of concerns
- Uniform Interface: Consistent resource identification
- Cacheable: Responses can be cached
- Layered System: Architecture can have multiple layers
- Code on Demand (optional): Server can send executable code

## 4. What are HTTP methods in REST?

**Answer:**
- **GET**: Retrieve resource (idempotent, safe)
- **POST**: Create resource (not idempotent)
- **PUT**: Update/replace resource (idempotent)
- **PATCH**: Partial update (idempotent)
- **DELETE**: Remove resource (idempotent)

## 5. What is the difference between PUT and PATCH?

**Answer:**
- **PUT**: Replaces entire resource.
- **PATCH**: Updates specific fields of resource.

## 6. What is the difference between POST and PUT?

**Answer:**
- **POST**: Creates new resource, not idempotent.
- **PUT**: Creates or updates resource, idempotent.

## 7. What is RESTful resource naming?

**Answer:**
RESTful resources use nouns, not verbs, and follow hierarchical structure:
- `/users` - collection
- `/users/123` - specific resource
- `/users/123/orders` - sub-resource

## 8. What is HTTP status code?

**Answer:**
HTTP status codes indicate the result of an HTTP request:
- **2xx**: Success (200 OK, 201 Created, 204 No Content)
- **3xx**: Redirection (301 Moved, 304 Not Modified)
- **4xx**: Client Error (400 Bad Request, 401 Unauthorized, 404 Not Found)
- **5xx**: Server Error (500 Internal Error, 502 Bad Gateway, 503 Service Unavailable)

## 9. What is API versioning?

**Answer:**
API versioning manages changes while maintaining backward compatibility:
- URL versioning: `/api/v1/users`
- Header versioning: `Accept: application/vnd.api+json;version=1`
- Query parameter: `/api/users?version=1`

## 10. What is the difference between Authentication and Authorization?

**Answer:**
- **Authentication**: Verifying who the user is (login).
- **Authorization**: Determining what the user can do (permissions).

## 11. What is API authentication methods?

**Answer:**
- API Keys
- OAuth 2.0
- JWT (JSON Web Tokens)
- Basic Authentication
- Bearer Token

## 12. What is JWT?

**Answer:**
JWT (JSON Web Token) is a compact, URL-safe token format for securely transmitting information between parties.

## 13. What is OAuth 2.0?

**Answer:**
OAuth 2.0 is an authorization framework that allows applications to obtain limited access to user accounts.

## 14. What is API rate limiting?

**Answer:**
Rate limiting restricts the number of requests a client can make within a time period, preventing abuse and ensuring fair usage.

## 15. What is API throttling?

**Answer:**
API throttling slows down request processing when limits are exceeded, rather than rejecting requests immediately.

## 16. What is the difference between Rate Limiting and Throttling?

**Answer:**
- **Rate Limiting**: Rejects requests when limit exceeded.
- **Throttling**: Delays requests when limit exceeded.

## 17. What is API pagination?

**Answer:**
API pagination splits large result sets into smaller pages, improving performance and user experience.

## 18. What is the difference between Offset and Cursor Pagination?

**Answer:**
- **Offset**: Uses page number and size (`?page=1&size=10`), simple but inefficient for large datasets.
- **Cursor**: Uses cursor/token (`?cursor=abc123`), efficient and consistent.

## 19. What is API filtering and sorting?

**Answer:**
Filtering and sorting allow clients to query specific data:
- Filtering: `/users?status=active&role=admin`
- Sorting: `/users?sort=name&order=asc`

## 20. What is HATEOAS?

**Answer:**
HATEOAS (Hypermedia as the Engine of Application State) includes links in API responses, enabling clients to discover available actions.

## 21. What is API documentation?

**Answer:**
API documentation describes API endpoints, parameters, responses, and examples (OpenAPI/Swagger, RAML, API Blueprint).

## 22. What is OpenAPI/Swagger?

**Answer:**
OpenAPI (formerly Swagger) is a specification for describing REST APIs, enabling code generation and interactive documentation.

## 23. What is API Gateway?

**Answer:**
API Gateway is a single entry point that handles routing, authentication, rate limiting, and protocol translation for multiple APIs.

## 24. What is the difference between REST and GraphQL?

**Answer:**
- **REST**: Multiple endpoints, fixed response structure, over-fetching/under-fetching.
- **GraphQL**: Single endpoint, flexible queries, clients request exactly what they need.

## 25. What is GraphQL?

**Answer:**
GraphQL is a query language and runtime for APIs that allows clients to request exactly the data they need.

## 26. What is the difference between REST and gRPC?

**Answer:**
- **REST**: HTTP/JSON, human-readable, flexible, slower.
- **gRPC**: HTTP/2/Protocol Buffers, binary, type-safe, faster.

## 27. What is gRPC?

**Answer:**
gRPC is a high-performance RPC framework using HTTP/2 and Protocol Buffers for efficient service communication.

## 28. What is API testing?

**Answer:**
API testing validates API functionality, performance, and reliability (unit tests, integration tests, load tests).

## 29. What is API mocking?

**Answer:**
API mocking creates fake API responses for testing and development when real APIs are unavailable.

## 30. What is API contract testing?

**Answer:**
Contract testing ensures API consumers and providers maintain compatible contracts (Pact, Spring Cloud Contract).

## 31. What is API security best practices?

**Answer:**
- Use HTTPS/TLS
- Implement authentication and authorization
- Validate and sanitize inputs
- Use rate limiting
- Implement CORS properly
- Keep APIs updated
- Log and monitor
- Use API keys securely
- Implement request validation
- Handle errors securely

## 32. What is CORS?

**Answer:**
CORS (Cross-Origin Resource Sharing) allows web pages to make requests to different domains, controlled by HTTP headers.

## 33. What is API caching?

**Answer:**
API caching stores responses to reduce server load and improve response times (HTTP cache headers, Redis, CDN).

## 34. What is the difference between Cache-Control and ETag?

**Answer:**
- **Cache-Control**: Directives for caching behavior (max-age, no-cache).
- **ETag**: Entity tag for conditional requests, enables validation caching.

## 35. What is API monitoring?

**Answer:**
API monitoring tracks API performance, availability, errors, and usage metrics for observability and troubleshooting.

## 36. What is API versioning strategy?

**Answer:**
- URL versioning: `/v1/users`
- Header versioning: `Accept: application/vnd.api+json;version=1`
- Deprecation: Gradual migration with warnings

## 37. What is API design best practices?

**Answer:**
- Use RESTful conventions
- Consistent naming
- Proper HTTP methods
- Meaningful status codes
- Version APIs
- Document thoroughly
- Handle errors gracefully
- Support pagination
- Implement filtering/sorting
- Use appropriate content types

## 38. What is the difference between SOAP and REST?

**Answer:**
- **SOAP**: XML-based, strict standards, stateful, heavier.
- **REST**: JSON/XML, flexible, stateless, lighter.

## 39. What is Webhook?

**Answer:**
Webhook is a callback mechanism where an API sends HTTP POST requests to a URL when an event occurs.

## 40. What is the difference between Webhook and Polling?

**Answer:**
- **Webhook**: Server pushes events to client (real-time, efficient).
- **Polling**: Client repeatedly requests updates (delayed, inefficient).

