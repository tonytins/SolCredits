extends Node2D

@onready var daynight_cycle = $DayNight
@onready var wallet = $Controls/WalletUI

func _ready():
	daynight_cycle.time_tick.connect(wallet.set_daytime)
