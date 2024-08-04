extends CanvasModulate

@export var gradient: GradientTexture1D
@export var INGAME_SPEED = 1.0
@export var INITIAL_HOUR = 12

const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60
const INGAME_REAL_TIME_DUR = (2 * PI) / MINUTES_PER_DAY

signal time_tick(day:int, hour:int, minute:int)

var time: float = 0.0
var pass_minute =  -1

func _ready():
	time = INGAME_REAL_TIME_DUR * INITIAL_HOUR * MINUTES_PER_HOUR

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta * INGAME_REAL_TIME_DUR * INGAME_SPEED
	var cycle = (sin(time / PI / 2) + 1.0) / 2.0
	self.color = gradient.gradient.sample(cycle)
	
	_recalcuate_time()
	
func _recalcuate_time():
	var total_minutes = int(time / INGAME_REAL_TIME_DUR)
	var day = int(total_minutes / MINUTES_PER_DAY)
	var current_day_mins = total_minutes % MINUTES_PER_DAY
	var hour = int(current_day_mins / MINUTES_PER_HOUR)
	var minute = int(current_day_mins % MINUTES_PER_HOUR)
	
	if pass_minute != minute:
		pass_minute = minute
		time_tick.emit(day, hour, minute)
