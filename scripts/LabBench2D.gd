extends Node2D
class_name LabBench2D

## Bancada Virtual de Química 2D (Experimento Redução do CuO por C)
## Renderiza e simula em tempo real:
## - S1: Sistema de Aquecimento (Bico de Bunsen, suporte universal, controle de temperatura)
## - S2: Sistema de Reação (Tubo de ensaio, incandescência, conversão CuO+C -> Cu avermelhado)
## - S3: Sistema de Detecção (Água de cal Ca(OH)2, borbulhamento de CO2 e turvação leitosa CaCO3)
## - Mecânica de Refluxo (Vácuo térmico e sucção de líquido)

signal reaction_started
signal reaction_progressed(progress: float)
signal reaction_completed
signal temperature_changed(temp: float)
signal turbidity_changed(turbidity: float)
signal system_highlighted(system_id: String)
signal reflux_hazard_alert(risk_level: float)
signal tube_fractured_thermal_shock
signal safe_procedure_achieved

# Variáveis de Estado do Experimento
@export var is_flame_on: bool = false
@export var flame_intensity: float = 0.8
@export var temperature: float = 25.0 # °C
@export var target_reaction_temp: float = 550.0 # °C onde a redução ocorre rapidamente
@export var reaction_progress: float = 0.0 # 0.0 (Preto CuO+C) -> 1.0 (Cobre Metálico Cu)
@export var limewater_turbidity: float = 0.0 # 0.0 (Límpida) -> 1.0 (Turva CaCO3)

# Física e Segurança do Refluxo
@export var is_delivery_tube_submerged: bool = true
@export var reflux_liquid_height: float = 0.0 # Altura do líquido subindo no tubo (0 a 100 px)
@export var reflux_risk: float = 0.0 # 0.0 (Seguro) a 1.0 (Crítico)
@export var is_broken: bool = false

# Cores Químicas Reais
const COLOR_CUO_C: Color = Color(0.12, 0.12, 0.14, 1.0) # Pó Preto de Óxido de Cobre e Carvão
const COLOR_INCANDESCENCE: Color = Color(1.0, 0.55, 0.1, 1.0) # Brilho alaranjado incandescente
const COLOR_COPPER_METAL: Color = Color(0.85, 0.45, 0.25, 1.0) # Cobre avermelhado formado
const COLOR_LIMEWATER_CLEAR: Color = Color(0.85, 0.95, 1.0, 0.35) # Água de cal transparente
const COLOR_LIMEWATER_MILKY: Color = Color(0.95, 0.95, 0.95, 0.88) # Turvação por Carbonato de Cálcio

# Animação e Partículas
var anim_time: float = 0.0
var bubbles: Array[Dictionary] = []

