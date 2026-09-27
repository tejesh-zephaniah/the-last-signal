extends Node


# ============================================================
# PLAYER PROGRESSION
# ============================================================

var radio_collected: bool = false
var radio_interaction_complete: bool = false

var laptop_checked: bool = false
var laptop_interaction_complete: bool = false

var beacon_activated: bool = false


# ============================================================
# DOORS
# ============================================================

var quarters_door_opened: bool = false
var quarters_door_closed: bool = false
var quarters_door_locked: bool = false

var control_door_opened: bool = false
var control_door_closed: bool = false
var control_door_locked: bool = false

var generator_door_opened: bool = false
var generator_door_closed: bool = false
var generator_door_locked: bool = false

var beacon_door_opened: bool = false
var beacon_door_closed: bool = false
var beacon_door_locked: bool = false


# ============================================================
# GENERATOR / POWER
# ============================================================

var generator_started: bool = false
var generator_on: bool = false
var power_on: bool = false


# ============================================================
# CONTROL ROOM
# ============================================================

var cctv_used: bool = false
var controller_used: bool = false
var emergency_button_used: bool = false


# ============================================================
# BEACON
# ============================================================

var beacon_console_used: bool = false


# ============================================================
# AI WORLD STATE
# ============================================================

var player_room: String = "Unknown"

var current_objective: String = ""

var last_ai_event: String = ""

var last_ai_reason: String = ""


# ============================================================
# STATION SYSTEMS
# ============================================================

var cctv_online: bool = true
var lights_online: bool = true
var radio_online: bool = true
var beacon_online: bool = true
var control_panel_online: bool = true


# ============================================================
# ALARM
# ============================================================

var alarm_active: bool = false
