# Docker Deep Dive

## Docker Internals
Docker is built on Linux kernel features:
- **Namespaces:** Provide isolation (PID, NET, IPC, MNT, UTS). Processes inside a container think they are the only processes on the system.
- **cgroups (Control Groups):** Resource limiting and metering (CPU, memory, block I/O).
- **Union File Systems (OverlayFS):** Layered file systems. Each instruction in a Dockerfile creates a read-only layer. The container runtime adds a thin read-write layer on top.

## Dockerfile Best Practices
1. **Multi-Stage Builds:** Essential for keeping production images small and secure by discarding build tools and intermediate artifacts.
2. **Layer Caching:** Order commands from least likely to change (OS, dependencies) to most likely to change (source code).
3. **.dockerignore:** Prevent unnecessary files (node_modules, .git, local env files) from being sent to the Docker daemon context.
4. **Least Privilege:** Do not run as root.

### Multi-Stage Build Example (TypeScript)
```dockerfile
# Stage 1: Build
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY --from=builder /app/dist ./dist
USER node
CMD ["node", "dist/index.js"]
```

## Docker Compose for Development
`docker-compose.yml` defines multi-container environments. Crucial for standardizing local development (spinning up Postgres, Redis, App together).

## Docker Volumes and Storage
- **Bind Mounts:** Map a host path to a container path (great for local dev live-reloading).
- **Volumes:** Managed by Docker, stored in `/var/lib/docker/volumes`. Best for persistent database data.
- **tmpfs:** In-memory, non-persistent.

## Container Security
- **Rootless Docker:** Run the Docker daemon and containers as non-root users.
- **Read-Only Root Filesystem:** Run container with `--read-only` to prevent attackers from dropping malware.
- **Capabilities:** Drop unnecessary Linux capabilities (`--cap-drop=ALL`).
- **Scanning:** Trivy or Docker Scout to find CVEs in base images.

## Health Checks
Crucial for orchestration (Docker Swarm, ECS, Kubernetes) to know if the application is actually ready to serve traffic.
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8080/health || exit 1
```

## Interview Questions
**Q: Why is my Docker build slow, and how do I fix it?**
A: Likely inefficient caching. Ensure `COPY package.json` and `npm install` happen *before* `COPY . .`. This caches the heavy dependency installation step unless package.json changes. Also, use multi-stage builds and check if `.dockerignore` is missing, causing a massive build context upload.

**Q: Explain the difference between `ENTRYPOINT` and `CMD`.**
A: `ENTRYPOINT` sets the executable that will always run when the container starts. `CMD` provides default arguments to `ENTRYPOINT` (or default command if no ENTRYPOINT). If you use `docker run image <args>`, the args override `CMD` but append to `ENTRYPOINT`.

**Q: How does a Union File System work in Docker?**
A: Images are composed of immutable layers. When a container starts, a read-write layer is placed on top. If a container modifies an existing file, the UFS uses a copy-on-write (CoW) strategy to copy the file from the lower read-only layer into the R/W layer, where it is modified.
