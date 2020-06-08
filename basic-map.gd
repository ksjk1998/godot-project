extends Spatial

var server = null
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#onready var host = get_node("/root/1")
var host = load("res://Player.tscn").instance()
#var map = load("res://basic-map.tscn").instance()

var players = {}

onready var label = get_node("/root/Spatial/1/Camera/IPADD/Status")
onready var count = get_node("/root/Spatial/1/Camera/IPADD/Count")

func create_server() :
	print("this code is running")
	server = NetworkedMultiplayerENet.new()
	server.create_server(4242, 2)
	get_tree().set_network_peer(server)
	host.set_name(str(get_tree().get_network_unique_id()))
	host.set_network_master(get_tree().get_network_unique_id())
	host.playerID = str(get_tree().get_network_unique_id())
#	get_node("/root").add_child(host)
	host.playerID = str(get_tree().get_network_unique_id())
	server.connect("peer_connected", self, "_peer_connected")
	server.connect("peer_disconnected", self, "_peer_disconnected")
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _peer_connected(id) :
#	var map = preload("res://basic-map.tscn").instance()
#	get_tree().get_root().add_child(map)
#	hide()
	register_player(id)
	var clientPlayer = load("res://Player.tscn").instance()
	clientPlayer.set_name(str(id))
	clientPlayer.set_network_master(id)
	get_node("/root/Spatial").add_child(clientPlayer)
	clientPlayer.playerID = str(id)
	clientPlayer.otherID = 1
	host.otherID = id
	label.text = label.text + "\nUser " + str(id) + " connected"
	count.text = "Total Users: " + str(get_tree().get_network_connected_peers().size())

func _peer_disconnected(id) :
	label.text = label.text + "\nUser " + str(id) + " disconnected"
	count.text = "Total Users: " + str(get_tree().get_network_connected_peers().size())

remote func register_player(id) :
	players[id] = ""
	if get_tree().is_network_server():
#		rpc_id(id, "register_player", 1)
		
		for pid in players:
			rpc_id(id, "register_player", pid)
			print("called" + str(id))
		rpc("update_player_list")

remote func update_player_list():
	for x in players:
		print(x)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
