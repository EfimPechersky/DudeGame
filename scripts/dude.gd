extends Node2D

@onready var animation = get_node("AnimationPlayer")
@onready var sprite = get_node("Idle")
var state:String = "idle"
func _process(delta:float)->void:
	if animation.current_animation !=state:
		animation.play(state)
	print(state)
	if Input.is_action_pressed("ui_up"):
		state="jump"
		if Input.is_action_pressed("ui_left"):
			sprite.flip_h=true
		elif Input.is_action_pressed("ui_right"):
			sprite.flip_h=false
	elif Input.is_action_pressed("ui_left"):
		state = "run"
		sprite.flip_h=true
	elif Input.is_action_pressed("ui_right"):
		state="run"
		sprite.flip_h=false
	else:
		state="idle"
