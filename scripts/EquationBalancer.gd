extends RefCounted
class_name EquationBalancer

## Validador de Equações Químicas e Análise Estequiométrica
## Responsável por verificar balanceamento, conservação de massa e coeficientes.

# Reação Principal 1: Redução Carbotérmica do Óxido de Cobre(II)
# 2 CuO (s) + 1 C (s) -> 2 Cu (s) + 1 CO2 (g)
const REDUCTION_EQUATION_COEFS: Dictionary = {
	"CuO": 2,
	"C": 1,
	"Cu": 2,
	"CO2": 1
}

# Reação de Identificação 2: Turvação da Água de Cal pelo CO2
# 1 Ca(OH)2 (aq) + 1 CO2 (g) -> 1 CaCO3 (s) + 1 H2O (l)
const LIMEWATER_EQUATION_COEFS: Dictionary = {
	"Ca(OH)2": 1,
	"CO2": 1,
	"CaCO3": 1,
	"H2O": 1
}

# Massas Molares (g/mol)
const MOLAR_MASSES: Dictionary = {
	"Cu": 63.55,
	"O": 16.00,
	"C": 12.01,
	"CuO": 79.55,
	"CO2": 44.01,
	"Ca": 40.08,
	"H": 1.008,
	"Ca(OH)2": 74.09,
	"CaCO3": 100.09,
	"H2O": 18.02
}

static func validate_reduction_equation(coef_cuo: int, coef_c: int, coef_cu: int, coef_co2: int) -> Dictionary:
	var is_correct = (coef_cuo == 2 and coef_c == 1 and coef_cu == 2 and coef_co2 == 1)
	
	var feedback: String = ""
	if is_correct:
		feedback = "Equação perfeitamente balanceada! 2 mol de CuO reagem com 1 mol de C produzindo 2 mol de Cu e 1 mol de CO2."
	else:
		var cu_react = coef_cuo
		var cu_prod = coef_cu
		var c_react = coef_c
		var c_prod = coef_co2
		var o_react = coef_cuo
		var o_prod = coef_co2 * 2
		
		if cu_react != cu_prod:
			feedback = "Desbalanceamento nos átomos de Cobre (Cu): %d reagentes vs %d produtos." % [cu_react, cu_prod]
		elif c_react != c_prod:
			feedback = "Desbalanceamento nos átomos de Carbono (C): %d reagentes vs %d produtos." % [c_react, c_prod]
		elif o_react != o_prod:
			feedback = "Desbalanceamento nos átomos de Oxigênio (O): %d reagentes vs %d produtos." % [o_react, o_prod]
		else:
			feedback = "Os coeficientes não estão na menor proporção inteira (esperado: 2, 1, 2, 1)."
			
	return {
		"is_correct": is_correct,
		"feedback": feedback
	}

static func calculate_theoretical_yield(mass_cuo_grams: float, mass_c_grams: float) -> Dictionary:
	# 2 * 79.55 g CuO (159.1 g) reage com 12.01 g C para formar 2 * 63.55 g Cu (127.1 g)
	var moles_cuo = mass_cuo_grams / MOLAR_MASSES["CuO"]
	var moles_c = mass_c_grams / MOLAR_MASSES["C"]
	
	# Proporção estequiométrica: 2 CuO : 1 C
	var is_c_limiting = (moles_cuo / 2.0) > moles_c
	var max_moles_cu: float
	var limiting_reagent: String
	
	if is_c_limiting:
		limiting_reagent = "Carbono (C)"
		max_moles_cu = moles_c * 2.0
	else:
		limiting_reagent = "Óxido de Cobre(II) (CuO)"
		max_moles_cu = moles_cuo
		
	var theoretical_cu_grams = max_moles_cu * MOLAR_MASSES["Cu"]
	
	return {
		"limiting_reagent": limiting_reagent,
		"theoretical_mass_cu": theoretical_cu_grams,
		"moles_cuo": moles_cuo,
		"moles_c": moles_c
	}
