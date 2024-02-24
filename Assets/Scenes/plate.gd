extends Area2D

var order: String
var available: bool = true
var in_range: bool = false
var plate_sprite: Sprite2D


func _ready() -> void:
	plate_sprite = %PlateSprite
	hide()
	
func _process(_delta: float) -> void:
	if in_range:
		if visible and Global.waiter.carrying < Global.waiter.carry_capacity:
			available = true
			get_node("%Food/"+order).hide() 
			Global.waiter.pick_up_food(order)
			hide()

func food_ready(food: String) -> void:
	order = food
	available = false
	if Global.no_plates.has(order):
		plate_sprite.hide()
	else:
		plate_sprite.show()
	get_node("%Food/"+order).show()
	show()

#Pick up plate
func _on_body_entered(body: Node2D) -> void:	
	if body is Waiter:
		in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body is Waiter:
		in_range = false
