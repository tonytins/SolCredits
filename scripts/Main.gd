extends Control

var battery_percentage: float = 0.0
var wallet: int = 168
var generating_energy: bool = true
@onready var wallet_ui_val = $MenuBar/Wallet/WalletVal
@onready var battery_ui_bar = $MenuBar/BatteryBar

func _ready():
	randomize()

func _process(delta):
	if generating_energy:
		generate_energy(delta)
	else:
		consume_energy(delta)
	check_wallet()
	print_status()

func generate_energy(delta):
	if battery_percentage < 500.0:
		battery_percentage += 10.0 * delta
		if battery_percentage >= 500.0:
			battery_percentage = 500.0
			generating_energy = false
			add_to_wallet()
	else:
		generating_energy = false

func consume_energy(delta):
	const low_battery = 150.0
	battery_percentage -= 5.0 * delta
	if battery_percentage <= low_battery:
		battery_percentage = low_battery
		generating_energy = true

func add_to_wallet():
	var earned_credits = randf_range(100, 200)
	wallet += earned_credits
	if wallet > 1000:
		wallet = 1000
	elif wallet > 500:
		wallet -= sell_energy(wallet - 300)

func sell_energy(amount):
	# Simulate selling the energy for credits
	return int(amount * 0.5)

func check_wallet():
	# Ensure the wallet does not exceed the limit
	if wallet > 1000:
		wallet = 1000

func print_status():
	wallet_ui_val.text = str(wallet)
	battery_ui_bar.value = battery_percentage
	# print("Battery: " + str(battery_percentage) + "%, Wallet: " + str(wallet) + " Credits")
