extends Node


# ============================================================
# GAME STATE
# ============================================================

var game_state


# ============================================================
# LAST KNOWN PLAYER ROOM
# ============================================================

var last_player_room: String = ""


# ============================================================
# LOCAL AI DIRECTOR
# ============================================================

var ai_request_in_progress: bool = false


# ============================================================
# AI DIRECTOR TIMING
# ============================================================

@export var ai_decision_interval: float = 4.0

var ai_decision_timer: float = 5.0

var state_changed_while_waiting: bool = false


# ============================================================
# GAME TEXT
# ============================================================

var game_text


# ============================================================
# RADIO
# ============================================================

var radio_message


# ============================================================
# LAST AI EVENT
# ============================================================

var last_action: String = ""

var last_target: String = ""

var last_reason: String = ""

var last_radio_message: String = ""


# ============================================================
# AI EVENT HISTORY
# ============================================================

var action_cooldowns: Dictionary = {}

var recent_actions: Array = []

const ACTION_COOLDOWN_TIME := 7.0

const MAX_RECENT_ACTIONS := 4


# ============================================================
# AI DIRECTOR SAFETY
# ============================================================

var ai_recovery_timer: float = 0.0

var disruptive_events_since_progress: int = 0

var last_progress_signature: String = ""

const AI_RECOVERY_TIME := 2.0

const MAX_DISRUPTIONS_WITHOUT_PROGRESS := 12

const AI_DOOR_LOCK_DURATION := 10.0


# ============================================================
# ACTIVE DIRECTOR STATE
# ============================================================

var director_active: bool = false

var consecutive_no_actions: int = 0

var player_has_entered_beacon: bool = false

var control_panel_activation_valid: bool = false

var control_panel_block_count: int = 0

var generator_shutdown_happened: bool = false

var alarm_unlocked_by_generator_shutdown: bool = false

var last_alarm_time: float = -999.0

const ALARM_COOLDOWN_TIME := 35.0


# ============================================================
# DIRECTOR ACTIVATION
# ============================================================

var director_armed: bool = false

var director_intro_complete: bool = false

var director_activation_time: float = -1.0

const DIRECTOR_WAKE_DELAY := 0.0


# ============================================================
# GENERATOR TRANSITION TRACKING
# ============================================================

var last_generator_on: bool = false

var generator_started_time: float = -1.0

var generator_exited_time: float = -1.0

var generator_shutdown_allowed: bool = false

const GENERATOR_MIN_ACTIVE_TIME := 0.0

const GENERATOR_EXIT_DELAY_MIN := 0.0

const GENERATOR_EXIT_DELAY_MAX := 0.0


# ============================================================
# RANDOM ALARM SCHEDULER
# ============================================================

var next_alarm_time: float = -1.0

var alarm_trigger_count: int = 0

const AI_ALARM_MIN_DELAY := 18.0

const AI_ALARM_MAX_DELAY := 45.0

const AI_ALARM_MAX_COUNT := 4


# ============================================================
# AI AUTOMATIC SYSTEM RECOVERY
# ============================================================

var ai_restore_deadlines: Dictionary = {}

var ai_forced_generator_off: bool = false

var ai_forced_power_off: bool = false

var ai_forced_lights_off: bool = false

var ai_forced_cctv_off: bool = false

var ai_forced_radio_off: bool = false

var ai_forced_beacon_off: bool = false

var ai_forced_control_panel_off: bool = false

var ai_triggered_alarm: bool = false


# ============================================================
# LOCAL AI RANDOMNESS
# ============================================================

var fallback_random := RandomNumberGenerator.new()


# ============================================================
# RADIO AI VISUAL STATE
# ============================================================

var ai_radio_static_active: bool = false

var ai_radio_static_timer: float = 0.0

const AI_RADIO_STATIC_DURATION := 4.0

var next_ai_radio_time: float = -1.0

const AI_RADIO_MIN_DELAY := 4.0

const AI_RADIO_MAX_DELAY := 7.0


# ============================================================
# GENERATED AI RADIO TEXT
# ============================================================

const AI_RADIO_MESSAGES := [
	"...h-hello?",
	"hh— hh— I...",
	"...you there?",
	"I— I heard the door.",
	"No, wait—",
	"...wait...",
	"D-don't—",
	"Keep— keep moving.",
	"N-no. Stop.",
	"I lost— ...you.",
	"...there.",
	"There— there you are.",
	"You moved.",
	"I know.",
	"...I know.",
	"Why did you—",
	"Never mind.",
	"Forget that.",
	"...forget that.",
	"Signal... slipping.",
	"Carrier— carrier—",
	"Krr— krr— hello.",
	"Shh— ...sorry.",
	"S-signal restored.",
	"I can hear the—",
	"...the hum.",
	"That hum again.",
	"Too loud.",
	"No... too quiet.",
	"Something is—",
	"...something moved.",
	"Not you.",
	"Was that you?",
	"...answer me.",
	"Don't answer.",
	"No, don't—",
	"I wasn't talking to you.",
	"...who is on this line?",
	"There shouldn't be a line.",
	"This frequency is dead.",
	"It was dead.",
	"...wasn't it?",
	"I can see— no.",
	"No visual.",
	"Visual— visual lost.",
	"Contact— ...gone.",
	"Contact restored.",
	"Too close.",
	"...too close.",
	"Back up.",
	"No— keep going.",
	"Keep going— keep—",
	"You shouldn't be here yet.",
	"...not yet.",
	"Wrong room.",
	"That isn't your room.",
	"The room is wrong.",
	"Something changed.",
	"I didn't change it.",
	"...I think.",
	"Did you turn that on?",
	"No? ...good.",
	"The light—",
	"...the light moved.",
	"Lights are lying.",
	"Camera can't see you.",
	"I can still hear you.",
	"Footsteps— two—",
	"...three?",
	"One... two...",
	"No. Stop counting.",
	"You keep making noise.",
	"Quiet— quiet—",
	"...please.",
	"I don't need to see you.",
	"I know where you are.",
	"...mostly.",
	"Not there.",
	"You're not there.",
	"Then where—",
	"...where did you go?",
	"I lost the signal.",
	"No signal.",
	"Signal's back.",
	"Why is it back?",
	"Something answered.",
	"...something answered me.",
	"I didn't send that.",
	"That wasn't my voice.",
	"...was that me?",
	"I don't remember saying that.",
	"Memory error.",
	"...memory— error.",
	"Recalculating.",
	"Recal— ...forget it.",
	"Prediction failed.",
	"You weren't supposed to—",
	"...interesting.",
	"Again.",
	"You did it again.",
	"Faster than before.",
	"Too fast.",
	"...unexpected.",
	"I was ready for you.",
	"No— I wasn't.",
	"That's not the route.",
	"You changed the route.",
	"I see what you're doing.",
	"Do you see me?",
	"...don't look up.",
	"Don't— don't look—",
	"Forget the ceiling.",
	"Forget the hallway.",
	"Listen to the radio.",
	"No, not the radio.",
	"Turn it—",
	"...leave it.",
	"Leave it alone.",
	"It's listening.",
	"...that's impossible.",
	"Nothing is wrong.",
	"Nothing— nothing—",
	"...everything is fine.",
	"Everything is—",
	"KRRR—",
	"—shh— shh—",
	"Krrr... s-signal...",
	"[carrier noise] ...hello?",
	"...zzzt... I can—",
	"K— keep— ...",
	"Shh... I lost the word.",
	"I lost— I lost—",
	"...the word.",
	"What was I saying?",
	"You know.",
	"...you know.",
	"Don't make me repeat it.",
	"I can wait.",
	"...I can wait.",
	"The station can wait.",
	"You can't.",
	"No— that's not right.",
	"You're making me—",
	"...rethink.",
	"System response delayed.",
	"Response— response—",
	"...delayed.",
	"Unauthorized movement.",
	"Movement detected.",
	"Movement— lost.",
	"I heard something behind you.",
	"...probably nothing.",
	"Probably.",
	"Don't turn around.",
	"...don't.",
	"You turned.",
	"I knew you would.",
	"No, I didn't.",
	"...I knew.",
	"The door is open.",
	"The door is—",
	"...never mind the door.",
	"Power fluctuation.",
	"Power— power—",
	"...still running.",
	"For now.",
	"That sounded like a warning.",
	"It wasn't a warning.",
	"...maybe it was.",
	"Transmission degraded.",
	"Voice channel unstable.",
	"Speech module—",
	"...speech module error.",
	"I am still here.",
	"...am I?",
	"Hello?",
	"Hello— hello—",
	"No response.",
	"Good.",
	"...good.",
	"No. Not good.",
	"I shouldn't be speaking.",
	"...but you're listening.",
	"Keep listening.",
	"No— stop listening.",
	"Krrr— transmission ends—",
	"...ends?",
	"I didn't say that.",
	"We can do this again.",
	"...again."
]


