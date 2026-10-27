function fish_greeting
    command -v fastfetch &> /dev/null && fastfetch --config $HOME/.config/fastfetch/config.jsonc
end
