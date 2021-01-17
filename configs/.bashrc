export HISTCONTROL=ignorespace:ignoredups:erasedups

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

zipdirs () {
	for name in */; do "C:/Program Files/7-Zip/7z.exe" a -r "${name::-1}.zip" "$name"; done
}
