extends Node2D

#Seating
var chairs: Array
var available_chairs: Array
var chair_position: Vector2
#Ordering
var order_queue: Array 

func _ready() -> void:
	#Get array of chairs, get every even index chair
	chairs = get_tree().get_nodes_in_group("chair")
	for i in range(0,chairs.size()/2):
		available_chairs.append(chairs[i*2])
#@return random table position Vector2
func request_table() -> Vector2:
	#Get random chair position, pop available chairs
	var random_chair: int = randi()%available_chairs.size()
	chair_position = available_chairs[random_chair].position
	available_chairs.pop_at(random_chair)
	return chair_position

func take_order(order1: String, order2: String):
	order_queue.append(order1)
	order_queue.append(order2)
	for i in order_queue:
		print(i)
