# Background 

When we build software, it usually follows a simple life cycle. First, developers write the source code and define the dependencies (external packages or libraries the project needs). Next comes the build step, where a package manager (like npm, pip, or Maven) installs those dependencies and prepares the application to run. After the build, the software may go through testing, and finally, it gets deployed to production where real users interact with it. Since the build process automatically pulls dependencies, if an attacker can trick the system into downloading a malicious package, their code will run during the build, often before anyone notices.

# Introduction: What is Dependency Confusion?

**Dependency confusion** (aka *namespace confusion* or *dependency hijacking*) is a software supply-chain attack where a build system is tricked into fetching a malicious package from a public registry instead of the intended private/internal registry.

An attacker publishes a package that **shares the exact name** of an internal dependency, often with a **higher version**, so the package manager resolves and installs the attacker’s package by default. If that package contains install-time scripts (for example, `postinstall` in npm), those scripts run automatically during `npm install` or image builds, giving the attacker arbitrary code execution inside the build/CI environment.


### Real-world example

A security researcher **Alex Birsan** published a proof-of-concept demonstrating that counterfeit packages could be used to trigger code execution inside the networks of dozens of major companies (including Apple, Microsoft, PayPal, Shopify, Netflix, Yelp, Tesla, and Uber). The study highlighted how registry resolution can be abused and drove organizations to improve dependency management practices.

Read the original writeup: [Dependency Confusion — Alex Birsan (Medium)](https://medium.com/@alex.birsan/dependency-confusion-4a5d60fec610)


# The concept we reproduced 

Imagine a company has an internal helper library called `company-internal-logger`. Their app depends on version `1.0.0` of it.

Attacker strategy:
1. The attacker publishes a package named `company-internal-logger` to the public registry and gives it a **higher version**, e.g. `9.9.9`.
2. When a build runs, the package manager resolves dependencies and may pick the **higher version** from the public registry instead of the internal version.
3. The attacker's package includes an `postinstall` script. This runs automatically during `npm install` inside the build environment, so the attacker’s code executes inside the build (CI) machine.

What our repo does to reproduce that safely:
- We run a **local registry** (Verdaccio) instead of using the public one.
- We publish the attacker package (`company-internal-logger@9.9.9`) into Verdaccio using the `publisher` service.
- We build the victim Docker image (the `vulnerable-builder` service). Its Dockerfile tells npm to use Verdaccio as registry and runs `npm install` during build.
- Because Verdaccio now contains the attacker package with the higher version, `npm install` installs the malicious package and runs its `postinstall`. The demo script `malicious.js` writes `/tmp/pwned.txt` and prints a message, a visible proof the code executed during the build.


> [!NOTE]  
> In the real world, an attacker would publish a malicious package to a public registry (npm, PyPI, etc.).  
> For safety, **we do not publish** anything publicly.  
> Instead, this repository simulates the same behaviour locally using **Verdaccio** (a private registry) and an automated publisher — so the demo runs with a single command.

##  Project Layout 

### `victim-app/` (the vulnerable application)
- `victim-app/package.json`  
  - Lists dependencies including `company-internal-logger: 1.0.0` (the internal package the app expects).
  - Purpose: declare the dependency that the attacker will impersonate.
- `victim-app/Dockerfile`  
  - Builds a Node image and **runs `npm install` during the image build**. It also sets npm registry to `http://verdaccio:4873/` that will simulates as public registery.
  - Purpose: this `RUN npm install` build step is the *vulnerable point*, lifecycle scripts in installed packages (like `postinstall`) execute here.
- `victim-app/index.js`  
  - Minimal app entrypoint to make the image valid.
  - Purpose: not relevant to the attack; only present so the Docker image can run.
 
### `attacker-payload/` (the malicious package)
- `attacker-payload/package.json`  
  - Declares the attacker package `name` (e.g. `company-internal-logger`), a **higher version** than the victim expects, and a `postinstall` script that runs `malicious.js`.
  - Purpose: mimic an attacker-published package that will be selected by the package manager.
- `attacker-payload/malicious.js`  
  - A small, intentionally harmless script that demonstrates code execution (prints a message and writes `/tmp/pwned.txt`).
  - Purpose: show a visible side-effect of code running during `npm install` so you can confirm the compromise.

### Orchestration & helper files
- `docker-compose.yml`  
  - Brings up three services:
    - `verdaccio` — a local npm registry simulator (safe replacement for npmjs.org).  
    - `publisher` — a tiny container that waits for Verdaccio and publishes the attacker package into it.  
    - `vulnerable-builder` — the service that builds the victim image (and runs `npm install`).
  - Purpose: automate the full demo workflow locally and keep everything self-contained.
- `demo-setup.sh`  
  - Convenience script that: starts Verdaccio + publisher, waits until the attacker package is published, then builds/starts the vulnerable builder.
  - Purpose: allow a user to reproduce the entire demo with one command and avoid timing issues (Compose builds images before starting services).


## Reproduction Steps

- **Prereq:** Docker & Docker Compose installed.
- **Clone repo:** `git clone https://github.com/amnaemaan/supply-chain-attacks-reproduction.git`
- **Enter demo folder:** `cd supply-chain-attacks-reproduction/dependency-confusion`
- **Make script executable:** `chmod +x demo-setup.sh`
- **Run demo:** `./demo-setup.sh`
- **Watch logs:** `docker compose logs -f vulnerable-builder` *(look for `Malicious code executed!`)*
- **Verify (optional):** `docker exec -it vulnerable-builder sh -c "ls -la /tmp && cat /tmp/pwned.txt || echo 'pwned.txt not present'"`
- **Cleanup:** `docker compose down --rmi all -v`

> If Docker requires `sudo` on your system, prefix the `docker` / `docker compose` commands with `sudo`.


## Safety note (must-read)
- **Do not publish** demo or malicious code to any public registry. This repo uses a local registry (Verdaccio) to keep the demo safe and local.  
- The included `malicious.js` is intentionally harmless (writes `/tmp/pwned.txt`). Real attackers can do far worse, treat supply-chain attacks seriously and only test in isolated environments.
