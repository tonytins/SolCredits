extends Control

@export var max_funds: float = 1000
@export var starting_funds: float = 168
## How many Kilowatt-Hour is generated per-cycle
@export var kilowatt_hour: float = 10
## Starting battery capacity
@export var battery_capacity: float = 500
@export var budget_minimum: float = 300
## How low the battery gets before resuming production
@export var consumption_threshold: float = 150

@onready var wallet_ui_val = $MenuBar/Wallet/WalletVal
@onready var battery_ui_bar = $MenuBar/BatteryBar
@onready var battery_capacity_ui_val = $MenuBar/BatteryCap/BatCapVal

var battery_percentage: float = 0
var wallet: float = starting_funds
var is_generating_energy: bool = true
var is_nighttime: bool = false
var energy_variability: float = 0

## Ensure the wallet does not exceed the limit
var is_wallet_full:
	get: if wallet <= max_funds:
		return false

func _ready():
	randomize()
	

func _process(delta):
	if is_generating_energy && !is_nighttime:
		energy_variability = randf_range(0.2, 0.4)
		generate_energy(delta)
	else:
		consume_energy(delta)

	update_status()

## Generate and store energy 
## until battery reaches battery_capacity
func generate_energy(delta):
	if battery_percentage < battery_capacity:
		battery_percentage += (kilowatt_hour * delta) / energy_variability
		if battery_percentage >= battery_capacity:
			battery_percentage = battery_capacity
			is_generating_energy = false
			add_to_wallet()
	else:
		is_generating_energy = false

## Battery consumes eneregy until
func consume_energy(delta):
	battery_percentage -= battery_percentage * delta
	if battery_percentage <= consumption_threshold:
		battery_percentage = consumption_threshold
		is_generating_energy = true

func add_to_wallet():
	# Ensure wallet does not exceed the limit
	if !is_wallet_full:
		# Calculate the amount of energy that can be sold as surplus
		var surplus_energy = max(battery_percentage - (consumption_threshold / battery_capacity), 0)
		# Convert surplus energy to credits
		var earned_credits = int(surplus_energy * energy_variability)
		wallet += earned_credits
		print_debug("Earned Ȼ" + str(earned_credits))


## Simulate selling the energy for credits
func sell_energy(amount):
	return int(amount * 0.5)
	
func update_status():
	wallet_ui_val.text = str(wallet)
	battery_ui_bar.value = battery_percentage
	battery_capacity_ui_val.text = str(battery_capacity)
