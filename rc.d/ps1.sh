# shellcheck shell=bash

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    read -r debian_chroot </etc/debian_chroot
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    # Literal ANSI escapes rather than `tput`, which cost a fork per color.
    # Everything non-printing must be wrapped in \[ \] so bash can compute
    # the prompt width correctly.
    PS1='\[\e[34;7m\]\u@\h\[\e[0m\] \[\e[32m\]\w\[\e[0m\]\n\$ '
else
    PS1='\u@\h \w\n\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# PS0 is printed after a command is read and before it runs (but not for
# empty lines): print a timestamp, formatted like `date`'s default output.
PS0='\D{%a %b %e %T %Z %Y}\n'
