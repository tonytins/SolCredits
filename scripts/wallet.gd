extends Control


@export var night_hour = 17
@export var day_hour = 9
@export var max_funds: float = 1000
@export var starting_funds: float = 168
## Starting battery capacity
@export var battery_capacity: float = 500
## How low the battery gets before resuming production
@export var consumption_threshold: float = 50

@onready var _wallet_ui_val = $MenuBar/BatteryCap/BatCapVal
@onready var _battery_ui_bar = $MenuBar/BatteryBar
@onready var _battery_cap_ui_val = $MenuBar/BatteryCap/BatCapVal
@onready var _clock_ui = $Clock/TimeVal
@onready var _ampm_ui = $Clock/AmPmVal
@onready var _charging_indictor = preload("res://charging_indictor.tres")
@onready var _draining_indictor = preload("res://draining_indictor.tres")

var _battery_percentage: float = 0
var _wallet: float = starting_funds
var _energy_variability: float = 0
var _get_12_hour: float
var _get_24_hour
var _get_minute: float
var _get_am_pm: String
var _is_generating_energy: bool = true
var _kilowatt_hour = battery_capacity / 1000
var _noise = FastNoiseLite.new()

func _ready():
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.seed = randi()
	_noise.fractal_octaves = 4
	_noise.frequency = 1.0 / 20.0
	
	_battery_percentage = battery_capacity
	
	update_status()
	
func _process(delta):
	if _is_generating_energy:
		charge_battery(delta)
	else:
		drain_battery(delta)
		
	manage_wallet()
	check_time()
	update_status()

func set_daytime(day: int, hour: int, minute: int) -> void:
	if hour == 0:
		hour = 12
		
	_get_12_hour = float(_set_hour(hour))
	_get_minute = float(_set_minute(minute))
	_get_am_pm = _set_am_pm(hour)
	_convert_to_24(hour)
	
	_clock_ui.text = str(_get_24_hour) + ":" + _set_minute(minute)
	_ampm_ui.text = _get_am_pm
	
func _convert_to_24(hour: int):
	var _last_hour = hour
	
	if _get_am_pm == "pm":
		_last_hour + 1
		_get_24_hour = _last_hour
	elif _get_am_pm == "am":
		_get_24_hour = hour

func check_time():
	# Switch between day and night based on time
	if _get_24_hour >= 17 or _get_24_hour < 9:
		_is_generating_energy = false
	else:
		_is_generating_energy = true

func _set_hour(hour: int) -> String:
	if hour > 12:
		return str(hour - 12)
	return str(hour)
	
func _set_minute(minute: int) -> String:
	if minute < 10:
		return "0" + str(minute)
	return str(minute)

func _set_am_pm(hour: int) -> String:
	if hour < 12:
		return "am"
	else:
		return "pm"

func charge_battery(delta):
	if _is_generating_energy:
		var generation_rate = _kilowatt_hour * max_funds * (1 + _energy_variability)
		_battery_percentage += generation_rate * delta
		if _battery_percentage >= battery_capacity:
			_battery_percentage = battery_capacity
			add_to_wallet()
			
	_battery_ui_bar.add_theme_stylebox_override("fill", _charging_indictor)

func drain_battery(delta):
	if _battery_percentage <= battery_capacity:
		_battery_percentage -= sin(_kilowatt_hour / _energy_variability / PI / 2)
		
	if _battery_percentage <= 250.0:
		_battery_percentage = max(_battery_percentage, 0)
		_is_generating_energy = true
	
	_battery_ui_bar.add_theme_stylebox_override("fill", _draining_indictor)

func add_to_wallet():
	# Calculate the amount of energy that can be sold as surplus
	var surplus_energy = max(_battery_percentage - 250.0, 0)
	var earned_credits = int(surplus_energy * randf_range(_kilowatt_hour * 0.2, _kilowatt_hour * 0.4)) # Convert surplus energy to credits
	_battery_percentage = 250.0 # Set battery to the minimum threshold for consumption
	_wallet += earned_credits
	# Ensure wallet does not exceed the limit
	if _wallet > max_funds:
		_wallet = max_funds
		# print_debug("Earned Ȼ" + str(earned_credits))

func manage_wallet():
	# Manage the wallet to ensure it doesn't exceed limits
	if _wallet > max_funds:
		_wallet = max_funds

## Simulate selling the energy for credits
func sell_energy(amount):
	return int(amount * 0.5)
	
func opening_scene():
	DialogueManager.show_example_dialogue_balloon(load("res://dialogues/Opening.dialogue"), "start")

func update_status():
	_wallet_ui_val.text = str(_wallet)
	_battery_ui_bar.value = _battery_percentage
	_battery_cap_ui_val.text = str(battery_capacity)
