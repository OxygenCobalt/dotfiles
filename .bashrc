#
# ~/.bashrc
#

[[ $- != *i* ]] && return

# Enable prompt color.
if [[ ${EUID} == 0 ]] ; then
	PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
else
	PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
fi

xhost +local:root > /dev/null 2>&1

shopt -s checkwinsize # make sure bash responds to window sizes in all cases
shopt -s expand_aliases # expand all aliases
shopt -s histappend # enable history appending instead of overwriting

alias cp="cp -i"                           # Confirm before overwriting something
alias df='df -h'                           # Human-readable sizes
alias grep="rg"                            # Ripgrep is better
alias cat="bat"                            # Bat is better
alias ls="exa"                             # Exa is better
alias sxiv="nsxiv"                         # Nsxiv is maintained
alias more="less"                          # Less is better
alias rename="imv"                         # Unix rename is a joke
alias youtube-dl="yt-dlp"                  # yt-dlp is maintained

# Extract an archive
# Usage: ex [ARCHIVE]
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Remove orphan [i.e junk] packages from an installation.
# Note: May have to be ran multiple times to fully clean, may break certain non-installed dynamically linked packages
# Usage: pkgclean
pkgclean() {
	sudo pacman -R $(pacman -Qdtq)
}

CLR_A="\033[0;95m" # Blue
CLR_B="\033[0;94m" # Cyan
NC="\033[0m"       # No color

# Begin our splash 
SPLASH="
                                                                                ${CLR_A}WW${NC}                  
             ${CLR_B}WOxkOOOOOOOOOOOkx0W${NC}                                      ${CLR_A}WNX00OOOOOOOOOOOO0XW${NC}          
             ${CLR_B}W0oxKXXXXXXXXXKxo0w${NC}                                  ${CLR_A}WK0OOOOO0KXNWWWWWWNX0OOOk0XW${NC}      
               ${CLR_B}KxkW       NkxX${NC}                                ${CLR_A}WKOkOO0KN                  WXOkk0N${NC}    
                ${CLR_B}XxkN     NxxX${NC}                             ${CLR_A}WX0OkO0XW                         WXkxON${NC}  
                 ${CLR_B}NkxX   XxkN${NC}                           ${CLR_A}WKOkkOXW                                XOx0N${NC}
${CLR_A}W${NC}                 ${CLR_B}WOxKWKdOW${NC}                         ${CLR_A}N0OkO0NW                                     Xkx${NC}
${CLR_A}k0W${NC}                ${CLR_B}W0ddd0W${NC}                     ${CLR_A}WX0OkkOKW                      ${CLR_B}W0d0W${NC}               ${CLR_A}WX${NC}
${CLR_A}KkxKW${NC}               ${CLR_B}WKxKW${NC}                   ${CLR_A}WKOkkO0XW                        ${CLR_B}WOdkdOW${NC}                   
 ${CLR_A}WKkkKW                                 WN0Okk0XW${NC}                           ${CLR_B}NkxX XxkN${NC}               
   ${CLR_A}WKkkOXW                           NKOkkOKN${NC}                              ${CLR_B}XxkN   NxxX${NC}              
     ${CLR_A}WXOkkOXW                   WX0OOOO0NW${NC}                                ${CLR_B}KdkN     NkxX${NC}             
        ${CLR_A}WX0OOOO0KXNWWWWWWNXK0OOOOOOKNW${NC}                                  ${CLR_B}W0dOW       WOd0W${NC}           
            ${CLR_A}WXK0OOOOOOOOOOOOO0XNW${NC}                                      ${CLR_B}WOld0KKKKKKKKK0dlOW${NC}          
                     ${CLR_A}WW${NC}                                                ${CLR_B}W0kOOOOOOOOOOOOOk0W${NC}          
"

echo -e "$SPLASH"

# We show a different german greeting for their respective time of day.
# "Morgen" for morning, "Tag" for afternoon, and "Abend" for evening
HOUR=$(date +"%H" | awk 'END { print int($1) }')

if (($HOUR >= 0)); then
	GREETING=$(echo "Morgen")
fi

if (($HOUR >= 12)); then
	GREETING=$(echo "Tag")
fi

if (($HOUR >= 16)); then
	GREETING=$(echo "Abend")
fi

# Greet the user
echo -e "$GREETING, ${CLR_A}$(whoami)${NC}"

# Now get the current uptime and load. 
UPTIME=$(uptime)
TIME=$(echo $UPTIME | awk 'END { print $1 }')

# Calculate the CPU percentage
CPU=$(grep 'cpu ' /proc/stat | awk '{usage = ($2 + $4) * 100 / ($2 + $4 + $5); } END {print int(usage + 0.5)"%"}')

# Calculate the RAM percentage
RAM_TOTAL=$(grep -oP '^MemTotal: *\K[0-9]+' /proc/meminfo)
RAM_USED=$(grep -oP '^MemAvailable: *\K[0-9]+' /proc/meminfo)
RAM=$(echo $RAM_USED  $RAM_TOTAL | awk '{usage = (($2 - $1) / $2) * 100} END {print int(usage + 0.5)"%"}')

# Calculate the load [Good indicator of network usage]
LOAD=$(echo $UPTIME | awk 'END { print $10 }' | tr -d ,)

echo -e "${CLR_B}time${NC}: $TIME | ${CLR_B}cpu${NC}: $CPU | ${CLR_B}ram${NC}: $RAM | ${CLR_B}load${NC}: $LOAD"
