extends Node2D


# Declare member variables here. Examples:
# var a = 2
puppet var puppet_motion = Vector2()
puppet var puppet_rotation = Vector2()
var motion = Vector2()
var prev_bombing = false
var bomb_index = 0

var charge_stage = 0
var charge_strength = 0
var charge_cap = 10

# Use sync because it will be called everywhere
sync func setup_bomb(bomb_name, pos, by_who, path):
	var bomb = preload("res://bomb.tscn").instance()
	bomb.set_name(bomb_name) # Ensure unique name for the bomb
	bomb.position = get_parent().get_parent().position
	bomb.from_player = by_who
	bomb.path = path
	# No need to set network master to bomb, will be owned by server by default
	get_node("../../../..").add_child(bomb)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Change to something that is hidden
func set_user_name(new_name):
	get_node("Label").set_text(new_name)

func _physics_process(_delta):
	var motionNew = Vector2()
	if is_network_master():
		if Input.is_action_pressed("move_left"):
			motionNew += Vector2(-3, 0)
		if Input.is_action_pressed("move_right"):
			motionNew += Vector2(3, 0)
		if Input.is_action_pressed("move_up"):
			motionNew += Vector2(0, -3)
		if Input.is_action_pressed("move_down"):
			motionNew += Vector2(0, 3)
		motion = motionNew
		
		
		var m = get_global_mouse_position()
		var aim_speed = deg2rad(5)
		var ang = get_angle_to(m)
		if ang > 0 + aim_speed:
			rotation += aim_speed
		elif ang < 0 - aim_speed:
			rotation -= aim_speed
		

		var bombing = Input.is_action_pressed("set_bomb")

		if bombing and not prev_bombing:
			var bomb_name = get_name() + str(bomb_index)
			var bomb_pos = position
			rpc("setup_bomb", bomb_name, bomb_pos, get_tree().get_network_unique_id(), get_parent().get_parent().get_path())
		prev_bombing = bombing

		rset("puppet_motion", motion)
		#rset("puppet_rotation", rotation)

	else:
		motion = puppet_motion
		#rotation = puppet_rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
