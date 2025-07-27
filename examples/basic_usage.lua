#!/usr/bin/env lua

--[[
    Exemplo básico de uso do Framework LuaCrapper
    Este exemplo demonstra como usar o framework para fazer scraping de múltiplas URLs
--]]

-- Carregar o framework
local LuaCrapper = require('src.luacrapper')

-- Função principal
local function main()
    print('=== LuaCrapper - Exemplo Básico ===')
    print('Iniciando scraping de exemplo...')
    
    -- Criar instância do scraper
    local scraper = LuaCrapper:new({
        max_concurrent = 3,
        requests_per_second = 2,
        timeout = 10
    })
    
    -- URLs de exemplo para scraping
    local urls = {
        'https://httpbin.org/html',
        'https://httpbin.org/json',
        'https://httpbin.org/xml',
        'https://httpbin.org/user-agent',
        'https://httpbin.org/headers'
    }
    
    print('Adicionando URLs para scraping...')
    
    -- Adicionar URLs ao scraper
    for i, url in ipairs(urls) do
        scraper:add_url(url, {
            priority = i,
            metadata = {
                source = 'exemplo_basico',
                index = i
            }
        })
        print('  [' .. i .. '] ' .. url)
    end
    
    print('\nIniciando processamento...')
    
    -- Iniciar o scraping
    scraper:start()
    
    -- Aguardar conclusão
    scraper:wait()
    
    print('\nProcessamento concluído!')
    
    -- Obter estatísticas
    local stats = scraper:get_stats()
    print('\n=== Estatísticas ===')
    print('Total de tarefas: ' .. stats.total_tasks)
    print('Tarefas concluídas: ' .. stats.completed_tasks)
    print('Tarefas com erro: ' .. stats.failed_tasks)
    print('Taxa de sucesso: ' .. string.format('%.1f%%', (stats.completed_tasks / stats.total_tasks) * 100))
    
    -- Obter resultados
    local results = scraper:get_results()
    print('\n=== Resultados ===')
    
    for i, result in ipairs(results) do
        print('\nResultado ' .. i .. ':')
        print('  URL: ' .. result.url)
        print('  Status: ' .. result.status_code)
        print('  Tamanho: ' .. (result.size or 0) .. ' bytes')
        print('  Tipo: ' .. (result.content_type or 'unknown'))
        
        if result.data and result.data.basic_info then
            local info = result.data.basic_info
            print('  Título: ' .. (info.title or 'N/A'))
            print('  Palavras: ' .. (info.word_count or 0))
            print('  Links: ' .. (info.link_count or 0))
        end
    end
    
    -- Exportar resultados
    print('\n=== Exportação ===')
    
    -- Exportar para JSON
    local json_result = scraper:export('json', 'basic_example_results.json')
    if json_result.success then
        print('✓ Exportado para JSON: ' .. json_result.filename)
        print('  Registros: ' .. json_result.records)
        print('  Tamanho: ' .. json_result.size .. ' bytes')
    end
    
    -- Exportar para CSV
    local csv_result = scraper:export('csv', 'basic_example_results.csv')
    if csv_result.success then
        print('✓ Exportado para CSV: ' .. csv_result.filename)
        print('  Registros: ' .. csv_result.records)
        print('  Tamanho: ' .. csv_result.size .. ' bytes')
    end
    
    -- Exportar resumo
    local summary = {
        execution_summary = {
            started_at = os.date('%Y-%m-%d %H:%M:%S'),
            total_urls = #urls,
            statistics = stats,
            export_files = {
                json_result.filename,
                csv_result.filename
            }
        }
    }
    
    local summary_result = scraper:export('json', 'basic_example_summary.json', summary)
    if summary_result.success then
        print('✓ Resumo exportado: ' .. summary_result.filename)
    end
    
    print('\n=== Exemplo Concluído ===')
    print('Verifique os arquivos de saída gerados:')
    print('  - basic_example_results.json')
    print('  - basic_example_results.csv')
    print('  - basic_example_summary.json')
end

-- Executar exemplo
if arg and arg[0] and arg[0]:match('basic_usage%.lua$') then
    main()
end

return {
    main = main,
    description = 'Exemplo básico de uso do LuaCrapper'
}