function fish_greeting
    set_color cba6f7
    echo " _       __ _                 ____         __        "
    echo "| |     / /(_)_____ ____     / __ \ ____  / /_ _____ "
    echo "| | /| / // // ___// __ \   / / / // __ \/ __// ___/ "
    echo "| |/ |/ // /(__  )/ /_/ /  / /_/ // /_/ / /_ (__  )  "
    echo "|__/|__//_//____// .___/  /_____/ \____/\__//____/   "
    echo "                /_/                                  "
    set_color normal
    command -v fastfetch &> /dev/null && fastfetch --config $HOME/.config/fastfetch/config.jsonc
end
