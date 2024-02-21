extends Area2D

var order: String
var available: bool = false
var steak_time: int = 6
var spaghetti_time: int = 4
var salad_time: int = 2

func _ready() -> void:
	hide()
	available = true

#Cooking Process
func _process(_delta: float) -> void:
	if Restaurant.order_queue.size() > 0 and available:
		order = Restaurant.order_queue.pop_front()
		available = false
		#Cook timers
		match order: 
			"Steak":
				await get_tree().create_timer(steak_time).timeout
			"Spaghetti":
				await get_tree().create_timer(spaghetti_time).timeout
			"Salad":
				await get_tree().create_timer(salad_time).timeout
		get_node("%Food/"+order).show()
		show()

#Pick up plate
func _on_body_entered(body: Node2D) -> void:
	if body is Waiter:
		body = body as Waiter
		if !available and body.food_carried.size() < body.carry_capacity:
			available = true
			hide()
			get_node("%Food/"+order).hide() 
			body.pick_up_food(order)

