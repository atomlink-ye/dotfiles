if status is-interactive
    # Commands to run in interactive sessions can go here
end
# Homebrew & Node
set -gx PATH /opt/homebrew/bin $PATH
set -gx PATH /opt/homebrew/opt/node@22/bin $PATH

# Homebrew update interval: 30 days
set -gx HOMEBREW_AUTO_UPDATE_SECS (math "30 * 24 * 60 * 60")
status --is-interactive; and source (brew --prefix)/share/fish/vendor_completions.d/brew.fish

# Proxy helpers
function set_proxy
    set -gx http_proxy http://127.0.0.1:7890
    set -gx https_proxy $http_proxy
    echo "终端代理已开启。"
end

function unset_proxy
    set -e http_proxy
    set -e https_proxy
    echo "终端代理已关闭。"
end

# pnpm
set -gx PNPM_HOME /Users/fan/Library/pnpm
if type -q fish_add_path
    fish_add_path --path $PNPM_HOME
else
    set -gx PATH $PNPM_HOME $PATH
end
