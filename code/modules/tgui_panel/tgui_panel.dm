/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui_panel datum
 * Hosts tgchat and other nice features.
 */
/datum/tgui_panel
	var/client/client
	var/datum/tgui_window/window
	var/broken = FALSE
	var/initialized_at
	/// Debounces the protected-playback notice so a failing track doesn't spam the player.
	var/protected_playback_warned = FALSE
	/// How many times on_initialize_timed_out() has auto-retried initialize()
	/// without the window ever reaching READY.
	var/init_retry_count = 0
	/// Timer id for the currently-pending on_initialize_timed_out() check, so a
	/// manual retry (nuke_chat()/fix_tgui_panel) can't end up running a second,
	/// untracked timeout chain alongside the automatic one.
	var/init_timeout_timer

/datum/tgui_panel/New(client/client, id)
	src.client = client
	window = new(client, id)
	window.subscribe(src, PROC_REF(on_message))

/datum/tgui_panel/Del()
	window.unsubscribe(src)
	window.close()
	return ..()

/**
 * public
 *
 * TRUE if panel is initialized and ready to receive messages.
 */
/datum/tgui_panel/proc/is_ready()
	return !broken && window.is_ready()

/**
 * public
 *
 * Initializes tgui panel.
 */
/datum/tgui_panel/proc/initialize(force = FALSE)
	set waitfor = FALSE
	if(force)
		// A manual retry (nuke_chat(), after the automatic retries already gave
		// up) gets its own fresh attempt budget instead of immediately
		// re-triggering the same "giving up" message on its very first timeout.
		init_retry_count = 0
	// Minimal sleep to defer initialization to after client constructor
	sleep(1 TICKS)
	initialized_at = world.time
	// Perform a clean initialization
	window.initialize(
		strict_mode = TRUE,
		assets = list(
			get_asset_datum(/datum/asset/simple/tgui_panel),
		))
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/fontawesome))
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/tgfont))
	window.send_asset(get_asset_datum(/datum/asset/simple/roguefonts))
	// window.send_asset(get_asset_datum(/datum/asset/spritesheet_batched/chat))
	// Other setup
	request_telemetry()
	if(init_timeout_timer)
		deltimer(init_timeout_timer)
	init_timeout_timer = addtimer(CALLBACK(src, PROC_REF(on_initialize_timed_out)), PANEL_INIT_RETRY_DELAY, TIMER_STOPPABLE)
	window.send_message("testTelemetryCommand")

/**
 * private
 *
 * Called when initialization has timed out.
 */
/datum/tgui_panel/proc/on_initialize_timed_out()
	init_timeout_timer = null
	if(!client || window.is_ready())
		return
	// The window never sent anything back (no 'ready', no telemetry ack) - this
	// is the same stuck state manually clicking Reconnect or /nuke_chat fixes,
	// most often seen when a client reconnects into a still-booting world and
	// its browser control's first load/asset fetch never completes. Retry the
	// same re-initialize nuke_chat() already uses, a few times automatically,
	// before falling back to asking the player to do it manually.
	init_retry_count++
	if(init_retry_count < PANEL_INIT_MAX_RETRIES)
		initialize()
		return
	SEND_TEXT(client, span_userdanger("Failed to load fancy chat, click <a href='byond://?src=[REF(src)];reload_tguipanel=1'>HERE</a> to attempt to reload it."))

/**
 * private
 *
 * Callback for handling incoming tgui messages.
 */
/datum/tgui_panel/proc/on_message(type, payload)
	// Any inbound message is proof the window is alive - stop counting failed attempts.
	init_retry_count = 0
	if(type == "ready")
		broken = FALSE
		window.send_message("update", list(
			"config" = list(
				"client" = list(
					"ckey" = client.ckey,
					"address" = client.address,
					"computer_id" = client.computer_id,
				),
				"window" = list(
					"fancy" = FALSE,
					"locked" = FALSE,
				),
			),
		))
		if(client?.prefs)
			set_chat_theme(client.prefs.statbrowser_theme)
		return TRUE

	if(type == "audio/setAdminMusicVolume")
		client.admin_music_volume = payload["volume"]
		return TRUE

	if(type == "audio/protected")
		if(!protected_playback_warned)
			to_chat(client, span_warning("The music track could not be played - it returned a protected playback error, likely due to being copyrighted."))
			protected_playback_warned = TRUE
			addtimer(VARSET_CALLBACK(src, protected_playback_warned, FALSE), 10 SECONDS)
		return TRUE

	if(type == "telemetry")
		analyze_telemetry(payload)
		return TRUE

/**
 * public
 *
 * Sends a round restart notification.
 */
/datum/tgui_panel/proc/send_roundrestart()
	window.send_message("roundrestart")

/datum/tgui_panel/proc/set_chat_theme(statbrowser_theme)
	window.send_message("set_chat_theme", statbrowser_theme == "light" ? "leatherbound" : "dark")
