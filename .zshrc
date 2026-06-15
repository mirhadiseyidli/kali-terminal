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

# Git branch info in the prompt (vcs_info)
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
# reset text color before running a command so command output isn't tinted
preexec() { print -n '\e[0m' }
setopt prompt_subst

# colors
c_frame='%F{47}'    # green  frame / brackets / dashes
c_user='%F{45}'     # cyan   user@host
c_path='%F{99}'      # blue   working dir
c_branch='%F{219}'   # green  branch name
c_action='%F{1}'    # red    in-progress git action (rebase/merge) + error mark
c_jobs='%F{179}'    # tan    background-jobs gear
c_input='%F{47}'    # spring-green text you type
Bon='%B'            # bold on
Bof='%b'            # bold off
rst='%f'            # reset color

# components
comp_userhost="${c_user}${Bon}%n@%m${Bof}"
comp_path="${c_path}${Bon}%(6~.%-1~/…/%4~.%5~)${Bof}"
comp_branch='${vcs_info_msg_0_}'                 # filled in by vcs_info each prompt
comp_sign="${c_user}${Bon}\$${Bof}"              # the $ sign
comp_err="%(?.. %? ${c_action}${Bon}⨯${Bof}${rst})"   # exit code + ⨯ on failure
comp_jobs="%(1j. %j ${c_jobs}${Bon}⚙${Bof}${rst}.)"   # job count + gear when jobs exist

# decorators
d_top='┌──'         # top corner
d_bot='└─'          # bottom corner
d_nl=$'\n'          # newline between the two lines
d_branch_icon='⎇'   # branch icon (U+2387) — renders without a Nerd Font

# branch segment, drawn by vcs_info (here %b = branch name; bold-off handled in PROMPT)
zstyle ':vcs_info:git:*' formats       "${Bon}${c_frame}-(${c_branch}${d_branch_icon} %b${c_frame})"
zstyle ':vcs_info:git:*' actionformats "${Bon}${c_frame}-(${c_branch}${d_branch_icon} %b${c_action}|%a${c_frame})"

if [ "$color_prompt" = yes ]; then
  PROMPT="${c_frame}${d_top}(${comp_userhost}${c_frame})-[${comp_path}${c_frame}]${comp_branch}${Bof}${c_frame}${d_nl}${c_frame}${d_bot}${comp_sign}${c_input} "
  RPROMPT="${comp_err}${comp_jobs}"
fi

# tidy up the helper vars (PROMPT/RPROMPT are now fully baked literal strings)
unset c_frame c_user c_path c_branch c_action c_jobs c_input Bon Bof rst \
      comp_userhost comp_path comp_branch comp_sign comp_err comp_jobs \
      d_top d_bot d_nl d_branch_icon

# Customize ls colors
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
