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

<br/><br/>
## PlatformCon 2026 Workshops

1. [Hunting compromised software dependencies inside Kubernetes workloads](https://github.com/ndouglas-cloudsmith/compromised-dependencies-kubernetes/tree/main)
2. **[AI agents & platform engineering: Efficiency boost or new source of trouble?](https://github.com/ndouglas-cloudsmith/AI-agents-platform-engineering)**
3. [Audit-ready Kubernetes: How to leverage policy-as-code for continuous compliance](https://github.com/ndouglas-cloudsmith/audit-ready-kubernetes/tree/main)
4. [The ghost in the machine: Securing AI agent skills](https://github.com/ndouglas-cloudsmith/ghost-in-the-machine/tree/main)
