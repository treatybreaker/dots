#!/bin/bash

# Dependencies:
#	- wf-recorder: https://github.com/ammen99/wf-recorder
#	- notification daemon: https://archlinux.org/packages/?name=notification-daemon
#	- wl-clipboard: https://github.com/bugaevc/wl-clipboard
#
#	Some of this is hacky because I can't get wf-recorder to nicely output GIFs by itself :(

mk-mp4() {
	local program_name="Screen Capture"
	local pid_file="/tmp/mk-gif-pid"

	if [[ -f "${pid_file}" ]]; then
		notify-send "Saving ${program_name}" "This May Take a Minute" -a "${program_name}"
		if ! kill -SIGINT "$(cat "${pid_file}")" 2>/dev/null; then
			notify-send "Failed ${program_name}" "Failed to Save Screen Capture" -u "critical" -a "${program_name}"
			rm -rf "${pid_file}"
			exit 1
		fi
		inotifywait -e delete_self "${pid_file}" &&
			notify-send "Saved ${program_name}" "Successfully Saved Screen Capture to Clipboard" -a "${program_name}"
	else
		local input_tmpfile
		notify-send "Starting ${program_name}" "Recording GIF of Selected Region" -a "${program_name}"
		(
			local tmp_dir
			tmp_dir="$(mktemp -d)"
			cd "${tmp_dir}"
			input_tmpfile="${tmp_dir}/$(mktemp wf-recorder.XXXXXXXXXXX)"
			wf-recorder -g "$(slurp)" -f "${input_tmpfile}.mp4" -c h264_vaapi -d /dev/dri/renderD128 --framerate 24 -- &
			printf "%s" $! >"${pid_file}"
			wait
			wl-copy --type video/mp4 <"${input_tmpfile}.mp4"
			rm -f "${pid_file}"
		)
	fi
}

mk-mp4
