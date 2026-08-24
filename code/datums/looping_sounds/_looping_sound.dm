/// Extra tiles beyond a loop's normal hearing range that get preloaded ahead of time,
/// so a player walking toward the source is less likely to hit the decode hitch exactly
/// as they cross into audible range.
#define LOOPING_SOUND_PRELOAD_RANGE_BUFFER 4
/// How many clients get the initial (silent) preload send per batch.
#define LOOPING_SOUND_ATTACH_BATCH_SIZE 6
/// Ticks between preload batches, so a crowd near the same source doesn't all hitch on the same frame.
#define LOOPING_SOUND_ATTACH_BATCH_DELAY 1

GLOBAL_LIST_EMPTY(created_sound_groups)
/datum/sound_group
	var/list/reserved_channels = list()
	var/channel_count = 1
	var/last_iter = 1

/datum/sound_group/New()
	. = ..()
	reserved_channels = list()
	for(var/channel = 1 to channel_count)
		reserved_channels += SSsounds.reserve_sound_channel(src)

/datum/sound_group/torches
	channel_count = 150

/datum/sound_group/fire_loop
	channel_count = 150

/datum/sound_group/instruments
	channel_count = 32 //probably more than enough

/*
	parent	(the source of the sound)			The source the sound comes from

	mid_sounds		(list or soundfile)		Since this can be either a list or a single soundfile you can have random sounds. May contain further lists but must contain a soundfile at the end.
	mid_length		(num)					The length to wait between playing mid_sounds

	start_sound		(soundfile)				Played before starting the mid_sounds loop
	start_length	(num)					How long to wait before starting the main loop after playing start_sound

	end_sound		(soundfile)				The sound played after the main loop has concluded

	chance			(num)					Chance per loop to play a mid_sound
	volume			(num)					Sound output volume
	max_loops		(num)					The max amount of loops to run for.
	direct			(bool)					If true plays directly to provided atoms instead of from them
*/
/datum/looping_sound
	var/atom/parent // the atom we belong to
	var/mid_sounds
	var/mid_length = 1
	var/start_sound
	var/start_length
	var/end_sound = 'sound/blank.ogg'
	var/chance
	var/volume = 100
	var/vary = FALSE
	var/max_loops = 0
	var/cur_num_loops = 0
	var/direct
	var/extra_range = 0
	var/falloff
	var/frequency
	var/stopped = TRUE
	var/persistent_loop = FALSE //we stay in the client's played_loops so we keep updating volume even when out of range
	var/cursound
	var/list/thingshearing = list() // this is a list of WEAKREFS to the mobs that can currently hear us
	var/ignore_walls = TRUE
	var/timerid
	/// Has the looping started yet?
	var/loop_started = FALSE
	///our sound channel
	var/channel
	var/datum/sound_group/sound_group
	var/starttime // A world.time snapshot of when the loop was started.
	/// Which bitflag pref we check for when playing this to listeners, if any. This will check for its ABSENCE, not its presence.
	var/filter_pref
	/// Timer id for the currently-queued attach_loop_to_clients() batch, if any.
	var/attach_batch_timer

/datum/looping_sound/New(_parent, start_immediately=FALSE, _direct=FALSE, _channel = 0)
/*	if(!mid_sounds)
		WARNING("A looping sound datum was created without sounds to play.")//Obsolete now, instruments don't start with sounds
		return*/
	if(islist(_parent))
		WARNING("A looping sound datum was created using a list, this is no longer allowed please change to a parent")
		return

	var/datum/sound_group/group
	if(sound_group)
		for(var/datum/sound_group/listed in GLOB.created_sound_groups)
			if(listed.type != sound_group)
				continue
			group = listed
		if(!group)
			group = new sound_group
			GLOB.created_sound_groups |= group
		if(group.last_iter >= group.channel_count)
			group.last_iter = 1

		var/picked_channel = group.reserved_channels[group.last_iter]
		group.last_iter++
		channel = picked_channel

	if(start_sound && !istype(start_sound, /sound))
		start_sound = sound(start_sound)

	mid_sounds = canonize_sounds(mid_sounds)

	parent = _parent
	direct = _direct

	if(_channel)
		channel = _channel
	if(!channel)
		channel = SSsounds.reserve_sound_channel(src)

	if(start_immediately)
		start()

/// Takes in a list of sound files, returns a list of corresponding sound datums.
/datum/looping_sound/proc/canonize_sounds(input_sounds)
	. = list()
	for(var/sound_candidate in input_sounds)
		if(isfile(sound_candidate))
			. += sound(sound_candidate)
		else if(istype(sound_candidate, /sound))
			. += sound_candidate
		else if(islist(sound_candidate))
			. += list(canonize_sounds(sound_candidate))

