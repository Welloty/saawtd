extends Control

@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var deploy_btn: Button = $DeployButton
@onready var settings_btn: Button = $SettingsButton
@onready var abort_btn: Button = $AbortButton

var _base_x: Dictionary = {}

func _ready() -> void:
	fade_overlay.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_OUT)

	for btn: Button in [deploy_btn, settings_btn, abort_btn]:
		_base_x[btn] = btn.position.x
		btn.mouse_entered.connect(_on_btn_entered.bind(btn))
		btn.mouse_exited.connect(_on_btn_exited.bind(btn))

func _on_btn_entered(btn: Button) -> void:
	var tween := create_tween()
	tween.tween_property(btn, "position:x", _base_x[btn] + 18.0, 0.15).set_ease(Tween.EASE_OUT)

func _on_btn_exited(btn: Button) -> void:
	var tween := create_tween()
	tween.tween_property(btn, "position:x", _base_x[btn], 0.15).set_ease(Tween.EASE_OUT)

func _on_deploy_pressed() -> void:
	# TODO: Change to actual game scene path when ready
	_fade_and_go("res://main/main.tscn")

func _on_settings_pressed() -> void:
	pass # TODO: Add settings scene

func _on_abort_pressed() -> void:
	fade_overlay.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.45).set_ease(Tween.EASE_IN)
	await tween.finished
	get_tree().quit()

func _fade_and_go(scene_path: String) -> void:
	var tween := create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_IN)
	await tween.finished
	get_tree().change_scene_to_file(scene_path)
