# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples

setopt autocd              # change directory just by typing its name
#setopt correct            # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

WORDCHARS=${WORDCHARS//\/} # Don't consider certain characters part of the word

# hide EOL sign ('%')
PROMPT_EOL_MARK=""

# configure key keybindings
bindkey -e                                        # emacs key bindings
bindkey ' ' magic-space                           # do history expansion on space
bindkey '^U' backward-kill-line                   # ctrl + U
bindkey '^[[3;5~' kill-word                       # ctrl + Supr
bindkey '^[[3~' delete-char                       # delete
bindkey '^[[1;5C' forward-word                    # ctrl + ->
bindkey '^[[1;5D' backward-word                   # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history    # page up
bindkey '^[[6~' end-of-buffer-or-history          # page down
bindkey '^[[H' beginning-of-line                  # home
bindkey '^[[F' end-of-line                        # end
bindkey '^[[Z' undo                               # shift + tab undo last action

# enable completion features
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# History configurations
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
#setopt share_history         # share command history data

# force zsh to show the complete history
alias history="history 0"

# configure `time` format
TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

configure_prompt() {
    parse_git_branch() {
		local branch=$(git symbolic-ref --short HEAD 2> /dev/null)
		if [[ $branch != "" ]]; then
			echo "｢ %F{reset}${branch}%F{%(#.blue.green)} ｣ "
		fi
    }

    prompt_symbol=㉿
    # Skull emoji for root terminal
    case "$PROMPT_ALTERNATIVE" in
        twoline)
		PROMPT=$'%F{%(#.red.green)}${debian_chroot:+$debian_chroot─}${VIRTUAL_ENV:+$(basename $VIRTUAL_ENV)─}%n%F{reset}'$prompt_symbol$'%F{%(#.orange.red)}%m %B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}\n$(parse_git_branch)%B%(#.%F{red}#.%F{blue}$)%b%F{reset} '
            # Right-side prompt with exit codes and background processes
            #RPROMPT=$'%(?.. %? %F{red}%B⨯%b%F{reset})%(1j. %j %F{yellow}%B⚙%b%F{reset}.)'
            ;;
        oneline)
            PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%B%F{%(#.red.blue)}%n@%m%b%F{reset}:%B%F{%(#.blue.green)}%~%b%F{reset}%(#.#.$) '
            RPROMPT=
            ;;
        backtrack)
            PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%B%F{red}%n@%m%b%F{reset}:%B%F{blue}%~%b%F{reset}%(#.#.$) '
            RPROMPT=
            ;;
    esac
    unset prompt_symbol
}

# The following block is surrounded by two delimiters.
# These delimiters must not be modified. Thanks.
# START KALI CONFIG VARIABLES
PROMPT_ALTERNATIVE=twoline
NEWLINE_BEFORE_PROMPT=yes
# STOP KALI CONFIG VARIABLES

if [ "$color_prompt" = yes ]; then
    # override default virtualenv indicator in prompt
    VIRTUAL_ENV_DISABLE_PROMPT=1

    configure_prompt

    # enable syntax-highlighting
    if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
        . /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
        ZSH_HIGHLIGHT_STYLES[default]=none
        ZSH_HIGHLIGHT_STYLES[unknown-token]=underline
        ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
        ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[global-alias]=fg=green,bold
        ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[path]=bold
        ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
        ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
        ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[command-substitution]=none
        ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[process-substitution]=none
        ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=green
        ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=green
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
        ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[assign]=none
        ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
        ZSH_HIGHLIGHT_STYLES[named-fd]=none
        ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
        ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan
        ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=green,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan,bold
        ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout
    fi
else
    PROMPT='${debian_chroot:+($debian_chroot)}%n@%m:%~%(#.#.$) '
fi
unset color_prompt force_color_prompt

toggle_oneline_prompt(){
    if [ "$PROMPT_ALTERNATIVE" = oneline ]; then
        PROMPT_ALTERNATIVE=twoline
    else
        PROMPT_ALTERNATIVE=oneline
    fi
    configure_prompt
    zle reset-prompt
}
zle -N toggle_oneline_prompt
bindkey ^P toggle_oneline_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|Eterm|aterm|kterm|gnome*|alacritty)
    TERM_TITLE=$'\e]0;${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%n@%m: %~\a'
    ;;