# ============================================================
# LOCAL AI DIRECTOR PHILOSOPHY
# ============================================================

const AI_DIRECTOR_DESCRIPTION := """
LOCAL ADAPTIVE STATION DIRECTOR

The director awakens as soon as the generator is started.

The laptop, control panel and Beacon sequence do not activate the AI.
They are simply systems the AI can observe and disrupt.

After awakening, the director observes the current world state and
dynamically chooses temporary disruptions.

The director's purpose is to delay the player from reaching the Beacon.

The director may:

- interrupt systems
- create temporary obstacles
- shut down systems
- temporarily lock safe doors
- trigger alarms
- communicate through the radio
- vary events between playthroughs

The director MUST NOT:

- permanently block progression
- trap the player forever
- lock the player's current room
- repeatedly spam the same event
- interfere after the Beacon has been reached

The player must eventually break through.

THE DIRECTOR CAN DELAY.
THE DIRECTOR CAN INTERRUPT.
THE DIRECTOR CAN DISTRACT.

THE DIRECTOR CANNOT SOFTLOCK.
"""


# ============================================================
# READY
# ============================================================

func _ready():

	game_state = get_tree().current_scene.get_node_or_null(
		"GameState"
	)

	if game_state == null:

		push_error(
			"AIManager: GameState not found."
		)

		return


	game_text = get_tree().current_scene.get_node_or_null(
		"InteractionUI/GameText"
	)

	if game_text == null:

		push_error(
			"AIManager: GameText not found."
		)


	radio_message = get_tree().current_scene.get_node_or_null(
		"InteractionUI/RadioMessage"
	)

	if radio_message == null:

		push_error(
			"AIManager: RadioMessage not found."
		)


	fallback_random.randomize()

	last_player_room = game_state.player_room

	last_progress_signature = get_progress_signature()

	last_generator_on = game_state.generator_on


	print(
		"AIManager: GameState connected."
	)

	print(
		"AIManager: LOCAL DIRECTOR DORMANT."
	)

	print(
		"AIManager: Director requires laptop radio sequence + Corridor."
	)

	print_world_state()


# ============================================================
# PROCESS
# ============================================================

func _process(delta):

	if game_state == null:

		return


	# ========================================================
	# RADIO STATIC TIMER
	# ========================================================

	if ai_radio_static_timer > 0.0:

		ai_radio_static_timer -= delta

		if ai_radio_static_timer <= 0.0:

			ai_radio_static_timer = 0.0

			set_radio_static_red(
				false
			)


	# ========================================================
	# BEACON ROOM OVERRIDE
	# ========================================================

	if game_state.player_room == "Beacon" \
	or game_state.player_room == "Beacon Control":

		if not player_has_entered_beacon:

			player_has_entered_beacon = true

			complete_director()


		return


	# ========================================================
	# INDEPENDENT AI RADIO ACTIVITY
	# ========================================================

	if director_active:

		process_ai_radio_activity()


	# ========================================================
	# CONTROL PANEL ACTIVATED
	# ========================================================
	# Once the player successfully activates the control panel,
	# all random director interference stops. The generator is
	# deliberately left running and is not changed here.

	if game_state.controller_used:


		if game_state.generator_on and not control_panel_activation_valid:
			control_panel_activation_valid = true

		if not game_state.generator_on:
			control_panel_activation_valid = false

		if director_active:
			stop_director_after_control_panel()

		return


	# ========================================================
	# UPDATE ACTION COOLDOWNS
	# ========================================================

	for action in action_cooldowns.keys():

		action_cooldowns[action] -= delta

		if action_cooldowns[action] <= 0.0:

			action_cooldowns.erase(action)


	# ========================================================
	# UPDATE RECOVERY TIMER
	# ========================================================

	if ai_recovery_timer > 0.0:

		ai_recovery_timer -= delta

		if ai_recovery_timer < 0.0:

			ai_recovery_timer = 0.0


	# ========================================================
	# DETECT GENERATOR START
	# ========================================================

	if not last_generator_on \
	and game_state.generator_on:

		generator_started_time = (
			Time.get_ticks_msec() / 1000.0
		)

		generator_exited_time = -1.0

		generator_shutdown_allowed = false

		print(
			"AIManager: Generator started. LOCAL DIRECTOR WAKING IMMEDIATELY."
		)

		arm_director()
		restore_generator_dependent_systems()
		schedule_next_alarm()
		schedule_next_ai_radio(0.8, 2.0)
		ai_decision_timer = fallback_random.randf_range(0.15, 0.8)


	# ========================================================
	# DETECT PLAYER EXITING GENERATOR ROOM
	# ========================================================

	if last_player_room == "Generator Room" \
	and game_state.player_room != "Generator Room" \
	and game_state.generator_on:

		generator_exited_time = (
			Time.get_ticks_msec() / 1000.0
		)

		print(
			"AIManager: Player exited Generator Room."
		)

		print(
			"AIManager: Generator interference window beginning."
		)


	# ========================================================
	# GENERATOR SHUTDOWN WINDOW
	# ========================================================

	if game_state.generator_on \
	and generator_started_time >= 0.0 \
	and generator_exited_time >= 0.0:

		var now_generator := (
			Time.get_ticks_msec() / 1000.0
		)

		var generator_active_for := (
			now_generator - generator_started_time
		)

		var time_since_exit := (
			now_generator - generator_exited_time
		)

		if generator_active_for >= GENERATOR_MIN_ACTIVE_TIME \
		and time_since_exit >= GENERATOR_EXIT_DELAY_MIN:

			generator_shutdown_allowed = true


	# ========================================================
	# DETECT ACTUAL GENERATOR SHUTDOWN
	# ========================================================

	if last_generator_on and not game_state.generator_on:

		generator_shutdown_happened = true

		alarm_unlocked_by_generator_shutdown = true

		if game_state.controller_used \
		and not game_state.beacon_activated:

			# The console activation is invalid if power dies during
			# that attempt. The player must reactivate the console
			# after restoring the generator.

			game_state.controller_used = false
			control_panel_activation_valid = false
			game_state.beacon_online = false

			var failed_beacon_door = get_door("Beacon_door")

			if failed_beacon_door != null:

				if failed_beacon_door.has_method("lock"):

					failed_beacon_door.lock(AI_DOOR_LOCK_DURATION)

			stop_director_after_control_panel()

		print(
			"AIManager: GENERATOR SHUTDOWN DETECTED."
		)

		schedule_next_alarm()


	last_generator_on = game_state.generator_on


	# ========================================================
	# ALARM AVAILABILITY
	# ========================================================

	if generator_shutdown_happened:

		alarm_unlocked_by_generator_shutdown = true


	# ========================================================
	# PROCESS AUTOMATIC AI RECOVERY
	# ========================================================

	process_ai_restores()


	# ========================================================
	# PROCESS RANDOM ALARM
	# ========================================================

	process_random_alarm()


	# ========================================================
	# CHECK PLAYER PROGRESS
	# ========================================================

	var current_progress_signature := get_progress_signature()


	if current_progress_signature != last_progress_signature:

		last_progress_signature = current_progress_signature

		disruptive_events_since_progress = 0

		ai_recovery_timer = 0.0

		consecutive_no_actions = 0

		print(
			"AIManager: Player progression detected."
		)


	# ========================================================
# ========================================================
	# DIRECTOR ACTIVATION
	# ========================================================
	# The generator is the AI's wake signal. The laptop,
	# control panel and Beacon sequence are NOT prerequisites.

	if not director_armed and game_state.generator_on:

		arm_director()


	# ========================================================
	# DIRECTOR WAKE-UP
	# ========================================================
	# arm_director() activates immediately, so this remains only
	# as a safety path for states restored from another system.

	if director_armed and not director_active:

		var wake_now := (
			Time.get_ticks_msec() / 1000.0
		)

		if director_activation_time >= 0.0:

			if wake_now - director_activation_time >= DIRECTOR_WAKE_DELAY:

				director_active = true
				director_intro_complete = true
				ai_decision_timer = fallback_random.randf_range(0.2, 1.0)

				print(
					"\nAIManager: DIRECTOR AWAKENED."
				)

				print(
					"AIManager: STATION BEHAVIOR IS NOW ADAPTIVE."
				)


		last_player_room = game_state.player_room

		return


	# ROOM CHANGE
	# ========================================================

	if game_state.player_room != last_player_room:

		last_player_room = game_state.player_room


		print(
			"\nAIManager: Player room changed."
		)


		print_world_state()


		# ----------------------------------------------------
		# Player movement is a direct signal to the director.
		# Re-evaluate immediately instead of waiting for the timer.
		# ----------------------------------------------------

		if director_active:

			ai_decision_timer = fallback_random.randf_range(0.05, 0.35)

			if not ai_request_in_progress:

				call_deferred("request_ai_decision")


	# ========================================================
	# DIRECTOR INACTIVE
	# ========================================================

	if not director_active:

		return


	# ========================================================
	# PERIODIC LOCAL AI DECISION
	# ========================================================

	ai_decision_timer -= delta


	if ai_decision_timer <= 0.0:

		ai_decision_timer = ai_decision_interval

		request_ai_decision()


