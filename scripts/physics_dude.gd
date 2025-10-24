extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 800.0
@onready var animation_player = get_node("AnimationPlayer")
@onready var sprite = get_node("DudeSprite")
var double_jump=true
var wall_jump=false

enum State {IDLE, RUN, JUMP, DOUBLE_JUMP, WALL, WALL_JUMP, STUN}
func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction*SPEED
	move_and_slide()
	if velocity.y<0 and double_jump:
		animation_player.play("jump")
	elif is_on_wall() and velocity.y!=0:
		animation_player.play("wall")
	elif velocity.y<0 and !double_jump:
		animation_player.play("double_jump")
	elif velocity.y>0:
		animation_player.play("fall")
	if is_on_wall() and velocity.y>0:
		velocity.y=GRAVITY/10
	elif is_on_floor() or is_on_wall() and !double_jump:
		double_jump=true
	else:
		velocity.y+=GRAVITY*delta
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y=JUMP_VELOCITY
	elif Input.is_action_just_pressed("ui_up") and double_jump and not (is_on_floor() or is_on_wall()):
		velocity.y=JUMP_VELOCITY
		double_jump=false
	elif Input.is_action_just_pressed("ui_up") and is_on_wall():
		velocity.y=JUMP_VELOCITY*0.8
		if sprite.flip_h:
			velocity.x=-JUMP_VELOCITY
		else:
			velocity.x=JUMP_VELOCITY
	if direction != 0:
		if is_on_floor():
			animation_player.play("run")
		sprite.flip_h = direction<0
	elif is_on_floor():
		animation_player.play("idle")

	
