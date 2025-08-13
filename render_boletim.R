# Definir o repositório CRAN
options(repos = c(CRAN = "https://cloud.r-project.org"))

Sys.setenv(RSTUDIO_PANDOC = "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools")

# Instalar pacotes necessários
pacotes <- c("rmarkdown", "yaml")
instalar <- pacotes[!pacotes %in% rownames(installed.packages())]
if (length(instalar)) install.packages(instalar)

# Carregar pacotes
lapply(pacotes, library, character.only = TRUE)

# Ler parâmetros do YAML
params <- yaml::read_yaml("params.yaml")

# Renderizar o boletim
rmarkdown::render(
  input = "BOLETIM_SRAG.Rmd",
  params = params,
  output_format = "word_document",
  encoding = "UTF-8",  # Adicione esta linha para especificar a codificação
  envir = new.env()
)