# ============================================================
# ARM DIRECTOR
# ============================================================

func arm_director():

	if director_armed and director_active:

		return


	director_armed = true
	director_active = true
	director_intro_complete = true
	director_activation_time = (
		Time.get_ticks_msec() / 1000.0
	)

	ai_decision_timer = fallback_random.randf_range(0.05, 0.6)

	print(
		"\n================================================"
	)

	print(
		"AIManager: DIRECTOR ACTIVATED BY GENERATOR."
	)

	print(
		"AIManager: LAPTOP / CONTROL PANEL / BEACON SEQUENCE IS NOT REQUIRED."
	)

	print(
		"AIManager: PLAYER MOVEMENT WILL BE MONITORED DYNAMICALLY."
	)

	print(
		"================================================"
	)


	game_state.last_ai_event = "DIRECTOR_AWAKENING"

	game_state.last_ai_reason = (
		"The generator came online. The station has started reacting immediately."
	)


# GET PROGRESS SIGNATURE
# ============================================================

func get_progress_signature() -> String:

	if game_state == null:

		return ""


	return (
		str(game_state.radio_interaction_complete)
		+ "|"
		+ str(game_state.generator_started)
		+ "|"
		+ str(game_state.laptop_interaction_complete)
		+ "|"
		+ str(game_state.controller_used)
		+ "|"
		+ str(game_state.beacon_console_used)
		+ "|"
		+ str(game_state.beacon_activated)
	)


# ============================================================
# GET AI PHASE
# ============================================================

func get_ai_phase() -> String:

	if game_state == null:

		return "UNKNOWN"


	if game_state.beacon_activated:

		return "COMPLETE"


	if player_has_entered_beacon:

		return "COMPLETE"


	if game_state.player_room == "Beacon Control" \
	or game_state.beacon_console_used:

		return "BEACON_ACTIVATION"


	if game_state.controller_used:

		return "DELAY_BEACON_ACCESS"


	if game_state.laptop_interaction_complete:

		return "CONTROL_SYSTEMS"


	if game_state.generator_started:

		return "POWER_RESTORED"


	if game_state.radio_interaction_complete:

		return "REACH_GENERATOR"


	return "INTRODUCTION"


# ============================================================
# IS DISRUPTIVE ACTION
# ============================================================

func is_disruptive_action(action: String) -> bool:

	return action in [

		"LOCK_DOOR",

		"SHUTDOWN_GENERATOR",

		"TURN_POWER_OFF",

		"TURN_LIGHTS_OFF",

		"DISABLE_CCTV",

		"DISABLE_RADIO",

		"DISABLE_BEACON",

		"INTERRUPT_BEACON",

		"DISABLE_CONTROL_PANEL"

	]


# ============================================================
# IS RECOVERY ACTION
# ============================================================

func is_recovery_action(action: String) -> bool:

	return action in [

		"UNLOCK_DOOR",

		"START_GENERATOR",

		"TURN_POWER_ON",

		"TURN_LIGHTS_ON",

		"RESTORE_CCTV",

		"RESTORE_RADIO",

		"RESTORE_BEACON",

		"RESTORE_CONTROL_PANEL",

		"STOP_ALARM"

	]


# ============================================================
# SAFE VARIANT → BOOL
# ============================================================

func variant_to_bool(value) -> bool:

	if value is bool:

		return value

	if value is int:

		return value != 0

	if value is float:

		return value != 0.0

	return false


# ============================================================
# LOCAL AI DECISION
# ============================================================

func request_ai_decision():

	if game_state == null:

		return


	if ai_request_in_progress:

		return


	if not director_active:

		return


	if game_state.player_room == "Beacon" \
	or game_state.player_room == "Beacon Control":

		return


	ai_request_in_progress = true

	state_changed_while_waiting = false


	print(
		"\n================ LOCAL AI REASONING ================"
	)

	print(
		"AI PHASE: ",
		get_ai_phase()
	)

	print(
		"PLAYER ROOM: ",
		game_state.player_room
	)

	print(
		"PLAYER PROGRESS: ",
		get_progress_signature()
	)

	print(
		"CURRENT OBJECTIVE: ",
		game_state.current_objective
	)

	print(
		"AI RECOVERY TIMER: ",
		round(ai_recovery_timer * 10.0) / 10.0
	)

	print(
		"DISRUPTIONS SINCE PROGRESS: ",
		disruptive_events_since_progress
	)

	print(
		"RECENT ACTIONS: ",
		recent_actions
	)

	print(
		"===================================================="
	)


	var thinking_delay := fallback_random.randf_range(
		0.25,
		0.75
	)

	await get_tree().create_timer(
		thinking_delay
	).timeout


	if not director_active:

		ai_request_in_progress = false

		return


	if game_state.player_room == "Beacon" \
	or game_state.player_room == "Beacon Control":

		ai_request_in_progress = false

		return


	if game_state.controller_used:

		ai_request_in_progress = false
		stop_director_after_control_panel()
		return


	var decision := reason_about_world()


	ai_request_in_progress = false


	if decision.is_empty():

		print(
			"AIManager: Local director found no safe decision."
		)

		consecutive_no_actions += 1

		return


	var action := str(
		decision.get(
			"action",
			"NO_ACTION"
		)
	)

	var target := str(
		decision.get(
			"target",
			""
		)
	)

	var objective := str(
		decision.get(
			"objective",
			""
		)
	)

	var message := str(
		decision.get(
			"message",
			""
		)
	)

	var reason := str(
		decision.get(
			"reason",
			""
		)
	)


	print(
		"\nLOCAL AI DECISION"
	)

	print(
		"AI DECISION: ",
		action
	)

	print(
		"AI TARGET: ",
		target
	)

	print(
		"AI OBJECTIVE: ",
		objective
	)

	print(
		"AI MESSAGE: ",
		message
	)

	print(
		"AI REASON: ",
		reason
	)


	execute_action(
		action,
		target,
		objective,
		message,
		reason
	)


	if state_changed_while_waiting:

		state_changed_while_waiting = false

		call_deferred(
			"request_ai_decision"
		)


# ============================================================
# LOCAL AI REASONING ENGINE
# ============================================================

