# shellcheck shell=sh

# Start or reuse an ssh-agent and load the default keys. The agent's
# environment is saved to ~/.ssh/agent.env so all shells share one agent.
#
# Only in a terminal: ssh-add may need to prompt for a passphrase, and
# graphical sessions read ~/.profile without one.
if [ -t 0 ] && [ -d ~/.ssh ]; then
    ssh_agent_env=~/.ssh/agent.env
    # shellcheck disable=SC1090
    [ -f "$ssh_agent_env" ] && . "$ssh_agent_env" >/dev/null

    # ssh-add -l exits 0 if the agent has keys, 1 if it has none, 2 if unreachable
    ssh-add -l >/dev/null 2>&1
    ssh_agent_state=$?

    if [ -z "$SSH_AUTH_SOCK" ] || [ "$ssh_agent_state" = 2 ]; then
        (umask 077 && ssh-agent >|"$ssh_agent_env")
        # shellcheck disable=SC1090
        . "$ssh_agent_env" >/dev/null
        ssh-add >/dev/null 2>&1
    elif [ "$ssh_agent_state" = 1 ]; then
        ssh-add >/dev/null 2>&1
    fi

    unset ssh_agent_env ssh_agent_state
fi
