extends KinematicBody

signal _on_ServerButton_pressed

#constants
const GRAVITY = 9.8

#mouse sensitivity
export(float,0.1,1.0) var sensitivity_x = 0.5
export(float,0.1,1.0) var sensitivity_y = 0.4

#physics
export(float,10.0, 30.0) var speed = 10.0
export(float,10.0, 50.0) var jump_height = 25
export(float,1.0, 10.0) var mass = 6.0
export(float,0.1, 3.0, 0.1) var gravity_scl = 1.0

#instances ref
onready var player_cam = $Camera
onready var ground_ray = $GroundRay
onready var ipadd = $Camera/IPADD
onready var serverButton = $Camera/ServerButton
onready var status = $Camera/IPADD/Status

#variables
var net_mas = true 
var mouse_motion = Vector2()
var mouse_state = 0
var gravity_speed = 0

puppet var puppet_transform = Vector3()
var playerID = 0
var otherID = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ground_ray.enabled = true
	ipadd.visible = false
	serverButton.visible = false
	print(net_mas)

var velocity = Vector3()
var boost = 0.0
func _physics_process(delta):
	
	#camera and body rotation
	if !mouse_state and net_mas :
		rotate_y(deg2rad(20)* - mouse_motion.x * sensitivity_x * delta)
		player_cam.rotate_y(deg2rad(20) * - mouse_motion.y * sensitivity_y * delta)
		player_cam.rotation.x = clamp(player_cam.rotation.x, deg2rad(-47), deg2rad(47))
		mouse_motion = Vector2()
	
	#gravity
	gravity_speed -= GRAVITY * gravity_scl * mass * delta
	
	if net_mas :
		#character moviment
		if not ground_ray.is_colliding() :
			boost = boost + 0.001
		else :
			boost = boost - 0.005
		boost = clamp(boost, 0, 0.15)
		velocity = (velocity * (boost + 0.8)) + _axis() * speed
		velocity.y = gravity_speed
#		rpc_unreliable("puppet_transform",translation)
		if get_tree().get_network_peer() != null :
			rset_unreliable("puppet_transform",translation)
	else :
		translation = puppet_transform
	#jump
	if Input.is_action_just_pressed("jump") and ground_ray.is_colliding() and net_mas :
		velocity.y = jump_height
	gravity_speed = move_and_slide(velocity).y

# warning-ignore:unused_argument
func _process(delta) :
	if Input.is_action_just_pressed("escape") and net_mas :
		if mouse_state == 0 :
			ipadd.visible = true
			status.visible = true
			serverButton.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_state = 1
		else :
			ipadd.visible = false
			status.visible = false
			serverButton.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_state = 0
	if Input.is_action_just_pressed("enter") :
		get_tree().network_peer = null
		var peer = NetworkedMultiplayerENet.new()
		peer.create_client(ipadd.text, 4242)
		get_tree().set_network_peer(peer)
		print(str(is_network_master()))
		net_mas = is_network_master()
		peer.connect("connection_failed", self, "_on_connection_failed")
# lazy zoom code
#	if Input.is_action_pressed("rmb") :
#		player_cam.fov = 30.0
#	else :
#		player_cam.fov = 90.0

func _on_connection_failed(error) :
	ipadd.text = "Error connecting to server: " + error


func _input(event):
	
	if event is InputEventMouseMotion and net_mas :
		mouse_motion = event.relative


func _axis():
	var direction = Vector3()
	
	if Input.is_key_pressed(KEY_W) and net_mas:
		direction -= get_global_transform().basis.x.normalized()
		
	if Input.is_key_pressed(KEY_S) and net_mas:
		direction += get_global_transform().basis.x.normalized()
		
	if Input.is_key_pressed(KEY_A) and net_mas:
		direction -= get_global_transform().basis.y.normalized()
		
	if Input.is_key_pressed(KEY_D) and net_mas:
		direction += get_global_transform().basis.y.normalized()
		
	return direction.normalized()

func _on_ServerButton_pressed():
	emit_signal("_on_ServerButton_pressed")
