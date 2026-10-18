extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var speed: float = 150.0
@export var jump_velocity: float = -550.0
@export var player: Node2D

enum BossState { IDLE, CHASE, ATTACK }
var current_state: BossState = BossState.IDLE

var rng = RandomNumberGenerator.new()

var state_timer: float = 0.0
@export var idle_duration: float = 2.0 
@export var chase_duration: float = 3.0 

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	rng.randomize() 
	start_idle_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	match current_state:
		BossState.IDLE:
			process_idle(delta)
		BossState.CHASE:
			process_chase(delta)
		BossState.ATTACK:
			pass
			
	move_and_slide()

func start_idle_state() -> void:
	current_state = BossState.IDLE
	velocity.x = 0
	state_timer = idle_duration

func process_idle(delta: float) -> void:
	state_timer -= delta
	if state_timer <= 0:
		start_chase_state()

func start_chase_state() -> void:
	current_state = BossState.CHASE
	state_timer = chase_duration

func process_chase(delta: float) -> void:
	state_timer -= delta
	
	if is_instance_valid(player):
		var direction = sign(player.global_position.x - global_position.x)
		velocity.x = direction * speed
		
		# قفزة عشوائية مرتفعة لمرة واحدة أثناء المطاردة إذا كان على الأرض
		if is_on_floor() and rng.randf() < 0.01:
			velocity.y = jump_velocity
	else:
		velocity.x = 0
	
	if state_timer <= 0:
		velocity.x = 0
		choose_random_attack()

func choose_random_attack() -> void:
	current_state = BossState.ATTACK
	
	var attack_choice = rng.randi_range(1, 4)
	
	match attack_choice:
		1:
			perform_attack_1()
		2:
			perform_attack_2()
		3:
			perform_attack_3()
		4:
			perform_attack_4()

func perform_attack_1() -> void:
	print("attack 1")
	sprite.play("attack1")
	velocity.x = 0
	await get_tree().create_timer(1.5).timeout
	finish_attack()

func perform_attack_2() -> void:
	print("attack 2")
	sprite.play("attack2")
	velocity.x = 0
	await get_tree().create_timer(2.0).timeout
	finish_attack()

func perform_attack_3() -> void:
	print("attack 3")
	sprite.play("attack3")
	if is_instance_valid(player) and is_on_floor():
		var direction = sign(player.global_position.x - global_position.x)
		velocity.x = direction * (speed * 2.0)
		velocity.y = jump_velocity 
	
	await get_tree().create_timer(1.0).timeout
	velocity.x = 0
	finish_attack()

func perform_attack_4() -> void:
	print("attack 4")
	
	velocity.x = 0
	await get_tree().create_timer(2.5).timeout
	finish_attack()

func finish_attack() -> void:
	start_idle_state()
