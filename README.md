# Boletim SRAG (RMarkdown) — Geração automatizada (Word)

Este repositório contém um fluxo completo para **gerar automaticamente um boletim de SRAG** a partir de uma base `.csv`, com **filtros por ano/município**, **cálculo de indicadores epidemiológicos** e **exportação em Word** (`.docx`) via **RMarkdown**.

---

## ✅ O que este projeto faz

- Lê a base `Bancos/SRAG.csv`
- Lê parâmetros em `params.yaml` (ex.: `ano_ref`, `municipio`)
- Aplica filtros e padronizações territoriais
- Calcula indicadores (casos, incidência, óbitos, letalidade etc.)
- Renderiza automaticamente o arquivo **`BOLETIM_SRAG.Rmd`** em **Word**
- Pode ser executado com **duplo clique** via `atualizar_boletim.bat`

---

## 📁 Estrutura do repositório

> (Os nomes podem variar conforme seu projeto, mas a lógica é esta)

.
├─ Bancos/
│ └─ SRAG.csv
├─ BOLETIM_SRAG.Rmd
├─ render_boletim.R
├─ params.yaml
├─ atualizar_boletim.bat
└─ README.md

perl
Copiar código

### Descrição dos arquivos
- **`Bancos/SRAG.csv`**: base principal do boletim (SRAG).
- **`params.yaml`**: parâmetros para o boletim (ano e município).
- **`BOLETIM_SRAG.Rmd`**: template do boletim (texto, tabelas e gráficos).
- **`render_boletim.R`**: script que verifica dependências (Pandoc), lê parâmetros e renderiza o `.Rmd`.
- **`atualizar_boletim.bat`**: executa o `render_boletim.R` encontrando o `Rscript` automaticamente.

---

## 🧩 Pré-requisitos

### 1) R instalado
- Qualquer versão recente do R deve funcionar.
- O `.bat` tenta localizar o `Rscript`:
  - via `PATH`
  - via `C:\Program Files\R\...`
  - via `%LOCALAPPDATA%\Programs\R\...`

### 2) Pandoc disponível (obrigatório para Word)
Para gerar `.docx`, o `rmarkdown` precisa do **Pandoc**.

**Opções:**
- ✅ **RStudio instalado** (recomendado): inclui Pandoc/Quarto
- ✅ Pandoc instalado separadamente e disponível no sistema

> Se você usa RStudio, o caminho geralmente aparece em:
> `Sys.getenv("RSTUDIO_PANDOC")`

### 3) Pacotes R
O `render_boletim.R` instala automaticamente (se faltar):
- `rmarkdown`
- `yaml`

> Seu `.Rmd` pode depender de outros pacotes (ex.: `dplyr`, `ggplot2`, `stringr`, `glue` etc.).  
> Garanta que estes estejam listados/instalados conforme o seu boletim.

---

## 🚀 Como executar

### Execução com duplo clique (Windows)
1. Ajuste `params.yaml`
2. Dê duplo clique em:
   - **`atualizar_boletim.bat`**

O Word (`.docx`) será gerado conforme definido no `BOLETIM_SRAG.Rmd`.

### Execução via terminal
Na pasta do projeto:

```bash
Rscript render_boletim.R
⚙️ Parâmetros (params.yaml)
Exemplo (salvar em UTF-8, com linha em branco no final):
```

```bash
yaml

filtro_ano:
  - 2020
  - 2025
ano_ref: 2025
municipio:            
  - "planaltina"
  - "sobradinho"

usar_filtro_municipio: true
```
Observações importantes
O params.yaml deve estar em UTF-8 (evita erro de “invalid multibyte” / “entrada inválida”).
Se quiser só 1 município basta por só 1 na lista, se quiser todos, ponha []

O nome do município deve seguir o mesmo padrão esperado pelo seu script (ver seção “Padronização”).

## 🧼 Padronização e filtros

Padronização de município
O projeto considera uma etapa para padronizar o texto do município (ex.: caixa alta/baixa, acentos, espaços).
Exemplo típico de regra (pode variar no seu código):

remover espaços duplicados

remover acentos

converter para maiúsculas

normalizar hífens e apóstrofos

Recomendação: padronize tanto SRAG.csv quanto a base de população da mesma forma para garantir join correto.

## 🧮 Indicadores epidemiológicos (cálculos)

A seguir está a lógica recomendada (e geralmente utilizada) para os principais indicadores do boletim.

Observação: os nomes de colunas podem variar. Ajuste conforme sua base.

1) Casos por Semana Epidemiológica (SE)
Definição: número de registros SRAG na SE.

Cálculo:

casos(SE) = n() após filtros.

Exemplo (lógica):