*)
    ;;
esac

precmd() {
    # Print the previously configured title
    print -Pnr -- "$TERM_TITLE"

    # Print a new line before the prompt, but only if it is not the first line
    if [ "$NEWLINE_BEFORE_PROMPT" = yes ]; then
        if [ -z "$_NEW_LINE_BEFORE_PROMPT" ]; then
            _NEW_LINE_BEFORE_PROMPT=1
        else
            print ""
        fi
    fi
}

# enable color support of ls, less and man, and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:" # fix ls color for folders with 777 permissions

    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'

    export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
    export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
    export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
    export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
    export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
    export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
    export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

    # Take advantage of $LS_COLORS for completion as well
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
fi

# some more ls aliases
alias ll='ls -l'
alias la='ls -lA'
alias l='ls -CF'

# enable auto-suggestions based on the history
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    # change suggestion color
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi

# enable command-not-found if installed
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi

# Node
alias start='npm start'
alias dev='npm run dev'
alias npi='npm install'
alias npmi='npm install'
alias npu='npm uninstall'
alias npmu='npm uninstall'
alias npr='npm run'
alias npmr='npm run'
alias yadd='yarn add'
alias yrem='yarn remove'
alias submit='npm run submit'
alias npup='npx npm-check-updates'
alias npxup='npx npm-check-updates'
alias ntree='tree -I "font|img|node_modules" .'
alias nclean='find . -type d -name "node_modules" -exec rm {} +'
alias nalias='alias | egrep "npm|node" | sed -E "s/='\''(.+)'\''/\t\1/"'

# Git
alias gco='git commit -m'
alias gch='git checkout'
alias gchours='git checkout --ours'
alias gchtheirs='git checkout --theirs'
alias gcl='git clone'
alias ga='git add'
alias gd='git diff'
alias gdiff='git diff'
alias glog='git log'
alias pull='git pull'
alias gp='git push'
alias gpdev='git push -u origin dev'
alias gpmain='git push -u origin main'
alias gpdevmain='git push -u origin dev:main'
alias grm='git rm --cached'
alias gsearch='sh -c '\''git grep $1 $(git rev-list --all)'\'' _'
alias gisearch='sh -c '\''git grep -i $1 $(git rev-list --all)'\'' _'
alias gesearch='sh -c '\''git grep -e $1 $(git rev-list --all)'\'' _'
alias gstat='git status'
alias gsw='git switch'
alias gup='git update-index --no-assume-unchanged'
alias galias='alias | grep git | sed -E "s/='\''(.+)'\''/\t\1/"'

# Docker
alias dbuild='docker build .'
alias dbtag='docker build . -t'
alias dcls='docker container ls'
alias dc='docker compose'
alias dcup='docker compose up'
alias dls='docker ps'
alias dlss='docker ps --size'
alias dps='docker ps'
alias dpss='docker ps --size'
alias drun='docker run -t'

# Misc
## Modified default
alias curl='curl -#'
alias dd='dd status=progress'
alias sdd='sudo dd status=progress'
alias objdump='objdump -M intel --disassembler-color=on'
alias rsync='rsync -ah --info=progress2'

## Finding & Listing
alias lb='ls /bin /usr/bin /usr/local/bin | sort | uniq | column'
alias lc='echo $?'
alias le='ls -A | grep .env | column'
alias lss='sh -c '\''du -d${2:-99999} -ah $1 | sort -hr | less'\'' _'
alias lookup='GREP_COLORS="ms=0:mc=0" sh -c '\''grep -rnw --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.build --exclude-dir=.next --exclude=package*.json --exclude=*.pdf --color=auto -E ".*$1.*" "${2:-.}"'\'' _'
alias ilookup='sh -c '\''grep -rnw --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.build --exclude-dir=.next --exclude=package*.json --exclude=*.pdf --color=auto -iE ".*$1.*" "${2:-.}"'\'' _'
alias wlookup='grep -rnw --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.build --exclude-dir=.next --exclude=package*.json --exclude=*.pdf --color=auto -E'
alias iwlookup='grep -rnw --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.build --exclude-dir=.next --exclude=package*.json --exclude=*.pdf --color=auto -iE'
alias pdflookup='pdfgrep -Rn'
alias ipdflookup='pdfgrep -Rni'
alias cpdflookup='sh -c '\''pdfgrep -Rc "$1" $2 $3 | egrep -v ":0$" | sed -E "s/(.+)\:([0-9]+)/\x1b[35m\1\x1b[0m:\x1b[36m\2/"'\'' _'