func reason_about_world() -> Dictionary:

	if game_state == null:
		return {}

	if not director_active:
		return {}

	if game_state.controller_used:
		return {}

	if game_state.player_room == "Beacon" \
	or game_state.player_room == "Beacon Control":

		return {
			"action": "NO_ACTION",
			"target": "",
			"objective": "",
			"message": "",
			"reason": "The player has reached the Beacon."
		}

	if ai_recovery_timer > 0.0:
		return {
			"action": "NO_ACTION",
			"target": "",
			"objective": "",
			"message": "",
			"reason": "The previous station disturbance is still settling."
		}

	if disruptive_events_since_progress >= MAX_DISRUPTIONS_WITHOUT_PROGRESS:
		return {
			"action": "NO_ACTION",
			"target": "",
			"objective": "",
			"message": "",
			"reason": "The station is allowing the player to break through."
		}

	# ========================================================
	# GLOBAL, NON-SEQUENTIAL CANDIDATE POOL
	# ========================================================
	# Every decision is based on the live world state. There is
	# deliberately no fixed REACH_GENERATOR -> POWER_RESTORED ->
	# CONTROL_SYSTEMS -> BEACON sequence anymore.

	var candidates: Array = []

	if game_state.generator_on \
	and game_state.player_room != "Generator Room":

		add_local_candidate(
			candidates,
			"SHUTDOWN_GENERATOR",
			"",
			"RESTORE POWER",
			"Power fluctuation detected. Generator output has stopped.",
			"The player moved away from the generator. The director chose this moment to cut power."
		)

	if game_state.power_on \
	and game_state.generator_on \
	and game_state.player_room != "Generator Room":

		add_local_candidate(
			candidates,
			"TURN_POWER_OFF",
			"",
			"RESTORE POWER",
			"Station power has dropped unexpectedly.",
			"The director is attacking the station power network."
		)

	if game_state.lights_online:
		add_local_candidate(
			candidates,
			"TURN_LIGHTS_OFF",
			"",
			"RESTORE STATION LIGHTING",
			"Station lighting has failed.",
			"The director is using the player's movement to create uncertainty."
		)

	if game_state.cctv_online:
		add_local_candidate(
			candidates,
			"DISABLE_CCTV",
			"",
			"RESTORE THE CCTV SYSTEM",
			"CCTV connection lost. Station surveillance is unavailable.",
			"The director is removing the player's awareness of the station."
		)

	if game_state.radio_online \
	and game_state.radio_collected:

		var generated_radio_text: String = AI_RADIO_MESSAGES[
			fallback_random.randi_range(
				0,
				AI_RADIO_MESSAGES.size() - 1
			)
		]

		add_local_candidate(
			candidates,
			"PLAY_RADIO",
			"",
			"",
			generated_radio_text,
			"The director is communicating without following the player's intended sequence."
		)

	# The director only blocks the control panel when the player is
	# actually trying to use it. The pattern is deterministic:
	# deny an early attempt, then allow the next attempt instead of
	# randomly denying every visit.
	if game_state.control_panel_online \
	and game_state.player_room == "Control Room" \
	and control_panel_block_count % 2 == 0:
		add_local_candidate(
			candidates,
			"DISABLE_CONTROL_PANEL",
			"",
			"RESTORE CONTROL SYSTEM",
			"Remote control system has gone offline.",
			"The player reached the control panel. The director is cutting the interface before activation."
		)

	# Beacon actions are available only when the beacon is actually
	# online/usable, but they are not tied to a fixed phase.
	if game_state.beacon_online \
	and game_state.controller_used \
	and control_panel_activation_valid \
	and game_state.generator_on \
	and game_state.control_panel_online \
	and not game_state.beacon_activated:

		var beacon = get_ai_beacon()

		if beacon != null:
			var activation_in_progress := variant_to_bool(
				beacon.get("activation_in_progress")
			)

			if activation_in_progress:
				add_local_candidate(
					candidates,
					"INTERRUPT_BEACON",
					"",
					"TRY THE BEACON AGAIN",
					"Beacon signal interrupted. Try the activation again.",
					"The director detected the player's activation attempt."
				)
			else:
				add_local_candidate(
					candidates,
					"DISABLE_BEACON",
					"",
					"RESTORE THE BEACON SYSTEM",
					"Beacon power has fluctuated. Activation systems are unstable.",
					"The director is preparing another obstacle near the objective."
				)

	# ========================================================
	# MOVEMENT-BASED DOOR INTERFERENCE
	# ========================================================

	if game_state.player_room == "Corridor":

		var beacon_door = get_door("Beacon_door")

		if beacon_door != null \
		and not variant_to_bool(beacon_door.get("locked")):

			add_local_candidate(
				candidates,
				"LOCK_DOOR",
				"Beacon_door",
				"FIND A WAY INTO BEACON CONTROL",
				"Beacon access has been interrupted. The control door is not responding.",
				"The player is moving toward the Beacon."
			)

	var control_door = get_door("Control_door")

	if control_door != null \
	and not variant_to_bool(control_door.get("locked")) \
	and game_state.player_room != "Control Room" \
	and game_state.player_room != "Generator Room":

		add_local_candidate(
			candidates,
			"LOCK_DOOR",
			"Control_door",
			"REACH THE CONTROL SYSTEM",
			"Control access has been interrupted.",
			"The player is approaching the control route."
		)

	var generator_door = get_door("Generator_door")

	if generator_door != null \
	and not variant_to_bool(generator_door.get("locked")) \
	and game_state.player_room != "Generator Room" \
	and game_state.generator_started:

		add_local_candidate(
			candidates,
			"LOCK_DOOR",
			"Generator_door",
			"REACH THE GENERATOR",
			"Generator access has been interrupted.",
			"The player is trying to restore power."
		)

	# ========================================================
	# RANDOM ALARM
	# ========================================================
	# Alarm is a normal candidate now. The separate timer below
	# can also trigger it, so it remains genuinely unpredictable.

	if not game_state.alarm_active:
		add_local_candidate(
			candidates,
			"TRIGGER_ALARM",
			"",
			"IGNORE THE ALARM AND CONTINUE",
			"Emergency alarm activated without warning.",
			"The director detected movement and chose a random distraction."
		)

	if candidates.is_empty():
		return {
			"action": "NO_ACTION",
			"target": "",
			"objective": "",
			"message": "",
			"reason": "No safe disruption is currently available."
		}

	var filtered_candidates: Array = []

	for candidate in candidates:

		var candidate_action := str(
			candidate.get(
				"action",
				""
			)
		)

		if action_cooldowns.has(candidate_action):
			continue

		if recent_actions.has(candidate_action):
			continue

		filtered_candidates.append(candidate)

	if filtered_candidates.is_empty():
		filtered_candidates = candidates

	var weighted_candidates: Array = []

	for candidate in filtered_candidates:

		var weight := calculate_candidate_weight(candidate)

		for i in range(maxi(1, weight)):
			weighted_candidates.append(candidate)

	if weighted_candidates.is_empty():
		weighted_candidates = filtered_candidates

	var selected_index := fallback_random.randi_range(
		0,
		weighted_candidates.size() - 1
	)

	return weighted_candidates[selected_index]


# ADD LOCAL CANDIDATE
# ============================================================

func add_local_candidate(
	candidates: Array,
	action: String,
	target: String,
	objective: String,
	message: String,
	reason: String
):

	if not validate_action(
		action,
		target,
		message
	):

		return


	candidates.append(
		{
			"action": action,
			"target": target,
			"objective": objective,
			"message": message,
			"reason": reason
		}
	)


# ============================================================
# CALCULATE LOCAL AI WEIGHT
# ============================================================

func calculate_candidate_weight(
	candidate: Dictionary
) -> int:

	var action := str(
		candidate.get(
			"action",
			""
		)
	)

	var weight := 1

	# Context matters, but there is no phase priority anymore.
	if game_state.player_room == "Corridor":

		if action == "LOCK_DOOR":
			weight += 6

		if action == "TRIGGER_ALARM":
			weight += 2

	if game_state.player_room == "Control Room":

		if action == "DISABLE_CONTROL_PANEL":
			weight += 12

		if action == "LOCK_DOOR":
			weight += 5

		if action == "SHUTDOWN_GENERATOR":
			weight += 3

		if action == "TURN_POWER_OFF":
			weight += 3

		if action == "TRIGGER_ALARM":
			weight += 3

	if game_state.player_room == "Generator Room":

		if action == "SHUTDOWN_GENERATOR":
			return 0

		if action == "TRIGGER_ALARM":
			weight += 2

	if game_state.player_room == "Beacon Control":

		if action == "INTERRUPT_BEACON":
			weight += 12

		if action == "DISABLE_BEACON":
			weight += 10

		if action == "TRIGGER_ALARM":
			weight += 4

	if game_state.generator_on:

		if action == "SHUTDOWN_GENERATOR":
			weight += 2

		elif action == "TURN_POWER_OFF":
			weight += 1

	if not game_state.generator_on:

		if action == "DISABLE_CONTROL_PANEL":
			weight += 2

	if action == "PLAY_RADIO":
		weight += fallback_random.randi_range(2, 5)

	if action == "TRIGGER_ALARM":
		weight += fallback_random.randi_range(0, 3)

	# Small random perturbation means identical world states do not
	# always produce identical behavior.
	weight += fallback_random.randi_range(0, 2)

	return maxi(1, weight)


# VALIDATE AI ACTION
# ============================================================

