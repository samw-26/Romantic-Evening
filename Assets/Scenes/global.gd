extends Node2D

#Seating
var chairs: Array[Node]
var available_chairs: Array[Node]
#Ordering
var order_queue: Array 
var priority_queue: Array
var extra_food: Array
#Cook Time
var food_dict: Dictionary = {"Water": 2,"Wine": 2,"Beer": 2,"Steak": 5, "Spaghetti": 5, "Salad": 5,"Icecream":3,"PumpkinPie":3,"ChocolateCake":3}
var no_plates: Array = ["Water","Wine","Beer","Salad","Icecream"]
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

#Audio
var volume: float = -20

#Title
var in_title: bool = true

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
		if !closing and !in_menu:
			#Clock
			if clock_timer.is_stopped():
				clock_timer.start()
			var hour: String = str(int((300+300-clock_timer.time_left)/60))
			var minutes: String = str(int((300+300-clock_timer.time_left))%60)
			if int(minutes) < 10:
				minutes = str(0) + minutes
			clock_label.text = hour+":"+minutes+"pm"
			#Cooking
			if !priority_queue.is_empty():
				food_waiting(priority_queue.pop_back())
			elif !order_queue.is_empty():
				if extra_food.has(order_queue.back()):
					extra_food.pop_at(extra_food.find(order_queue.pop_back()))
				else:
					cook(order_queue.pop_back())

		#Once restaurant is empty and closing, show end game screen
		if couple_count == 0 and closing and !in_menu:
			get_tree().paused = true
			in_menu = true
			game_started = false
			closing_node.show()
			quota_end.text = "Quota: $"+str(quota)
			var current_tip = 0
			while current_tip <= tip:
				await get_tree().create_timer(2/tip).timeout
				tip_end.text = "Tips: $"+str(current_tip)
				current_tip += 1
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
	order_queue.push_front(order1)
	order_queue.push_front(order2)

#Cook food and display plates
func cook(order: String) -> void:
	#Cook time
	await get_tree().create_timer(food_dict[order],false).timeout
	#Display plate
	for plate in plates:
		if plate.available:
			plate.available = false
			await get_tree().create_timer(0.5,false).timeout
			plate.food_ready(order)
			return
	priority_queue.push_front(order)
	
func food_waiting(order: String):
	for plate in plates:
		if plate.available:
			plate.available = false
			await get_tree().create_timer(0.5,false).timeout
			plate.food_ready(order)
			return
	priority_queue.append(order)