func _ready() -> void:
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	anim_time += delta
	
	# 1. Simulação Térmica (S1)
	if is_flame_on and not is_broken:
		var target_temp = 25.0 + (flame_intensity * 750.0)
		temperature = move_toward(temperature, target_temp, delta * 85.0 * flame_intensity)
	else:
		temperature = move_toward(temperature, 25.0, delta * 30.0)
		
	temperature_changed.emit(temperature)
	
	# 2. Simulação da Reação Química de Redução (S2)
	# 2 CuO (s) + C (s) -> 2 Cu (s) + CO2 (g)
	if temperature >= 380.0 and reaction_progress < 1.0 and not is_broken:
		var reaction_speed = (temperature - 350.0) / 400.0 * 0.08
		if reaction_progress == 0.0:
			reaction_started.emit()
		reaction_progress = clamp(reaction_progress + reaction_speed * delta, 0.0, 1.0)
		reaction_progressed.emit(reaction_progress)
		if reaction_progress >= 1.0:
			reaction_completed.emit()
			
	# 3. Simulação da Reação de Detecção do CO2 na Água de Cal (S3)
	# Ca(OH)2 (aq) + CO2 (g) -> CaCO3 (s) + H2O (l)
	if reaction_progress > 0.05 and reaction_progress < 1.0 and is_flame_on and not is_broken:
		if is_delivery_tube_submerged:
			limewater_turbidity = clamp(limewater_turbidity + delta * 0.12, 0.0, 1.0)
			turbidity_changed.emit(limewater_turbidity)
			
			# Gerar bolhas de CO2
			if randf() < 0.35:
				bubbles.append({
					"pos": Vector2(randf_range(490, 520), 380),
					"radius": randf_range(2.0, 4.5),
					"speed": randf_range(40.0, 80.0)
				})
	
	# Atualizar bolhas
	for i in range(bubbles.size() - 1, -1, -1):
		bubbles[i]["pos"].y -= bubbles[i]["speed"] * delta
		bubbles[i]["pos"].x += sin(anim_time * 5.0 + i) * 0.5
		if bubbles[i]["pos"].y < 330:
			bubbles.remove_at(i)
			
	# 4. Simulação de Risco de Refluxo (Física do Resfriamento e Vácuo)
	# Se apagar o fogo com o tubo mergulhado na água fria: sucção de líquido!
	if not is_flame_on and temperature > 150.0 and is_delivery_tube_submerged and reaction_progress > 0.1:
		reflux_risk = clamp(reflux_risk + delta * 0.45, 0.0, 1.0)
		reflux_liquid_height = reflux_risk * 140.0
		reflux_hazard_alert.emit(reflux_risk)
		
		# Se atingir o topo e entrar no tubo quente: Choque térmico e quebra!
		if reflux_risk >= 0.95 and not is_broken:
			is_broken = true
			tube_fractured_thermal_shock.emit()
	else:
		reflux_risk = move_toward(reflux_risk, 0.0, delta * 0.3)
		reflux_liquid_height = move_toward(reflux_liquid_height, 0.0, delta * 60.0)
		
	queue_redraw()

func _draw() -> void:
	# Desenho da Bancada do Laboratório (Dimensões 800 x 500 px relativo)
	draw_lab_stand()
	draw_bunsen_burner()
	draw_test_tube_and_contents()
	draw_delivery_tube()
	draw_limewater_beaker()
	if is_broken:
		draw_broken_effect()

func draw_lab_stand() -> void:
	# Base de ferro pesada do Suporte Universal
	draw_rect(Rect2(120, 430, 200, 20), Color(0.2, 0.22, 0.25), true)
	# Haste vertical metálica
	draw_rect(Rect2(150, 120, 10, 310), Color(0.65, 0.68, 0.72), true)
	# Garra fixadora (clamp) segurando o tubo
	draw_line(Vector2(155, 230), Vector2(250, 245), Color(0.35, 0.38, 0.42), 6.0)
	draw_circle(Vector2(250, 245), 9.0, Color(0.25, 0.28, 0.32))

func draw_bunsen_burner() -> void:
	# S1 - Bico de Bunsen
	var burner_pos = Vector2(280, 430)
	# Base circular
	draw_rect(Rect2(burner_pos.x - 30, burner_pos.y - 12, 60, 12), Color(0.3, 0.33, 0.38), true)
	# Tubo vertical do bico
	draw_rect(Rect2(burner_pos.x - 8, burner_pos.y - 85, 16, 73), Color(0.7, 0.72, 0.76), true)
	# Válvula de entrada de ar (anel)
	draw_rect(Rect2(burner_pos.x - 10, burner_pos.y - 40, 20, 14), Color(0.85, 0.65, 0.15), true)
	
	# Chama Animada do Bico Bunsen
	if is_flame_on and not is_broken:
		var flame_h = 45.0 * flame_intensity + sin(anim_time * 25.0) * 4.0
		var flame_w = 12.0 * flame_intensity + cos(anim_time * 20.0) * 2.0
		var top_y = burner_pos.y - 85 - flame_h
		
		# Cone externo azul/alaranjado
		var flame_points: PackedVector2Array = [
			Vector2(burner_pos.x - flame_w, burner_pos.y - 85),
			Vector2(burner_pos.x - flame_w * 0.5, top_y + flame_h * 0.4),
			Vector2(burner_pos.x, top_y),
			Vector2(burner_pos.x + flame_w * 0.5, top_y + flame_h * 0.4),
			Vector2(burner_pos.x + flame_w, burner_pos.y - 85)
		]
		draw_colored_polygon(flame_points, Color(0.2, 0.6, 1.0, 0.85))
		
		# Cone interno azul intenso (zona redutora/mais quente)
		var inner_flame: PackedVector2Array = [
			Vector2(burner_pos.x - flame_w * 0.5, burner_pos.y - 85),
			Vector2(burner_pos.x, burner_pos.y - 85 - flame_h * 0.55),
			Vector2(burner_pos.x + flame_w * 0.5, burner_pos.y - 85)
		]
		draw_colored_polygon(inner_flame, Color(0.4, 0.9, 1.0, 0.95))

