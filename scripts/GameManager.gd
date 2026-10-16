extends Node

## Singleton GameManager (Autoload)
## Gerencia estado global, pontuação, badges (conquistas), dados de relatórios e progresso.
## Baseado nos princípios de Gamificação (Deterding, 2011) e Teoria do Flow (Csikszentmihalyi, 1990).

signal badge_unlocked(badge_id: String, badge_name: String, badge_desc: String)
signal score_updated(new_total_score: int)
signal level_completed(level_num: int, score: int, stars: int)

# Progresso dos Níveis
var current_level: int = 1
var levels_unlocked: Dictionary = {
	1: true,
	2: false,
	3: false
}

var level_scores: Dictionary = {
	1: 0,
	2: 0,
	3: 0
}

var total_score: int = 0

# Conquistas (Badges)
var badges: Dictionary = {
	"iniciante": {
		"id": "iniciante",
		"name": "Químico Iniciante",
		"desc": "Concluiu a montagem guiada e observou os três sistemas (S1, S2, S3).",
		"icon": "🏅",
		"unlocked": false
	},
	"seguranca_refluxo": {
		"id": "seguranca_refluxo",
		"name": "Mestre da Segurança",
		"desc": "Evitou o refluxo de líquido na bancada com sucesso no Nível Médio.",
		"icon": "🛡️",
		"unlocked": false
	},
	"tecnico": {
		"id": "tecnico",
		"name": "Técnico de Laboratório",
		"desc": "Completou o Nível Médio com controle estequiométrico e equações corretas.",
		"icon": "🧪",
		"unlocked": false
	},
	"redox_master": {
		"id": "redox_master",
		"name": "Especialista em Oxirredução",
		"desc": "Identificou corretamente a transferência de elétrons e balanceou a reação.",
		"icon": "⚡",
		"unlocked": false
	},
	"pesquisador": {
		"id": "pesquisador",
		"name": "Pesquisador Júnior",
		"desc": "Finalizou a investigação científica completa e submeteu o relatório com nota máxima.",
		"icon": "🏆",
		"unlocked": false
	}
}

# Caderno Virtual de Anotações (Notas coletadas durante os experimentos)
var notebook_entries: Array[Dictionary] = []

# Relatório Científico do Nível 3
var scientific_report: Dictionary = {
	"unknown_sample_identified": false,
	"selected_reagent": "",
	"hypothesis": "",
	"temperature_max": 0.0,
	"mass_cuo_initial": 15.9, # g
	"mass_c_initial": 1.2,    # g
	"mass_cu_obtained": 0.0,  # g
	"yield_percent": 0.0,
	"balanced_equation": "",
	"redox_oxidizing_agent": "",
	"redox_reducing_agent": "",
	"conclusion": "",
	"rubric_score": 0
}

func _ready() -> void:
	print("[GameManager] Inicializado com sucesso.")

func add_score(points: int) -> void:
	total_score += points
	score_updated.emit(total_score)

func unlock_badge(badge_id: String) -> void:
	if badges.has(badge_id) and not badges[badge_id]["unlocked"]:
		badges[badge_id]["unlocked"] = true
		add_score(150)
		badge_unlocked.emit(badge_id, badges[badge_id]["name"], badges[badge_id]["desc"])
		print("[GameManager] Badge desbloqueada: ", badges[badge_id]["name"])

func complete_level(level_num: int, score: int) -> void:
	level_scores[level_num] = max(level_scores[level_num], score)
	add_score(score)
	
	# Desbloqueia próximo nível
	if level_num < 3:
		levels_unlocked[level_num + 1] = true
	
	var stars: int = 1
	if score >= 300:
		stars = 3
	elif score >= 200:
		stars = 2
		
	level_completed.emit(level_num, score, stars)

func add_notebook_entry(system_id: String, title: String, observation: String, timestamp_str: String = "") -> void:
	notebook_entries.append({
		"system": system_id, # "S1", "S2" ou "S3"
		"title": title,
		"text": observation,
		"time": Time.get_time_string_from_system() if timestamp_str.is_empty() else timestamp_str
	})

func reset_experiment_data() -> void:
	notebook_entries.clear()
	scientific_report["unknown_sample_identified"] = false
	scientific_report["selected_reagent"] = ""
	scientific_report["hypothesis"] = ""
	scientific_report["temperature_max"] = 0.0
	scientific_report["mass_cu_obtained"] = 0.0
	scientific_report["yield_percent"] = 0.0
	scientific_report["balanced_equation"] = ""
	scientific_report["redox_oxidizing_agent"] = ""
	scientific_report["redox_reducing_agent"] = ""
	scientific_report["conclusion"] = ""
	scientific_report["rubric_score"] = 0