## Displaying
alias clr='clear'
alias cah='highlight'
alias resize='convert -resize'
alias logan='sh -c '\''cat "${1:-.}" | cut "-d " -f1,4,7 | egrep -v "/socket.io|/check|/me|/sign-in|/sign-up|/.well-known|/favicon|/robots.txt|/apple-app-site-association|/$" | sort | uniq -w 13 | sed -Erz "s/ \[([0-9]+)\/([a-zA-Z]+)\/([0-9]+):([0-9]+):([0-9]+):([0-9]+)/\t\1 \2 \3 \4:\5/g"'\'' _'
alias original='alias | grep'

## Managing
alias adbpush='sh -c '\''adb push $1 ${2:-/sdcard/Pictures/}'\'' _'
alias layout='setxkbmap -print | grep keycodes | sed -E "s/.+\((.+)\).+/\1/mg"'
alias schown='sudo chown -R $USER:$USER'

## Hash
alias blake2b512sum='openssl dgst -blake2b512'
alias blake2s256sum='openssl dgst -blake2s256'
alias keccak256sum='openssl dgst -keccak-256'
alias sha3-256sum='openssl dgst -sha3-256'
alias shake256sum='openssl dgst -shake-256'
alias ssh-fingerprints='sh -c '\''find /etc/ssh ~/.ssh/ -iname "*$1*.pub" -exec ssh-keygen -l -E ${2:-sha256} -f {} \;'\'' _'

alias aalias='alias | sed -E "s/='\''(.+)'\''/ \1/"'

alias gchanges='sh -c '\''git diff --name-only HEAD ${1:-HEAD^}'\'' _'
alias gschanges='sh -c '\''git diff --name-only HEAD ${1:-HEAD^} | egrep "^(\w*(\.(([jt]sx{0,1})|(yml)|(jsonc{0,1}))$)|(Dockerfile)|((src)|(test)|(\.well-known)|(cron)|(public)\/)$2)"'\'' _'

alias ip-local='ip -4 -o -c=never a | egrep "wlan|eth" | cut "-d " -f7 | cut "-d/" -f1'
alias ip-iface='ip -4 -o -c=never a | egrep "wlan|eth" | cut "-d " -f2'
alias vpn-exception='sh -c '\''sudo ip route add $1 via $(ip -4 -o -c=never a | egrep "wlan|eth" | cut "-d " -f7 | cut "-d/" -f1) dev $(ip -4 -o -c=never a | egrep "wlan|eth" | cut "-d " -f2)'\'' _'

## FFMpeg
alias ffmpeg-cut='sh -c '\''ffmpeg -ss "$3" -t "$4" -i "$2" -vcodec copy -acodec copy "$1"'\'' _'
ffmpeg-merge() {
	output="$1"
	shift

	touch .pipeline.txt
	for input in $@; do
		echo "file '$input'" >> .pipeline.txt
	done
	ffmpeg -f concat -safe 0 -i .pipeline.txt -map 0 -codec copy "$output"
	# rm .pipeline.txt
}
alias ffmpeg-img='sh -c '\''ffmpeg -loop 1 -f image2 -i "$2" -c:v libx264 -t "$3" "$1"'\'' _'

ffmpeg-overlay() {
	ffmpeg -i "$2" -i "$3" -filter_complex "overlay=main_w-overlay_w:main_h-overlay_h:enable='between(t,$4,$5)'" -preset fast -c:a copy "$1"
}

