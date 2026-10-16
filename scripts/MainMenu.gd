extends Control

## Menu Principal e Hub de Níveis
## Apresenta seleção de níveis, galeria de insígnias e fundamentação teórico-metodológica.

@onready var btn_level_1: Button = $VBoxContainer/LevelCards/BtnLevel1
@onready var btn_level_2: Button = $VBoxContainer/LevelCards/BtnLevel2
@onready var btn_level_3: Button = $VBoxContainer/LevelCards/BtnLevel3
@onready var lbl_total_score: Label = $TopHeader/HBox/LblScore
@onready var badges_container: HBoxContainer = $VBoxContainer/BadgesPanel/VBox/BadgesHBox

func _ready() -> void:
	setup_level_buttons()
	update_badges_display()
	update_score()

func setup_level_buttons() -> void:
	if btn_level_1:
		btn_level_1.pressed.connect(_on_level_1_pressed)
	if btn_level_2:
		btn_level_2.pressed.connect(_on_level_2_pressed)
	if btn_level_3:
		btn_level_3.pressed.connect(_on_level_3_pressed)
	
	# Bloqueio progressivo de níveis
	var lvl2_unlocked = GameManager.levels_unlocked.get(2, false)
	var lvl3_unlocked = GameManager.levels_unlocked.get(3, false)
	
	btn_level_2.disabled = not lvl2_unlocked
	btn_level_3.disabled = not lvl3_unlocked
	
	if lvl2_unlocked:
		btn_level_2.text = "⚗️ NÍVEL 2: Técnico de Laboratório\n(Desbloqueado ⭐)\n\n• Proporções estequiométricas\n• Minigame de risco de refluxo\n• Associação de equações"
	if lvl3_unlocked:
		btn_level_3.text = "🔬 NÍVEL 3: Investigador Químico\n(Desbloqueado ⭐)\n\n• Amostra desconhecida e hipótese\n• Balança digital e fotometria\n• Minigame redox e relatório"

func _on_level_1_pressed() -> void:
	print("[MainMenu] Carregando Nível 1...")
	get_tree().change_scene_to_file("res://scenes/Level1_Iniciante.tscn")

func _on_level_2_pressed() -> void:
	print("[MainMenu] Carregando Nível 2...")
	get_tree().change_scene_to_file("res://scenes/Level2_Tecnico.tscn")

func _on_level_3_pressed() -> void:
	print("[MainMenu] Carregando Nível 3...")
	get_tree().change_scene_to_file("res://scenes/Level3_Investigador.tscn")

func update_score() -> void:
	lbl_total_score.text = "Pontuação Total: %d pts  " % GameManager.total_score

func update_badges_display() -> void:
	if badges_container == null:
		return
		
	for child in badges_container.get_children():
		child.queue_free()
		
	for b_id in GameManager.badges.keys():
		var b_data = GameManager.badges[b_id]
		var badge_label = Label.new()
		if b_data["unlocked"]:
			badge_label.text = "%s %s" % [b_data["icon"], b_data["name"]]
			badge_label.modulate = Color(1.0, 0.85, 0.2)
		else:
			badge_label.text = "🔒 Bloqueada"
			badge_label.modulate = Color(0.5, 0.5, 0.5)
		badges_container.add_child(badge_label)
