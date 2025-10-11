# Folder: $HOME\Documents\PowerShell\Modules\term.ai
# File:   term.ai.psm1

# Examples of LLMs that work well with this:
#  - granite4:micro
#  - granite4:tiny-h (though, be wary that it needs more powerful hardware.)

# --- Configuration ---
$script:TermAI_Model = "granite4:micro-powershell"
$script:TermAI_KeepAliveSec = 45
$script:TermAI_UnloadTimer = $null

$script:AssistantName = "Shel.ly"

function Start-PowershellModelUnloadTimer {
    # Create a timer (if not already created)
    if (-not $script:TermAI_UnloadTimer) {
        $script:TermAI_UnloadTimer = New-Object System.Timers.Timer
        $script:TermAI_UnloadTimer.AutoReset = $false
        $script:TermAI_UnloadTimer.add_Elapsed({
                try {
                    & "C:\Users\$env:USERNAME\AppData\Local\Programs\Ollama\ollama.exe" stop $script:TermAI_Model | Out-Null
                }
                catch {}
            })
    }
}

function Restart-PowershellModelUnloadTimer {
    if ($script:TermAI_UnloadTimer) {
        $script:TermAI_UnloadTimer.Interval = [double]($script:TermAI_KeepAliveSec * 1000)
        $script:TermAI_UnloadTimer.Stop()
        $script:TermAI_UnloadTimer.Start()
    }
}

# Start the feature. Binds Enter so we can inspect the current line.
function Test-OllamaAvailable {
    try {
        & "C:\Users\$env:USERNAME\AppData\Local\Programs\Ollama\ollama.exe" list | Out-Null
        return $true
    }
    catch { return $false }
}

function Start-OllamaService {
    try {
        Start-Process "C:\Users\$env:USERNAME\AppData\Local\Programs\Ollama\ollama.exe" -ArgumentList "serve" -WindowStyle Hidden
        Start-Sleep -Seconds 2
        return (Test-OllamaAvailable)
    }
    catch { return $false }
}

function Start-TermAI {
    param(
        [string]$Trigger = '#',          # Lines starting with this mean "ask AI"
        [switch]$EchoPrompt              # Show the prompt line above the answer
    )

    if (-not (Test-OllamaAvailable)) {
        Write-Host "Ollama not running. Starting Ollama..." -ForegroundColor Yellow
        if (-not (Start-OllamaService)) {
            Write-Host "Failed to start Ollama. Please check installation." -ForegroundColor Red
            return
        }
        Write-Host "Ollama started successfully." -ForegroundColor Green
    }

    # Persist settings for the key handler to read
    Set-Variable -Name TermAI_Trigger     -Scope Script -Value $Trigger
    Set-Variable -Name TermAI_EchoPrompt  -Scope Script -Value $EchoPrompt.IsPresent

    # Initialize the timer if needed
    Start-PowershellModelUnloadTimer

    # Rebind Enter key
    Set-PSReadLineKeyHandler -Key Enter -BriefDescription 'TermAI intercept' -ScriptBlock {
        param($key, $arg)

        # Read current input buffer
        $line = $null; $cursor = 0
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

        $trigger = (Get-Variable -Name TermAI_Trigger -Scope Script -ValueOnly)
        $echo = (Get-Variable -Name TermAI_EchoPrompt -Scope Script -ValueOnly)

        $escapedTrigger = [regex]::Escape($trigger)
        if ($line -match "^\s*$escapedTrigger\s*(.*)$") {
            $promptText = $Matches[1]

            # Clear input line so it doesn’t execute
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()

            if ($echo) {
                Write-Host ""
                Write-Host "[you] $promptText"
            }

            # Invokes the Ollama model reply.
            Invoke-Ollama -promptText $promptText
            # Reset idle timer
            Restart-PowershellModelUnloadTimer
        }

        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
}

function Invoke-Ollama {
    param([string]$promptText)

    $model = $script:TermAI_Model
    $assistantName = $script:AssistantName
    $keepAlive = $script:TermAI_KeepAliveSec

    Write-Host "[$assistantName]: " -NoNewline

    # Directly stream output from Ollama, assuming it outputs UTF-8
    & "C:\Users\$env:USERNAME\AppData\Local\Programs\Ollama\ollama.exe" run --keepalive "$($keepAlive)s" $model $promptText | ForEach-Object {
        $line = $_.Trim()
        $line.ToCharArray() | ForEach-Object {
            Write-Host $_ -NoNewline
            Start-Sleep -Milliseconds 10
        }
        Write-Host ""
    }
}

# Stop the feature. Restores normal Enter behavior and unloads the model.
function Stop-TermAI {
    Set-PSReadLineKeyHandler -Key Enter -Function AcceptLine
    if ($script:TermAI_UnloadTimer) {
        $script:TermAI_UnloadTimer.Stop()
        $script:TermAI_UnloadTimer.Dispose()
        $script:TermAI_UnloadTimer = $null
    }
    try { & "C:\Users\$env:USERNAME\AppData\Local\Programs\Ollama\ollama.exe" stop $script:TermAI_Model | Out-Null } catch {}
}

Export-ModuleMember -Function Start-TermAI, Stop-TermAI, Invoke-Ollama