ffmpeg-build() {
	output="$1"
	inputs=()
	shift

	for ((i = 1 ; i < $# + 1 ; i++)); do
		input=${@[$i]}

		echo "Input: $input"

		# for input in $@; do
		if [[ "$input" =~ .(jpg|jpeg|png|bmp|webp)$ ]]; then
			duration=5
			
			if [[ ${@[((i + 1))]} =~ ^[0-9]+$ ]]; then
				duration=${@[((i + 1))]}
				((i++))
			fi
			echo "$duration"

			ffmpeg-img "$i-$output" "$input" "$duration" &> /dev/null

			inputs+=("$i-$output")
		elif [[ "$input" =~ .(avi|mp4|mov|mkv)$ ]]; then
			inputs+=("$i-$output")
		fi
	done
	ffmpeg-merge "$output" $inputs
}

shred-folder() {
	if [[ "$1" == "" ]]; then
		echo "Error: Folder missing" >& 2
		return 1
	fi
	folder="$1"
	shift
	find "$folder" -type f -exec shred -vu $@ {} \;
	find "$folder" -type d -empty -delete
}

vpn-exception-host() {
	if [[ "$1" == "" ]]; then
		echo "Error: Host missing" >& 2
		return 1
	fi
	iface=$(ip -4 -o -c=never a | egrep "wlan|eth")
	iface_ip=$(echo "$iface" | cut "-d " -f7 | cut "-d/" -f1)
	iface_name=$(echo $iface | cut "-d " -f2)
	n=0
	for ip in $(host -t a $1 | grep "has address" | cut -f4 '-d ' | tr '\n' ' '); do
		echo "\e[32;1m+\e[0m \e[35m$ip\e[0m via \e[35m$iface_ip\e[0m dev \e[36m$iface_name\e[0m"
		sudo ip route add "$ip" via "$iface_ip" dev "$iface_name"
		((n++))
	done
	if [[ $n == 0 ]]; then
		echo "Error: Could not find any IPv4 for $1" >& 2
		return 1
	fi
}
vpn-exception-host-remove() {
	if [[ "$1" == "" ]]; then
		echo "Error: Host missing" >& 2
		return 1
	fi
	iface=$(ip -4 -o -c=never a | egrep "wlan|eth")
	iface_ip=$(echo "$iface" | cut "-d " -f7 | cut "-d/" -f1)
	iface_name=$(echo $iface | cut "-d " -f2)
	n=0
	for ip in $(host -t a $1 | grep "has address" | cut -f4 '-d ' | tr '\n' ' '); do
		echo "\e[31;1m-\e[0m \e[35m$ip\e[0m via \e[35m$iface_ip\e[0m dev \e[36m$iface_name\e[0m"
		sudo ip route del "$ip" via "$iface_ip" dev "$iface_name"
		((n++))
	done
	if [[ $n == 0 ]]; then
		echo "Error: Could not find any IPv4 for $1" >& 2
		return 1
	fi
}
vpn-exception-reset() {
	iface=$(ip -4 -o -c=never a | egrep "wlan|eth")
	iface_ip=$(echo "$iface" | cut "-d " -f7 | cut "-d/" -f1)
	iface_name=$(echo $iface | cut "-d " -f2)
	n=0
	for ip in $(ip route | grep "$iface_ip dev $iface_name" | cut '-d ' -f1); do
		echo "\e[31;1m-\e[0m \e[35m$ip\e[0m via \e[35m$iface_ip\e[0m dev \e[36m$iface_name\e[0m"
		sudo ip route del "$ip" via "$iface_ip" dev "$iface_name"
		((n++))
	done
	if [[ $n == 0 ]]; then
		echo "No exception found: nothing to do" >& 2
		return 1
	fi
}
shell-colour() {
	256_colours() {
		printf "\e[4m8-bit 256-colours (6x6x6)\e[0m \e[2m(non-standard)\e[0m\n"
		for ((bright = 0 ; bright < 16 ; bright++)); do
			printf "\e[48;5;%im %03i \e[0m" $bright $bright
			if (( bright % 6 == 5)); then
				echo
			fi
		done
		echo
		for ((red = 0 ; red < 6 ; red++)); do
			for ((green = 0 ; green < 6 ; green++)); do
				for ((blue = 0 ; blue < 6 ; blue++)); do
					colour=(( 16 + (red * 36) + green * 6 + blue ))
					printf "\e[48;5;%im %03i \e[0m" $colour $colour
				done
				echo
			done
		done
		for ((bright = 232 ; bright < 256 ; bright++)); do
			printf "\e[48;5;%im %03i \e[0m" $bright $bright
			if (( bright % 6 == 3)); then
				echo
			fi
		done
		echo
		echo "  16 + (RED*36) + (GREEN*6) + BLUE"
		printf '  \\e[<38|48>;5;\e[1m<colour>\e[0mm\n'
	}
	rgb_colours() {
		printf "\e[4m24-bit RGB colours\e[0m \e[2m(non-standard)\e[0m\n"
		printf '  \\e[<38|48>;2;\e[1m<RED>\e[0m;\e[1m<GREEN>\e[0m;\e[1m<BLUE>\e[0mm\n'
	}
	extended_footer() {
		echo
		echo "  Foreground  38"
		echo "  Background  48"
	}
	case "$1" in
		"-256")
			256_colours
			;;
		"-rgb")
			rgb_colours
			;;
		"-x")
			256_colours
			echo
			rgb_colours
			;;
		"-h"|"-?"|"--help")
			printf "\e[4mUsage:\e[0m $0 { -256 | -rgb | -x }\n"
			echo
			echo "  -l    4-bit legacy colours and style"
			echo "  -256  8-bit extended 256 colours (non-standard)"
			echo "  -rgb  24-bit extended RGB colours (non-standard)"
			echo "  -x    All extended colours (non-standard)"
			echo
			echo "  -h --help  Show this help"
			echo "  -?    Alias for -h"
			echo
			echo "Note: No parameter will print legacy colours"
			return 0
			;;
		"-l"|"")
			show_list() {
				local title=$1
				local i=$2
				shift 2

				printf "\e[4m${title}\e[0m\n"
				if (( i >= 30 )); then
					printf "  DEFAULT      %i\n" ((i+9))
					printf "               \e[4mNormal\e[0m      \e[4mBright (non-standard)\e[0m\n"
				fi
				for c in "$@"; do
					if (( i == 8 )); then
						printf "  %-16s %i  \e[%im%-8s\e[0m\n" "$c" $i $i "Lorem Ipsum"
					elif (( i < 30 )); then
						printf "  \e[%im%-16s %i  %-8s\e[0m\n" $i "$c" $i "Lorem Ipsum"
					else
						printf "  \e[%im%-12s %i %-8s \e[%im%i %-9s\e[0m\n" $i "$c" $i "Lorem" ((i+60)) ((i+60)) "Lorem"
					fi
					((i++))
				done
				if (( i < 30 )); then
					printf "  DOUBLE_UNDERLINE 21 \e[21mLorem Ipsum\e[0m\n"
				fi
				echo
			}
			style=("NORMAL/RESET" "BOLD" "DIM" "ITALIC" "UNDERLINE" "BLINK" "BLINK_FAST" "REVERSE" "HIDE" "STRIKE")
			show_list "Style" 0 $style

			colour=("BLACK" "RED" "GREEN" "YELLOW" "BLUE" "MAGENTA" "CYAN" "WHITE")
			show_list "Foreground" 30 $colour
			show_list "Background" 40 $colour
			printf '  \e[2m4-bit\e[0m \e[2m(Legacy)\e[0m\n'
			return 0
			;;
		*)
			printf "\e[31mError\e[0m: Unknown argument $1\n" >&2
			printf "Type '$0 -h' for more information\n" >&2
			return 1
			;;
	esac
	extended_footer
}
alias shc='shell-colour'
# dpdflookup() {
# 	local text="$1"
# 	local _path="."
# 	shift
# 	if [[ $1 != '' ]]; then
# 		_path="$1"
# 		shift
# 	fi

