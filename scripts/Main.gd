extends Control

const wallet_limit: float = 1000

@export var starting_funds: float = 168
## How many kilowatts is generated per-cycle
@export var kilowatts: float = 10
## Starting battery capacity
@export var battery_capacity: float = 500
@export var budget_minimum: float = 300
## How low the battery gets before resuming production
@export var battery_minimum: float = 150
@export var battery_consumption: float = 5

@onready var wallet_ui_val = $MenuBar/Wallet/WalletVal
@onready var battery_ui_bar = $MenuBar/BatteryBar
@onready var battery_capacity_ui_val = $MenuBar/BatteryCap/BatCapVal

var battery_percentage: float = 0
var wallet: float = starting_funds
var generating_energy: bool = true
var earned_income:
	get: return battery_capacity / kilowatts

func _ready():
	randomize()

func _process(delta):
	if generating_energy:
		generate_energy(delta)
	else:
		consume_energy(delta)

	check_wallet()
	display_status()

## Generate and store energy 
## until battery reaches battery_capacity
func generate_energy(delta):
	if battery_percentage < battery_capacity:
		battery_percentage += kilowatts * delta
		if battery_percentage >= battery_capacity:
			battery_percentage = battery_capacity
			generating_energy = false
			add_to_wallet()
	else:
		generating_energy = false

## Battery consumes eneregy until
func consume_energy(delta):
	battery_percentage -= battery_consumption * delta
	if battery_percentage <= battery_minimum:
		battery_percentage = battery_minimum
		generating_energy = true

func add_to_wallet():
	wallet += earned_income
	if wallet > wallet_limit:
		wallet = wallet_limit
	## Simulate spending
	elif wallet > budget_minimum:
		wallet -= sell_energy(wallet - 300)

## Simulate selling the energy for credits
func sell_energy(amount):
	return int(amount * 0.5)

## Ensure the wallet does not exceed the limit
func check_wallet():
	if wallet > wallet_limit:
		wallet = wallet_limit

func display_status():
	wallet_ui_val.text = str(wallet)
	battery_ui_bar.value = battery_percentage
	battery_capacity_ui_val.text = str(battery_capacity)
