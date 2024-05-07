# hide EOL sign ('%')
export PROMPT_EOL_MARK=""

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
    else
	  color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
  # Customize the prompt
  PROMPT=$'%F{35}┌──(%B%F{38}%n@%m%b%F{35})-[%B%F{4}%(6~.%-1~/…/%4~.%5~)%b%F{35}]%F{011}%(1j.%F{011}${vcs_info_msg_0_}%F{011}.)%F{35}\n%F{35}└─%B%F{38}$%b%F{reset} '
  RPROMPT=$'%(?.. %? %F{1}%B⨯%b%F{reset})%(1j. %j %F{179}%B⚙%b%F{reset}.)'
fi

# Customize ls colors
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