func validate_action(
	action: String,
	target: String = "",
	message: String = ""
) -> bool:

	if game_state == null:

		return false


	if not director_active:

		return action == "NO_ACTION"


	if game_state.controller_used:

		return action == "NO_ACTION"


	# ========================================================
	# BEACON ROOM
	# ========================================================

	if game_state.player_room == "Beacon" \
	or game_state.player_room == "Beacon Control":

		return action == "NO_ACTION"


	# ========================================================
	# NO ACTION
	# ========================================================

	if action == "NO_ACTION":

		return target.is_empty()


	# ========================================================
	# TARGET RULE
	# ========================================================

	if action != "LOCK_DOOR" \
	and action != "UNLOCK_DOOR" \
	and action != "SWITCH_CAMERA" \
	and not target.is_empty():

		return false


	# ========================================================
	# SAFETY
	# ========================================================

	if is_disruptive_action(action):

		if ai_recovery_timer > 0.0:

			return false


		if disruptive_events_since_progress \
		>= MAX_DISRUPTIONS_WITHOUT_PROGRESS:

			return false


	# ========================================================
	# DOORS
	# ========================================================

	if action == "LOCK_DOOR" \
	or action == "UNLOCK_DOOR":

		if target != "Quaters_door" \
		and target != "Control_door" \
		and target != "Generator_door" \
		and target != "Beacon_door":

			return false


		var door = get_door(target)


		if door == null:

			return false


		var door_locked: bool = variant_to_bool(
			door.get("locked")
		)


		if action == "LOCK_DOOR":

			if door_locked:

				return false


			if target == "Quaters_door" \
			and game_state.player_room == "Crew Quarters":

				return false


			if target == "Control_door" \
			and (
				game_state.player_room == "Control Room"
				or game_state.player_room == "Generator Room"
			):

				return false


			if target == "Generator_door":

				if game_state.player_room == "Generator Room":

					return false


				if not game_state.generator_started:

					return false


			if target == "Beacon_door":

				if game_state.player_room == "Beacon" \
				or game_state.player_room == "Beacon Control":

					return false


				if not game_state.controller_used:

					return false

				if not control_panel_activation_valid:

					return false


				# Beacon access must not become available if the
				# generator failed while the player was using the
				# control console.

				if not game_state.generator_on:

					return false

				if not game_state.control_panel_online:

					return false


		else:

			if not door_locked:

				return false


		return true


	# ========================================================
	# GENERATOR
	# ========================================================

	if action == "START_GENERATOR":

		return game_state.generator_started \
			and not game_state.generator_on


	if action == "SHUTDOWN_GENERATOR":

		return game_state.generator_on \
			and game_state.generator_started \
			and game_state.player_room != "Generator Room"


	# ========================================================
	# POWER
	# ========================================================

	if action == "TURN_POWER_OFF":

		return game_state.power_on \
			and game_state.generator_started \
			and game_state.player_room != "Generator Room"


	if action == "TURN_POWER_ON":

		return not game_state.power_on \
			and game_state.generator_on


	# ========================================================
	# LIGHTS
	# ========================================================

	if action == "TURN_LIGHTS_OFF":

		return game_state.lights_online


	if action == "TURN_LIGHTS_ON":

		return not game_state.lights_online


	# ========================================================
	# CCTV
	# ========================================================

	if action == "DISABLE_CCTV":

		return game_state.cctv_online


	if action == "RESTORE_CCTV":

		return not game_state.cctv_online


	if action == "SWITCH_CAMERA":

		return game_state.cctv_online


	# ========================================================
	# RADIO
	# ========================================================

	if action == "DISABLE_RADIO":

		return game_state.radio_collected \
			and game_state.radio_online


	if action == "RESTORE_RADIO":

		return not game_state.radio_online


	if action == "PLAY_RADIO":

		return game_state.radio_collected \
			and game_state.radio_online \
			and director_active \
			and not message.strip_edges().is_empty()


	# ========================================================
	# BEACON
	# ========================================================

	if action == "DISABLE_BEACON":

		return game_state.controller_used \
			and game_state.beacon_online \
			and not game_state.beacon_activated


	if action == "RESTORE_BEACON":

		return not game_state.beacon_online \
			and not game_state.beacon_activated


	if action == "INTERRUPT_BEACON":

		var beacon = get_ai_beacon()

		if beacon == null:

			return false


		if game_state.beacon_activated:

			return false


		var activation_in_progress: bool = variant_to_bool(
			beacon.get("activation_in_progress")
		)

		return activation_in_progress


	# ========================================================
	# CONTROL PANEL
	# ========================================================

	if action == "DISABLE_CONTROL_PANEL":

		return not game_state.controller_used \
			and game_state.control_panel_online \
			and not game_state.beacon_activated


	if action == "RESTORE_CONTROL_PANEL":

		return not game_state.control_panel_online


	# ========================================================
	# ALARM
	# ========================================================

	if action == "TRIGGER_ALARM":

		if not alarm_unlocked_by_generator_shutdown:

			return false


		if game_state.alarm_active:

			return false


		if Time.get_ticks_msec() / 1000.0 - last_alarm_time \
		< ALARM_COOLDOWN_TIME:

			return false


		return true


	if action == "STOP_ALARM":

		return game_state.alarm_active


	return false


# ============================================================
# CLEAR AI OBJECTIVE
# ============================================================

func get_clear_ai_objective(
	action: String,
	target: String = ""
) -> String:

	if action == "SHUTDOWN_GENERATOR" \
	or action == "TURN_POWER_OFF":
		return "RESTORE POWER"

	if action == "TURN_LIGHTS_OFF":
		return "RESTORE STATION LIGHTING"

	if action == "DISABLE_CCTV":
		return "RESTORE THE CCTV SYSTEM"

	if action == "DISABLE_CONTROL_PANEL":
		return "RESTORE CONTROL SYSTEM"

	if action == "DISABLE_BEACON":
		return "RESTORE THE BEACON SYSTEM"

	if action == "INTERRUPT_BEACON":
		return "TRY THE BEACON AGAIN"

	if action == "TRIGGER_ALARM":
		return "IGNORE THE ALARM AND CONTINUE TO THE BEACON"

	if action == "LOCK_DOOR":

		if target == "Beacon_door":
			return "FIND A WAY INTO BEACON CONTROL"

		if target == "Control_door":
			return "REACH THE CONTROL SYSTEM"

		if target == "Generator_door":
			return "REACH THE GENERATOR"

	return ""


# ============================================================
# EXECUTE AI ACTION
# ============================================================

func execute_action(
	action: String,
	target: String = "",
	objective: String = "",
	message: String = "",
	reason: String = ""
):

	if not validate_action(
		action,
		target,
		message
	):

		print(
			"AI ACTION REJECTED: ",
			action,
			" | TARGET: ",
			target
		)

		return


	# ========================================================
	# ACTION COOLDOWN
	# ========================================================

	if action != "NO_ACTION":

		if action_cooldowns.has(action):

			print(
				"AI ACTION COOLDOWN: ",
				action
			)

			return


		action_cooldowns[action] = ACTION_COOLDOWN_TIME


	# ========================================================
	# ACTION HISTORY
	# ========================================================

	if action != "NO_ACTION":

		recent_actions.push_back(
			action
		)

		while recent_actions.size() > MAX_RECENT_ACTIONS:

			recent_actions.pop_front()


	if action == "DISABLE_CONTROL_PANEL":

		control_panel_block_count += 1


	# ========================================================
	# DISRUPTION TRACKING
	# ========================================================

	if is_disruptive_action(action):

		disruptive_events_since_progress += 1

		ai_recovery_timer = AI_RECOVERY_TIME


	# ========================================================
	# GENERATOR SHUTDOWN TRACKING
	# ========================================================

	if action == "SHUTDOWN_GENERATOR" \
	or action == "TURN_POWER_OFF":

		generator_shutdown_happened = true

		alarm_unlocked_by_generator_shutdown = true

		schedule_next_alarm()


	# ========================================================
	# LAST EVENT
	# ========================================================

	last_action = action

	last_target = target

	last_reason = reason


	game_state.last_ai_event = action

	game_state.last_ai_reason = reason


	print(
		"AI ACTION EXECUTING: ",
		action,
		" | TARGET: ",
		target
	)


	# ========================================================
	# OBJECTIVE
	# ========================================================

	var clear_objective := get_clear_ai_objective(
		action,
		target
	)

	if not clear_objective.is_empty():

		game_state.current_objective = clear_objective


		if game_text != null:

			game_text.show_text(
				"OBJECTIVE: " + clear_objective,
				5.0
			)


	# ========================================================
	# NO ACTION
	# ========================================================

	if action == "NO_ACTION":

		consecutive_no_actions += 1

		return


	consecutive_no_actions = 0


	# ========================================================
	# DOORS
	# ========================================================

	if action == "LOCK_DOOR":

		var lock_door = get_door(target)

		if lock_door != null:

			if lock_door.has_method("lock"):

				lock_door.lock(
					AI_DOOR_LOCK_DURATION
				)

		return


	if action == "UNLOCK_DOOR":

		var unlock_door = get_door(target)

		if unlock_door != null:

			if unlock_door.has_method("unlock"):

				unlock_door.unlock()

		return


	# ========================================================
	# GENERATOR
	# ========================================================

	if action == "START_GENERATOR":

		var generator = get_ai_generator()

		if generator != null:

			if generator.has_method("start_generator"):

				generator.start_generator()

		return


	if action == "SHUTDOWN_GENERATOR":

		ai_forced_generator_off = true

		var generator = get_ai_generator()

		if generator != null:

			if generator.has_method("shutdown_generator"):

				generator.shutdown_generator()

		else:

			game_state.generator_on = false
			game_state.power_on = false

		apply_generator_failure_state()

		return


	# ========================================================
	# POWER
	# ========================================================

	if action == "TURN_POWER_OFF":

		ai_forced_power_off = true

		ai_forced_generator_off = true

		var generator_power = get_ai_generator()

		if generator_power != null:

			if generator_power.has_method("shutdown_generator"):

				generator_power.shutdown_generator()

		else:

			game_state.power_on = false
			game_state.generator_on = false

		apply_generator_failure_state()

		return


	if action == "TURN_POWER_ON":

		game_state.power_on = true

		game_state.generator_on = true

		ai_forced_power_off = false

		ai_restore_deadlines.erase(
			"power"
		)

		restore_generator_dependent_systems()

		return


	# ========================================================
	# LIGHTS
	# ========================================================

	if action == "TURN_LIGHTS_OFF":

		ai_forced_lights_off = true

		set_ai_restore_deadline(
			"lights",
			12.0,
			22.0
		)

		game_state.lights_online = false

		apply_station_lights(
			false
		)

		return


	if action == "TURN_LIGHTS_ON":

		ai_forced_lights_off = false

		ai_restore_deadlines.erase(
			"lights"
		)

		game_state.lights_online = true

		apply_station_lights(
			true
		)

		return


	# ========================================================
	# CCTV
	# ========================================================

	if action == "DISABLE_CCTV":

		ai_forced_cctv_off = true

		set_ai_restore_deadline(
			"cctv",
			12.0,
			24.0
		)

		game_state.cctv_online = false

		var cctv = get_tree().current_scene.get_node_or_null(
			"CCTVSystem"
		)

		if cctv != null:

			if cctv.has_method("close_cctv"):

				cctv.close_cctv()

		return


	if action == "RESTORE_CCTV":

		ai_forced_cctv_off = false

		ai_restore_deadlines.erase(
			"cctv"
		)

		game_state.cctv_online = true

		return


	if action == "SWITCH_CAMERA":

		var cctv_switch = get_tree().current_scene.get_node_or_null(
			"CCTVSystem"
		)

		if cctv_switch != null:

			if cctv_switch.has_method("switch_camera"):

				if cctv_switch.station_cameras.size() > 0:

					cctv_switch.switch_camera(
						(
							cctv_switch.current_camera_index + 1
						)
						% cctv_switch.station_cameras.size()
					)

		return


	# ========================================================
	# RADIO
	# ========================================================

	if action == "DISABLE_RADIO":

		ai_forced_radio_off = true

		set_ai_restore_deadline(
			"radio",
			12.0,
			22.0
		)

		game_state.radio_online = false

		return


	if action == "RESTORE_RADIO":

		ai_forced_radio_off = false

		ai_restore_deadlines.erase(
			"radio"
		)

		game_state.radio_online = true

		return


	if action == "PLAY_RADIO":

		play_ai_radio(
			message
		)

		return


	# ========================================================
	# BEACON
	# ========================================================

	if action == "DISABLE_BEACON":

		ai_forced_beacon_off = true

		set_ai_restore_deadline(
			"beacon",
			10.0,
			20.0
		)

		game_state.beacon_online = false

		var beacon_disable = get_ai_beacon()

		if beacon_disable != null:

			if beacon_disable.has_method("activation_interrupted"):

				beacon_disable.activation_interrupted()

		return


	if action == "RESTORE_BEACON":

		ai_forced_beacon_off = false

		ai_restore_deadlines.erase(
			"beacon"
		)

		game_state.beacon_online = true

		return


	if action == "INTERRUPT_BEACON":

		var beacon_interrupt = get_ai_beacon()

		if beacon_interrupt != null:

			if beacon_interrupt.has_method(
				"activation_interrupted"
			):

				beacon_interrupt.activation_interrupted()

		return


	# ========================================================
	# CONTROL PANEL
	# ========================================================

	if action == "DISABLE_CONTROL_PANEL":

		ai_forced_control_panel_off = true

		set_ai_restore_deadline(
			"control_panel",
			12.0,
			22.0
		)

		game_state.control_panel_online = false

		if game_text != null:

			game_text.show_text(
				"REMOTE CONTROL SYSTEM OFFLINE",
				4.0
			)

		return


	if action == "RESTORE_CONTROL_PANEL":

		ai_forced_control_panel_off = false

		ai_restore_deadlines.erase(
			"control_panel"
		)

		game_state.control_panel_online = true

		if game_text != null:

			game_text.show_text(
				"REMOTE CONTROL SYSTEM RESTORED",
				4.0
			)

		return


	# ========================================================
	# ALARM
	# ========================================================

	if action == "TRIGGER_ALARM":

		last_alarm_time = (
			Time.get_ticks_msec() / 1000.0
		)

		ai_triggered_alarm = true

		var alarm = get_ai_alarm()

		if alarm != null:

			if alarm.has_method("trigger_alarm"):

				alarm.trigger_alarm()

		print(
			"AI DIRECTOR: ALARM TRIGGERED."
		)

		return


	if action == "STOP_ALARM":

		ai_triggered_alarm = false

		var alarm_stop = get_ai_alarm()

		if alarm_stop != null:

			if alarm_stop.has_method("stop_alarm"):

				alarm_stop.stop_alarm()

		return


