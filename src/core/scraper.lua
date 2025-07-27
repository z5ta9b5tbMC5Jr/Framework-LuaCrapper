--[[
    Scraper - Motor principal de scraping
    Desenvolvido por: Bypass-dev
    Ano: 2025
--]]

local Scraper = {}
Scraper.__index = Scraper

local HTMLParser = require('src.plugins.html_parser')
local DataExtractor = require('src.plugins.data_extractor')

-- Construtor
function Scraper:new(config)
    local instance = {
        config = config or {},
        html_parser = nil,
        data_extractor = nil,
        stats = {
            requests_made = 0,
            bytes_downloaded = 0,
            average_response_time = 0
        }
    }
    
    setmetatable(instance, self)
    
    -- Inicializar componentes
    instance.html_parser = HTMLParser:new(config)
    instance.data_extractor = DataExtractor:new(config)
    
    return instance
end

-- Fazer scraping de uma URL
function Scraper:scrape(task)
    local start_time = os.clock()
    
    -- Fazer requisição HTTP
    local response = self:_make_request(task)
    
    if not response then
        error('Falha na requisição HTTP')
    end
    
    -- Processar resposta
    local result = {
        task_id = task.id,
        url = task.url,
        final_url = response.final_url or task.url,
        status_code = response.status_code,
        headers = response.headers,
        content_type = response.headers and response.headers['content-type'] or 'unknown',
        size = response.body and #response.body or 0,
        scraped_at = os.date('%Y-%m-%d %H:%M:%S'),
        metadata = {
            user_agent = self.config.user_agent,
            timeout = self.config.timeout,
            attempts = task.attempts,
            tags = task.tags or {}
        }
    }
    
    -- Analisar HTML se aplicável
    if response.body and self:_is_html_content(response) then
        result.parsed_html = self.html_parser:parse(response.body)
        result.data = self.data_extractor:extract(result.parsed_html, task)
    else
        result.data = response.body
    end
    
    -- Atualizar estatísticas
    local response_time = os.clock() - start_time
    self:_update_stats(response_time, result.size)
    
    return result
end

-- Fazer requisição HTTP
function Scraper:_make_request(task)
    -- Implementação básica usando io.popen (para compatibilidade)
    local url = task.url
    local timeout = self.config.timeout or 30
    local user_agent = self.config.user_agent or 'LuaCrapper/1.0'
    
    -- Comando curl básico
    local cmd = string.format(
        'curl -s -L --max-time %d -H "User-Agent: %s" "%s"',
        timeout, user_agent, url
    )
    
    local handle = io.popen(cmd)
    if not handle then
        return nil
    end
    
    local body = handle:read('*a')
    local success = handle:close()
    
    if not success or not body or body == '' then
        return nil
    end
    
    -- Simular resposta HTTP
    return {
        status_code = 200,
        headers = {
            ['content-type'] = 'text/html; charset=utf-8'
        },
        body = body,
        final_url = url
    }
end

-- Verificar se o conteúdo é HTML
function Scraper:_is_html_content(response)
    if not response.headers then
        return false
    end
    
    local content_type = response.headers['content-type'] or ''
    return content_type:find('text/html') ~= nil
end

-- Atualizar estatísticas
function Scraper:_update_stats(response_time, size)
    self.stats.requests_made = self.stats.requests_made + 1
    self.stats.bytes_downloaded = self.stats.bytes_downloaded + size
    
    -- Calcular tempo médio de resposta
    local total_time = self.stats.average_response_time * (self.stats.requests_made - 1)
    self.stats.average_response_time = (total_time + response_time) / self.stats.requests_made
end

-- Obter estatísticas
function Scraper:get_stats()
    return self.stats
end

return Scraper