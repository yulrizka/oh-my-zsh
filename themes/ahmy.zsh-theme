local user="%{$fg_bold[grey]%}%m %{$reset_color%}"
local indicator="%(!.#.➜)"
local ret_status="%(?:%{$fg_bold[green]%}$indicator :%{$fg_bold[red]%}$indicator %s)"
PROMPT='${user}$(git_prompt_info)%{$fg_bold[blue]%}%c ${ret_status}%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$BG[236]%}%{$FG[113]%} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}%{$FG[236]%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%} %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}"
LSCOLORS=Exfxcxdxbxegedabagacad
