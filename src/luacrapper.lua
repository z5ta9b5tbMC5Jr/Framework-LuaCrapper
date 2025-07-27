--[[
    Framework LuaCrapper - Web Scraping Distribuído
    Desenvolvido por: Bypass-dev
    Ano: 2025
    
    Arquivo principal do framework
--]]

local LuaCrapper = {}
LuaCrapper.__index = LuaCrapper

-- Dependências
local Scheduler = require('src.core.scheduler')
local Scraper = require('src.core.scraper')
local QueueManager = require('src.core.queue_manager')
local JSONExporter = require('src.exporters.json_exporter')
local CSVExporter = require('src.exporters.csv_exporter')
local config = require('config.config')

-- Construtor
function LuaCrapper:new(options)
    local instance = {
        config = options or {},
        scheduler = nil,
        scraper = nil,
        queue_manager = nil,
        exporters = {},
        running = false,
        results = {},
        stats = {
            total_urls = 0,
            processed_urls = 0,
            failed_urls = 0,
            start_time = nil,
            end_time = nil
        }
    }
    
    setmetatable(instance, self)
    
    -- Inicializar componentes
    instance:_initialize()
    
    return instance
end

-- Inicialização dos componentes
function LuaCrapper:_initialize()
    -- Configurações padrão
    local default_config = {
        max_concurrent = 5,
        rate_limit = 1,
        retry_attempts = 3,
        timeout = 30,
        user_agent = 'LuaCrapper/1.0 (Bypass-dev)',
        rabbitmq_enabled = false,
        export_format = 'json'
    }
    
    -- Mesclar configurações
    for k, v in pairs(default_config) do
        if self.config[k] == nil then
            self.config[k] = v
        end
    end
    
    -- Inicializar componentes
    self.scheduler = Scheduler:new(self.config)
    self.scraper = Scraper:new(self.config)
    self.queue_manager = QueueManager:new(self.config)
    
    -- Inicializar exportadores
    self.exporters.json = JSONExporter:new()
    self.exporters.csv = CSVExporter:new()
end

-- Adicionar URL para scraping
function LuaCrapper:add_url(url, options)
    options = options or {}
    local task = {
        url = url,
        method = options.method or 'GET',
        headers = options.headers or {},
        data = options.data,
        priority = options.priority or 1,
        tags = options.tags or {},
        created_at = os.time()
    }
    
    self.queue_manager:add_task(task)
    self.stats.total_urls = self.stats.total_urls + 1
    
    return self
end

-- Adicionar múltiplas URLs
function LuaCrapper:add_urls(urls)
    for _, url_data in ipairs(urls) do
        if type(url_data) == 'string' then
            self:add_url(url_data)
        else
            self:add_url(url_data.url, url_data.options)
        end
    end
    
    return self
end

-- Iniciar o processo de scraping
function LuaCrapper:start()
    if self.running then
        error('LuaCrapper já está em execução')
    end
    
    self.running = true
    self.stats.start_time = os.time()
    
    print(string.format('[LuaCrapper] Iniciando scraping de %d URLs...', self.stats.total_urls))
    
    -- Iniciar scheduler
    self.scheduler:start(function(task)
        return self:_process_task(task)
    end)
    
    return self
end

-- Processar uma tarefa
function LuaCrapper:_process_task(task)
    local success, result = pcall(function()
        return self.scraper:scrape(task)
    end)
    
    if success and result then
        self.stats.processed_urls = self.stats.processed_urls + 1
        table.insert(self.results, result)
        
        -- Callback de sucesso
        if self.config.on_success then
            self.config.on_success(result, task)
        end
        
        return result
    else
        self.stats.failed_urls = self.stats.failed_urls + 1
        
        -- Callback de erro
        if self.config.on_error then
            self.config.on_error(result, task)
        end
        
        return nil
    end
end

-- Parar o scraping
function LuaCrapper:stop()
    if not self.running then
        return self
    end
    
    self.running = false
    self.stats.end_time = os.time()
    
    self.scheduler:stop()
    
    print('[LuaCrapper] Scraping interrompido')
    
    return self
end

-- Aguardar conclusão
function LuaCrapper:wait()
    -- Implementação simples de espera sem corrotinas
    local max_wait_time = 30 -- máximo 30 segundos
    local start_time = os.clock()
    
    while self.running and self.queue_manager:has_tasks() do
        -- Verificar timeout
        if os.clock() - start_time > max_wait_time then
            print('[LuaCrapper] Timeout atingido, finalizando...')
            break
        end
        
        -- Processar próxima tarefa
        local task = self.queue_manager:get_next_task()
        if task then
            self:_process_task(task)
        else
            -- Pequena pausa se não há tarefas
            self:_sleep(0.1)
        end
    end
    
    self:stop()
    
    return self
end

-- Função auxiliar para simular sleep
function LuaCrapper:_sleep(seconds)
    local start = os.clock()
    while os.clock() - start < seconds do
        -- Busy wait
    end
end

-- Exportar resultados
function LuaCrapper:export(filename, format)
    format = format or self.config.export_format
    
    local exporter = self.exporters[format]
    if not exporter then
        error('Formato de exportação não suportado: ' .. format)
    end
    
    return exporter:export(self.results, filename)
end

-- Obter estatísticas
function LuaCrapper:get_stats()
    local stats = {}
    for k, v in pairs(self.stats) do
        stats[k] = v
    end
    
    if stats.start_time and stats.end_time then
        stats.duration = stats.end_time - stats.start_time
        stats.urls_per_second = stats.processed_urls / stats.duration
    end
    
    return stats
end

-- Obter resultados
function LuaCrapper:get_results()
    return self.results
end

-- Limpar resultados
function LuaCrapper:clear_results()
    self.results = {}
    return self
end

return LuaCrapper