# 04 Reliability

## 1. SLIs, SLOs, and SLAs
- **SLI (Service Level Indicator):** A quantitative measure of some aspect of the level of service provided. (e.g., "99.9% of HTTP requests responded in < 200ms").
- **SLO (Service Level Objective):** A target value for the service level as measured by an SLI. Internal goals.
- **SLA (Service Level Agreement):** A business contract with customers that includes consequences (e.g., financial penalties) if the SLO is not met.

### Error Budgets
Derived from the SLO. If SLO is 99.9%, the error budget is 0.1%. When the budget is depleted, feature freezes or deployment halts are triggered to focus on reliability.

## 2. Resiliency Patterns

### Circuit Breakers
Prevents an application from repeatedly trying to execute an operation that's likely to fail, allowing the system to recover.
- **Closed:** Normal operation.
- **Open:** After a threshold of failures, the circuit opens, failing fast without calling the downstream service.
- **Half-Open:** Periodically allows a single test request to see if the downstream service has recovered.

### Timeouts
Never make a remote call without a timeout. Prevents threads from blocking indefinitely, exhausting resources.

### Retries with Exponential Backoff and Jitter
If a call fails (e.g., transient network issue), retry.
- **Exponential Backoff:** Wait progressively longer between retries (1s, 2s, 4s, 8s) to avoid overwhelming the recovering service.
- **Jitter:** Add randomness to the backoff interval to prevent a "thundering herd" of retrying clients hitting the server simultaneously.

### Bulkheads
Partition system resources so that a failure in one part doesn't cascade to the rest. (e.g., separate connection pools for different microservices).

### Graceful Degradation
If a non-critical component fails, the system should still function, albeit with reduced features. (e.g., if the recommendation engine is down, show a default list of popular items instead of crashing the homepage).

## 3. Chaos Engineering
The discipline of experimenting on a system to build confidence in its capability to withstand turbulent conditions.
- Example: Netflix Chaos Monkey. Randomly terminates EC2 instances in production to ensure the architecture is truly resilient and auto-scaling works.

## 4. Redundancy and Failover
- **N+1 Redundancy:** Having at least one independent backup component to ensure system availability in the event of a component failure.
- **Active-Passive / Active-Active:** Multi-region or multi-AZ setups. If AZ A goes down, traffic is routed to AZ B. Requires asynchronous data replication.

## 5. Health Checks
- **Liveness Probes:** Checks if the container/app is running. If it fails, the orchestrator (Kubernetes) restarts it.
- **Readiness Probes:** Checks if the app is ready to serve traffic (e.g., database connection established). If it fails, the app is removed from the load balancer rotation.

## 6. Blast Radius Reduction
Designing systems so that the impact of a failure is isolated. Strategies include regionalization, cell-based architecture, and strict isolation of customer data.

## 7. Code Example: Circuit Breaker and Retry (Python)
```python
import time
import random

class CircuitBreakerOpenException(Exception):
    pass

class CircuitBreaker:
    def __init__(self, failure_threshold=3, recovery_timeout=10):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.failures = 0
        self.last_failure_time = None
        self.state = 'CLOSED'

    def call(self, func, *args, **kwargs):
        if self.state == 'OPEN':
            if time.time() - self.last_failure_time > self.recovery_timeout:
                self.state = 'HALF_OPEN'
            else:
                raise CircuitBreakerOpenException("Circuit is OPEN")

        try:
            result = func(*args, **kwargs)
            self.reset()
            return result
        except Exception as e:
            self.record_failure()
            raise e

    def record_failure(self):
        self.failures += 1
        self.last_failure_time = time.time()
        if self.failures >= self.failure_threshold:
            self.state = 'OPEN'

    def reset(self):
        self.failures = 0
        self.state = 'CLOSED'

# Example Usage
cb = CircuitBreaker()

def unreliable_network_call():
    if random.random() < 0.7:
        raise Exception("Network timeout")
    return "Success"

for i in range(10):
    try:
        print(f"Attempt {i}:", cb.call(unreliable_network_call))
    except Exception as e:
        print(f"Attempt {i} failed:", str(e))
    time.sleep(1)
```

## 8. Interview Questions & Answers
**Q: How do you prevent a cascading failure in a microservices architecture?**
*A:* I would implement strict timeouts on all RPC/HTTP calls. I'd use Circuit Breakers to fail fast when a downstream service is struggling. I'd implement Bulkheads (isolated thread pools per dependency) so one slow service doesn't consume all threads. Lastly, I'd ensure aggressive caching and graceful degradation are in place so the system can serve degraded responses instead of failing completely.
