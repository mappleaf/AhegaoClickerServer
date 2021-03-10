extends Node


onready var player_container_scene = preload("res://src/scenes/PlayerContainer.tscn")


func start(id) -> void:
	# TOKEN FIRST
	CreatePlayerContainer(id)

func CreatePlayerContainer(id) -> void:
	var new_player_container = player_container_scene.instance()
	new_player_container.name = str(id)
	get_parent().add_child(new_player_container, true)
	var player_container = get_node("../" + str(id))
	FillPlayerContainer(player_container)

func FillPlayerContainer(player_container) -> void:
	player_container.owned_units = ServerData.test_data.owned_units
	player_container.units_in_room = ServerData.test_data.units_in_room