/datum/looping_sound/proc/set_mid_sounds(list/new_mid_sounds)
	mid_sounds = canonize_sounds(new_mid_sounds)
	cursound = null

/datum/looping_sound/Destroy()
	stop()
	// really seriously make sure we have like none of these references hanging...
	for (var/datum/weakref/listener_ref in thingshearing)
		var/mob/M = listener_ref.resolve()
		if (M?.client)
			M.client.played_loops -= src
	// explicitly free our channel, since we might have a ref left in SSsounds
	if (channel)
		SSsounds.free_datum_channels(src)
		channel = null
	parent = null
	thingshearing = null
	return ..()

/datum/looping_sound/proc/start(atom/on_behalf_of)
	stopped = FALSE
	if(on_behalf_of)
		set_parent(on_behalf_of)
	loop_started = TRUE
//	if(timerid)
//		return
	on_start()

/datum/looping_sound/proc/stop(null_parent)
	stopped = TRUE
	if(attach_batch_timer)
		deltimer(attach_batch_timer)
		attach_batch_timer = null
	if(null_parent)
		set_parent(null)
	on_stop()
	loop_started = FALSE
//		if(!timerid)
//			return
//		deltimer(timerid)
//		timerid = null

/datum/looping_sound/proc/sound_loop()
//	START_PROCESSING(SSsoundloopers, src)
	if(!cursound)
		cursound = get_sound(starttime)

	if(max_loops && cur_num_loops >= max_loops)
		cur_num_loops = 0
		stop()
		return 1
	else if(max_loops)
		cur_num_loops++
	if(stopped)
		stop()
		return 1
	if(!chance || prob(chance))
		play(cursound)
//	if(!timerid)
//		timerid = addtimer(CALLBACK(src, PROC_REF(sound_loop), world.time), mid_length, TIMER_CLIENT_TIME | TIMER_STOPPABLE | TIMER_LOOP)

/datum/looping_sound/proc/play(soundfile)
	if (!parent)
		return

	starttime = world.time

	if(direct)
		if(ismob(parent))
			var/mob/mob = parent
			mob.playsound_local(mob, soundfile, volume, vary, frequency, falloff, repeat = src, channel = channel)
		return
	var/list/R = playsound(parent, soundfile, volume, vary, extra_range, falloff, frequency, channel, ignore_walls = ignore_walls, repeat = src)
	for(var/datum/weakref/listener_ref in thingshearing)
		var/mob/M = listener_ref.resolve()
		if(!M?.client)
			thingshearing -= listener_ref
			continue
		if(!(M in R) || M.IsSleeping())// they are out of range
			var/list/L = M.client.played_loops[src]
			if(L)
				var/sound/SD = L["SOUND"]
				if(SD)
					if(persistent_loop)
						L["MUTESTATUS"] = TRUE
						L["VOL"] = 0
						M.mute_sound(SD)
						//M.play_ambience()
					else
						M.client.played_loops -= src
						thingshearing -= listener_ref
						M.stop_sound_channel(SD.channel)
		else
			on_hear_sound(M)

/datum/looping_sound/proc/on_hear_sound(mob/M)
	if(!persistent_loop || !M?.client)
		return

	var/list/L = M.client.played_loops[src]
	if(!L)
		return

	L["MUTESTATUS"] = FALSE
	L["VOL"] = volume

	var/sound/SD = L["SOUND"]
	if(SD)
		M.unmute_sound(SD)

/datum/looping_sound/proc/get_sound(starttime, _mid_sounds)
	. = _mid_sounds || mid_sounds
	while(islist(.) && !isnull(.))
		. = pickweight(.)

/datum/looping_sound/proc/on_start()
	var/start_wait = 0
	if(start_sound) //does ANYTHING even use start_sound
		play(start_sound)
		start_wait = start_length
	if(persistent_loop)
		attach_loop_to_all_clients()
	addtimer(CALLBACK(src, PROC_REF(begin_loop)), start_wait, TIMER_CLIENT_TIME)
	if(persistent_loop && !(src in GLOB.persistent_sound_loops))
		GLOB.persistent_sound_loops += src

