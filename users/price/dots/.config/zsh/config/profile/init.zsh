#!/usr/bin/env zsh

configure() {

}

init() {
	local wkdir="${BASE_ZSH_CONFIG_DIR}/config/profile"
	source "${wkdir}/profile/options.zsh"
	source "${wkdir}/profile/env.zsh"
	source "${wkdir}/profile/functions.zsh"
	source "${wkdir}/profile/aliases.zsh"
	source "${wkdir}/profile/keybinds.zsh"

	configure
}

init