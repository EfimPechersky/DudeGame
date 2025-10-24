extends Node2D

@onready var anim = get_node("SlimeBody/AnimationPlayer")
var dead=false
func _ready()->void:
	anim.play("idle")
func death():
	if not dead:
		dead=true
		anim.play("death")
