extends Control

signal game_paused_from_menu_button

func _ready() -> void:
	self.visible = false

func _on_SpeechContainer_game_paused() -> void:
	self.visible = false

func _on_SpeechContainer_game_resumed() -> void:
	self.visible = true

func _on_SpeechContainer_game_started() -> void:
	self.visible = true

func _on_Menu_button_down() -> void:
	emit_signal("game_paused_from_menu_button")
