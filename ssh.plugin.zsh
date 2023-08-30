#!/usr/bin/env zsh

ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-${TMPDIR:-/tmp}/zsh-${UID:-user}}"
CACHE_FILE="${ZSH_CACHE_DIR}/ssh-hosts.zsh"

hosts=()
if [[ -f ~/.ssh/config ]]; then
  if [[ "$CACHE_FILE" -nt "$HOME/.ssh/config" ]]; then
    source "$CACHE_FILE"
  else
    mkdir -p "${CACHE_FILE:h}"
    hosts=( $(grep '^Host ' ~/.ssh/config | awk '{first = $1; $1 = ""; print $0; }' | tr " " "\n" | grep -v '*' | sort -u | uniq | xargs ) )
    typeset -p hosts >! "$CACHE_FILE" 2> /dev/null
    zcompile "$CACHE_FILE"
  fi
fi

zstyle ':completion:*:hosts' hosts $hosts

zstyle ':completion:*:(ssh|scp|sshfs|mosh):*' sort false
zstyle ':completion:*:(ssh|scp|sshfs|mosh):*' format ' %F{yellow}-- %d --%f'

zstyle ':completion:*:(ssh|scp|sshfs|mosh):*' group-name ''
zstyle ':completion:*:(ssh|scp|sshfs|mosh):*' verbose yes

zstyle ':completion:*:(scp|rsync|sshfs):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync|sshfs):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr

zstyle ':completion:*:(ssh|mosh):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(ssh|mosh):*' group-order users hosts-domain hosts-host users hosts-ipaddr

zstyle ':completion:*:(ssh|scp|sshfs|mosh):*:hosts-host' ignored-patterns '*(.|:)*' loopback localhost broadcasthost 'ip6-*'
zstyle ':completion:*:(ssh|scp|sshfs|mosh):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|sshfs|mosh):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.*' '255.255.255.255' '::1' 'fe80::*' 'ff02::*'
