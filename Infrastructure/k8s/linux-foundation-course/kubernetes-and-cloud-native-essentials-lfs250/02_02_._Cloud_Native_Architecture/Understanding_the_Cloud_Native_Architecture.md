# Understanding the Cloud Native Architecture

# Cloud Native Architecture Fundamentals

At its core, the idea of cloud native architecture is to optimize your software for cost efficiency, reliability, and faster time-to-market by combining cultural, technological, and architectural design patterns.

The term _cloud native_ appears in various definitions, some of which focus on technologies, while others may focus on the cultural side of things.

The [Cloud Native Computing Foundation defines it](https://github.com/cncf/toc/blob/main/DEFINITION.md) as follows:

_“Cloud native practices empower organizations to develop, build, and deploy workloads in computing environments (public, private, hybrid cloud) to meet their organizational needs at scale in a programmatic and repeatable manner. It i**s characterized by loosely coupled systems that interoperate in a manner that is secure, resilient, manageable, sustainable, and observable.**_

_Cloud native technologies and architectures typically consist of some combination of containers, service meshes, multi-tenancy, microservices, immutable infrastructure, serverless, and declarative APIs — this list is non-exhaustive.__”_

Traditional applications are usually designed with a monolithic approach in mind, meaning they are self-contained and include all the functionality and components needed to fulfill a task. A monolithic application typically has a single codebase and is delivered as a single binary that runs on a server.

If you think of e-commerce software for an online shop, a monolithic application would include every functionality from the graphical user interface, listing products, shopping cart, checkout, processing orders, and much more.

While it can be very easy to develop and deploy an application in this format, it can be equally challenging to manage complexity, scale development across multiple teams, implement changes quickly, and scale the application out efficiently when it comes under heavy load.

Cloud Native Architecture can address the increasing complexity of applications and the growing user demand. The basic idea is to break your application into smaller pieces, making it more manageable. Instead of providing all functionality in a single application, you have multiple decoupled applications that communicate over a network. If we stick to the example from before, you could have an app for your user interface, your checkout, and everything else. These small, independent applications with a clearly defined scope of functions are often referred to as _microservices_.

That makes it possible to have multiple teams, each owning different functions of your application, while also operating and scaling them individually. For example, if many people try to buy products, you can scale services that handle heavy loads, such as the shopping cart and checkout.

**![Diagram comparing architectures: the monolithic model combines UI, business logic, and data access in one unit, while the microservice model separates these into independent services, each with its own database and connection to the UI.](https://d36ai2hkxl16us.cloudfront.net/course-uploads/e0df7fbf-a057-42af-8a1f-590912be5460/ch9ud860v954-Monolithicvsmicroservices.png)**The diagram compares Monolithic Architecture and Microservice Architecture. In the monolithic model, the UI, business logic, and data access layer are tightly integrated into a single deployable unit that runs on one server. In contrast, the microservice model breaks the application into multiple independent microservices, each handling a specific function and connected to its own database or storage. The UI communicates with these services individually, allowing greater flexibility, scalability, and ease of updates compared to the monolithic approach.

**Monolithic vs Microservices Architecture  
**

Cloud native architecture can offer many advantages, but it can also be complex to integrate and therefore requires specific requirements to work efficiently.