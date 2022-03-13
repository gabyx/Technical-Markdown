# =============================================================================
# TechnicalMarkdown
# 
# @date Sun Mar 06 2022
# @author Gabriel Nützi, gnuetzi@gmail.com
# =============================================================================

# Runs only on interactive ZSH.

if [[ ! -d ~/.zplug ]]; then
    git clone https://github.com/zplug/zplug ~/.zplug
fi

HISTFILE=~/.zsh_history
HISTSIZE=10000          #How many lines of history to keep in memory
SAVEHIST=10000          #Number of history entries to save to disk
setopt appendhistory    #Append history to the history file (no overwriting)
setopt sharehistory     #Share history across terminals
setopt incappendhistory #Immediately append to the history file, not just when a term is killed"

source ~/.zplug/init.zsh
zplug 'zplug/zplug' #, hook-build:'zplug --self-manage'

# Command-not-found extension.
zplug "plugins/command-not-found", from:oh-my-zsh

# Zsh completions and auto suggestions.
zplug "zsh-users/zsh-completions", depth:1
zplug "zsh-users/zsh-autosuggestions", depth:1
zplug "zsh-users/zsh-syntax-highlighting", depth:1
zplug "zsh-users/zsh-history-substring-search", depth:1

# Docker completion.
zplug "felixr/docker-zsh-completion", depth:1

# Cd enhancements.
zplug "supercrabtree/k", depth:1

# Style
zplug "romkatv/powerlevel10k", as:theme, depth:1
export TERM=xterm-256color

if ! zplug check --verbose; then
    zplug install
fi

zplug load --verbose

# Del/Home/End
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char

# Ctrl+ Left/right
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Keybindings for substring search plugin. Maps up and down arrows.
bindkey -M main '^[OA' history-substring-search-up
bindkey -M main '^[OB' history-substring-search-down
bindkey -M main '^[[A' history-substring-search-up
bindkey -M main '^[[B' history-substring-search-down

# Keybindings for autosuggestions plugin
bindkey '^ ' autosuggest-accept
bindkey '^f' autosuggest-accept

# Gray color for autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

# To customize prompt, run 'p10k configure' or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Add GPG_TTY to shell config,
# only if not running in VSCode environment.
if [ -z "${VSCODE_GIT_ASKPASS+x}" ]; then
    export GPG_TTY=$(tty)
else
    # VS Code setup
    # Remove git credential manager core
    sudo git config --system --unset-all credential.helper ".*git-credential-manager-core.*"
fi

# Execute verison check if enabled.
# Get this containers latest version.
export TECHMD_BUILD_VERSION_REMOTE=$(curl --max-time 5 -fsSL "https://api.github.com/repos/gabyx/technicalmarkdown/releases/latest" 2>/dev/null | jq '.tag_name | sub("^v";"";"g")' -r)
# Load splash screen.
if [ -f ~/.shell-entry-splash.sh ]; then
    ~/.shell-entry-splash.sh "$(echo "$TECHMD_CONTAINER_NAME" | sed -E 's/-/ /g')"
fi

# Source the default python environment.
PYTHON_ENV="${PYTHON_ENV:-~/python-envs/default}"
if [ -f "$PYTHON_ENV" ]; then
    . ~/python-envs/default/bin/activate
fi
