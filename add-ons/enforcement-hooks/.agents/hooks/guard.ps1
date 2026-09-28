# PreToolUse guard for coding agents (GitHub Copilot in VS Code and Claude Code).
# Reads the hook input JSON from stdin. Prints a deny or ask decision as JSON, or nothing to leave the call to the normal permission flow.

$raw = [Console]::In.ReadToEnd()

$shellTools = @('Bash', 'PowerShell', 'run_in_terminal')
$editTools = @('Edit', 'Write', 'MultiEdit', 'NotebookEdit', 'create_file', 'replace_string_in_file', 'multi_replace_string_in_file', 'edit_notebook_file', 'apply_patch')

$denyCommands = [ordered]@{
    'git\s+push\b'                  = 'Pushing is left to the user. Report the branch and commits instead.'
    '--no-verify\b'                 = 'Commit and push hooks must not be bypassed.'
    'git\s+reset\s+--hard\b'        = 'Hard resets can destroy work. Ask the user to run it.'
    'git\s+clean\s+-[A-Za-z]*f'     = 'git clean deletes untracked files. Ask the user to run it.'
}
$askCommands = [ordered]@{
    'git\s+(rebase|filter-branch)\b'            = 'Rewriting history needs confirmation.'
    'git\s+commit\b[^"]*--amend\b'              = 'Amending a commit needs confirmation.'
    'git\s+branch\s+(-D|--delete\s+--force)\b'  = 'Force-deleting a branch needs confirmation.'
    'git\s+tag\s+\S'                            = 'Creating or deleting tags can trigger pipelines.'
    '\brm\s+-[A-Za-z]*r[A-Za-z]*f|\brm\s+-[A-Za-z]*f[A-Za-z]*r' = 'Recursive deletion needs confirmation.'
    'Remove-Item\b[^"]*-Recurse'                = 'Recursive deletion needs confirmation.'
}
$protectedPaths = '(^|[\\/])(\.agents[\\/]+hooks[\\/]|\.claude[\\/]+settings[^\\/]*\.json$|\.github[\\/]+hooks[\\/])'

function Write-Decision([string]$decision, [string]$reason) {
    @{
        hookSpecificOutput = @{
            hookEventName            = 'PreToolUse'
            permissionDecision       = $decision
            permissionDecisionReason = $reason
        }
    } | ConvertTo-Json -Compress -Depth 3
    exit 0
}

$toolName = ''
$toolMatch = [regex]::Match($raw, '"tool_name"\s*:\s*"([^"]+)"')
if ($toolMatch.Success) { $toolName = $toolMatch.Groups[1].Value }

if ($shellTools -contains $toolName) {
    foreach ($pattern in $denyCommands.Keys) {
        if ($raw -match $pattern) { Write-Decision 'deny' $denyCommands[$pattern] }
    }
    foreach ($pattern in $askCommands.Keys) {
        if ($raw -match $pattern) { Write-Decision 'ask' $askCommands[$pattern] }
    }
}

if ($editTools -contains $toolName) {
    foreach ($m in [regex]::Matches($raw, '"(file_path|filePath|path)"\s*:\s*"([^"]*)"')) {
        $path = $m.Groups[2].Value -replace '\\\\', '\'
        if ($path -match $protectedPaths) {
            Write-Decision 'deny' 'Agent hook files and hook settings change only with the user''s approval. Ask the user to edit them.'
        }
    }
}

exit 0