func draw_test_tube_and_contents() -> void:
	# S2 - Tubo de Ensaio inclinado com a mistura de CuO + C
	var tube_start = Vector2(220, 180)
	var tube_end = Vector2(285, 335)
	
	# Cálculo da cor atual da mistura sólida
	var current_mixture_color: Color
	if reaction_progress < 0.2:
		current_mixture_color = COLOR_CUO_C
	elif reaction_progress < 0.85:
		# Fase de transição e incandescência
		var t = (reaction_progress - 0.2) / 0.65
		current_mixture_color = COLOR_CUO_C.lerp(COLOR_INCANDESCENCE, sin(t * PI))
		current_mixture_color = current_mixture_color.lerp(COLOR_COPPER_METAL, t)
	else:
		current_mixture_color = COLOR_COPPER_METAL
		
	# Fundo do tubo (Mistura reagente)
	draw_circle(tube_end, 14.0, current_mixture_color)
	draw_line(tube_end - Vector2(10, 25), tube_end, current_mixture_color, 24.0)
	
	# Brilho de Incandescência quando a temperatura está alta
	if temperature > 420.0 and reaction_progress > 0.15 and reaction_progress < 0.95 and is_flame_on:
		var glow_alpha = clamp((temperature - 400.0) / 300.0, 0.0, 0.8) * (0.8 + 0.2 * sin(anim_time * 15.0))
		draw_circle(tube_end, 20.0, Color(1.0, 0.6, 0.1, glow_alpha * 0.5))
	
	# Vidro do Tubo de Ensaio (Bordas transparentes)
	draw_line(tube_start, tube_end, Color(0.8, 0.9, 1.0, 0.55), 26.0)
	draw_line(tube_start - Vector2(12, 0), tube_end - Vector2(12, 0), Color(1.0, 1.0, 1.0, 0.7), 2.5)
	draw_line(tube_start + Vector2(12, 0), tube_end + Vector2(12, 0), Color(0.5, 0.7, 0.9, 0.6), 2.5)
	draw_arc(tube_end, 13.0, 0, PI, 16, Color(1.0, 1.0, 1.0, 0.8), 2.5)
	
	# Rolha de Borracha na boca do tubo
	draw_rect(Rect2(tube_start.x - 14, tube_start.y - 12, 28, 18), Color(0.35, 0.22, 0.15), true)

func draw_delivery_tube() -> void:
	# Tubo de desprendimento de gás (Vidro curvo que vai da rolha até o copo com água de cal)
	var pts: PackedVector2Array = [
		Vector2(220, 170),
		Vector2(220, 130),
		Vector2(505, 130),
		Vector2(505, 390 if is_delivery_tube_submerged else 290)
	]
	
	# Desenha linha de vidro duplo
	for i in range(pts.size() - 1):
		draw_line(pts[i], pts[i+1], Color(0.85, 0.95, 1.0, 0.6), 6.0)
		draw_line(pts[i], pts[i+1], Color(1.0, 1.0, 1.0, 0.85), 1.5)
		
	# Gás CO2 se movendo no tubo quando reagindo
	if is_flame_on and reaction_progress > 0.05 and reaction_progress < 1.0:
		var gas_offset = fmod(anim_time * 80.0, 450.0)
		# Pequena indicação de fluxo de vapor
		draw_circle(Vector2(220 + clamp(gas_offset, 0.0, 285.0), 130), 2.5, Color(1.0, 1.0, 1.0, 0.7))
		
	# Refluxo de Líquido no Tubo de Vidro (Água de cal sendo sugada para cima)
	if reflux_liquid_height > 0.0:
		var reflux_start_y = 390
		var reflux_end_y = 390 - reflux_liquid_height
		draw_line(Vector2(505, reflux_start_y), Vector2(505, reflux_end_y), Color(0.3, 0.7, 1.0, 0.85), 5.0)