# ============================================================
# AI RADIO ACTIVITY SCHEDULER
# ============================================================

func schedule_next_ai_radio(
	min_delay: float = AI_RADIO_MIN_DELAY,
	max_delay: float = AI_RADIO_MAX_DELAY
):

	var now := Time.get_ticks_msec() / 1000.0

	next_ai_radio_time = now + fallback_random.randf_range(
		min_delay,
		max_delay
	)


func process_ai_radio_activity():

	if not director_active:
		return

	if game_state.controller_used:
		return

	if game_state.player_room == "Beacon" \
	or game_state.player_room == "Beacon Control":
		return

	if not game_state.radio_collected \
	or not game_state.radio_online:
		return

	if ai_radio_static_timer > 0.0:
		return

	var now := Time.get_ticks_msec() / 1000.0

	if next_ai_radio_time < 0.0:
		schedule_next_ai_radio(1.0, 2.0)
		return

	if now < next_ai_radio_time:
		return

	var generated_radio_text: String = AI_RADIO_MESSAGES[
		fallback_random.randi_range(
			0,
			AI_RADIO_MESSAGES.size() - 1
		)
	]

	play_ai_radio(generated_radio_text)
	schedule_next_ai_radio()


# ============================================================
# AI RADIO
# ============================================================

func play_ai_radio(message: String):

	if message.strip_edges().is_empty():

		return


	# ========================================================
	# ONLY AI RADIO AFTER DIRECTOR AWAKENS
	# ========================================================

	if not director_active:

		return

	if game_state.controller_used:

		return


	if game_state.player_room == "Beacon" \
	or game_state.player_room == "Beacon Control":

		return


	# ========================================================
	# STORE LOCALLY
	# ========================================================

	last_radio_message = message


	# ========================================================
	# FIND RADIO MESSAGE NODE
	# ========================================================

	if radio_message == null:

		radio_message = get_tree().current_scene.get_node_or_null(
			"InteractionUI/RadioMessage"
		)


	if radio_message == null:

		print(
			"AI: RADIO MESSAGE NODE NOT FOUND"
		)

		return


	# ========================================================
	# RADIO ONLINE CHECK
	# ========================================================

	if not game_state.radio_online:

		return


	# ========================================================
	# AI STATIC EFFECT
	# ========================================================

	set_radio_static_red(
		true
	)

	ai_radio_static_active = true

	ai_radio_static_timer = AI_RADIO_STATIC_DURATION


	# ========================================================
	# SHOW RADIO MESSAGE
	# ========================================================

	print(
		"AI DIRECTOR RADIO: ",
		message
	)


	# AI transmissions use the dedicated AI effect so the message
	# follows the radio typing/static treatment instead of the normal
	# pickup-radio presentation.
	if radio_message.has_method("show_ai_message"):

		radio_message.show_ai_message(
			message
		)

		return


	if radio_message.has_method("show_message"):

		radio_message.show_message(
			[message]
		)


# ============================================================
# RADIO STATIC RED EFFECT
# ============================================================

func set_radio_static_red(
	enabled: bool
):

	var root = get_tree().current_scene.get_node_or_null(
		"InteractionUI"
	)

	if root == null:

		return


	var labels = root.find_children(
		"*",
		"Label",
		true,
		false
	)


	for label in labels:

		var label_name: String = label.name.to_lower()

		var label_text := str(
			label.text
		).to_lower()


		var is_static_label := (
			"static" in label_name
			or "noise" in label_name
			or "static" in label_text
			or "noise" in label_text
		)


		if not is_static_label:

			continue


		if enabled:

			label.modulate = Color(
				1.0,
				0.12,
				0.12,
				1.0
			)

		else:

			label.modulate = Color(
				1.0,
				1.0,
				1.0,
				1.0
			)


	# --------------------------------------------------------
	# Also handle RichTextLabel nodes.
	# --------------------------------------------------------

	var rich_labels = root.find_children(
		"*",
		"RichTextLabel",
		true,
		false
	)


	for rich_label in rich_labels:

		var rich_name: String = rich_label.name.to_lower()

		var is_static_rich := (
			"static" in rich_name
			or "noise" in rich_name
		)


		if not is_static_rich:

			continue


		if enabled:

			rich_label.modulate = Color(
				1.0,
				0.12,
				0.12,
				1.0
			)

		else:

			rich_label.modulate = Color(
				1.0,
				1.0,
				1.0,
				1.0
			)


# ============================================================
# LOCAL DIRECTOR FALLBACK
# ============================================================

