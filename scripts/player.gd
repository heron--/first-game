extends CharacterBody2D


const SPEED = 250.0
const JUMP_VELOCITY = -300.0

@onready var sprite = $AnimatedSprite2D
@onready var roll_timer = $RollTimer

const MAX_JUMP_COUNT = 2
const DODGE_DURATION = .5

enum PlayerAction { ATTACKING, IDLE, JUMPING, ROLLING, RUNNING, WALKING }

var player_state = {
	action = PlayerAction.IDLE,
	jump_count = 0,
}

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("player_move_left", "player_move_right")

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	####
	# Handle Dodge
	####
	if (Input.is_action_just_pressed("player_move_dodge") and
		(player_state.action == PlayerAction.IDLE or
		player_state.action == PlayerAction.RUNNING or
		player_state.action == PlayerAction.WALKING) and
	is_on_floor() and
	direction != 0):
		beginRoll()

	####
	# Handle Jump
	####
	if (Input.is_action_just_pressed("player_move_jump") and
	player_state.jump_count < MAX_JUMP_COUNT):
		player_state["jump_count"] += 1 if is_on_floor() else 2
		velocity.y = JUMP_VELOCITY
		
	if is_on_floor():
		player_state.jump_count = 0
		
	if direction < 0:
		sprite.flip_h = true
	elif direction > 0:
		sprite.flip_h = false
	player_state.action = getPlayerAction()
	sprite.animation = getAnimation()
	sprite.play()

		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func beginRoll():
	player_state.action = PlayerAction.ROLLING
	roll_timer.wait_time = DODGE_DURATION
	roll_timer.start()
	
	
func getPlayerAction() -> PlayerAction:
	if player_state["action"] == PlayerAction.ROLLING:
		return PlayerAction.ROLLING
		
	if is_on_floor():
		var direction := Input.get_axis("player_move_left", "player_move_right")
		if (direction < -0.8 and direction < 0) or (direction > 0.8 and direction > 0):
			return PlayerAction.RUNNING
		if direction < 0 or direction > 0:
			return PlayerAction.WALKING
			
	if !is_on_floor():
		return PlayerAction.JUMPING
			
	return PlayerAction.IDLE
	

func getAnimation() -> String:
	if player_state["action"] == PlayerAction.ROLLING:
		return 'roll'

	if player_state["action"] == PlayerAction.RUNNING:
		return 'run'
	if player_state["action"] == PlayerAction.WALKING:
		return 'walk'	
		
	if player_state["action"] == PlayerAction.IDLE or player_state["action"] == null:
		return 'idle'
			
	if !is_on_floor():
		return 'jump'
	
	return 'idle'
	
func resetPlayerAction():
	player_state["action"] = PlayerAction.IDLE


func _on_roll_timer_timeout() -> void:
	resetPlayerAction()
	player_state["action"] = getPlayerAction()