```bash
r

df %>%
  filter(ano == ano_ref, municipio == municipio_ref) %>%
  group_by(SE) %>%
  summarise(casos = n(), .groups = "drop")
```
2) Incidência por 100.000 habitantes
Definição: taxa de SRAG por 100 mil habitantes.

Fórmula:
```bash
inc(SE) = (casos(SE) / população_município_ano) * 100000
```
Importante (território):


No DF, atenção: RAs não são municípios IBGE. Se você filtra por RA, precisa de população por RA (ou converter a análise para município IBGE “Brasília”).

Exemplo (resumo):
```bash
r

inc = 100000 * casos / populacao
```
3) Óbitos por SRAG por SE
Definição: soma dos óbitos SRAG por SE.

Cálculo (depende da coluna):

Se existe coluna obitos (0/1 ou contagem): sum(obitos)

Se óbito é inferido por status: filtrar e contar

Exemplo:


```bash
r
df %>%
  group_by(SE) %>%
  summarise(obitos = sum(obitos, na.rm = TRUE), .groups = "drop")
```
4) Letalidade (%)
Definição: proporção de óbitos entre os casos SRAG no período.

Fórmula:
```bash
letalidade(%) = (óbitos / casos) * 100
```
Exemplo:
```bash
r
letalidade = ifelse(casos > 0, 100 * obitos / casos, NA_real_)
```
5) Indicadores agregados (resumo anual)
No boletim, geralmente é útil apresentar também:

total de casos no ano

total de óbitos no ano

letalidade anual

semanas com óbito

semana de pico (casos e/ou óbitos)

Semana de pico (exemplo):

```bash
r
pico <- df_se %>% arrange(desc(casos)) %>% slice(1)
```

6) Diagrama de controle

Definição:
O diagrama de controle é utilizado para identificar desvios no padrão esperado de incidência, com base em séries históricas anteriores. Ele permite classificar a situação epidemiológica em zonas (controle, segurança, alerta e epidêmica).

Base histórica:

Considera-se um período de anos anteriores ao ano de referência (ano_ref).

Excluem-se anos epidêmicos definidos em ano_epidemico.

Calcula-se a incidência por semana epidemiológica (SE).

Cálculo da incidência histórica:
```bash
inc = (casos / população) * 100000
```

Cálculo dos limiares por SE e município:
```bash
Média histórica:

media = mean(inc)
```

Desvio padrão:
```bash
sd = sd(inc)
```

Limites:
```bash
limite_inferior = media - 2 * sd
limite_alerta   = media + 2 * sd
limite_epidemico = media + 3 * sd
```

Classificação das zonas:

Zona	Intervalo
Zona de controle	0 até média
Zona de segurança	média até média - 2DP
Zona de alerta	média + 2DP
Zona epidêmica	acima de média + 3DP

Interpretação:

- Valores acima do limite epidêmico sugerem possível surto.

- A visualização é realizada por município, podendo ser facetada quando há múltiplos territórios selecionados.

- Pode-se aplicar média móvel (ex.: janela de 4 semanas) para suavização e nowcasting.


7) Taxa de transmissibilidade viral (R0)

Definição:
A taxa de transmissibilidade viral estima a velocidade de propagação da infecção ao longo do tempo. Pode ser representada por indicadores derivados da variação semanal de casos.

No contexto do boletim, a transmissibilidade pode ser aproximada por:

1) Crescimento percentual semanal
```bash
Tx_crescimento = ((casos_t - casos_t-1) / casos_t-1) * 100
```

Interpretação:

Valor positivo indica expansão da transmissão.

Valor negativo indica redução da circulação viral.

2) Razão de crescimento (proxy simplificada do Rt)
```bash
Rt_aproximado = casos_t / casos_t-1
```

Interpretação:

Valor	Situação
```bash
Rt > 1	Expansão da transmissão
Rt = 1	Estabilidade
Rt < 1	Redução da transmissão
```
Observações metodológicas

Para reduzir instabilidade, recomenda-se utilizar média móvel (ex.: 4 semanas).

Valores devem ser interpretados com cautela em municípios de pequeno porte devido à maior variabilidade.

A análise é complementar ao diagrama de controle e à incidência.

## 📊 Gráficos (interpretação)

Casos + incidência (eixo duplo)
Um padrão comum é:

colunas: casos por SE

linha: incidência reescalada para caber no mesmo gráfico

segundo eixo: incidência real

Boas práticas:

Sempre validar se o dataframe do gráfico tem linhas:

evita max() retornar -Inf quando está vazio.

Checar NA e pop == 0 antes de calcular incidência.

Exemplo de proteção:

```bash
r

stopifnot(nrow(df_plot) > 0)
```
## 🛠️ Solução de problemas

