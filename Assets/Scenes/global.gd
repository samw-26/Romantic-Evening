extends Node2D

#Seating
var chairs: Array[Node]
var available_chairs: Array[Node]
#Ordering
var order_queue: Array 
#Cook Time
var food_dict: Dictionary = {"Steak": 6, "Spaghetti": 4, "Salad": 2}
var plates: Array[Node]
#Gameplay
const max_couples: int = 12
var couple_count: int = 0
var game_started: bool = false

#Waiter
var waiter: Waiter

#UI
var tip: int = 0
var tip_label: Label
var quota_label: Label
var time_left: float 
var clock_label: Label
var clock_timer: Timer
var closing: bool = false

#Game loop
func _process(_delta: float) -> void:
	#When nodes are ready
	if game_started:
		#Clock
		if clock_timer.is_stopped() and !closing:
			clock_timer.start()
		var hour: String = str(int((300+300-clock_timer.time_left)/60))
		var minutes: String = str(int((300+300-clock_timer.time_left))%60)
		if int(minutes) < 10:
			minutes = str(0) + minutes
		clock_label.text = hour+":"+minutes+"pm"
		#Cooking
		if !order_queue.is_empty():
			cook(order_queue.pop_front())

#@return random table position Vector2
func request_table() -> Node:
	#Get random chair position, pop available chairs
	var random_chair: int = randi()%available_chairs.size()
	var chair = available_chairs[random_chair]
	available_chairs.pop_at(random_chair)
	return chair

#Add customer orders
func take_order(order1: String, order2: String):
	order_queue.append(order1)
	order_queue.append(order2)

#Cook food and display plates
func cook(order: String) -> void:
	#Cook
	match order: 
			"Steak":
				await get_tree().create_timer(food_dict[order]).timeout
			"Spaghetti":
				await get_tree().create_timer(food_dict[order]).timeout
			"Salad":
				await get_tree().create_timer(food_dict[order]).timeout
	#Display plate
	for plate in plates:
		if plate.available:
			plate.food_ready(order)
			break

