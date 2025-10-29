## Why this project matters

You spend most days inside PowerShell. Generic copilots miss the context. **ollama-pwsh-copilot** hijacks the Enter key so you can ask a local LLM without breaking flow. It is one of the ten projects I built to show real progress instead of pitching unfinished ideas.

## What you get

- **Inline PowerShell help** driven by an Ollama model tuned with the `Modelfile` in this repo.
- **Keep-alive timer** that spins down the model after 45 seconds of idle time.
- **Single keybinding** that routes prompts starting with `#` to the assistant named _Shel.ly_.

## Requirements

- Windows 10 or later.
- [Ollama](https://ollama.com/) installed at `C:\Users\<you>\AppData\Local\Programs\Ollama\ollama.exe`.
- PowerShell 7.4 or later with `PSReadLine` enabled.

## Install it this week

1. Clone the repo.
2. Copy the folder to `$HOME\Documents\PowerShell\Modules\ollama-pwsh-copilot`.
3. Run `Import-Module ollama-pwsh-copilot` inside PowerShell.

Do this only after you confirm Ollama is installed. The path is hard-coded. If your install lives elsewhere, update the module file before importing.

## Build the model

You need the model ready before the module can respond.

```powershell
ollama create granite4:micro-powershell -f ./Modelfile
```

Run that from the repo root. The Modelfile sets the system persona to keep replies focused on PowerShell scripting.

## Use it

1. Start Ollama manually or let the module boot it.
2. Run `Start-TermAI -Trigger '# ' -EchoPrompt`.
3. Type `# Get the current process list sorted by CPU`. Hit Enter. Shel.ly prints the answer inline.

`Stop-TermAI` restores the default Enter key and shuts down the model when the timer expires.

## Limitations you need to know

- The Ollama path is hard-coded. Change `$script:TermAI_Model` and the executable path if your setup differs.
- The module does not ship with tests yet. Manual verification is required.
- Streaming output uses a fixed 10 ms delay per character. Expect slower prints on long replies.

## Roadmap when you have time

- Extract configuration into a JSON file so users stop editing the module directly.
- Add Pester tests around the key handler and idle timer.
- Expose a helper that lists available models instead of editing the script.

## Maintenance rules

All coding and writing rules live in `docs/`. Follow them before touching a file. They keep functions small and the tone consistent.

## License and conduct

The project ships under the MIT License with attribution to Octavian Tocan. Contributors follow the Contributor Covenant Code of Conduct.
