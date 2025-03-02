set -euoE pipefail

mk-screen-cap() {
	local program_name="Screen Capture"
	local pid_file="/tmp/mk-gif-pid"
	local output_type="${1:-webm}"

	if [[ -f "$pid_file" ]]; then
		printf "Ending screen capture\n"
		notify-send "Saving ${program_name}" "This May Take a Minute" -a "$program_name"
		if ! kill -SIGINT "$(cat "$pid_file")"; then
			notify-send "Failed ${program_name}" "Failed to Save Screen Capture" -u "critical" -a "$program_name"
			printf "Failed to save screen capture!\n"
			rm -rf "$pid_file"
			exit 1
		fi
	else
		printf -- "Beginning recording\n"
		local tmp_file
		notify-send "Starting ${program_name}" "Recording ${output_type^^} of Selected Region" -a "$program_name"
		local tmp_dir
		tmp_dir="$(mktemp -d)"
		local file_extension="$output_type"
		if [[ "$output_type" == "gif" ]]; then
			file_extension="webm"
		fi
		local tmp_file
		tmp_file="$(mktemp --tmpdir="$tmp_dir" recording.XXXXXXXXXXX).${file_extension}"
		printf "Working temp file: '%s'\n" "$tmp_file"

		local geometry
		geometry="$(slurp)"
		wl-screenrec --filename "$tmp_file" --geometry "$geometry" &
		local pid="${!}"
		printf "%s" "$pid" >"$pid_file"
		printf "Putting pid: '%d' into pid file: '%s'\n" "$pid" "$pid_file"
		wait -n "$pid"

		if [[ "$output_type" == "gif" ]]; then
			printf "Converting recording to gif...\n"
			local gifski_tmpout
			gifski_tmpout="${tmp_dir}/$(mktemp -- "$tmp_dir" gifski.XXXXXXXXXXX).gif"
			gifski --output "$gifski_tmpout" "$tmp_file"
			mv "$gifski_tmpout" "$tmp_file"
		fi

		local save_path
		save_path="${HOME}/Videos/Screen-Recordings"
		mkdir -p "$save_path"
		save_path="${save_path}/$(date --iso-8601="seconds").${output_type}"
		printf "Recording ended, saving to: '%s'\n" "$save_path"
		mv "$tmp_file" "$save_path"

		printf "Copying recording to clipboard\n"
		local mimetype
		mimetype="$(file -b --mime-type "$save_path")"
		wl-copy --type="$mimetype" <"$save_path"
		rm -f "$pid_file"
		notify-send "Saved ${program_name}" "Successfully Saved Screen Capture to Clipboard" -a "$program_name"
		printf "Finished Recording, exiting...\n"
	fi
}

mk-screen-cap "${@}"
