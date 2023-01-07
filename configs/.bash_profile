export HISTCONTROL=ignorespace:ignoredups:erasedups

alias ..="cd .."
alias ...="cd ../.."

# Zip store all directories in working directory, optionally encrypt.
zipdirs () {
	if [[ -z "$1" ]]; then
		for name in */; do
			"C:/Program Files/7-Zip/7z.exe" a -r -t7z -mx=0 "${name::-1}.7z" "$name"
		done
	else
		for name in */; do
			"C:/Program Files/7-Zip/7z.exe" a -r -t7z -mx=0 -mhe -p"$1" "${name::-1}.7z" "$name"
		done
	fi
}

# Kill processes by port.
kp () {
	for pid in $(netstat -aon | grep -P ":$1 .+ LISTENING" | awk '{ print $NF }'); do
		taskkill -f -pid $pid
	done
}
