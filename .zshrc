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
# Make spring-green (xterm-256 color 48 ≈ #00ff87) the terminal's DEFAULT
# foreground via OSC 10. This is the key trick: a program's reset (\e[0m / \e[39m)
# returns to the *default* fg, so making the default green keeps ALL output green —
# even the part after a command emits its own reset (which a per-command preexec
# tint could not do; that's why `ls` reverted everything after the first entry).
# Re-asserted before each prompt so a full-screen program (vim, less) that restores
# the foreground on exit can't leave it stuck on the old color.
autoload -Uz add-zsh-hook
_green_default_fg() { print -n '\e]10;#00ff87\a' }
_green_default_fg                      # set immediately for this shell
add-zsh-hook precmd _green_default_fg  # and keep it set before every prompt
setopt prompt_subst

# Don't special-highlight the auto-removable completion suffix (e.g. the trailing
# "/" Tab adds after a dir). Its default is `bold`, which iTerm2 renders as a
# washed-out/white shade until you type. `none` lets it inherit the normal green.
zle_highlight=(suffix:none)

# colors
c_frame='%F{48}'    # green  frame / brackets / dashes
c_user='%F{45}'     # cyan   user@host
c_path='%F{99}'      # blue   working dir
c_branch='%F{219}'   # green  branch name
c_action='%F{1}'    # red    in-progress git action (rebase/merge) + error mark
c_jobs='%F{179}'    # tan    background-jobs gear
c_input='%F{48}'    # spring-green text you type
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
  PROMPT="${c_frame}${d_top}(${comp_userhost}${c_frame})-[${comp_path}${c_frame}]${comp_branch}${Bof}${c_frame}${d_nl}${c_frame}${d_bot}${comp_sign}${rst} "
  RPROMPT="${comp_err}${comp_jobs}"
fi

# tidy up the helper vars (PROMPT/RPROMPT are now fully baked literal strings)
unset c_frame c_user c_path c_branch c_action c_jobs c_input Bon Bof rst \
      comp_userhost comp_path comp_branch comp_sign comp_err comp_jobs \
      d_top d_bot d_nl d_branch_icon

# NOTE: ls's own coloring is disabled on purpose. With CLICOLOR on, `ls` colors
# each filename and emits its own reset afterward, which wipes out the spring-green
# we set in preexec — so everything after the first colored entry fell back to the
# terminal default. Leaving CLICOLOR unset lets all output stay uniformly green.
# (To restore per-file ls colors instead of all-green, re-add the two lines below.)
# export CLICOLOR=1
# export LSCOLORS=ExFxCxDxBxegedabagacad
