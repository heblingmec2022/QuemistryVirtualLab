extends Control

## Nível 1 - O Químico Iniciante (Ciclo 1 DBR)
## Foco: Reconhecimento de materiais, montagem guiada e observação qualitativa de S1, S2 e S3.
## Alinhamento BNCC: EM13CNT101

@onready var lab_bench: LabBench2D = $LabBench2D
@onready var dialog_panel: PanelContainer = $UI/DialogPanel
@onready var dialog_text: Label = $UI/DialogPanel/VBox/DialogText
@onready var next_btn: Button = $UI/DialogPanel/VBox/NextButton
@onready var flame_toggle_btn: Button = $UI/ControlPanel/FlameToggleButton
@onready var systems_panel: PanelContainer = $UI/SystemsPanel
@onready var lbl_s1: Label = $UI/SystemsPanel/VBox/LblS1
@onready var lbl_s2: Label = $UI/SystemsPanel/VBox/LblS2
@onready var lbl_s3: Label = $UI/SystemsPanel/VBox/LblS3
@onready var score_lbl: Label = $UI/TopBar/ScoreLabel

var current_step: int = 0
var step_descriptions: Array[String] = [
	"Olá, jovem cientista! Bem-vindo ao Laboratório Virtual de Química.\nHoje investigaremos a transformação de substâncias por aquecimento.",
	"Etapa 1: Reconhecendo a bancada.\nTemos o Bico de Bunsen (S1), o Tubo com pó preto CuO + Carvão (S2) e o Copo com Água de Cal (S3).",
	"Etapa 2: Hora de aquecer!\nClique no botão 'Acender Bico de Bunsen' para iniciar o aquecimento da mistura.",
	"Etapa 3: Observe atentamente o Sistema 2 (S2) no fundo do tubo e o Sistema 3 (S3) no copo!",
	"Excelente observação!\nS1 forneceu energia térmica.\nS2 brilhou intensamente e formou um sólido avermelhado (Cobre metálico - Cu).\nS3 borbulhou e ficou branco leitoso pela formação de CaCO3.",
	"Parabéns! Você completou o Nível 1 com sucesso e garantiu sua primeira insígnia!"
]

func _ready() -> void:
	update_dialog()
	next_btn.pressed.connect(_on_next_pressed)
	flame_toggle_btn.pressed.connect(_on_flame_toggle_pressed)
	
	lab_bench.reaction_started.connect(_on_reaction_started)
	lab_bench.reaction_progressed.connect(_on_reaction_progressed)
	lab_bench.reaction_completed.connect(_on_reaction_completed)
	lab_bench.temperature_changed.connect(_on_temp_changed)
	lab_bench.turbidity_changed.connect(_on_turbidity_changed)
	
	flame_toggle_btn.disabled = true
	systems_panel.visible = false
	update_score_ui()

func update_score_ui() -> void:
	if score_lbl:
		score_lbl.text = "Pontos: %d" % GameManager.total_score

func update_dialog() -> void:
	dialog_text.text = step_descriptions[current_step]
	
	if current_step == 2:
		flame_toggle_btn.disabled = false
		next_btn.disabled = true
	elif current_step == 3:
		flame_toggle_btn.disabled = false
		next_btn.disabled = true
		systems_panel.visible = true
	else:
		next_btn.disabled = false

func _on_next_pressed() -> void:
	if current_step < step_descriptions.size() - 1:
		current_step += 1
		update_dialog()
	else:
		# Conclusão do Nível
		GameManager.unlock_badge("iniciante")
		GameManager.complete_level(1, 350)
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_flame_toggle_pressed() -> void:
	var new_state = not lab_bench.is_flame_on
	lab_bench.set_flame(new_state)
	flame_toggle_btn.text = "Apagar Bico Bunsen" if new_state else "Acender Bico Bunsen"
	
	if new_state and current_step == 2:
		current_step = 3
		update_dialog()

func _on_temp_changed(temp: float) -> void:
	lbl_s1.text = "S1 (Aquecimento): %.1f °C" % temp

func _on_reaction_started() -> void:
	lbl_s2.text = "S2 (Reação): Iniciando incandescência..."

func _on_reaction_progressed(progress: float) -> void:
	lbl_s2.text = "S2 (Reação): Redução em andamento (%.0f%%) - Formando Cobre" % (progress * 100.0)

func _on_turbidity_changed(turbidity: float) -> void:
	lbl_s3.text = "S3 (Detecção): Borbulhando CO2 -> Água de cal turva (%.0f%%)" % (turbidity * 100.0)

func _on_reaction_completed() -> void:
	lbl_s2.text = "S2 (Reação): Concluída! Cobre metálico avermelhado formado."
	lbl_s3.text = "S3 (Detecção): Precipitado branco de Carbonato de Cálcio visível."
	next_btn.disabled = false
	current_step = 4
	update_dialog()
	GameManager.add_notebook_entry("S1", "Aquecimento", "Temperatura atingiu mais de 500 °C.")
	GameManager.add_notebook_entry("S2", "Redução CuO", "Pó preto transformou-se em sólido avermelhado brilhante.")
	GameManager.add_notebook_entry("S3", "Detecção CO2", "Formação de gás que turvou a água de cal.")
