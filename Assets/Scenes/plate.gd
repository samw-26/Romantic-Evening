extends Area2D

var order: String
var available: bool = true
var steak_time: int = 6
var spaghetti_time: int = 4
var salad_time: int = 2

func _ready() -> void:
	hide()

func food_ready(food: String) -> void:
	order = food
	available = false
	get_node("%Food/"+order).show()
	show()

#Pick up plate
func _on_body_entered(body: Node2D) -> void:	
	if body is Waiter:
		body = body as Waiter
		if visible and body.food_carried.size() < body.carry_capacity:
			available = true
			get_node("%Food/"+order).hide() 
			body.pick_up_food(order)
			hide()