# 	find ${_path} $@ -name '*.pdf' -exec sh -c "pdftotext -nopgbrk '{}' - | sed -Erz 's/([a-zA-Z0-9 _–-])\n/\1/g' | grep --with-filename --label='{}' --color '${text}'" \;
# }
# mvsed() {
# 	local _regex="$1"
# 	local _path="."
# 	shift
# 	if [[ $1 != '' ]]; then
# 		_path="$1"
# 		shift
# 	fi

# 	find ${_path} $@ -not -name '.' -exec sh -c 'echo "{}" $(echo {} | sed -Erz "s/([.\[\]\(\)*^$+?{|])/\\1/g; '${_regex}'")' \;
# }
rimg() {
	if [ ! -f "$1" ]; then
		echo "No such file '$1'" >&2
		return 1
	fi
	local width=$(identify -format '%w' "$1")
	local height=$(identify -format '%h' "$1")
	local filename=$(echo "${1%.*}")
	local ext=$(echo "${$(basename -- "$1")##*.}")
	local round_px=0
	local round_ratio=${2:-10}
	if (( width > height )); then
		round_px=$(( height / round_ratio ))
	else
		round_px=$(( width / round_ratio ))
	fi

	maskname=".mask.png"

	convert -size "${width}x${height}" xc:none -draw "roundrectangle 0,0,${width},${height},${round_px},${round_px}" "$maskname"
	convert "$1" -matte "$maskname" -compose DstIn -composite "$filename-rounded.$ext"
	rm "$maskname"
}

