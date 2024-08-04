extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	opening_scene()

func opening_scene():
	DialogueManager.show_example_dialogue_balloon(load("res://dialogues/Opening.dialogue"), "start")
