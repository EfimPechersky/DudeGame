extends CharacterBody2D
signal bonk
signal kill(blob)
const SPEED = 200.0
const JUMP_VELOCITY = -450.0
const GRAVITY = 800.0
const PICKUP_DISTANCE = 40
const THROW_FORCE = 400
const STUNT_TIME = 0.2
@onready var animation_player = get_node("AnimationPlayer")
@onready var sprite = get_node("DudeSprite")
@onready var step_audio = get_node("StepPlayer")
@onready var jump_audio = get_node("JumpPlayer")
var invis=false
var crate:RigidBody2D=null
var double_jump:bool=false
var interactive=null
var stunt_delay=0
enum State {IDLE, RUN, JUMP, DOUBLE_JUMP, WALL, WALL_JUMP, STUNT, FALL}
var is_held:bool = false
var current_state:State = State.IDLE
func set_state(new_state:State):
	current_state=new_state

func _ready()->void:
	step_audio.volume_db=linear_to_db(10)
	jump_audio.volume_db=linear_to_db(10)
	set_state(State.IDLE)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pickup") and not is_held:
		var state = get_world_2d().direct_space_state
		var query = PhysicsShapeQueryParameters2D.new()
		var shape = CircleShape2D.new()
		shape.radius=PICKUP_DISTANCE
		query.shape = shape
		query.collide_with_areas=true
		query.transform = Transform2D(0,global_position)
		query.exclude=[self]
		var results = state.intersect_shape(query)
		for result in results:
			if "Crate" == result.collider.name:
				crate = result.collider
				crate.hold(self)
				is_held=true
			if result.collider is Area2D:
				interactive=result.collider
		if interactive and interactive.has_method("activate"):
			interactive.activate()
			interactive=null
				
	if event.is_action_released("pickup") and is_held:
		var direction = Vector2.LEFT if sprite.flip_h else Vector2.RIGHT
		direction.y=-1
		is_held=false
		crate.release(direction*THROW_FORCE)
		crate=null
		
func handle_idle(delta:float):
	animation_player.play("idle")
	var direction = Input.get_axis("left", "right")
	if direction!=0:
		velocity.x = direction*SPEED
		set_state(State.RUN)
	else:
		velocity.x = move_toward(velocity.x,0,SPEED/20)
		#velocity.x=0
	if Input.is_action_just_pressed("jump")and is_on_floor():
		jump_audio.play()
		velocity.y=JUMP_VELOCITY
		double_jump=true
		set_state(State.JUMP)
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		jump_audio.play()
		velocity.y=JUMP_VELOCITY
		double_jump=false
		set_state(State.DOUBLE_JUMP)
func handle_held():
	if crate:
		if is_held:
			crate.global_transform.origin = global_position + Vector2(0,-50)
	
func handle_run(delta:float):
	animation_player.play("run")
	if !step_audio.is_playing():
		step_audio.play()
	var direction = Input.get_axis("left", "right")
	if direction!=0:
		velocity.x = direction*SPEED
	else:
		set_state(State.IDLE)
		#velocity.x=0
		return
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump_audio.play()
		velocity.y=JUMP_VELOCITY
		double_jump=true
		set_state(State.JUMP)
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		jump_audio.play()
		velocity.y=JUMP_VELOCITY
		double_jump=false
		set_state(State.DOUBLE_JUMP)

func handle_jump(delta):
	animation_player.play("jump")
	var direction = Input.get_axis("left", "right")
	if direction!=0:
		velocity.x = direction*SPEED
	else:
		velocity.x = move_toward(velocity.x,0,SPEED/80)
	if Input.is_action_just_pressed("jump") and double_jump:
		jump_audio.play()
		velocity.y=JUMP_VELOCITY
		double_jump=false
		set_state(State.DOUBLE_JUMP)

func handle_double_jump(delta):
	animation_player.play("double_jump")
	var direction = Input.get_axis("left", "right")
	if direction!=0:
		velocity.x = direction*SPEED
	else:
		velocity.x = move_toward(velocity.x,0,SPEED/80)
	if Input.is_action_just_pressed("jump") and double_jump:
		velocity.y=JUMP_VELOCITY
		double_jump=false
		set_state(State.DOUBLE_JUMP)

func update_flip():
	if velocity.x!=0:
		sprite.flip_h=velocity.x<0
func damage():
	invis=true
	await get_tree().create_timer(5).timeout
	invis=false
func handle_stunt(delta):
	if stunt_delay<=0:
		set_state(State.IDLE)
	stunt_delay-=delta
func handle_collision():
	var collision_count = get_slide_collision_count()
	var platform:StaticBody2D
	for i in collision_count:
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.name=="BoxBody":
			var force=4
			stunt_delay=STUNT_TIME
			var normal = collision.get_normal()
			if normal.y<0.5:
				force=2
				stunt_delay=STUNT_TIME/2
			bonk.emit()
			velocity=normal*SPEED*force
			set_state(State.STUNT)
		elif "Wall" in collider.name:
			var normal = collision.get_normal()
			if abs(normal.x)>0.5:
				velocity=normal*SPEED
				stunt_delay = STUNT_TIME
				set_state(State.STUNT)
		elif "Bridge" in collider.name:
			platform = collider
		elif collider.name=="SlimeBody":
			var normal = collision.get_normal()
			if normal.y<-0.5:
				kill.emit(collider.get_parent())
		elif collider.name=="Trap":
			var trap = collider
			var normal = collision.get_normal()
			if trap.is_on==false and normal.y<-0.5:
				trap.hit()
		elif "Rock" in collider.name:
			var normal = collision.get_normal()
			collider.apply_impulse(-normal*10)
	if Input.is_action_just_pressed("down") and platform!=null:
		for child in platform.get_children():
			child.disabled=true
		await get_tree().create_timer(0.1).timeout
		for child in platform.get_children():
			child.disabled=false
		
func _physics_process(delta:float)->void:
	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.RUN:
			update_flip()
			handle_run(delta)
		State.JUMP:
			update_flip()
			handle_jump(delta)
		State.DOUBLE_JUMP:
			update_flip()
			handle_double_jump(delta)
		State.STUNT:
			update_flip()
			handle_stunt(delta)
	if is_on_floor() and current_state in [State.JUMP, State.DOUBLE_JUMP] and velocity.y>=0:
		if abs(velocity.x)>0:
			set_state(State.RUN)
		else:
			set_state(State.IDLE)
	if not is_on_floor():
		velocity.y+=GRAVITY*delta
		if velocity.y>0:
			animation_player.play("fall")
	handle_collision()
	move_and_slide()
	handle_held()
	
