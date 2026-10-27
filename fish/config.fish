# Autostart Hyprland on a bare TTY1 login -- for anyone logging in on a raw
# TTY with no display manager (SDDM/GDM/etc). Inert if you use one: a DM
# doesn't put you on tty1 via a normal login shell the way this checks for.
# wisp-shell itself autostarts from hyprland.lua's own
# hl.on("hyprland.start", ...) hook once Hyprland is actually up.
if status is-login
    and test (tty) = /dev/tty1
    and not set -q WAYLAND_DISPLAY
    and not set -q DISPLAY
    exec start-hyprland
end

if status is-interactive
    # Ensure local bin is on PATH for wisp cli
    fish_add_path $HOME/.local/bin

    # Starship custom prompt
    command -v starship &> /dev/null && starship init fish | source

    # Wisp Ember syntax colours: white commands, grey arguments, semantic red/green/yellow
    set -g fish_color_normal eef0f4
    set -g fish_color_command eef0f4 --bold
    set -g fish_color_keyword eef0f4 --bold
    set -g fish_color_param b8bcc6
    set -g fish_color_option 8a8f9b
    set -g fish_color_quote a6e3a1
    set -g fish_color_escape f9e2af
    set -g fish_color_redirection 8a8f9b
    set -g fish_color_operator 8a8f9b
    set -g fish_color_end 8a8f9b
    set -g fish_color_comment 5c616c --italics
    set -g fish_color_error f38ba8
    set -g fish_color_valid_path --underline
    set -g fish_color_autosuggestion 5c616c
    set -g fish_color_cancel f38ba8
    set -g fish_color_selection --background=20232a
    set -g fish_color_search_match --background=20232a
    set -g fish_pager_color_prefix eef0f4 --bold
    set -g fish_pager_color_completion b8bcc6
    set -g fish_pager_color_description 5c616c
    set -g fish_pager_color_progress 8a8f9b
    set -g fish_pager_color_selected_background --background=20232a

    # Direnv + Zoxide
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish --cmd cd | source

    # Better ls
    command -v eza &> /dev/null && alias ls='eza --icons --group-directories-first -1'

    # fastfetch + the wisp banner now run from functions/fish_greeting.fish,
    # which fish calls automatically instead of its own default greeting
    # ("Welcome to fish...") -- calling fastfetch here too would double-print.

    # Abbrs
    abbr lg 'lazygit'
    abbr gd 'git diff'
    abbr ga 'git add .'
    abbr gc 'git commit -am'
    abbr gl 'git log'
    abbr gs 'git status'
    abbr gst 'git stash'
    abbr gsp 'git stash pop'
    abbr gp 'git push'
    abbr gpl 'git pull'
    abbr gsw 'git switch'
    abbr gsm 'git switch main'
    abbr gb 'git branch'
    abbr gbd 'git branch -d'
    abbr gco 'git checkout'
    abbr gsh 'git show'

    abbr l 'ls'
    abbr ll 'ls -l'
    abbr la 'ls -a'
    abbr lla 'ls -la'

    # For jumping between prompts in terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end

    # Custom wisp fish config if exists
    set -q XDG_CONFIG_HOME && set -l cConf $XDG_CONFIG_HOME/wisp-dots || set -l cConf $HOME/.config/wisp-dots
    source $cConf/user-config.fish 2> /dev/null
end
