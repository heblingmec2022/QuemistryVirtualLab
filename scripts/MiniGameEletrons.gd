extends PanelContainer
class_name MiniGameEletrons

## Minigame Interativo de Oxirredução (Nível 3)
## Permite ao aluno visualizar a transferência de elétrons e classificar os agentes oxidante e redutor.

signal completed_successfully

@onready var option_cuo: OptionButton = $VBoxContainer/GridContainer/OptionCuO
@onready var option_c: OptionButton = $VBoxContainer/GridContainer/OptionC
@onready var feedback_label: Label = $VBoxContainer/FeedbackLabel
@onready var confirm_btn: Button = $VBoxContainer/ConfirmButton

func _ready() -> void:
	setup_options()
	if confirm_btn:
		confirm_btn.pressed.connect(_on_confirm_pressed)

func setup_options() -> void:
	if option_cuo:
		option_cuo.clear()
		option_cuo.add_item("Selecione o papel do CuO...")
		option_cuo.add_item("Agente Oxidante (Sofre Redução: Cu²⁺ + 2e⁻ -> Cu⁰)")
		option_cuo.add_item("Agente Redutor (Sofre Oxidação)")
		
	if option_c:
		option_c.clear()
		option_c.add_item("Selecione o papel do Carbono (C)...")
		option_c.add_item("Agente Redutor (Sofre Oxidação: C⁰ -> C⁴⁺ + 4e⁻)")
		option_c.add_item("Agente Oxidante (Sofre Redução)")

func _on_confirm_pressed() -> void:
	# Opção 1 em CuO é Agente Oxidante, Opção 1 em C é Agente Redutor
	var is_cuo_correct = (option_cuo.selected == 1)
	var is_c_correct = (option_c.selected == 1)
	
	if is_cuo_correct and is_c_correct:
		feedback_label.text = "✅ Excelente! O Carbono doa elétrons (oxidação/redutor) e o Cobre recebe elétrons (redução/oxidante)."
		feedback_label.modulate = Color(0.3, 0.9, 0.3)
		GameManager.scientific_report["redox_oxidizing_agent"] = "Óxido de Cobre(II) - CuO"
		GameManager.scientific_report["redox_reducing_agent"] = "Carbono - C"
		GameManager.unlock_badge("redox_master")
		completed_successfully.emit()
	else:
		feedback_label.text = "❌ Incorreto. Lembre-se: O elemento que reduz seu Nox (Cu²⁺ -> Cu⁰) é o Agente Oxidante!"
		feedback_label.modulate = Color(1.0, 0.3, 0.3)
