# shellcheck shell=bash

envfile=~/.ssh/agent.env

# only use this function if you're sure that "$envfile" exists
function load_env_inner() {
    # we don't need to follow this file for checks; it's generated
    # shellcheck disable=SC1090
    source "$envfile" >| /dev/null
}

function load_env() {
    if [ -f "$envfile" ]; then
        # we don't need to follow this file for checks; it's generated
        # shellcheck disable=SC1090
        load_env_inner
    fi
}

function agent_start() {
    (
        umask 077
        ssh-agent >| "$envfile"
    )
    load_env_inner
}

load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ "$agent_run_state" = 2 ]; then
    agent_start
    ssh-add >| /dev/null 2>&1
elif [ "$SSH_AUTH_SOCK" ] && [ "$agent_run_state" = 1 ]; then
    ssh-add >| /dev/null 2>&1
fi

unset env
