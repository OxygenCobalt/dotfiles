#
# ~/.bashrc
#

[[ $- != *i* ]] && return

# Enable color. Pretty much every terminal has it now.
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
alias more="less"                          # Less is better
alias rename="imv"                         # Rename is a joke

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

# Begin our splash
SPLASH="
                                                                                \033[0;34mWW\033[0m                  
             \033[0;36mWOxkOOOOOOOOOOOkx0W\033[0m                                      \033[0;34mWNX00OOOOOOOOOOOO0XW\033[0m          
             \033[0;36mW0oxKXXXXXXXXXKxo0w\033[0m                                  \033[0;34mWK0OOOOO0KXNWWWWWWNX0OOOk0XW\033[0m      
               \033[0;36mKxkW       NkxX\033[0m                                \033[0;34mWKOkOO0KN                  WXOkk0N\033[0m    
                \033[0;36mXxkN     NxxX\033[0m                             \033[0;34mWX0OkO0XW                         WXkxON\033[0m  
                 \033[0;36mNkxX   XxkN\033[0m                           \033[0;34mWKOkkOXW                                XOx0N\033[0m
\033[0;34mW\033[0m                 \033[0;36mWOxKWKdOW\033[0m                         \033[0;34mN0OkO0NW                                     Xkx\033[0m
\033[0;34mk0W\033[0m                \033[0;36mW0ddd0W\033[0m                     \033[0;34mWX0OkkOKW                   \033[0;36mW0d0W\033[0m                  \033[0;34mWX\033[0m
\033[0;34mKkxKW\033[0m               \033[0;36mWKxKW\033[0m                   \033[0;34mWKOkkO0XW                     \033[0;36mWOdkdOW\033[0m                   
 \033[0;34mWKkkKW                                 WN0Okk0XW\033[0m                        \033[0;36mNkxX XxkN\033[0m                  
   \033[0;34mWKkkOXW                           NKOkkOKN\033[0m                           \033[0;36mXxkN   NxxX\033[0m                 
     \033[0;34mWXOkkOXW                   WX0OOOO0NW\033[0m                             \033[0;36mKdkN     NkxX\033[0m                
        \033[0;34mWX0OOOO0KXNWWWWWWNXK0OOOOOOKNW\033[0m                               \033[0;36mW0dOW       WOd0W\033[0m              
            \033[0;34mWXK0OOOOOOOOOOOOO0XNW\033[0m                                   \033[0;36mWOld0KKKKKKKKK0dlOW\033[0m             
                     \033[0;34mWW\033[0m                                             \033[0;36mW0kOOOOOOOOOOOOOk0W\033[0m             
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
echo -e "$GREETING, \033[0;34m$(whoami)\033[0m"

# Now get the current uptime and load. 
UPTIME=$(uptime)
TIME=$(echo $UPTIME | awk 'END { print $1 }')

# Calculate the CPU percentage
CPU=$(grep 'cpu ' /proc/stat | awk '{usage = ($2 + $4) * 100 / ($2 + $4 + $5); } END {print int(usage + 0.5)"%"}')

# Calculate the RAM percentage
RAM_TOTAL=$(grep -oP '^MemTotal: *\K[0-9]+' /proc/meminfo)
RAM_USED=$(grep -oP '^MemFree: *\K[0-9]+' /proc/meminfo)
RAM=$(echo $RAM_USED  $RAM_TOTAL | awk '{usage = (($2 - $1) / $2) * 100} END {print int(usage + 0.5)"%"}')

# Calculate the load [Good indicator of network usage]
LOAD=$(echo $UPTIME | awk 'END { print $10"%" }')

echo -e "\033[0;36mtime\033[0m: $TIME | \033[0;36mcpu\033[0m: $CPU | \033[0;36mram\033[0m: $RAM | \033[0;36mload\033[0m: $LOAD"