1) invalid multibyte character
Causa: arquivo .R, .Rmd ou .yaml salvo fora de UTF-8.
```bash
✅ Solução:

Salvar render_boletim.R, BOLETIM_SRAG.Rmd e params.yaml em UTF-8 (sem BOM)

Garantir linha final no params.yaml

2) Pandoc não encontrado
Causa: o Rscript não encontrou o Pandoc (mesmo com RStudio instalado).
```
```bash
✅ Solução:

No RStudio, rode:

r
Copiar código
Sys.getenv("RSTUDIO_PANDOC")
Ajuste o render_boletim.R para apontar para esse caminho quando rodar via Rscript.

3) Indicadores “zerados” após left_join(pop)
Causa comum: chave territorial inconsistente (municipio como texto vs código IBGE / RA no DF).
```
```bash
✅ Solução:

Preferir join por código (ex.: id_municipio)

Padronizar strings (acentos, caixa, espaços)

Validar com anti_join() para ver o que não casa

```
## 🔒 Reprodutibilidade e transparência
Este repositório foi organizado para:

garantir rastreabilidade (parâmetros via YAML)

padronizar cálculos (funções e pipelines claros)

facilitar execução em diferentes computadores (via .bat)

## 📬 Contato

Nome: José Lucas
E-mail: santos.joselucas.37@gmail.com
LinkedIn: www.linkedin.com/in/jose-lucas-santos

## 📰 Referências

1. BRASIL. Ministério da Saúde. Guia de Vigilância Epidemiológica. 10. ed. Brasília: Ministério da Saúde, 2023.
2. SILVA, T. F.; MORAIS, G. M.; ALMEIDA, R. B. Características clínicas de SRAG em crianças hospitalizadas: análise de um ano epidemiológico. Jornal de Pediatria, Porto Alegre, v. 100, n. 2, p. 101-109, 2024.
3. CORI, A., Ferguson, N. M., Fraser, C., & Cauchemez, S. (2013). A New Framework and Software to Estimate Time-Varying Reproduction Numbers During Epidemics. American Journal of Epidemiology.
4. FERREIRA, M. R.; COSTA, D. L.; PEREIRA, A. C. Estimativas do número reprodutivo efetivo (Rt) na vigilância viral respiratória. Revista Brasileira de Epidemiologia, São Paulo, v. 26, e230001, 2023.
5. CDC – CENTERS FOR DISEASE CONTROL AND PREVENTION. Principles of Epidemiology in Public Health Practice. 3. ed. Atlanta: CDC, 2012. Disponível em: https://www.cdc.gov/csels/dsepd/ss1978/index.html.
6. MEDRONHO, Roberto de Andrade et al. Epidemiologia. 2. ed. São Paulo: Atheneu, 2009.
7. UNIVERSIDADE FEDERAL DE SANTA CATARINA. Construção de diagramas de controle na vigilância em saúde. Florianópolis: UFSC, 2024. (Cursos Integrados em Vigilância em Saúde).
8. SOUSA, M. L. et al. Vigilância da Síndrome Respiratória Aguda Grave: análise dos dados de notificação no Brasil. Epidemiologia e Serviços de Saúde, Brasília, v. 34, n. 1, e20242345, 2025.
9. SANTOS, J.; LIMA, P. C. Perfil da SRAG no pós-pandemia: desafios para a vigilância. Cadernos de Saúde Pública, Rio de Janeiro, v. 40, n. 1, p. 25-35, 2024.
10. VIANA, V.A.F. SOBRINHO, S.A.C. JÚNIOR, F.S.FILHO, J.Q.S.CAVALCANTE, K.F. SILVA, D.B. MELLO, L.M.S. MELO, M.E.L. MACÊDO, S.M.S. LIMA, S.T.S. DUARTE, L.M.F. ARAÚJO, F.M.C. LIMA, A.Â.M.  CLINICAL, EPIDEMIOLOGICAL AND VACCINATION CHARACTERISTICSIN CHILDREN AND ADOLESCENTS OF SEVERE ACUTE RESPIRATORYSYNDROME DUE TO COVID-19 IN BRAZIL (2020 TO 2024). medRxiv preprint doi: https://doi.org/10.1101/2025.09.18.25336058; this version posted September 19, 2025.
11. RUIVO, A.P., BAUERMANN, M.C., GREGIANINI, T.S., SANTOS, F.M., GODINHO, F., BAETHGEN, L.F., MACHADO, T.R.M., MARTINS, L.G., MONDINI, R.P., PORT, C.N., CORREA, A., SELAYARAN, T., RESENDE, P.C., WALLAU, G.L., SALVATO, R.S., e VEIGA, A.B.G. Surveillance of respiratory viruses in severe acute respiratory infections in Southern Brazil, 2023–2024.




