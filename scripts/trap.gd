extends StaticBody2D

@onready var anim = get_node("AnimationPlayer")
@onready var fire = get_node("Fire/CollisionShape2D")
@onready var particles = get_node("GPUParticles2D")
var is_on=false
func _ready()->void:
	turn_off()
	
func turn_on():
	is_on=true
	particles.emitting=true
	fire.disabled=false
	anim.play("on")
	await get_tree().create_timer(5).timeout
	turn_off()

func turn_off():
	is_on=false
	particles.emitting=false
	fire.disabled=true
	anim.play("off")

func hit():
	anim.play("hit")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hit":
		turn_on()
