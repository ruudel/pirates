extends Node

signal sailing_started(duration: float)
signal sailing_event_triggered(event: SailingEvent)
signal sailing_event_resolved(event: SailingEvent, choice_index: int)
signal sailing_arrived

const MIN_SAIL_TIME = 15.0
const MAX_SAIL_TIME = 35.0

# Timing — events fire at these fractions of total sail time
const EVENT_WINDOW_1 = 0.35
const EVENT_WINDOW_2 = 0.70

var _sail_duration:  float = 0.0
var _elapsed:        float = 0.0
var _is_sailing:     bool  = false
var _is_paused:      bool  = false   # true while an event is resolving
var _events_to_fire: Array = []      # pre-rolled events for this voyage
var _events_fired:   int   = 0
var _destination_id: String = ""

func start_sailing(destination_id: String, grand_line: bool = false) -> void:
	_destination_id = destination_id
	_sail_duration  = randf_range(MIN_SAIL_TIME, MAX_SAIL_TIME)
	_elapsed        = 0.0
	_is_sailing     = true
	_is_paused      = false
	_events_fired   = 0
	_events_to_fire = _roll_events(grand_line)
	sailing_started.emit(_sail_duration)

func skip_to_arrival() -> void:
	if not _is_sailing:
		return
	_events_to_fire.clear()
	_arrive()

func resolve_event(event: SailingEvent, choice_index: int) -> void:
	_apply_effect(event, choice_index)
	sailing_event_resolved.emit(event, choice_index)
	_is_paused = false

func _process(delta: float) -> void:
	if not _is_sailing or _is_paused:
		return

	_elapsed += delta
	var progress = _elapsed / _sail_duration

	# Check event windows
	if _events_fired < _events_to_fire.size():
		var windows = [EVENT_WINDOW_1, EVENT_WINDOW_2]
		if _events_fired < windows.size() and progress >= windows[_events_fired]:
			_fire_next_event()
			return

	if progress >= 1.0:
		_arrive()

func _fire_next_event() -> void:
	if _events_to_fire.is_empty():
		return
	var event = _events_to_fire[_events_fired]
	_events_fired += 1
	_is_paused = true
	sailing_event_triggered.emit(event)

func _arrive() -> void:
	_is_sailing = false
	sailing_arrived.emit()
	MapData.finish_travel(_destination_id)

func _roll_events(grand_line: bool) -> Array:
	var count  = SailingEventPool.roll_event_count()
	var result = []
	for i in range(count):
		var event = SailingEventPool.get_event(grand_line)
		if event:
			result.append(event)
	return result

func _apply_effect(event: SailingEvent, choice_index: int) -> void:
	if choice_index >= event.choices.size():
		return
	var choice = event.choices[choice_index]
	match choice.effect:
		SailingEvent.Effect.STAT_BUFF:
			print("Crew morale +", choice.effect_value)
			# hook into crew stats later
		SailingEvent.Effect.STAT_DEBUFF:
			print("Crew morale -", choice.effect_value)
		SailingEvent.Effect.GAIN_RESOURCE:
			print("Resources +", choice.effect_value)
			# hook into resource manager later
		SailingEvent.Effect.LOSE_RESOURCE:
			print("Resources -", choice.effect_value)
		SailingEvent.Effect.NONE:
			pass

func get_destination_id() -> String:
	return _destination_id

func get_sail_duration() -> float:
	return _sail_duration