pad() {
	awk 'BEGIN {FS=OFS="'"${2:=~}"'"} {$1 = sprintf("  \x1b[36;1m%-'"${1:=32}"'s\x1b[0m", $1)} 1'
}

# Insensitive AND grep
iagrep() {
	local __geval="grep -i $1"

	shift
	for gcmd in $@; do
		__geval+=" | grep -i $gcmd"
	done
	eval $__geval
}

# Search within manual
msearch() {
	man -k "$@" | grep "(1)" | iagrep "$@" | cut "-d " -f1,3- | sed -Erz 's/- / ~ /g' | pad 4
}

# Search within (uninstalled) packages
asearch() {
	apt search "$@" 2> /dev/null | sed -Erz 's/\n([a-zA-Z0-9_.-]+)\/kali-rolling(([a-zA-Z0-9 ,:+.-]|\[|\])+)/\1/g' | sed -Erz 's/\n  / ~ /g' | iagrep "$@" | pad 18
}

# Search within manual and packages
search() {
	printf "\e[1;4mManual:\e[0m\n"
	msearch $@

	printf "\n\e[1;4mPackages:\e[0m\n"
	asearch $@
}

push() {
	if [[ "$1" == "" ]]; then
		echo "No comment specified" >&2
		echo "Usage: $0 <comment> <file> ..."
		return 1
	elif [[ "$2" == "" ]]; then
		echo "No file specified" >&2
		echo "Usage: $0 <comment> <file> ..."
		return 1
	fi
	comment="$1"
	shift
	git add $@
	if [ $? -ne 0 ]; then
		return 1
	elif [[ $(git status) == *"nothing"* ]]; then
		echo "Already up to date."
		return 0
	fi
	git status
	git commit -m "$comment"
	git push
}

update-zsh() {
	cd "$ENHANCED_PATH"
	if [ -d "$folder" ]; then
		cd $folder
		git_pull=$(git pull origin main 2> /dev/null)
		echo $git_pull
		
		if [[ $? -ne 0 || $git_pull == *"Already up to date"* ]]; then
			return 0
		elif [[ $git_pull == *"vscode"* || $git_pull == *"gnome-terminal-profiles"* || $git_pull == *"import.sh"* || $git_pull == *"fonts"* || $git_pull == *"libre-office"* ]]; then
			./import.sh
		else
			./import-zsh.sh
		fi
	else
		git clone https://github.com/MikeCod/EnhancedTerminal.git $folder
		if [ $? -ne 0 ]; then
			return 0
		fi
		cd $folder
		./import.sh
	fi
    

	echo "Run the command below to update your current terminal:
	. ~/.zshrc
	"
}

