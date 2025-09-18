# ⛓️ Supply-chain-attacks-reproduction

> A collection of learning-oriented, reproducible demonstrations of software supply-chain attacks. Each module is intentionally small and self-contained to clearly illustrate the attack mechanics, the execution path, and recommended mitigation strategies.

---

## What is a software supply-chain vulnerability?

A **software supply-chain vulnerability** is a weakness introduced anywhere in the lifecycle of software — during development, packaging, distribution, or deployment. Modern applications depend on many external components (open-source libraries, third-party packages, CI/CD tools, container images, and managed services). If **any** one of those components is compromised, the risk cascades across every software that relies on it. This makes the software supply chain a high-value target, where a single breach can ripple out to thousands of organizations.

---

## Current modules

- **Dependency Confusion** — [dependency-confusion/README.md](./dependency-confusion/README.md)  
  A focused reproduction of a dependency confusion scenario, demonstrating how a malicious package can replace an intended internal package and execute during build/deploy.

> More modules planned: Package Typosquatting, Compromised CI/CD, Malicious Container Images, Signed Artifact Tampering, and others.

---

