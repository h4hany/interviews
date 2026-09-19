# Deployment Strategies

## Blue-Green Deployments
Two identical environments (Blue and Green).
- **Process:** Blue is currently live. Deploy the new version to Green. Run tests on Green. If successful, switch the router/load balancer to point traffic to Green.
- **Pros:** Near zero-downtime, instant rollback (switch router back to Blue).
- **Cons:** Requires double the infrastructure capacity. Database state can be tricky if the schema changes.

## Canary Deployments
Gradually shift traffic to the new version.
- **Process:** Deploy the new version to a small subset of servers (e.g., 5% of traffic). Monitor error rates and latency. If stable, increase to 10%, 25%, 100%.
- **Pros:** Limits blast radius of a bad release to a small percentage of users.
- **Cons:** More complex pipeline, requires robust observability (metrics, logs) to evaluate canary health.

## Rolling Deployments
Replace instances of the old version with the new version sequentially.
- **Process:** Take down 1 instance, upgrade it, put it back in the load balancer. Repeat for all instances.
- **Pros:** No extra infrastructure required.
- **Cons:** Deployment takes time. Application must support running vOld and vNew concurrently (backward compatibility is crucial). Rollbacks are slow (must roll back sequentially).

## Feature Flags (Dark Launches)
Decouple deployment from release.
- **Process:** Deploy the new code to production wrapped in a feature toggle. The code is running in prod but turned off (`if (flag.enabled) { new_feature() }`).
- **Pros:** Zero-downtime release (just flip a switch in a UI like LaunchDarkly). Instant rollback. Enables A/B testing.
- **Cons:** Technical debt (must clean up old flags). Complexity in code.

## Traffic Shifting
Advanced routing at the API Gateway or Service Mesh level (Envoy, Istio).
- Route users by header, location, or internal ID to specific backend versions.

## Zero-Downtime Deployments
The ultimate goal. Requires:
1. Load balancer draining (wait for existing requests to finish before killing an instance).
2. Stateless applications.
3. Backward-compatible database changes.

## Interview Questions
**Q: How do you handle database migrations in a Blue-Green deployment?**
A: This is the hardest part. The database must be decoupled from the application deployment. You must perform "Expand and Contract" migrations. First, apply a backward-compatible DB change (e.g., add a column, but don't require it). Deploy the new code to Green. Both Blue (old) and Green (new) can talk to the database simultaneously. Switch traffic. Later, clean up (contract) the database if needed.

**Q: You deploy a new version and error rates spike. Walk me through your immediate actions.**
A: 
1. **Stop the bleed:** Initiate an immediate rollback to the previous known-good version (or flip the feature flag back).
2. **Verify:** Confirm the error rates have returned to normal baseline.
3. **Investigate:** Only after users are safe, look at logs, traces, and metrics from the failed deployment to find root cause.
