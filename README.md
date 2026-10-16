# 🧪 Laboratório Virtual de Química (Godot Engine 4.x)
**Experimento:** Redução Carbotérmica do Óxido de Cobre(II) com Carvão

---

## 📌 Visão Geral do Projeto
Este laboratório virtual gamificado foi desenvolvido como produto educacional para o Ensino Médio, fundamentado na metodologia **Design-Based Research (DBR)**, na **Teoria do Flow** (*Mihaly Csikszentmihalyi, 1990*) e no design de **Gamificação** (*Sebastian Deterding, 2011*).

---

## 🔬 Fundamentação Química
O experimento aborda as seguintes reações químicas:

1. **Reação Principal (Redução no Tubo - Sistema S2):**
   $$2\text{CuO}_{(s)} + \text{C}_{(s)} \xrightarrow{\Delta} 2\text{Cu}_{(s)} + \text{CO}_{2(g)}$$
   * *Observação:* Transição do pó preto ($\text{CuO}+\text{C}$) para incandescência alaranjada e formação de Cobre metálico avermelhado ($\text{Cu}$).

2. **Reação de Identificação do Gás (Detecção no Béquer - Sistema S3):**
   $$\text{Ca(OH)}_{2(aq)} + \text{CO}_{2(g)} \longrightarrow \text{CaCO}_{3(s)\downarrow} + \text{H}_2\text{O}_{(l)}$$
   * *Observação:* Borbulhamento de $\text{CO}_2$ e turvação leitosa da água de cal por precipitação de Carbonato de Cálcio ($\text{CaCO}_3$).

---

## 🎮 Estrutura dos 3 Níveis (Ciclos DBR)

### 1. Nível 1 – Fácil: *O Químico Iniciante* (Ciclo 1 DBR | BNCC EM13CNT101)
* **Objetivo:** Reconhecimento dos materiais e observação guiada de fenômenos visuais.
* **Mecânicas:**
  * Diálogo interativo com assistente virtual.
  * Acendimento do Bico de Bunsen (**S1**).
  * Observação da incandescência e mudança de cor (**S2**).
  * Observação do borbulhamento e turvação da água de cal (**S3**).
  * Conquista da Insígnia: 🏅 *Químico Iniciante*.

### 2. Nível 2 – Médio: *Técnico de Laboratório* (Ciclo 2 DBR | BNCC EM13CNT204)
* **Objetivo:** Controle de variáveis, segurança procedimental e equações químicas.
* **Mecânicas:**
  * Seleção da proporção estequiométrica correta ($2:1$).
  * Controle de intensidade da chama.
  * **Minigame de Risco de Refluxo:** afastar o béquer com água de cal antes de apagar a chama para evitar sucção de líquido frio e quebra por choque térmico.
  * Associação de coeficientes estequiométricos.
  * Conquista da Insígnia: 🧪 *Técnico de Laboratório* e 🛡️ *Mestre da Segurança*.

### 3. Nível 3 – Difícil: *Investigador Químico* (Ciclo 3 DBR | BNCC EM13CNT303)
* **Objetivo:** Investigação científica aberta, oxirredução, cálculos e relatório com rúbrica.
* **Mecânicas:**
  * Investigação de amostra desconhecida e formulação de hipótese.
  * Painel de telemetria multivariável simultânea (Curva de Temperatura $\text{S1}$, Balança Digital com cálculo de rendimento em $\text{S2}$, Fotometria de turbidez em $\text{S3}$).
  * **Minigame de Oxirredução:** visualização da transferência de elétrons ($\text{Cu}^{2+} + 2e^- \rightarrow \text{Cu}^0$ e $\text{C}^0 \rightarrow \text{C}^{4+} + 4e^-$).
  * Elaboração e submissão de Relatório Científico avaliado por rúbrica de competências.
  * Conquista da Insígnia: 🏆 *Pesquisador Júnior* e ⚡ *Especialista em Oxirredução*.

---

## 🚀 Como Executar no Godot Engine

1. Baixe o **Godot Engine 4.x** (versão Standard recomendada: [godotengine.org](https://godotengine.org/download)).
2. Abra o Godot e clique no botão **"Import"** (ou "Importar").
3. Navegue até esta pasta:
   ```text
   Godot_LabVirtual_Quimica/
   ```
4. Selecione o arquivo `project.godot` e clique em **"Open"** -> **"Import & Edit"**.
5. Pressione **F5** (ou o botão de Play no canto superior direito do Godot) para rodar o laboratório completo!

---

## 📁 Estrutura de Arquivos

```text
Godot_LabVirtual_Quimica/
├── project.godot                  # Configurações do motor e singleton GameManager
├── icon.svg                       # Ícone do projeto
├── scenes/
│   ├── MainMenu.tscn              # Menu principal, seleção de níveis e badges
│   ├── Level1_Iniciante.tscn      # Cena do Nível 1
│   ├── Level2_Tecnico.tscn        # Cena do Nível 2
│   ├── Level3_Investigador.tscn   # Cena do Nível 3
│   ├── LabBench2D.tscn            # Cena da bancada e vidraria 2D
│   ├── RefluxRiskPanel.tscn       # Minigame do alerta de refluxo
│   ├── MiniGameEletrons.tscn      # Minigame interativo de oxirredução
│   └── RelatorioUI.tscn           # Interface do relatório científico
└── scripts/
    ├── GameManager.gd             # Singleton (pontos, progresso, badges)
    ├── LabBench2D.gd              # Simulação física e renderização procedural da bancada
    ├── EquationBalancer.gd        # Balanceador e cálculos estequiométricos
    ├── RefluxRiskControl.gd       # Controle do minigame de refluxo
    ├── MiniGameEletrons.gd        # Controle do minigame redox
    ├── Level1_Iniciante.gd        # Lógica do Nível 1
    ├── Level2_Tecnico.gd          # Lógica do Nível 2
    ├── Level3_Investigador.gd     # Lógica do Nível 3
    ├── RelatorioUI.gd             # Lógica da tela de relatório
    └── MainMenu.gd                # Lógica do menu principal
```
