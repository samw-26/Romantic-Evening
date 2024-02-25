class_name Couple
extends CharacterBody2D
## Controls couple behaviour such as movement, tipping, ordering, and leaving.


var center: int = 722
var row_diff: int = 80
var off_screen: int = 960
var speed: int = 200

#Animations
var man_anim: AnimatedSprite2D
var woman_anim: AnimatedSprite2D
var dress: AnimatedSprite2D
var eyes: AnimatedSprite2D

#Booleans
var at_table: bool = false
var ready_to_order: bool = false
var has_ordered: bool = false
var order1_received: bool = false
var order2_received: bool = false
var hunger_started: bool = false
var freed_table: bool = false
var in_range: bool = false

#Find table
var table: Node2D
var table_destination: Vector2
var direction: Vector2 = Vector2.ZERO
var current_table: Table

#Ordering/Dining
var drink_options: Array = ["Water", "Wine", "Beer"]
var main_options: Array = ["Steak","Spaghetti","Salad"]
var dessert_options: Array = ["Icecream", "PumpkinPie", "ChocolateCake"]
var man_orders: Array
var woman_orders: Array
var course_counter: int = 0

#Bubbles
var man_bubble: Sprite2D
var woman_bubble: Sprite2D
var man_question: Sprite2D
var woman_question: Sprite2D
#Man Chosen orders
var man_drink: Sprite2D
var man_main: Sprite2D
var man_dessert: Sprite2D
var man_food_sprites: Array
#Woman Chosen orders
var woman_drink: Sprite2D
var woman_main: Sprite2D
var woman_dessert: Sprite2D
var woman_food_sprites: Array

#Eating
var meal_timer: Timer
var eating: bool = false
var finished: bool = false

#Tip
var tip: int = 0
var give_tip: bool = false
var has_triggered_animation = false

#Love bar
var love_bar: ProgressBar
var love_lost: int = 0 
var max_expected_love: int = 0


func _ready() -> void:
	#Animation nodes
	man_anim = %Man
	woman_anim = %Woman
	dress= %Dress
	eyes = %Eyes
	#Choose orders and set meal duration
	man_orders = [drink_options.pick_random(),main_options.pick_random(),dessert_options.pick_random()]
	woman_orders = [drink_options.pick_random(),main_options.pick_random(),dessert_options.pick_random()]
	meal_timer = %MealTimer as Timer
	#Nodes
	#Man
	man_bubble = get_node("%ManOrder")
	man_question = %ManOrder/Question
	man_drink = get_node("%ManOrder/"+man_orders[0])
	man_main = get_node("%ManOrder/"+man_orders[1])
	man_dessert = get_node("%ManOrder/"+man_orders[2])
	man_food_sprites = [man_drink,man_main,man_dessert]
	#Woman
	woman_bubble = get_node("%WomanOrder")
	woman_question = %WomanOrder/Question
	woman_drink = get_node("%WomanOrder/"+woman_orders[0])
	woman_main = get_node("%WomanOrder/"+woman_orders[1])
	woman_dessert = get_node("%WomanOrder/"+woman_orders[2])
	woman_food_sprites = [woman_drink,woman_main,woman_dessert]
	
	#Setup
	man_bubble.hide()
	man_question.show()
	woman_bubble.hide()
	woman_question.show()

	#Randomize woman
	var random_eye_color = [Color.BLUE,Color.DARK_GREEN,Color.SADDLE_BROWN,Color.BLACK].pick_random()
	var random_dress_color = [Color.BLUE,Color.DARK_VIOLET,Color.RED,Color.WEB_GREEN,Color.CORAL,Color.DARK_ORANGE,Color.DIM_GRAY,Color.WEB_PURPLE, Color.GRAY,Color.CRIMSON,Color.ORANGE,Color.ORANGE_RED].pick_random()
	dress.set_modulate(random_dress_color)
	eyes.set_modulate(random_eye_color)
	
	#Love bar
	love_bar = %LoveBar as ProgressBar
	love_bar.hide()
	love_bar.value = 0
	max_expected_love = int(meal_timer.get_wait_time())
	
	#Get random table
	table = Global.request_table()
	table_destination = table.position
	
	


func _physics_process(_delta: float) -> void:
	#Animations
	if !at_table:
		Global.animate(man_anim,direction)
		Global.animate(woman_anim,direction)
		Global.animate(dress,direction)
		eye_frame(direction)
	elif man_anim.is_playing():
		man_anim.stop()
		man_anim.set_animation("walk_right")
		man_anim.frame = 1
		woman_anim.stop()
		woman_anim.set_animation("walk_left")
		woman_anim.frame = 1
		dress.stop()
		dress.set_animation("walk_left")
		dress.frame = 1
		eye_frame(Vector2.LEFT)

	if !Global.closing:
		#Go to table
		if(!at_table and !finished):
			go_to_table()
		#Dining
		if(at_table):
			#Ordering, wait for customers to decide
			if !ready_to_order:
				await get_tree().create_timer(2,false).timeout
				ready_to_order = true
			elif ready_to_order and !eating:
				if !love_bar.visible:
					love_bar.show()
				order()
			#Eating 
			elif eating:
				if meal_timer.is_stopped():
					meal_timer.start()
					%LoveTimer.start()
		#Finished
		if finished:
			exit_restaurant()

	if Global.closing:
		finished = true
		exit_restaurant()

	#Movement
	velocity = direction * speed
	move_and_slide()

