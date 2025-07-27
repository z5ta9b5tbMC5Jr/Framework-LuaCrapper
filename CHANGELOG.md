# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-27

### Adicionado
- **Framework Principal**: Implementação completa do LuaCrapper
- **Scheduler Inteligente**: Sistema de agendamento com rate limiting e retry automático
- **Processamento Paralelo**: Suporte a corrotinas para scraping simultâneo
- **Sistema de Filas**: Gerenciamento inteligente de tarefas com suporte opcional ao RabbitMQ
- **Análise HTML**: Parser integrado com suporte a lua-gumbo
- **Exportação Flexível**: Suporte nativo para JSON e CSV com metadados
- **Interface CLI**: Linha de comando completa (`bin/luacrapper`)
- **Sistema de Configuração**: Múltiplos ambientes e configurações personalizáveis
- **Tratamento de Erros**: Sistema robusto de recuperação e logging
- **Sistema de Rotulação**: Tags personalizadas para organização de dados

### Características Principais
- ⚡ **Performance**: Processamento paralelo com corrotinas
- 🛡️ **Confiabilidade**: Rate limiting e sistema de retry com backoff exponencial
- 🔍 **Flexibilidade**: Suporte a múltiplos formatos de exportação
- 🏷️ **Organização**: Sistema de tags para categorização
- 📊 **Monitoramento**: Estatísticas detalhadas e logging

### Arquivos Principais
- `src/luacrapper.lua` - Classe principal do framework
- `src/core/scheduler.lua` - Gerenciador de workers e concorrência
- `src/core/scraper.lua` - Motor principal de scraping
- `src/core/queue_manager.lua` - Sistema de filas de tarefas
- `src/plugins/html_parser.lua` - Parser HTML com lua-gumbo
- `src/plugins/data_extractor.lua` - Extração de dados estruturados
- `src/exporters/json_exporter.lua` - Exportação para JSON
- `src/exporters/csv_exporter.lua` - Exportação para CSV
- `src/utils/rate_limiter.lua` - Controle de taxa de requisições
- `src/utils/retry_handler.lua` - Sistema de retry inteligente
- `src/config/config.lua` - Gerenciamento de configurações
- `bin/luacrapper` - Interface de linha de comando
- `examples/basic_usage.lua` - Exemplos de uso

### Dependências
- **Lua 5.1+** (obrigatório)
- **lua-http** (opcional, para cliente HTTP avançado)
- **lua-gumbo** (opcional, para parser HTML robusto)
- **lua-rabbitmq-client** (opcional, para integração com RabbitMQ)
- **lua-cjson** (opcional, para processamento JSON otimizado)
- **luasocket** (opcional, para comunicação de rede)

### Compatibilidade
- ✅ Lua 5.1, 5.2, 5.3, 5.4
- ✅ LuaJIT 2.0+
- ✅ Windows, Linux, macOS
- ✅ Sistemas embarcados com Lua

### Exemplos de Uso
- Scraping básico com múltiplas URLs
- Exportação para JSON e CSV
- Interface de linha de comando
- Configuração personalizada
- Sistema de retry e rate limiting

---

**Desenvolvido por:** Bypass-dev  
**Licença:** MIT  
**Ano:** 2025
