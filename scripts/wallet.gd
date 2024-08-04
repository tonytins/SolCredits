extends Control


@export var night_hour = 18
@export var day_hour = 5
@export var max_funds: float = 1000
@export var starting_funds: float = 168
## Starting battery capacity
@export var battery_capacity: float = 500
## How low the battery gets before resuming production
@export var consumption_threshold: float = 50

@onready var _wallet_ui_val = $MenuBar/Wallet/WalletVal
@onready var _battery_ui_bar = $MenuBar/BatteryBar
@onready var _battery_cap_ui_val = $MenuBar/BatteryCap/BatCapVal
@onready var _clock_ui = $Clock/TimeVal
@onready var _ampm_ui = $Clock/AmPmVal
@onready var _charging_indictor = preload("res://charging_indictor.tres")
@onready var _draining_indictor = preload("res://draining_indictor.tres")

var _battery_percentage: float = 0
var _wallet: float = starting_funds
var _energy_variability: float = 0
var _get_clock_hour: float
var _get_minute: float
var _get_am_pm: String
var _is_generating_energy: bool = true
var _killwatt_hour = battery_capacity / 1000
var _noise = FastNoiseLite.new()

## Ensure the _wallet does not exceed the limit
var _is_wallet_full:
	get: if _wallet <= max_funds:
		return false

func _ready():
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.seed = randi()
	_noise.fractal_octaves = 4
	_noise.frequency = 1.0 / 20.0
	
func _process(delta):
	_energy_variability = randf_range(_killwatt_hour, _killwatt_hour + 2)
	if _is_generating_energy:
		charge_battery(delta)
	else:
		drain_battery(delta)
		
	update_status()

func set_daytime(day: int, hour: int, minute: int) -> void:
	_get_clock_hour = float(_set_hour(hour))
	_get_minute = float(_set_minute(minute))
	_get_am_pm = _set_am_pm(hour)
	
	_clock_ui.text = str(_get_clock_hour) + ":" + _set_minute(minute)
	_ampm_ui.text = _get_am_pm

func _set_hour(hour:int) -> String:
	if hour == 0:
		return str(12)
	if hour > 12:
		return str(hour - 12)
	return str(hour)
	
func _set_minute(minute:int) -> String:
	if minute < 10:
		return "0" + str(minute)
	return str(minute)

func _set_am_pm(hour:int) -> String:
	if hour < 12:
		return "am"
	else:
		return "pm"

## Generate and store energy 
## until battery reaches battery_capacity
func charge_battery(delta):
	_battery_ui_bar.add_theme_stylebox_override("fill", _charging_indictor)
	if _battery_percentage < battery_capacity:
		_battery_percentage += sin((_killwatt_hour / PI) / _energy_variability + 2)
		if _battery_percentage >= battery_capacity:
			_battery_percentage = battery_capacity
			_is_generating_energy = false
			add_to_wallet()
	else:
		_is_generating_energy = true

## Battery consumes eneregy until
func drain_battery(delta):
	_battery_ui_bar.add_theme_stylebox_override("fill", _draining_indictor)
	_battery_percentage -= sin((_killwatt_hour / PI) / _energy_variability + 2)
	if _battery_percentage <= consumption_threshold:
		_battery_percentage = consumption_threshold
		_is_generating_energy = true

func add_to_wallet():
	# Ensure _wallet does not exceed the limit
	if !_is_wallet_full:
		# Calculate the amount of energy that can be sold as surplus
		var surplus_energy = max(consumption_threshold / _killwatt_hour, 0)
		# Convert surplus energy to credits
		var earned_credits = int(surplus_energy * _energy_variability)
		_wallet += earned_credits
		print_debug("Earned Ȼ" + str(earned_credits))


## Simulate selling the energy for credits
func sell_energy(amount):
	return int(amount * 0.5)
	
func opening_scene():
	DialogueManager.show_example_dialogue_balloon(load("res://dialogues/Opening.dialogue"), "start")

func update_status():
	_wallet_ui_val.text = str(_wallet)
	_battery_ui_bar.value = _battery_percentage
	_battery_cap_ui_val.text = str(battery_capacity)
