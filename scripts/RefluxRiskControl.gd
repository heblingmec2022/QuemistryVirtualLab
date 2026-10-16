extends PanelContainer
class_name RefluxRiskControl

## Minigame e Monitor de Risco de Refluxo (Nível 2)
## Simula o perigo de refluxo quando o aquecimento cessa antes de retirar o tubo do béquer.

signal reflux_avoided
signal reflux_accident

@onready var progress_bar: ProgressBar = $VBoxContainer/RiskProgressBar
@onready var warning_label: Label = $VBoxContainer/WarningLabel
@onready var action_button: Button = $VBoxContainer/ActionButton

var is_active: bool = false
var risk_level: float = 0.0

func _ready() -> void:
	visible = false
	if action_button:
		action_button.pressed.connect(_on_action_button_pressed)

func start_monitoring() -> void:
	is_active = true
	visible = true
	risk_level = 0.0
	update_ui()

func set_risk(val: float) -> void:
	risk_level = clamp(val, 0.0, 1.0)
	update_ui()
	
	if risk_level >= 0.95:
		reflux_accident.emit()
		is_active = false

func update_ui() -> void:
	if progress_bar:
		progress_bar.value = risk_level * 100.0
	
	if warning_label:
		if risk_level > 0.7:
			warning_label.text = "⚠️ PERIGO CRÍTICO DE REFLUXO! AFASTE O BÉQUER AGORA!"
			warning_label.modulate = Color(1.0, 0.2, 0.2)
		elif risk_level > 0.3:
			warning_label.text = "⚠️ Alerta: Líquido subindo no tubo de desprendimento!"
			warning_label.modulate = Color(1.0, 0.8, 0.2)
		else:
			warning_label.text = "Condição de refluxo estável."
			warning_label.modulate = Color(0.4, 0.9, 0.4)

func _on_action_button_pressed() -> void:
	# Aluno clica para afastar o copo com água de cal
	risk_level = 0.0
	is_active = false
	visible = false
	reflux_avoided.emit()
	GameManager.unlock_badge("seguranca_refluxo")
