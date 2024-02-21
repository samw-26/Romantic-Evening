extends Node2D

#Seating
var chairs: Array[Node]
var available_chairs: Array[Node]
#Ordering
var order_queue: Array 
#Cook Time
var food_dict: Dictionary = {"Steak": 6, "Spaghetti": 4, "Salad": 2}
#Gameplay
var couple_scene: PackedScene = preload("res://couple.tscn")
const max_couples: int = 12
var couple_count: int = 0
var game_started: bool = false
var spawner_is_stopped: bool = false

#Need signal for when Restaurant is ready since script is autoloaded
func _on_ready() -> void:
	Restaurant.chairs = get_tree().get_nodes_in_group("chair")
	for i in range(0,Restaurant.chairs.size()/2):
		Restaurant.available_chairs.append(Restaurant.chairs[i*2])
	await get_tree().create_timer(2).timeout #Wait before starting spawning
	$SpawnTimer.start()
	game_started = true

#Instantiate couple
func spawn_couple() -> void:
	var couple = couple_scene.instantiate()
	couple.global_position = $SpawnPoint.global_position
	$Couples.add_child(couple)
	Restaurant.couple_count += 1
#@return random table position Vector2
func request_table() -> Node:
	#Get random chair position, pop available chairs
	var random_chair: int = randi()%Restaurant.available_chairs.size()
	var chair = Restaurant.available_chairs[random_chair]
	Restaurant.available_chairs.pop_at(random_chair)
	return chair
#Add customer orders
func take_order(order1: String, order2: String):
	order_queue.append(order1)
	order_queue.append(order2)

func _on_spawn_timer_timeout() -> void:
	if Restaurant.couple_count < max_couples:
		spawn_couple()

