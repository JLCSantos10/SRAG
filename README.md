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

🧼 Padronização e filtros
Padronização de município
O projeto considera uma etapa para padronizar o texto do município (ex.: caixa alta/baixa, acentos, espaços).
Exemplo típico de regra (pode variar no seu código):

remover espaços duplicados

remover acentos

converter para maiúsculas

normalizar hífens e apóstrofos

Recomendação: padronize tanto SRAG.csv quanto a base de população da mesma forma para garantir join correto.

🧮 Indicadores epidemiológicos (cálculos)
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
📊 Gráficos (interpretação)
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
🛠️ Solução de problemas

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
🔒 Reprodutibilidade e transparência
Este repositório foi organizado para:

garantir rastreabilidade (parâmetros via YAML)

padronizar cálculos (funções e pipelines claros)

facilitar execução em diferentes computadores (via .bat)

📬 Contato

Nome: José Lucas
E-mail: santos.joselucas.37@gmail.com
LinkedIn: www.linkedin.com/in/jose-lucas-santos

