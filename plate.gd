extends Area2D

var order: String
var available: bool = false


func _ready() -> void:
	hide()
	%PlateRespawn.start()

func _process(_delta: float) -> void:
	if Restaurant.order_queue.size() > 0 and available:
		order = Restaurant.order_queue.pop_front()
		get_node("%Food/"+order).show()
		show()
		available = false

func _on_body_entered(body: Node2D) -> void:
	if body is Waiter and visible and body.carrying < body.carry_capacity:
		%PlateRespawn.start()
		hide()
		get_node("%Food/"+order).hide() 
		body.pick_up_food(order)

func _on_plate_respawn_timeout() -> void:
	available = true
