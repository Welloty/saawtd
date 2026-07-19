extends Control

@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var title_label: Label = $Title
@onready var subtitle_label: Label = $Subtitle
@onready var tagline_label: Label = $Tagline
@onready var tip_label: Label = $TipLabel

var tips: Array[String] = [
	"Position SAM sites on high ground for maximum radar coverage.",
	"Different missile types counter different threat profiles. Mix your arsenal.",
	"Radar detection range determines your reaction time. Protect it at all costs.",
	"Concentrate fire on priority targets before they breach the perimeter.",
	"Low-flying UAVs can evade long-range radar. Deploy mobile interceptors.",
	"Overlapping coverage zones eliminate blind spots in your air defence.",
]

func _ready() -> void:
	fade_overlay.modulate.a = 1.0
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	tagline_label.modulate.a = 0.0
	tip_label.modulate.a = 0.0
	tip_label.text = "TIP:  " + tips[randi() % tips.size()]

	var tween := create_tween().set_parallel(true)
	tween.tween_property(fade_overlay, "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_OUT)
	tween.tween_property(title_label, "modulate:a", 1.0, 1.0).set_delay(0.4)
	tween.tween_property(subtitle_label, "modulate:a", 1.0, 1.0).set_delay(0.65)
	tween.tween_property(tagline_label, "modulate:a", 1.0, 1.0).set_delay(0.85)
	tween.tween_property(tip_label, "modulate:a", 1.0, 1.0).set_delay(1.1)

	var timer := Timer.new()
	timer.wait_time = 2.5
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(_cycle_tip)

func _cycle_tip() -> void:
	var tween := create_tween()
	tween.tween_property(tip_label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): tip_label.text = "TIP:  " + tips[randi() % tips.size()])
	tween.tween_property(tip_label, "modulate:a", 1.0, 0.4)
