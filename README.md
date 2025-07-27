# Framework LuaCrapper - Web Scraping Distribuído

**Desenvolvido por:** Bypass-dev  
**Ano:** 2025  
**Versão:** 1.0

## 📋 Descrição

Framework robusto para Web Scraping Distribuído em Lua com suporte a processamento paralelo usando corrotinas, sistema de filas inteligente, análise HTML avançada e exportação flexível para múltiplos formatos. Ideal para projetos que necessitam de coleta de dados em larga escala com alta performance e confiabilidade.

## ✨ Características Principais

- 🚀 **Scheduler Inteligente**: Rate limiting automático e sistema de retry com backoff exponencial
- ⚡ **Processamento Paralelo**: Corrotinas para scraping simultâneo de múltiplas URLs
- 🔍 **Análise HTML Avançada**: Parser integrado com suporte a lua-gumbo para extração precisa
- 📊 **Sistema de Filas**: Gerenciamento inteligente de tarefas com suporte opcional ao RabbitMQ
- 💾 **Exportação Flexível**: Suporte nativo para JSON, CSV com metadados completos
- 🏷️ **Sistema de Rotulação**: Tags personalizadas para organização e categorização de dados
- 🛡️ **Tratamento de Erros**: Sistema robusto de recuperação e logging detalhado
- 🔧 **Interface CLI**: Linha de comando completa para automação e scripts
- ⚙️ **Configuração Flexível**: Múltiplos ambientes e configurações personalizáveis

## 📁 Estrutura do Projeto

```
Framework-LuaCrapper/
├── bin/
│   └── luacrapper              # Interface de linha de comando
├── src/
│   ├── core/
│   │   ├── scheduler.lua       # Gerenciador de workers e concorrência
│   │   ├── scraper.lua         # Motor principal de scraping
│   │   └── queue_manager.lua   # Sistema de filas de tarefas
│   ├── plugins/
│   │   ├── html_parser.lua     # Parser HTML com lua-gumbo
│   │   └── data_extractor.lua  # Extração de dados estruturados
│   ├── exporters/
│   │   ├── json_exporter.lua   # Exportação para JSON
│   │   └── csv_exporter.lua    # Exportação para CSV
│   ├── utils/
│   │   ├── rate_limiter.lua    # Controle de taxa de requisições
│   │   └── retry_handler.lua   # Sistema de retry inteligente
│   ├── config/
│   │   └── config.lua          # Gerenciamento de configurações
│   └── luacrapper.lua          # Classe principal do framework
├── config/
│   └── luacrapper.conf.example # Exemplo de configuração
├── examples/
│   └── basic_usage.lua         # Exemplos de uso
├── tests/
│   └── test_framework.lua      # Testes automatizados
└── exports/                    # Diretório de saída padrão
```

## 🔧 Dependências

### Obrigatórias
- **Lua 5.1+**: Interpretador Lua

### Opcionais (para funcionalidade completa)
- **lua-http**: Cliente HTTP avançado
- **lua-gumbo**: Parser HTML robusto
- **lua-rabbitmq-client**: Integração com RabbitMQ
- **lua-cjson**: Processamento JSON otimizado
- **luasocket**: Comunicação de rede

## 📦 Instalação

### Via LuaRocks (Recomendado)
```bash
# Dependências opcionais para funcionalidade completa
luarocks install lua-http
luarocks install lua-gumbo
luarocks install lua-rabbitmq-client
luarocks install lua-cjson
luarocks install luasocket
```

### Instalação Manual
```bash
git clone https://github.com/z5ta9b5tbMC5Jr/Framework-LuaCrapper.git
cd Framework-LuaCrapper
lua install.lua
```

## 🚀 Uso Básico

### Exemplo Simples
```lua
local LuaCrapper = require('src.luacrapper')

-- Configuração básica
local scraper = LuaCrapper:new({
    scheduler = {
        max_concurrent = 5,
        worker_timeout = 30
    },
    rate_limiter = {
        requests_per_second = 2
    },
    scraper = {
        timeout = 10,
        retry_attempts = 3
    }
})

-- Adicionar URLs
scraper:add_url('https://httpbin.org/json')
scraper:add_url('https://httpbin.org/headers')
scraper:add_url('https://httpbin.org/user-agent')

-- Executar scraping
scraper:start()
scraper:wait()

-- Obter resultados
local results = scraper:get_results()
local stats = scraper:get_stats()

print(string.format('Processadas: %d URLs', stats.processed_urls))
print(string.format('Sucessos: %d', stats.processed_urls - stats.failed_urls))
print(string.format('Falhas: %d', stats.failed_urls))

-- Exportar dados
scraper:export('results.json', 'json')
scraper:export('results.csv', 'csv')
```

## 💻 Interface de Linha de Comando

```bash
# Scraping de uma URL
lua bin/luacrapper scrape https://example.com

# Múltiplas URLs com configurações
lua bin/luacrapper scrape -j 10 -r 3 -o results.json https://site1.com https://site2.com
```

## 📊 Exemplos de Saída

### Execução do Exemplo Básico
```
$ lua examples/basic_usage.lua

=== Resultados ===
URLs processadas: 5
Sucessos: 5
Falhas: 0
Taxa de sucesso: 100.00%
Tempo total: 0.03 segundos

=== Exportando Resultados ===
JSON exportado: basic_example_results.json
CSV exportado: basic_example_results.csv
Resumo exportado: basic_example_summary.json
```

## 📄 Licença

MIT License - Desenvolvido por Bypass-dev (2025)

---

**⭐ Se este projeto foi útil para você, considere dar uma estrela no GitHub!**