# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$HOME/.local/bin:/opt/tools:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"

DISABLE_UPDATE_PROMPT="true"
export UPDATE_ZSH_DAYS=24

plugins=(git sudo debian zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

alias ytdl-video="youtube-dl -i --external-downloader aria2c --external-downloader-args '-c -j 16 -x 16 -s 16 -k 1M'"
alias ytdl-music="youtube-dl --external-downloader aria2c --external-downloader-args '-c -j 16 -x 16 -s 16 -k 1M' -f bestaudio --audio-quality 0 --audio-format flac -i -x --extract-audio"
alias ytdl-update="pip3 install --upgrade youtube_dl"

function chpwd {
  if [[ $PWD = "/mnt/TEAL" ]]; then
    ssh -t 172.16.0.140 "cd / ; zsh"
  elif [[ $PWD = "/mnt/TEAL"* ]]; then
    ssh -t 172.16.0.140 "cd ${PWD:9} ; zsh"
  fi
}
chpwd

export DEVKITPRO=/opt/devkitpro
export DEVKITARM=${DEVKITPRO}/devkitARM
export DEVKITPPC=${DEVKITPRO}/devkitPPC

export PATH=${DEVKITPRO}/tools/bin:$PATH