help-recovery() {
	printf "\e[4mUsual recovery tools:\e[0m
  cryptsetup    Encrypt Drive to LUKS
  curl          Download
  dd            Copy source to destination
  fdisk         Drives details
  lsblk         Drive listing
  man           READ THE FUCKING MANUAL
  mkfs          Format partition
  search Search in manual (first page) and packages
  help [<text>] Show this help,
                Or search in manual (first page) if an argument is given

  mount <source> <mountpoint> Mount partition
  umount <mountpoint>         Unmount partition

\e[4mUsual files:\e[0m
  /dev/zero     Null byte
  /dev/random   Random byte"
}
help() {
	if [[ $1 != "" ]]; then
		search $1
		return 0
	fi
	printf "\e[4mCommon useful tools:\e[0m
  alias             Display aliases
  asearch           Search in packages
  curl              Download
  dd                Copy source to destination
  fdisk             Drives details
  lb                Command listing (alias)
  le                Env files listing (alias)
  lookup            Search a text within files of the current folder
                    and all sub-folders
  lsblk             Drive listing
  jq                JSON format and filter
  man               READ THE FUCKING MANUAL
  mkfs              Format partition
  msearch           Search in manual (first page)
  pdfunite          Merge multiple PDF
  rimg              Round an image
  search            Search in manual and packages
  tesseract-ocr     Extract text from image.

  help              Show this help,
                    Or search in manual (first page) if an argument is given

\e[4mUsual files:\e[0m
  /dev/zero     Null byte
  /dev/random   Random byte"
}
git-convention() {
	printf "\e[4mGit conventional types:\e[0m
	
  \e[36;1mbuild\e[0m     Changes that affect the build system or external dependencies (e.g. gulp, npm)
  \e[36;1mchore\e[0m     Other changes that don't modify src or test files
   └─ \e[36;1mmeta\e[0m      Metadata changes (e.g. version)
  
  \e[36;1mdocs\e[0m      Documentation only changes
  \e[36;1mfeat\e[0m      New feature
  \e[36;1mfix\e[0m       Bug Fixes
  \e[36;1mops\e[0m       Operational components (e.g. infrastructure, deployment, etc.)
   ├─ \e[36;1mci\e[0m        Changes to our CI configuration files and scripts (e.g. Travis, Circle)
   └─ \e[36;1mrevert\e[0m    Reverts a previous commit
  
  \e[36;1mrefactor\e[0m  A code change that neither fixes a bug nor adds a feature
   └─ \e[36;1mperf\e[0m      Performance Improvements
  
  \e[36;1mstyle\e[0m     Changes that do not affect the meaning of the code (white-space, formatting, etc)
  \e[36;1mtest\e[0m      Adding missing tests or correcting existing tests


 \e[1m<type>(<scope>): <short summary>\e[0m
  │      │         └── \e[4mSummary\e[0m in present tense. Not capitalized. No dot at the end.
  │      └── \e[4mScope:\e[0m animations|app.json|common ...
  └── \e[4mType:\e[0m build|ci|docs|feat ...


\e[4mThe scope provides additional contextual information (Optional)\e[0m
  - Allowed Scopes depends on the specific project
  - Don't use issue identifiers as scopes

\e[4mBreaking Changes Indicator (Optional)\e[0m
   Indicated by \e[1m!\e[0m before the \e[1m:\e[0m in the subject line e.g. feat(api)!: remove status endpoint
"
}
alias gitc='git-convention'

repair() {
	case "$1" in
		"dock")
			sudo apt remove gnome-shell-extension-dashtodock
			;;
		"vpn")
			# Disable kill switch
			local device=$(nmcli d | grep vpn | cut '-d ' -f1)
			nmcli d delete "$device"
			if [ $? -ne 0 ]; then
				echo "Couldn't disable kill switch" >&2
				return 1
			fi
			echo "You can now install VPN back:"
			echo "  sudo apt install proton-vpn-gnome-desktop"
			;;
		"")
			;;
	esac
}

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:/snap/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools
export DOCKER_HOST=unix:///run/user/1000/docker.sock

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PRINT='
n'
export PATH=$PATH:$HOME/.maestro/bin
export ENHANCED_PATH='/home/night/Documents/project/EnhancedTerminal'