/datum/looping_sound/proc/attach_loop_to_all_clients()
	if(!persistent_loop)
		return

	var/soundfile = get_sound(world.time, mid_sounds)
	if(!soundfile)
		return

	cursound = soundfile

	// A fresh attach cycle (e.g. stop() then start() again) supersedes whatever
	// batch chain was already in flight - drop it instead of leaving it orphaned
	// (it would otherwise keep firing untracked, and a later stop() would only
	// ever cancel whichever chain is current).
	if(attach_batch_timer)
		deltimer(attach_batch_timer)
		attach_batch_timer = null

	// Preloading (a silent playsound_local) forces BYOND to decode the audio file
	// client-side right away, which is a synchronous hitch on that client. Sending it to
	// every connected client - regardless of where they are on the map - means anyone,
	// anywhere, can freeze for a moment the instant any instrument/musicbox starts
	// anywhere else on the server. Scope the preload to mobs who could plausibly hear
	// this loop soon instead, same as a real playsound() would reach.
	var/turf/source_turf = get_turf(parent)
	if(!source_turf)
		for(var/client/C in GLOB.clients) // no physical source to range-check against, fall back to old behavior
			var/mob/M = C.mob
			if(!M)
				continue
			if(filter_pref && !(C.prefs.toggles & filter_pref))
				continue
			M.playsound_local(null, soundfile, 0, vary, frequency, falloff, channel, FALSE, null, src)
		return

	var/maxdistance = world.view + extra_range + LOOPING_SOUND_PRELOAD_RANGE_BUFFER
	var/turf/above_turf = GET_TURF_ABOVE(source_turf)
	var/turf/below_turf = GET_TURF_BELOW(source_turf)
	var/list/targets = get_hearers_in_range(maxdistance, source_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)
	if(ignore_walls)
		if(above_turf)
			targets |= get_hearers_in_range(maxdistance, above_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)
		if(below_turf)
			targets |= get_hearers_in_range(maxdistance, below_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)

	// playsound() also always considers ghosts on the affected z-level(s) (range-checked
	// the same as everyone else) - without this, a spectating ghost near the source still
	// hits the exact decode hitch this preload exists to avoid.
	var/list/dead_candidates = SSmobs.dead_players_by_zlevel[source_turf.z].Copy()
	if(ignore_walls)
		if(above_turf)
			dead_candidates |= SSmobs.dead_players_by_zlevel[above_turf.z]
		if(below_turf)
			dead_candidates |= SSmobs.dead_players_by_zlevel[below_turf.z]
	for(var/mob/dead/D as anything in dead_candidates)
		var/turf/dead_turf = get_turf(D)
		if(dead_turf && get_dist(dead_turf, source_turf) <= maxdistance)
			targets |= D

	// Snapshot everything the batches need now, rather than having each deferred
	// batch re-read src's current vars - set_mid_sounds() or a second attach call
	// could otherwise change cursound etc. out from under an in-flight batch queue.
	attach_loop_to_clients(targets, soundfile, vary, frequency, falloff, channel, filter_pref)

/// Sends the silent preload to `targets` a handful at a time, spread across a few ticks,
/// instead of hitting every nearby client's decoder in the same synchronous pass.
/datum/looping_sound/proc/attach_loop_to_clients(list/targets, soundfile, vary, frequency, falloff, channel, filter_pref)
	attach_batch_timer = null
	if(stopped || !targets?.len)
		return

	var/list/batch = list()
	while(targets.len && batch.len < LOOPING_SOUND_ATTACH_BATCH_SIZE)
		batch += targets[targets.len]
		targets.len--

	for(var/mob/M in batch)
		if(!M.client)
			continue
		if(filter_pref && !(M.client.prefs.toggles & filter_pref))
			continue
		M.playsound_local(null, soundfile, 0, vary, frequency, falloff, channel, FALSE, null, src)

	if(targets.len)
		attach_batch_timer = addtimer(CALLBACK(src, PROC_REF(attach_loop_to_clients), targets, soundfile, vary, frequency, falloff, channel, filter_pref), LOOPING_SOUND_ATTACH_BATCH_DELAY)

/datum/looping_sound/proc/begin_loop()
	sound_loop()
	START_PROCESSING(SSsoundloopers, src)

/datum/looping_sound/proc/on_stop()
//	play(end_sound)
	STOP_PROCESSING(SSsoundloopers, src)
	if(persistent_loop)
		GLOB.persistent_sound_loops -= src
	if(!direct)
		for(var/datum/weakref/listener_ref in thingshearing)
			var/mob/M = listener_ref.resolve()
			if (!M)
				continue
			if(M.client)
				var/list/L = M.client.played_loops[src]
				if(L)
					var/sound/SD = L["SOUND"]
					if(SD)
						M.stop_sound_channel(SD.channel)
					M.client.played_loops -= src
					thingshearing -= listener_ref
	else
		var/mob/P = parent
		if(P && P.client)
			P.stop_sound_channel(channel) //This is mostly used for weather

/datum/looping_sound/proc/set_parent(new_parent)
	if(parent)
		UnregisterSignal(parent, COMSIG_PARENT_QDELETING)
	if(new_parent)
		parent = new_parent
		RegisterSignal(new_parent, COMSIG_PARENT_QDELETING, PROC_REF(handle_parent_del))

/datum/looping_sound/proc/handle_parent_del(datum/source)
	SIGNAL_HANDLER
	set_parent(null)
