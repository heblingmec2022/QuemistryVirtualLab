extends Control

## Nível 2 - Técnico de Laboratório (Ciclo 2 DBR)
## Foco: Controle de variáveis (proporções, chama), segurança contra refluxo e equações químicas.
## Alinhamento BNCC: EM13CNT204

@onready var lab_bench: LabBench2D = $LabBench2D
@onready var reflux_panel: RefluxRiskControl = $UI/RefluxRiskPanel
@onready var proportion_option: OptionButton = $UI/PrepPanel/VBox/ProportionOption
@onready var start_heating_btn: Button = $UI/PrepPanel/VBox/StartHeatingBtn
@onready var flame_slider: HSlider = $UI/ControlPanel/VBox/FlameSlider
@onready var flame_toggle_btn: Button = $UI/ControlPanel/VBox/FlameToggleBtn
@onready var detach_beaker_btn: Button = $UI/ControlPanel/VBox/DetachBeakerBtn
@onready var status_lbl: Label = $UI/StatusPanel/VBox/StatusLabel
@onready var equation_panel: PanelContainer = $UI/EquationPanel
@onready var eq_input_cu: SpinBox = $UI/EquationPanel/VBox/HBoxEq/SpinCu
@onready var eq_input_co2: SpinBox = $UI/EquationPanel/VBox/HBoxEq/SpinCO2
@onready var check_eq_btn: Button = $UI/EquationPanel/VBox/CheckEqBtn
@onready var eq_feedback_lbl: Label = $UI/EquationPanel/VBox/EqFeedbackLbl
@onready var finish_level_btn: Button = $UI/FinishLevelBtn

var selected_ratio_correct: bool = false
var reaction_done: bool = false
var equation_solved: bool = false

func _ready() -> void:
	setup_ui()
	connect_signals()

func setup_ui() -> void:
	proportion_option.clear()
	proportion_option.add_item("Selecione a proporção molar CuO : C...")
	proportion_option.add_item("Proporção 2 : 1 (Estequiométrica correta)")
	proportion_option.add_item("Proporção 1 : 1 (Excesso de Carvão)")
	proportion_option.add_item("Proporção 4 : 1 (Excesso de Óxido de Cobre)")
	
	equation_panel.visible = false
	finish_level_btn.visible = false
	$UI/ControlPanel.visible = false

func connect_signals() -> void:
	start_heating_btn.pressed.connect(_on_start_prep_pressed)
	flame_slider.value_changed.connect(_on_flame_slider_changed)
	flame_toggle_btn.pressed.connect(_on_flame_toggle_pressed)
	detach_beaker_btn.pressed.connect(_on_detach_beaker_pressed)
	check_eq_btn.pressed.connect(_on_check_equation_pressed)
	finish_level_btn.pressed.connect(_on_finish_level_pressed)
	
	lab_bench.reaction_completed.connect(_on_bench_reaction_completed)
	lab_bench.reflux_hazard_alert.connect(_on_reflux_alert)
	lab_bench.tube_fractured_thermal_shock.connect(_on_tube_fractured)
	lab_bench.safe_procedure_achieved.connect(_on_safe_procedure)

func _on_start_prep_pressed() -> void:
	if proportion_option.selected == 1:
		selected_ratio_correct = true
		status_lbl.text = "✅ Proporção 2:1 selecionada. Bancada pronta para aquecimento!"
		status_lbl.modulate = Color(0.3, 0.9, 0.3)
		$UI/PrepPanel.visible = false
		$UI/ControlPanel.visible = true
	else:
		status_lbl.text = "⚠️ Proporção inadequada. Selecione a proporção estequiométrica correta (2 CuO : 1 C)!"
		status_lbl.modulate = Color(1.0, 0.4, 0.4)

func _on_flame_slider_changed(val: float) -> void:
	lab_bench.flame_intensity = val / 100.0

func _on_flame_toggle_pressed() -> void:
	var new_state = not lab_bench.is_flame_on
	lab_bench.set_flame(new_state)
	flame_toggle_btn.text = "Apagar Bico Bunsen" if new_state else "Acender Bico Bunsen"
	
	if not new_state and reaction_done and lab_bench.is_delivery_tube_submerged:
		reflux_panel.start_monitoring()

func _on_detach_beaker_pressed() -> void:
	lab_bench.set_submerged_tube(false)
	detach_beaker_btn.disabled = true
	detach_beaker_btn.text = "Tubo Afastado com Segurança ✅"
	status_lbl.text = "✅ Procedimento de segurança realizado: Tubo removido da água de cal antes do resfriamento!"
	status_lbl.modulate = Color(0.3, 0.9, 0.3)
	reflux_panel.visible = false
	GameManager.unlock_badge("seguranca_refluxo")

func _on_reflux_alert(risk: float) -> void:
	reflux_panel.set_risk(risk)

func _on_tube_fractured() -> void:
	status_lbl.text = "💥 ACIDENTE! O líquido frio foi sugado para dentro do tubo quente e causou fratura por choque térmico!"
	status_lbl.modulate = Color(1.0, 0.2, 0.2)
	reflux_panel.visible = false

func _on_safe_procedure() -> void:
	if reaction_done and not equation_solved:
		equation_panel.visible = true

func _on_bench_reaction_completed() -> void:
	reaction_done = true
	status_lbl.text = "🔔 Reação finalizada! ATENÇÃO: Desconecte o tubo da água de cal antes de apagar a chama para evitar refluxo!"
	status_lbl.modulate = Color(1.0, 0.8, 0.2)

func _on_check_equation_pressed() -> void:
	var cu_val = int(eq_input_cu.value)
	var co2_val = int(eq_input_co2.value)
	
	var res = EquationBalancer.validate_reduction_equation(2, 1, cu_val, co2_val)
	if res["is_correct"]:
		equation_solved = true
		eq_feedback_lbl.text = "✅ " + res["feedback"]
		eq_feedback_lbl.modulate = Color(0.3, 0.9, 0.3)
		finish_level_btn.visible = true
	else:
		eq_feedback_lbl.text = "❌ " + res["feedback"]
		eq_feedback_lbl.modulate = Color(1.0, 0.3, 0.3)

func _on_finish_level_pressed() -> void:
	GameManager.unlock_badge("tecnico")
	GameManager.complete_level(2, 450)
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
