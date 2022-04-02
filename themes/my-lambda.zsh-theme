# PROMPT='λ %~/ $(git_prompt_info)%{$fg[orange]%}'
autoload colors && colors
#PROMPT='%K{166}%{$FG[226]λ %}%K %{$FG[136]%~/ %}'
#PROMPT='%{$FG[226]$BG{166]λ %} %{$FG[136]%~/ %}'
PROMPT='%{$FG[214]λ %} %{$FG[145]%~/ %}'
#PS1='%{$fg[red]%}λ '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
