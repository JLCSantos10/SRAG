# --------------------------------------------------
# Configuração inicial
# --------------------------------------------------

options(repos = c(CRAN = "https://cloud.r-project.org"))

pacotes <- c("rmarkdown", "yaml")

instalar <- pacotes[!pacotes %in% rownames(installed.packages())]
if (length(instalar)) install.packages(instalar)

lapply(pacotes, library, character.only = TRUE)

cat("Verificando Pandoc...\n")

# --------------------------------------------------
# Detectar Pandoc automaticamente
# --------------------------------------------------

cat("Verificando Pandoc...\n")

if (!rmarkdown::pandoc_available()) {
  
  # Caminho do RStudio (AppData)
  base_rstudio <- file.path(
    Sys.getenv("LOCALAPPDATA"),
    "Programs",
    "RStudio",
    "resources",
    "app"
  )
  
  possible_paths <- c(
    file.path(base_rstudio, "bin", "pandoc"),
    file.path(base_rstudio, "bin", "quarto", "bin", "tools")
  )
  
  found <- FALSE
  
  for (p in possible_paths) {
    if (dir.exists(p)) {
      Sys.setenv(RSTUDIO_PANDOC = p)
      found <- TRUE
      break
    }
  }
  
  # Verifica novamente após definir
  if (!rmarkdown::pandoc_available()) {
    stop("Pandoc nao encontrado. Verifique a instalacao do RStudio.")
  }
}

cat("Pandoc OK.\n")


# --------------------------------------------------
# Ler parâmetros YAML (corrigindo codificação)
# --------------------------------------------------

if (!file.exists("params.yaml")) {
  stop("Arquivo params.yaml não encontrado.")
}

params <- yaml::read_yaml("params.yaml")

# --------------------------------------------------
# Renderizar documento
# --------------------------------------------------

cat("Renderizando boletim...\n")

rmarkdown::render(
  input = "BOLETIM_SRAG.Rmd",
  params = params,
  output_format = "word_document",
  encoding = "UTF-8",
  envir = new.env()
)

cat("Boletim gerado com sucesso!\n")