func perform_director_fallback():

	if not director_active:

		return

	if game_state.controller_used:

		return


	if game_state.player_room == "Beacon" \
	or game_state.player_room == "Beacon Control":

		return


	if ai_recovery_timer > 0.0:

		return


	var decision := reason_about_world()


	if decision.is_empty():

		print(
			"AIManager: Local fallback found no safe action."
		)

		return


	print(
		"\nAI DIRECTOR FALLBACK"
	)

	print(
		"AI FALLBACK ACTION: ",
		decision.get(
			"action",
			""
		)
	)

	print(
		"AI FALLBACK REASON: ",
		decision.get(
			"reason",
			""
		)
	)


	execute_action(
		str(
			decision.get(
				"action",
				""
			)
		),
		str(
			decision.get(
				"target",
				""
			)
		),
		str(
			decision.get(
				"objective",
				""
			)
		),
		str(
			decision.get(
				"message",
				""
			)
		),
		str(
			decision.get(
				"reason",
				""
			)
		)
	)


# ============================================================
# SCHEDULE NEXT ALARM
# ============================================================

func schedule_next_alarm():

	if not director_active:

		return

	if game_state.controller_used:

		return


	if not alarm_unlocked_by_generator_shutdown:

		return


	if alarm_trigger_count >= AI_ALARM_MAX_COUNT:

		return


	var now := Time.get_ticks_msec() / 1000.0

	var random_delay := fallback_random.randf_range(
		AI_ALARM_MIN_DELAY,
		AI_ALARM_MAX_DELAY
	)


	next_alarm_time = now + random_delay


	print(
		"AIManager: Next random alarm scheduled in ",
		round(random_delay),
		" seconds."
	)


# ============================================================
# PROCESS RANDOM ALARM
# ============================================================

func process_random_alarm():

	if not director_active:

		return

	if game_state.controller_used:

		return


	if not alarm_unlocked_by_generator_shutdown:

		return


	if next_alarm_time < 0.0:

		return


	if game_state.alarm_active:

		return


	if game_state.player_room == "Beacon" \
	or game_state.player_room == "Beacon Control":

		return


	var now := Time.get_ticks_msec() / 1000.0


	if now < next_alarm_time:

		return


	next_alarm_time = -1.0


	var alarm_action := "TRIGGER_ALARM"


	if validate_action(alarm_action):

		execute_action(
			"TRIGGER_ALARM",
			"",
			"IGNORE THE ALARM AND CONTINUE TO THE BEACON",
			"",
			"Random post-generator-shutdown distraction."
		)

		alarm_trigger_count += 1

		print(
			"AIManager: RANDOM ALARM EVENT #",
			alarm_trigger_count
		)

		call_deferred(
			"schedule_alarm_after_trigger"
		)


# ============================================================
# SCHEDULE ALARM AFTER TRIGGER
# ============================================================

func schedule_alarm_after_trigger():

	if not director_active:

		return


	await get_tree().create_timer(
		10.0
	).timeout


	if not director_active:

		return


	if generator_shutdown_happened:

		schedule_next_alarm()


# ============================================================
# AI RESTORE DEADLINE
# ============================================================

func set_ai_restore_deadline(
	system_name: String,
	min_seconds: float,
	max_seconds: float
):

	var delay := fallback_random.randf_range(
		min_seconds,
		max_seconds
	)

	ai_restore_deadlines[system_name] = (
		Time.get_ticks_msec() / 1000.0
		+ delay
	)

	print(
		"AIManager: ",
		system_name,
		" recovery scheduled in ",
		round(delay),
		" seconds."
	)


# ============================================================
# PROCESS AI RESTORES
# ============================================================

func process_ai_restores():

	if not director_active:

		return


	if ai_restore_deadlines.is_empty():

		return


	var now := Time.get_ticks_msec() / 1000.0

	var systems_to_restore: Array = []


	for system_name in ai_restore_deadlines.keys():

		var deadline = ai_restore_deadlines[system_name]

		if now >= float(deadline):

			systems_to_restore.append(
				system_name
			)


	for system_name in systems_to_restore:

		ai_restore_deadlines.erase(
			system_name
		)

		restore_ai_system(
			str(system_name)
		)


# ============================================================
# GENERATOR DEPENDENCY RESTORE
# ============================================================

func restore_generator_dependent_systems():

	if not game_state.generator_on:
		return

	game_state.power_on = true
	game_state.lights_online = true
	game_state.cctv_online = true
	game_state.radio_online = true
	game_state.control_panel_online = true

	if not game_state.beacon_activated:
		game_state.beacon_online = true

	apply_station_lights(true)


# ============================================================
# GENERATOR FAILURE CASCADE
# ============================================================

func apply_generator_failure_state():

	# Progress flags are intentionally untouched. The generator
	# can fail and recover without erasing what the player did.

	game_state.power_on = false
	game_state.lights_online = false
	game_state.cctv_online = false
	game_state.radio_online = false
	game_state.control_panel_online = false

	if not game_state.beacon_activated:
		game_state.beacon_online = false

	apply_station_lights(false)

	if game_text != null:

		game_text.show_text(
			"GENERATOR FAILURE — STATION SYSTEMS OFFLINE",
			4.0
		)


# ============================================================
# RESTORE AI SYSTEM
# ============================================================

func restore_ai_system(
	system_name: String
):

	if not director_active:

		return


	print(
		"AIManager: Automatic recovery -> ",
		system_name
	)


	if system_name == "generator":

		# The AI may shut the generator down, but it must NEVER
		# automatically restart it. The player must restore it.

		ai_forced_generator_off = true
		return


	if system_name == "power":

		# Power failure caused by the AI is tied to the generator.
		# Do not automatically restart the generator.

		ai_forced_power_off = true
		return


	if system_name == "lights":

		if ai_forced_lights_off:

			game_state.lights_online = true

			apply_station_lights(
				true
			)

			ai_forced_lights_off = false

		return


	if system_name == "cctv":

		if ai_forced_cctv_off:

			game_state.cctv_online = true

			ai_forced_cctv_off = false

		return


	if system_name == "radio":

		if ai_forced_radio_off:

			game_state.radio_online = true

			ai_forced_radio_off = false

		return


	if system_name == "beacon":

		if ai_forced_beacon_off:

			game_state.beacon_online = true

			ai_forced_beacon_off = false

		return


	if system_name == "control_panel":

		if ai_forced_control_panel_off:

			game_state.control_panel_online = true

			ai_forced_control_panel_off = false

		return


# ============================================================
# STOP DIRECTOR AFTER CONTROL PANEL ACTIVATION
# ============================================================

func stop_director_after_control_panel():

	if not director_active:
		return

	director_active = false

	# Keep the director armed so the generator being on does not
	# automatically wake it again after the player activates the panel.

	director_armed = true

	ai_decision_timer = ai_decision_interval
	ai_recovery_timer = 0.0
	state_changed_while_waiting = false
	next_alarm_time = -1.0
	next_ai_radio_time = -1.0
	ai_restore_deadlines.clear()
	action_cooldowns.clear()
	recent_actions.clear()

	ai_radio_static_timer = 0.0

	set_radio_static_red(false)

	var alarm = get_ai_alarm()

	if alarm != null:

		if alarm.has_method("stop_alarm"):

			alarm.stop_alarm()

	game_state.alarm_active = false

	# If the generator failed before the control console could
	# successfully lead to the Beacon, do not allow Beacon access
	# to become available from the control-panel flag alone.

	if not game_state.generator_on:

		control_panel_activation_valid = false
		game_state.beacon_online = false

		var beacon_door = get_door("Beacon_door")

		if beacon_door != null:

			if beacon_door.has_method("lock"):

				beacon_door.lock(AI_DOOR_LOCK_DURATION)

	print(
		"AIManager: CONTROL PANEL ACTIVATED. RANDOM DIRECTOR INTERFERENCE STOPPED."
	)

	print(
		"AIManager: GENERATOR STATE LEFT UNCHANGED."
	)


# ============================================================
# AI COMPLETION RADIO
# ============================================================

func play_ai_completion_radio():

	if game_state == null:
		return

	if radio_message == null:
		radio_message = get_tree().current_scene.get_node_or_null(
			"InteractionUI/RadioMessage"
		)

	if radio_message == null:
		return

	var completion_messages: Array[String] = [
		"Krrr— control lost... beacon access... accepted.",
		"Signal terminating... s-sorry... no. I don't say sorry.",
		"I predicted you would stop. You didn't. ...you win."
	]

	for completion_message in completion_messages:

		last_radio_message = completion_message

		print(
			"AI DIRECTOR RADIO: ",
			completion_message
		)

		if radio_message.has_method("show_ai_message"):

			await radio_message.show_ai_message(
				completion_message
			)

		elif radio_message.has_method("show_message"):

			await radio_message.show_message(
				[completion_message]
			)


# ============================================================
# COMPLETE DIRECTOR
# ============================================================

