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
var quota: int = 200
var quota_label: Label
var time_left: float 
var clock_label: Label
var clock_timer: Timer
var closing: bool = false
var in_menu: bool = false
#End game screen
var closing_node: Control
var quota_end: Label
var tip_end: Label
var final_label: Label

#Animation control
func animate(anim: AnimatedSprite2D, direction: Vector2):
	if direction == Vector2.ZERO:
		anim.play("idle")
	elif direction == Vector2.RIGHT:
		anim.play("walk_right")
	elif direction == Vector2.LEFT:
		anim.play("walk_left")
	elif direction == Vector2.UP:
		anim.play("walk_back")
	elif direction == Vector2.DOWN:
		anim.play("walk_front")

#Game loop
func _process(_delta: float) -> void:
	#When nodes are ready
	if game_started:
		if !closing:
			#Clock
			if clock_timer.is_stopped():
				clock_timer.start()
			var hour: String = str(int((300+300-clock_timer.time_left)/60))
			var minutes: String = str(int((300+300-clock_timer.time_left))%60)
			if int(minutes) < 10:
				minutes = str(0) + minutes
			clock_label.text = hour+":"+minutes+"pm"
			#Cooking
			if !order_queue.is_empty():
				cook(order_queue.pop_front())

		#Once restaurant is empty and closing, show end game screen
		if couple_count == 0 and closing and !in_menu:
			in_menu = true
			game_started = false
			closing_node.show()
			quota_end.text = "Quota: $"+str(quota)
			tip_end.text = "Tips: $"+str(tip)
			if quota > tip:
				final_label.text = "You Did Not Meet Quota"
			else:
				final_label.text = "You Met Quota!"


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

