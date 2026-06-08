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

#### AI-BOMs

Similar to Software Bill of Material (SBOM), an AI-specific BOM exports a report of who made a model, how they built the model, and when they built the model: <br/>
```https://huggingface.co/spaces/GenAISecurityProject/OWASP-AIBOM-Generator``` <br/>
<br/>
In this task, we'll go to the above URL to scan the following Hugging Face model ```Pankaj001/malicious-artifact```. It's worth noting that models can contain vulnerable dependencies: <br/>
```https://huggingface.co/Pankaj001/malicious-artifact/blob/main/sample_notebook_files/classification_notebook.ipynb```


## Part 2: Malicious AI Skills


## PlatformCon 2026 Workshops

1. [Hunting compromised software dependencies inside Kubernetes workloads](https://github.com/ndouglas-cloudsmith/compromised-dependencies-kubernetes/tree/main)
2. **[AI agents & platform engineering: Efficiency boost or new source of trouble?](https://github.com/ndouglas-cloudsmith/AI-agents-platform-engineering)**
3. [Audit-ready Kubernetes: How to leverage policy-as-code for continuous compliance](https://github.com/ndouglas-cloudsmith/audit-ready-kubernetes/tree/main)
4. [The ghost in the machine: Securing AI agent skills](https://github.com/ndouglas-cloudsmith/ghost-in-the-machine/tree/main)