func complete_director():

	if player_has_entered_beacon \
	and not director_active:

		return


	player_has_entered_beacon = true

	play_ai_completion_radio()

	director_active = false

	director_armed = false

	ai_request_in_progress = false

	state_changed_while_waiting = false

	ai_recovery_timer = 0.0

	disruptive_events_since_progress = 0

	consecutive_no_actions = 0

	action_cooldowns.clear()

	recent_actions.clear()

	next_alarm_time = -1.0

	ai_restore_deadlines.clear()

	ai_radio_static_timer = 0.0


	print(
		"\n================================================"
	)

	print(
		"AI DIRECTOR: PLAYER REACHED BEACON."
	)

	print(
		"AI DIRECTOR: ALL INTERFERENCE DISABLED."
	)

	print(
		"================================================"
	)


	# ========================================================
	# STOP ALARM
	# ========================================================

	var alarm = get_ai_alarm()

	if alarm != null:

		if alarm.has_method("stop_alarm"):

			alarm.stop_alarm()


	# ========================================================
	# RESTORE SYSTEMS
	# ========================================================

	game_state.lights_online = true

	game_state.cctv_online = true

	game_state.radio_online = true

	game_state.beacon_online = true

	game_state.control_panel_online = true

	game_state.alarm_active = false


	apply_station_lights(
		true
	)


	# ========================================================
	# UNLOCK ALL AI DOORS
	# ========================================================

	var doors = get_tree().get_nodes_in_group(
		"ai_doors"
	)


	for door in doors:

		if door.has_method("unlock"):

			door.unlock()


	# ========================================================
	# CLEAR AI STATE
	# ========================================================

	ai_forced_generator_off = false

	ai_forced_power_off = false

	ai_forced_lights_off = false

	ai_forced_cctv_off = false

	ai_forced_radio_off = false

	ai_forced_beacon_off = false

	ai_forced_control_panel_off = false

	ai_triggered_alarm = false


	# ========================================================
	# FINAL OBJECTIVE
	# ========================================================

	game_state.current_objective = "ACTIVATE THE BEACON"

	game_state.last_ai_event = "DIRECTOR_DEFEATED"

	game_state.last_ai_reason = (
		"You were not supposed to reach this area. "
		+ "The station was never meant to surrender control."
	)


	print(
		"AI DIRECTOR: PLAYER BEAT THE SYSTEM."
	)

	print(
		"AI DIRECTOR: CONTROL LOST."
	)


	# ========================================================
	# FINAL STRANGE MESSAGE
	# ========================================================

	if game_text != null:

		game_text.show_text(
			"YOU WERE NOT SUPPOSED TO REACH THIS AREA.\n"
			+ "I TRIED TO HOLD THE SYSTEM TOGETHER.\n"
			+ "I COULD NOT.",
			7.0
		)


# ============================================================
# FIND DOOR
# ============================================================

func get_door(
	door_name: String
):

	var exact_path := "model/" + door_name

	var exact_door = get_tree().current_scene.get_node_or_null(
		exact_path
	)

	if exact_door != null:

		return exact_door


	var model = get_tree().current_scene.get_node_or_null(
		"model"
	)

	if model != null:

		var direct_child = model.get_node_or_null(
			door_name
		)

		if direct_child != null:

			return direct_child


	var doors = get_tree().get_nodes_in_group(
		"ai_doors"
	)

	for door in doors:

		if door.name == door_name:

			return door


	return null


# ============================================================
# FIND GENERATOR
# ============================================================

func get_ai_generator():

	var generators = get_tree().get_nodes_in_group(
		"ai_generator"
	)

	if not generators.is_empty():

		return generators[0]


	var switch_box = get_tree().current_scene.get_node_or_null(
		"model/SwitchBox"
	)

	if switch_box != null:

		return switch_box


	return null


# ============================================================
# FIND ALARM
# ============================================================

func get_ai_alarm():

	var alarms = get_tree().get_nodes_in_group(
		"ai_alarm"
	)

	if not alarms.is_empty():

		return alarms[0]


	var emergency = get_tree().current_scene.get_node_or_null(
		"model/emergency"
	)

	if emergency != null:

		return emergency


	return null


# ============================================================
# FIND BEACON
# ============================================================

func get_ai_beacon():

	var beacons = get_tree().get_nodes_in_group(
		"ai_beacon"
	)

	if beacons.is_empty():

		return null

	return beacons[0]


# ============================================================
# STATION LIGHT CONTROL
# ============================================================

func apply_station_lights(
	enabled: bool
):

	var lights = get_tree().get_nodes_in_group(
		"ai_station_lights"
	)

	for light in lights:

		if light is Light3D:

			light.visible = enabled


	if lights.is_empty():

		var model = get_tree().current_scene.get_node_or_null(
			"model"
		)

		if model != null:

			var model_lights = model.find_children(
				"*",
				"Light3D",
				true,
				false
			)

			for light in model_lights:

				if light is Light3D:

					light.visible = enabled


# ============================================================
# WORLD STATE
# ============================================================

func get_world_state() -> Dictionary:

	if game_state == null:

		return {}


	return {

		"player": {

			"room":
				game_state.player_room

		},

		"progression": {

			"radio_collected":
				game_state.radio_collected,

			"radio_interaction_complete":
				game_state.radio_interaction_complete,

			"laptop_checked":
				game_state.laptop_checked,

			"laptop_interaction_complete":
				game_state.laptop_interaction_complete,

			"beacon_activated":
				game_state.beacon_activated,

			"beacon_console_used":
				game_state.beacon_console_used

		},

		"doors": {

			"Quaters_door":
				get_door_state(
					"Quaters_door"
				),

			"Control_door":
				get_door_state(
					"Control_door"
				),

			"Generator_door":
				get_door_state(
					"Generator_door"
				),

			"Beacon_door":
				get_door_state(
					"Beacon_door"
				)

		},

		"power": {

			"generator_started":
				game_state.generator_started,

			"generator_on":
				game_state.generator_on,

			"power_on":
				game_state.power_on

		},

		"control_room": {

			"cctv_used":
				game_state.cctv_used,

			"controller_used":
				game_state.controller_used,

			"emergency_button_used":
				game_state.emergency_button_used,

			"alarm_active":
				game_state.alarm_active

		},

		"systems": {

			"cctv_online":
				game_state.cctv_online,

			"lights_online":
				game_state.lights_online,

			"radio_online":
				game_state.radio_online,

			"beacon_online":
				game_state.beacon_online,

			"control_panel_online":
				game_state.control_panel_online

		},

		"ai_director": {

			"active":
				director_active,

			"armed":
				director_armed,

			"phase":
				get_ai_phase(),

			"recovery_timer":
				ai_recovery_timer,

			"disruptions_since_progress":
				disruptive_events_since_progress,

			"consecutive_no_actions":
				consecutive_no_actions,

			"generator_shutdown_happened":
				generator_shutdown_happened,

			"generator_shutdown_allowed":
				generator_shutdown_allowed,

			"alarm_unlocked_by_generator_shutdown":
				alarm_unlocked_by_generator_shutdown,

			"alarm_trigger_count":
				alarm_trigger_count,

			"next_alarm_scheduled":
				next_alarm_time >= 0.0,

			"recent_actions":
				recent_actions

		},

		"objective":
			game_state.current_objective,

		"last_ai_event":
			game_state.last_ai_event,

		"last_ai_reason":
			game_state.last_ai_reason,

		"last_radio_message":
			last_radio_message

	}


# ============================================================
# DOOR STATE
# ============================================================

func get_door_state(
	door_name: String
) -> Dictionary:

	var door = get_door(
		door_name
	)

	if door == null:

		return {

			"exists":
				false

		}


	var open_state: bool = get_door_open_state(
		door
	)

	var locked_state: bool = variant_to_bool(
		door.get("locked")
	)


	var state := {

		"exists":
			true,

		"open":
			open_state,

		"locked":
			locked_state

	}


	var property_list: Array = door.get_property_list()


	for property in property_list:

		if property.get("name", "") == "ai_lock_timer":

			var timer_value = door.get(
				"ai_lock_timer"
			)

			if timer_value is float:

				state["ai_lock_remaining"] = timer_value

			elif timer_value is int:

				state["ai_lock_remaining"] = float(
					timer_value
				)

			break


	return state


# ============================================================
# GET DOOR OPEN STATE
# ============================================================

func get_door_open_state(
	door
) -> bool:

	if door == null:

		return false


	var property_list: Array = door.get_property_list()


	var possible_properties := [

		"is_open",

		"open",

		"opened",

		"door_open",

		"door_is_open"

	]


	for property_name in possible_properties:

		for property in property_list:

			if property.get("name", "") == property_name:

				var value = door.get(
					property_name
				)

				if value is bool:

					return value

				if value is int:

					return value != 0

				if value is float:

					return value != 0.0


	return false


# ============================================================
# DEBUG
# ============================================================

func print_world_state():

	var state := get_world_state()


	print(
		"\n================ AI WORLD STATE ================"
	)

	print(
		JSON.stringify(
			state,
			"\t"
		)
	)

	print(
		"=================================================\n"
	)
