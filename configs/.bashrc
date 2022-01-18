export HISTCONTROL=ignorespace:ignoredups:erasedups

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Zip store all directories in working directory, optionally encrypt.
zipdirs () {
	if [[ -z "$1" ]]; then
		for name in */; do "C:/Program Files/7-Zip/7z.exe" a -r -t7z -mx=0 "${name::-1}.7z" "$name"; done
	else
		for name in */; do "C:/Program Files/7-Zip/7z.exe" a -r -t7z -mx=0 -mhe -p$1 "${name::-1}.7z" "$name"; done
	fi
}

# Convert image to 1000x1000@72 JPEG@100%.
downsizecover () {
	local path="${1:-cover.jpg}"
	
	if [[ "$path" == *jpg ]]; then
		magick mogrify -resize "1000x1000>" -density 72 -quality 100 -interlace plane "${path}"
		exiftool -overwrite_original -all= "$path"
	else
		magick convert -resize "1000x1000>" -density 72 -quality 100 -interlace plane "$path" "${path%.*}.jpg"
		exiftool -overwrite_original -all= "${path%.*}.jpg"
		rm "$path"
	fi
}

# Create <8MB MP3@V1 audio clip.
gensample () {
	echo -ne "\x1B[0;33mConverting...\x1B[0m\r"
	ffmpeg -hide_banner -loglevel panic -i "$1" -c:a libmp3lame -q:a 1 -fs 8M -y "$1.tmp.mp3"
	echo -ne "\x1B[0;32mReady...     \x1B[0m\r\a"
	sleep 6
	rm "$1.tmp.mp3"
	echo -e "\x1B[0;31mDeleted       \x1B[0m"
	sleep 2
	exit
}

# Kill processes by port.
kp () {
	for pid in $(netstat -aon | grep :$1 | grep -oP "\s\d+\s"); do
		taskkill -f -pid $pid
	done
}