#Go to table
func go_to_table() -> void:
	if(global_position.y > table_destination.y + row_diff):
		direction = Vector2.UP
	elif(abs(global_position.x - table_destination.x) > 5):
		if(global_position.x > table_destination.x + 5):
			direction = Vector2.LEFT
		else:
			direction = Vector2.RIGHT
	elif(global_position.y > table_destination.y + 15):
			direction = Vector2.UP
	else:
		direction = Vector2.ZERO
		at_table = true

#Ordering
func order() -> void:
	#Start getting hungy
	if !hunger_started:
		%StatusTimer.start()
		hunger_started = true
	#Man and woman show question mark bubbles
	if !has_ordered and !man_bubble.visible and !woman_bubble.visible:
		man_question.show()
		woman_question.show()
		man_bubble.show()
		woman_bubble.show()
	
	#Take order if in range
	if in_range:
		#Show food when in range and have not ordered
		if !has_ordered:
			has_ordered = true
			man_question.hide()
			woman_question.hide()
			man_food_sprites[course_counter].show()
			woman_food_sprites[course_counter].show()
			Global.take_order(man_orders[course_counter],woman_orders[course_counter])
		#Attempt to serve food if has ordered
		elif has_ordered:
			if !order1_received:
				order1_received = Global.waiter.serve_food(man_orders[course_counter])
				
				if order1_received:
					man_food_sprites[course_counter].hide()
					man_bubble.hide()
					current_table.display_food(man_orders[course_counter],"")
					
			if !order2_received:
				order2_received = Global.waiter.serve_food(woman_orders[course_counter])
				
				if order2_received:
					woman_food_sprites[course_counter].hide()
					woman_bubble.hide()
					current_table.display_food("",woman_orders[course_counter])

	#Stop timers, commence eating
	if order1_received and order2_received:
		eating = true
		%StatusTimer.stop()

#Exit Restaurant
func exit_restaurant() -> void:
	$Area2D.monitoring = false
	at_table = false

	if love_bar.visible:
		love_bar.visible = false

	if !give_tip:
		Global.tip += int(love_bar.value)
		tip = int(love_bar.value)
		Global.tip_label.text = "Tips: $" + str(Global.tip)
		give_tip = true

	if(!freed_table):
		Global.available_chairs.append(table)
		%ManOrder.hide()
		%WomanOrder.hide()
		freed_table = true
	if (global_position.y < table_destination.y + row_diff):
		direction = Vector2.DOWN
	elif abs(global_position.x - center) > 2:
		if global_position.x < center:
			direction = Vector2.RIGHT
		elif global_position.x > center:
			direction = Vector2.LEFT
	elif abs(global_position.y - off_screen) > 5:
		direction = Vector2.DOWN
	else:
		Global.couple_count -= 1
		queue_free()

#Take Order
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Waiter:
		in_range = true
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Waiter:
		in_range = false

func _on_status_timer_timeout() -> void:
	#Hunger status
	if !eating:
		if !order1_received or !order2_received:
			if love_bar.value == 0:
				%WarningTimer.start()
			else:
				%LoveTimer.start()
		if !order1_received and !order2_received:
			%FlickerTimerMan.start()
			%FlickerTimerWoman.start()
		elif !order1_received:
			%FlickerTimerMan.start()
		elif !order2_received:
			%FlickerTimerWoman.start()

func _on_flicker_timer_man_timeout() -> void:
	#Hunger
	if !eating:
		if !has_ordered:
			man_question.visible = !man_question.visible
		elif has_ordered and !order1_received:
			man_food_sprites[course_counter].visible = !man_food_sprites[course_counter].visible
	else:
		%FlickerTimerMan.stop()

func _on_flicker_timer_woman_timeout() -> void:
	#Hunger
	if !eating:
		if !has_ordered:
			woman_question.visible = !woman_question.visible
		elif has_ordered and !order2_received:
			woman_food_sprites[course_counter].visible = !woman_food_sprites[course_counter].visible
	else:
		%FlickerTimerWoman.stop()

func eye_frame(dir: Vector2):
	if dir == Vector2.ZERO:
		eyes.frame = 0
	elif dir == Vector2.LEFT:
		eyes.frame = 1
	elif dir == Vector2.RIGHT:
		eyes.frame = 2
	elif dir == Vector2.UP:
		eyes.frame = 3
	elif dir == Vector2.DOWN:
		eyes.frame = 0

func _on_meal_timer_timeout() -> void:
	current_table.hide_food()
	course_counter += 1
	love_bar.value += max_expected_love - love_bar.value - love_lost
	if course_counter > 2:
		finished = true
		%LoveTimer.stop()
	elif course_counter == 1:
		meal_timer.set_wait_time(30)
	elif course_counter == 2:
		meal_timer.set_wait_time(15)
	if !finished:
		max_expected_love += int(meal_timer.get_wait_time())
		eating = false
		hunger_started = false
		has_ordered = false
		order1_received = false
		order2_received = false
		%LoveTimer.stop()

func _on_love_timer_timeout() -> void:
	if love_bar.value < 1 and !eating:
		finished = true
		if has_ordered:
			if !order1_received:
				Global.extra_food.append(man_orders[course_counter])
			if !order2_received:
				Global.extra_food.append(woman_orders[course_counter])
		%LoveTimer.stop()
	if !eating:
		love_bar.value -= 1
		love_lost += 1
	else:
		love_bar.value += 1

func _on_warning_timer_timeout() -> void:
	%LoveTimer.start()
