class_name Woman
extends CharacterBody2D

var table_destination: Vector2

func _ready() -> void:
	$Dress.set_modulate(Color(randf(),randf(),randf(),1))
	table_destination = Restaurant.chair_positions[1].position
	global_position = table_destination
