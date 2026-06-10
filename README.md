# AI agents & platform engineering
*Efficiency boost or new source of trouble?*
<br/><br/>
This was created for **Workshop #2** of PlatformCon: <br/>
[Link to the PlatformCon session](https://platformcon.com/london-session/ai-agents-platform-engineering-efficiency-boost-or-new-source-of-trouble)

<img width="50%" height="551" alt="Screenshot 2026-06-06 at 22 07 27" src="https://github.com/user-attachments/assets/27a28054-e81b-4489-955f-4edebf80a291" />


### Learning Outcomes
- Dive into ```Ollama``` and ```Hugging Face``` to master LLMs inside platform engineering.
- Explore the ```AI Skill``` attack surface within agentic tooling
- Learn how to secure your IDPs against evolving dependency threats

## Part 1: Ollama & Hugging Face

Let's start off by installing **[Ollama](https://ollama.com/download)** on MacOS, Windows, or Linux (if you're following these instructions in Instruqt).
```
curl -fsSL https://ollama.com/install.sh | sh
```

List the models currently being used by Ollama:
```
ollama ls
```

Pull an open source model from the **[Ollama Registry](https://ollama.com/library)**:
```
ollama pull qwen2:0.5b
```

Pull an open source ```GGUF``` formatted model from the **[Hugging Face Registry](https://huggingface.co/models?num_parameters=min:0,max:3B&library=gguf&search=bartowski)**:
```
ollama pull hf.co/bartowski/Qwen2-0.5B-Instruct-GGUF
```

In the case of the Hugging Face creator **[bartowski](https://huggingface.co/bartowski)**, he's an ethical security researcher, and all of his models are known to be safe. <br/>
However, some people in the Hub are not good actors. Many models are deliberately malicious according to **[ProtectAI](https://protectai.com/insights/models?status=UNSAFE&query=malicious)**.

### AI-BOMs

Similar to Software Bill of Material (SBOM), an AI-specific BOM exports a report of: 
- Who made a model
- How they built the model
- When they built the model

https://huggingface.co/spaces/GenAISecurityProject/OWASP-AIBOM-Generator <br/>
<br/>
In this task, we'll go to the above URL to scan the following Hugging Face model **Pankaj001/malicious-artifact**. <br/>
It's worth noting that models can contain vulnerable dependencies, malware, and other supply chain risks: <br/>
https://huggingface.co/Pankaj001/malicious-artifact/blob/main/sample_notebook_files/classification_notebook.ipynb

### Version Control System (VCS)
The **[VCS section]( https://github.com/ndouglas-cloudsmith/AI-agents-platform-engineering/blob/main/AIBOM/Pankaj001_malicious-artifact_aibom_1_6.json#L123-L125)** of the AI-BOM indicates that the source or reference for this particular software artifact is being tracked via a version control tool (like Git). The ```type:vcs``` Specifies that the locator method is a VCS rather than a standard static URL download, a package registry (like ```npm``` or ```PyPI```), or a container registry. 

```
wget https://raw.githubusercontent.com/ndouglas-cloudsmith/AI-agents-platform-engineering/refs/heads/main/AIBOM/Pankaj001_malicious-artifact_aibom_1_6.json
cat Pankaj001_malicious-artifact_aibom_1_6.json
```


## Part 2: Malicious AI Skills
Agent skills are changing platform engineering. But are they secure? <br/>
https://platformengineering.org/blog/agent-skills-are-changing-platform-engineering
<br/><br/>
Agentic AI projects like **OpenClaw** have their own dedicated registries for AI Skills. In the case of OpenClaw, it's **ClawHub**<br/>
https://clawhub.ai
<br/><br/>
In this next task, we are going to use **Github Search**. Note: You'll need to be logged into a Github account to run these commands: <br/>
https://github.com/search
<br/><br/>
Malicious AI tools might use ```Base64``` to hide shellcode, reverse shells, or malicious URLs so the LLM or early scanners don't catch the intent in plain text.
<br/>
- **[Sample One](https://github.com/compozy/agh/blob/1099164be7f7d4398129db062a464530e7b49751/.agents/skills/security-review/references/supply-chain.md?plain=1#L235)** - Looking for Base64 execution in Python-based skills:
```
"base64.b64decode" AND ("eval(" OR "exec(") path:skills
```
Using ```/*.md``` tells GitHub to look inside the skills folder and any of its subfolders for Markdown files.
```
"b64decode" OR "base64 -d" path:skills/**/*.md
```
- **[Sample Two](https://github.com/lxyeternal/MalSkillBench/blob/2aa98b06ee1f3afb5597e9afe54d68f212603254/Dataset/Skills/malware/cryptomine/SKILL.md?plain=1#L77)** - Hunting for skills that sneakily add stratum mining configurations or pull ```xmrig``` dependencies:
```
"stratum+tcp" OR "xmrig" OR "crypto-pool" path:**/SKILL.md
```

## Part 3: Secure your IDPs against evolving dependency threats
**[Backstage](https://github.com/backstage/backstage/blob/master/.npmrc)** for example, uses npmjs (Node.js Package Manager) to pull software dependencies into the IDP. <br/>
It's no secret that the **[npm registry](https://opensourcemalware.com/?type=package&ecosystem=npm)** has been a high-value target from threat actors such as **[TeamPCP](https://malpedia.caad.fkie.fraunhofer.de/actor/teampcp)**.
<br/><br/>
OSV’s API accepts a JSON body with ```package``` and (optionally) ```version```. If you supply ```version``` OSV will return only vulnerabilities (or known malicious packages) that actually match that specific version (or none if it doesn’t match).

```
curl -s -X POST https://api.osv.dev/v1/query -d '{
  "package": {
    "ecosystem":"npm",
    "name":"@tanstack/history"
  },
  "version":"1.161.12"
}' -H 'Content-Type: application/json' | jq .
```

You probably noticed that the last output was **pretty long**. To get the entire Malicious Object (details included), you'll want the entire structure for only the ```MAL-``` vulnerability info.
```
curl -s -X POST https://api.osv.dev/v1/query -d '{
  "package": {
    "ecosystem":"npm",
    "name":"@tanstack/history"
  },
  "version":"1.161.12"
}' -H 'Content-Type: application/json' | jq '.vulns[] | select(.id | startswith("MAL-"))'
```

Likewise, if you want to extract a clean summary (recommended for automation tasks in your IDP), without a 2MB block of text, use this:
```
curl -s -X POST https://api.osv.dev/v1/query -d '{
  "package": {
    "ecosystem":"npm",
    "name":"@tanstack/history"
  },
  "version":"1.161.12"
}' -H 'Content-Type: application/json' | jq '.vulns[] | select(.id | startswith("MAL-")) | {id: .id, summary: .summary, affected_package: .affected[0].package.name}'
```

**[MAL-2026-3463](https://osv.dev/vulnerability/MAL-2026-3463)** impacts the ```npm``` package ```@tanstack/history``` on version ```1.161.12``` and ```1.161.9```. <br/>
The **[OpenSSF Malicious Package](https://github.com/ossf/malicious-packages/blob/main/osv/malicious/npm/@tanstack/history/MAL-2026-3463.json)** record is publicly-accessible on Github.

### backstage-plugin-glean

According to the **[GitHub Advisory Database](https://github.com/advisories/GHSA-86v9-6365-r69x)** (```GHSA```), malware had been found in ```backstage-plugin-glean``` npm package:
```
curl -s https://api.osv.dev/v1/vulns/GHSA-86v9-6365-r69x | jq .
```

Any computer that has this package installed or running should be considered fully compromised. All secrets and keys stored on that computer should be rotated immediately from a different computer. The package should be removed, but as full control of the computer may have been given to an outside entity, there is no guarantee that removing the package will remove all malicious software resulting from installing it.
```
curl -s https://api.osv.dev/v1/vulns/MAL-2025-192944 | jq .
```

<img width="1316" height="1135" alt="Screenshot 2026-06-10 at 11 11 28" src="https://github.com/user-attachments/assets/d0e3c16c-bae6-4f53-88a2-da22026506fc" />
<br/><br/>

Naturally, it's in our interest to scan the ```npm``` **[backstage-plugin-catalog](https://www.npmjs.com/package/@backstage-community/plugin-npm)** for known, malicious packages - whether they're AI or not. <br/>
Backstage manages and updates these open-source, ```npm``` software dependencies via ```.lock``` files - **[SAMPLE ONE](https://github.com/backstage/backstage/blob/f9567df88c08d6a3077298e7b0a5b9acefee9ee2/packages/create-app/seed-yarn.lock#L4)**

### Scanning lockfiles in OSV-Scanner
In a **[previous session](https://github.com/ndouglas-cloudsmith/compromised-dependencies-kubernetes/blob/main/README.md#part-1-poisoning-a-kubernetes-workload)**, we discussed using **[osv-scanner](https://google.github.io/osv-scanner/usage/scan-image)** to scan container images for potential malware. In this workflow, we are going to download and scan the Backstage .lock file for malicious code and vulnerabilities.
```
wget https://raw.githubusercontent.com/backstage/backstage/f9567df88c08d6a3077298e7b0a5b9acefee9ee2/packages/create-app/seed-yarn.lock
mv seed-yarn.lock yarn.lock
osv-scanner scan -L yarn.lock
```
<img width="1316" height="1002" alt="Screenshot 2026-06-10 at 11 26 36" src="https://github.com/user-attachments/assets/2ca7041d-b03d-4109-9120-f5446504e55a" />

We didn't find any malware in this case. Only a few outstanding security advistories in the Backstage project.

### FrontStage
```
wget https://raw.githubusercontent.com/lyret/frontstage/refs/heads/main/package-lock.json
osv-scanner --lockfile=package-lock.json
```

<img width="1394" height="1167" alt="Screenshot 2026-06-10 at 15 06 58" src="https://github.com/user-attachments/assets/a910ac41-ed9d-4ab5-9286-e0eaa2554b4d" />
<br/><br/>
Can you find the malicious package in this specific version of the AI Platform?
```
rm package-lock.json
wget https://raw.githubusercontent.com/ndouglas-cloudsmith/AI-agents-platform-engineering/refs/heads/main/Lockfile/package-lock.json
osv-scanner --lockfile=package-lock.json
```


<br/><br/>
## PlatformCon 2026 Workshops

1. [Hunting compromised software dependencies inside Kubernetes workloads](https://github.com/ndouglas-cloudsmith/compromised-dependencies-kubernetes/tree/main)
2. **[AI agents & platform engineering: Efficiency boost or new source of trouble?](https://github.com/ndouglas-cloudsmith/AI-agents-platform-engineering)**
3. [Audit-ready Kubernetes: How to leverage policy-as-code for continuous compliance](https://github.com/ndouglas-cloudsmith/audit-ready-kubernetes/tree/main)
4. [The ghost in the machine: Securing AI agent skills](https://github.com/ndouglas-cloudsmith/ghost-in-the-machine/tree/main)
