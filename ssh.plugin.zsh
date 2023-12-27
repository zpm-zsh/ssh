#!/usr/bin/env zsh

ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-${TMPDIR:-/tmp}/zsh-${UID:-user}}"
CACHE_FILE="${ZSH_CACHE_DIR}/ssh-hosts.zsh"

hosts=()
if [[ -f ~/.ssh/config ]]; then
  if [[ "$CACHE_FILE" -nt "$HOME/.ssh/config1" ]]; then
    source "$CACHE_FILE"
  else
    mkdir -p "${CACHE_FILE:h}"
    hosts=( $(grep '^Host ' ~/.ssh/config | grep -v 'Ignore' | awk '{first = $1; $1 = ""; print $0; }' | tr " " "\n" | grep -v '*' | sort -u | uniq | xargs ) )

    # pre_hosts=()
    # post_hosts=()

    # for host in $raw_hosts; do
    #     if [[ "$host" == '*' ]]; then
    #         continue
    #     elif [[ "$host" == '*'* ]]; then
    #         post_hosts+=( "${host#?}" )
    #     elif [[ "$host" == *'*' ]]; then
    #         pre_hosts+=( "${host%?}" )
    #         hosts+=( "${host%?}" )
    #     else
    #         hosts+=( "${host}" )
    #     fi
    # done

    # for pre in $pre_hosts; do
    #     for post in $post_hosts; do
    #         hosts+=( "${pre}${post}" )
    #     done
    # done

    # ignore=( $(grep '^#Ignore' ~/.ssh/config | awk '{first = $1; $1 = ""; print $0; }' | tr " " "\n" | grep -v '*' | sort -u | uniq | xargs ) )

    # hosts=("${(@)hosts:|ignore}")

    typeset -p hosts >! "$CACHE_FILE" 2> /dev/null
    zcompile "$CACHE_FILE"
  fi
fi

zstyle ':completion:*:hosts' hosts $hosts

zstyle ':completion:*:(ssh|scp|sshfs|mosh):*' sort false
zstyle ':completion:*:(ssh|scp|sshfs|mosh):*' format ' %F{yellow}-- %d --%f'

zstyle ':completion:*:(ssh|scp|rsync|sshfs|mosh):*' group-name ''
zstyle ':completion:*:(ssh|scp|rsync|sshfs|mosh):*' verbose yes

zstyle ':completion:*:(ssh|mosh):*' group-order users hosts-host users

zstyle ':completion:*:(scp|rsync|sshfs):*' group-order files all-files hosts-domain hosts-host hosts-ipaddr users
