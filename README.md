📊 Atualização do Boletim de Síndrome Respiratória Aguda Grave (SRAG)

Este repositório contém os scripts e procedimentos necessários para atualização automática do Boletim Epidemiológico de Síndrome Respiratória Aguda Grave (SRAG) da Região Leste do Distrito Federal.

A execução do código gera automaticamente um arquivo Word com os indicadores, gráficos e análises atualizadas.

🎯 Objetivo

Automatizar a construção e atualização do boletim epidemiológico de SRAG, garantindo padronização e reprodutibilidade.

✅ Requisitos

R e RStudio instalados

Download: RStudio Desktop

Os arquivos de entrada devem estar na mesma pasta do projeto.

Arquivos obrigatoriamente em csv (.csv).

Não alterar:

Nome dos arquivos

Nome das colunas nos arquivos

Antes de rodar, certifique-se de que nenhum dos arquivos (boletim, planilha de monitoramento, subnotificações) esteja aberto.

📂 Estrutura esperada dos arquivos

srag_min → Planilha com os casos de SRAG (nome pode variar, mas sempre começa com Casos_SRAG).

params → Arquivo de parâmetros do boletim (ano de referência, intervalo temporal).

render_boletim.R → Script que calcula indicadores e gera o boletim.

BOLETIM_SRAG.Rmd → Modelo do boletim em formato RMarkdown.

atualizar_boletim.bat → Arquivo de execução rápida (roda todos os scripts automaticamente).

⚙️ Como atualizar o boletim

Defina o ano de referência

Abra o arquivo params (com Bloco de Notas).

Atualize os campos:

filtro_ano: intervalo de anos para análise temporal (ex: 2020–2025).

ano_ref: ano de interesse atual (ex: 2025).

ano_epidemico: caso exista um ano epidêmico que impacte a análise.

Salve o arquivo.

Execute a atualização

Dê duplo clique em atualizar_boletim.bat.

Uma janela preta será aberta e mostrará o progresso da execução.

Ao final, a mensagem exibida será:

Output created: BOLETIM_SRAG.docx
Pressione qualquer tecla para continuar...


Isso significa que o boletim foi atualizado com sucesso.

Ajuste final

Abra o arquivo BOLETIM_SRAG.docx.

Atualize o título com a semana epidemiológica correspondente.

Atualize os campos do sumário.

Copie o conteúdo para o modelo final do boletim de SRAG, se necessário.

📝 Observações importantes

Ao atualizar, o arquivo Word anterior será substituído.

🔔 Se precisar manter versões anteriores, salve cópias antes de rodar novamente.

O nome da planilha de casos pode variar, mas o script reconhece qualquer arquivo que comece com Casos_SRAG.

📌 Histórico de Revisão

v1.0 (06/2025) – Criação do procedimento de atualização automatizada do Boletim SRAG.

👨‍💻 Autor

José Lucas Costa dos Santos
Residente de Vigilância em Saúde – UnB