func draw_limewater_beaker() -> void:
	# S3 - Béquer contendo Água de Cal [Ca(OH)2]
	var beaker_pos = Vector2(505, 430)
	var beaker_w = 70.0
	var beaker_h = 90.0
	var beaker_rect = Rect2(beaker_pos.x - beaker_w * 0.5, beaker_pos.y - beaker_h, beaker_w, beaker_h)
	
	# Líquido (Interpolação entre translúcido e branco leitoso de CaCO3)
	var current_liquid_color = COLOR_LIMEWATER_CLEAR.lerp(COLOR_LIMEWATER_MILKY, limewater_turbidity)
	var liquid_rect = Rect2(beaker_rect.position.x + 3, beaker_rect.position.y + 25, beaker_w - 6, beaker_h - 28)
	draw_rect(liquid_rect, current_liquid_color, true)
	
	# Menisco e superfície do líquido
	draw_line(Vector2(liquid_rect.position.x, liquid_rect.position.y), 
			  Vector2(liquid_rect.position.x + liquid_rect.size.x, liquid_rect.position.y), 
			  Color(1.0, 1.0, 1.0, 0.8), 2.0)
	
	# Bolhas ativas de CO2
	for b in bubbles:
		draw_circle(b["pos"], b["radius"], Color(1.0, 1.0, 1.0, 0.75))
		
	# Vidro do Béquer (Borda externa e graduação)
	draw_line(Vector2(beaker_rect.position.x, beaker_rect.position.y), 
			  Vector2(beaker_rect.position.x, beaker_rect.position.y + beaker_h), Color(0.8, 0.9, 1.0, 0.7), 3.0)
	draw_line(Vector2(beaker_rect.position.x + beaker_w, beaker_rect.position.y), 
			  Vector2(beaker_rect.position.x + beaker_w, beaker_rect.position.y + beaker_h), Color(0.8, 0.9, 1.0, 0.7), 3.0)
	draw_line(Vector2(beaker_rect.position.x, beaker_rect.position.y + beaker_h), 
			  Vector2(beaker_rect.position.x + beaker_w, beaker_rect.position.y + beaker_h), Color(0.8, 0.9, 1.0, 0.7), 3.0)
	
	# Marcas de graduação em ml
	for i in range(1, 4):
		var mark_y = beaker_rect.position.y + beaker_h - (i * 20.0)
		draw_line(Vector2(beaker_rect.position.x + 4, mark_y), Vector2(beaker_rect.position.x + 14, mark_y), Color(1.0, 1.0, 1.0, 0.6), 1.5)

func draw_broken_effect() -> void:
	# Efeito visual de quebra do tubo por choque térmico (Refluxo acidental)
	var break_pos = Vector2(285, 335)
	draw_circle(break_pos, 25.0, Color(1.0, 0.2, 0.2, 0.4))
	for i in range(6):
		var angle = i * (TAU / 6.0)
		var crack_end = break_pos + Vector2(cos(angle), sin(angle)) * 30.0
		draw_line(break_pos, crack_end, Color(1.0, 1.0, 1.0, 0.9), 2.0)

# Métodos de Controle da Bancada
func set_flame(enabled: bool) -> void:
	is_flame_on = enabled
	if not is_flame_on and not is_delivery_tube_submerged and reflux_risk < 0.3:
		safe_procedure_achieved.emit()
	queue_redraw()

func set_submerged_tube(submerged: bool) -> void:
	is_delivery_tube_submerged = submerged
	if not submerged:
		reflux_liquid_height = 0.0
		reflux_risk = 0.0
	queue_redraw()

func reset_bench() -> void:
	is_flame_on = false
	temperature = 25.0
	reaction_progress = 0.0
	limewater_turbidity = 0.0
	is_delivery_tube_submerged = true
	reflux_liquid_height = 0.0
	reflux_risk = 0.0
	is_broken = false
	bubbles.clear()
	queue_redraw()
