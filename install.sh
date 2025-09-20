#install brew
echo "[INFO] installing brew"
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> /root/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /root/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

#brew install
echo "[INFO] installing bundle using brew"
brew bundle --file=~/.brewfile # --verbose

#nvim config
echo "[INFO] cloning nvim config"
git clone https://github.com/atomsi7/kickstart.nvim.git ~/.config/nvim
cp ~/.config/nvim/lua/custom/unsynced.lua.example ~/.config/nvim/lua/custom/unsynced.lua 

#change fish to default shell
sh -c 'echo "$(which fish)" >> /etc/shells'
chsh -s $(which fish)

