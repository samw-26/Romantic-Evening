extends Area2D

var order: String
var available: bool = true
var in_range: bool = false
var steak_time: int = 6
var spaghetti_time: int = 4
var salad_time: int = 2

func _ready() -> void:
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
	get_node("%Food/"+order).show()
	show()

#Pick up plate
func _on_body_entered(body: Node2D) -> void:	
	if body is Waiter:
		in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body is Waiter:
		in_range = false
