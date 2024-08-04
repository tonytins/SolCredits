extends CanvasModulate

const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY

var time: float = 0.0
var pass_minute =  -1

@export var gradient: GradientTexture1D
@export var INGAME_SPEED = 10
@export var INITIAL_HOUR = 12:
	set(h):
		INITIAL_HOUR = h
		time = INGAME_TO_REAL_MINUTE_DURATION * MINUTES_PER_HOUR * INITIAL_HOUR

signal time_tick(day:int, hour:int, minute:int)

func _ready():
	time = INGAME_TO_REAL_MINUTE_DURATION * MINUTES_PER_HOUR * INITIAL_HOUR

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta * INGAME_TO_REAL_MINUTE_DURATION * INGAME_SPEED
	
	var cycle = (sin(time - PI / 2.0) + 1.0) / 2.0
	self.color = gradient.gradient.sample(cycle)
	
	_recalcuate_time()
	
func _recalcuate_time():
	var total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)
	
	var day = int(total_minutes / MINUTES_PER_DAY)
	
	var current_day_mins = total_minutes % MINUTES_PER_DAY
	
	var hour = int(current_day_mins / MINUTES_PER_HOUR)
	var minute = int(current_day_mins % MINUTES_PER_HOUR)
	
	if pass_minute != minute:
		pass_minute = minute
		time_tick.emit(day, hour, minute)
