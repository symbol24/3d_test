extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	S.SpeedUpdate.connect(_update_speed)


func _update_speed(_speed:float) -> void:
	text = str(round(_speed))
