extends Control

## Tela de Relatório Científico e Avaliação por Rúbrica (Nível 3)
## Permite a redação, revisão de dados experimentais e atribuição de pontuação por competências.

@onready var lbl_summary: Label = $PanelContainer/VBox/ScrollContainer/ContentVBox/LblSummary
@onready var line_conclusion: TextEdit = $PanelContainer/VBox/ScrollContainer/ContentVBox/TextConclusion
@onready var rubric_label: Label = $PanelContainer/VBox/ScrollContainer/ContentVBox/LblRubric
@onready var submit_btn: Button = $PanelContainer/VBox/SubmitButton
@onready var back_btn: Button = $PanelContainer/VBox/BackButton

func _ready() -> void:
	display_report_data()
	submit_btn.pressed.connect(_on_submit_pressed)
	back_btn.pressed.connect(_on_back_pressed)

func display_report_data() -> void:
	var rep = GameManager.scientific_report
	var text_content = """=== RELATÓRIO DE INVESTIGAÇÃO EXPERIMENTAL ===

1. IDENTIFICAÇÃO DA AMOSTRA E HIPÓTESE
   - Amostra Sólida: Óxido de Cobre(II) - CuO (Pó Preto)
   - Agente Redutor Selecionado: %s
   - Hipótese Formulada: "%s"

2. DADOS EXPERIMENTAIS COLETADOS
   - Temperatura Máxima Atingida: %.1f °C
   - Massa Inicial de Reagentes: 17.10 g (15.90 g CuO + 1.20 g C)
   - Massa de Cobre (Cu) Obtida na Balança: %.2f g
   - Rendimento Prático da Reação: %.1f %%

3. CONCEITOS QUÍMICOS E OXIRREDUÇÃO
   - Reação Global: 2 CuO(s) + C(s) -> 2 Cu(s) + CO2(g)
   - Agente Oxidante: %s
   - Agente Redutor: %s
   - Detecção do Gás: Ca(OH)2(aq) + CO2(g) -> CaCO3(s) + H2O(l) (Turvação leitosa)
""" % [
		rep.get("selected_reagent", "C"),
		rep.get("hypothesis", "Redução carbotérmica formará cobre metálico"),
		rep.get("temperature_max", 580.0),
		rep.get("mass_cu_obtained", 12.52),
		rep.get("yield_percent", 98.5),
		rep.get("redox_oxidizing_agent", "CuO"),
		rep.get("redox_reducing_agent", "C")
	]
	
	lbl_summary.text = text_content
	rubric_label.text = "Rúbrica de Avaliação: [1. Hipótese: 20 pts] + [2. Segurança e Controle: 30 pts] + [3. Estequiometria: 25 pts] + [4. Oxirredução: 25 pts] = Total: 100 pts"

func _on_submit_pressed() -> void:
	GameManager.scientific_report["conclusion"] = line_conclusion.text
	GameManager.scientific_report["rubric_score"] = 100
	GameManager.unlock_badge("pesquisador")
	GameManager.complete_level(3, 500)
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
