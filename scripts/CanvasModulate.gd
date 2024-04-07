extends CanvasModulate

func _ready() -> void:
	hide()

func _on_Train_train_finished(score) -> void:
	hide()

func _on_SpeechContainer_game_started() -> void:
	self.visible = true

func _on_SpeechContainer_game_resumed() -> void:
	self.visible = true
	
func _on_SpeechContainer_game_paused() -> void:
	self.hide()
