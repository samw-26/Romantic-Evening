extends LineEdit

var music: AudioStreamPlayer
var regEx: RegEx
var old_text: String = ""

func _ready() -> void:
	music = %BackgroundMusic
	music.set_volume_db(Global.volume)
	text = str((Global.volume + 50) * 2)
	regEx = RegEx.new()
	regEx.compile("[^0-9]")

func _on_text_submitted(new_text: String) -> void:
	var volume: int = int(new_text)
	if volume <= 0:
		set_volume(0)
	elif volume > 100:
		set_volume(100)
	else:
		set_volume(volume)
	release_focus()
func _on_text_changed(new_text: String) -> void:
	if regEx.search(new_text):
		text = old_text
		caret_column = old_text.length()
	else:
		old_text = text

func set_volume(value: int) -> void:
	var db: float
	if value != 0:
		db = value*0.5 - 50
		music.set_stream_paused(false)
		music.set_volume_db(db)
	else:
		music.set_stream_paused(true)
	text = str(value)
	Global.volume = db
