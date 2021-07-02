export HISTCONTROL=ignorespace:ignoredups:erasedups

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Zip all directories in current directory.
zipdirs () {
	for name in */; do "C:/Program Files/7-Zip/7z.exe" a -r -mx=0 "${name::-1}.zip" "$name"; done
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

# Generate <8MB MP3@V1 target from source.
gensample () {
	echo -ne "\x1B[0;33mConverting...\x1B[0m\r"
	ffmpeg -hide_banner -loglevel panic -i "$1" -c:a libmp3lame -q:a 1 -fs 8M -y "$1.tmp.mp3"
	echo -ne "\x1B[0;32mReady...     \x1B[0m\r\a"
	sleep 5
	rm "$1.tmp.mp3"
	echo -e "\x1B[0;31mDeleted       \x1B[0m"
}
