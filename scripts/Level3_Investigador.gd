extends Control

## Nível 3 - Investigador Químico (Ciclo 3 DBR)
## Foco: Investigação aberta, controle multivariavel, estequiometria, oxirredução e relatório científico.
## Alinhamento BNCC: EM13CNT303

@onready var lab_bench: LabBench2D = $LabBench2D
@onready var hypothesis_panel: PanelContainer = $UI/HypothesisPanel
@onready var reagent_option: OptionButton = $UI/HypothesisPanel/VBox/ReagentOption
@onready var hypothesis_text: LineEdit = $UI/HypothesisPanel/VBox/HypothesisText
@onready var confirm_hypothesis_btn: Button = $UI/HypothesisPanel/VBox/ConfirmHypothesisBtn

@onready var telemetry_panel: PanelContainer = $UI/TelemetryPanel
@onready var lbl_temp_telemetry: Label = $UI/TelemetryPanel/VBox/Grid/LblTemp
@onready var lbl_mass_telemetry: Label = $UI/TelemetryPanel/VBox/Grid/LblMass
@onready var lbl_turbidity_telemetry: Label = $UI/TelemetryPanel/VBox/Grid/LblTurbidity

@onready var redox_minigame: MiniGameEletrons = $UI/RedoxMinigamePanel
@onready var flame_toggle_btn: Button = $UI/WorkbenchControls/FlameToggleBtn
@onready var open_report_btn: Button = $UI/WorkbenchControls/OpenReportBtn

var current_yield: float = 0.0

func _ready() -> void:
	setup_ui()
	connect_signals()

func setup_ui() -> void:
	reagent_option.clear()
	reagent_option.add_item("Selecione o agente redutor para o teste...")
	reagent_option.add_item("Carvão / Carbono em pó (C)")
	reagent_option.add_item("Gás Hidrogênio (H2)")
	reagent_option.add_item("Monóxido de Carbono (CO)")
	
	telemetry_panel.visible = false
	redox_minigame.visible = false
	open_report_btn.visible = false

func connect_signals() -> void:
	confirm_hypothesis_btn.pressed.connect(_on_confirm_hypothesis_pressed)
	flame_toggle_btn.pressed.connect(_on_flame_toggle_pressed)
	open_report_btn.pressed.connect(_on_open_report_pressed)
	
	lab_bench.temperature_changed.connect(_on_temp_changed)
	lab_bench.turbidity_changed.connect(_on_turbidity_changed)
	lab_bench.reaction_progressed.connect(_on_reaction_progressed)
	lab_bench.reaction_completed.connect(_on_reaction_completed)
	redox_minigame.completed_successfully.connect(_on_redox_completed)

func _on_confirm_hypothesis_pressed() -> void:
	if reagent_option.selected == 1:
		hypothesis_panel.visible = false
		telemetry_panel.visible = true
		GameManager.scientific_report["selected_reagent"] = "Carbono (C)"
		GameManager.scientific_report["hypothesis"] = hypothesis_text.text
		GameManager.scientific_report["unknown_sample_identified"] = true
		flame_toggle_btn.disabled = false
	else:
		hypothesis_text.placeholder_text = "Selecione o Carbono (C) para o teste carbotérmico nesta bancada!"

func _on_flame_toggle_pressed() -> void:
	var state = not lab_bench.is_flame_on
	lab_bench.set_flame(state)
	flame_toggle_btn.text = "Apagar Bico Bunsen" if state else "Acender Bico Bunsen"

func _on_temp_changed(temp: float) -> void:
	lbl_temp_telemetry.text = "Temperatura (S1): %.1f °C" % temp
	GameManager.scientific_report["temperature_max"] = max(GameManager.scientific_report["temperature_max"], temp)

func _on_turbidity_changed(turb: float) -> void:
	lbl_turbidity_telemetry.text = "Fotometria S3 (Turvação): %.1f %%" % (turb * 100.0)

func _on_reaction_progressed(prog: float) -> void:
	# Massa inicial: 15.90g CuO + 1.20g C = 17.10g total
	# Na reação completa, 15.90g CuO gera 12.71g de Cu metálico + 4.40g de CO2 liberado
	var current_mass_solid = 17.10 - (prog * 4.39)
	lbl_mass_telemetry.text = "Balança Digital (S2): %.2f g" % current_mass_solid

func _on_reaction_completed() -> void:
	current_yield = 98.5 # % de rendimento experimental
	GameManager.scientific_report["mass_cu_obtained"] = 12.52 # g
	GameManager.scientific_report["yield_percent"] = current_yield
	lab_bench.set_submerged_tube(false) # Remove tubo em segurança
	
	# Abre Minigame de Oxirredução
	redox_minigame.visible = true

func _on_redox_completed() -> void:
	open_report_btn.visible = true
	open_report_btn.grab_focus()

func _on_open_report_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/RelatorioUI.tscn")
