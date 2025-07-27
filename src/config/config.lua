--[[
    Config - Gerenciamento de configurações
    Desenvolvido por: Bypass-dev
    Ano: 2025
--]]

local Config = {}
Config.__index = Config

-- Configurações padrão
local DEFAULT_CONFIG = {
    -- Scheduler
    scheduler = {
        max_concurrent = 5,
        worker_timeout = 30
    },
    
    -- Rate Limiter
    rate_limiter = {
        requests_per_second = 2,
        burst_size = 5
    },
    
    -- Scraper
    scraper = {
        timeout = 10,
        retry_attempts = 3,
        user_agent = 'LuaCrapper/1.0 (Bypass-dev)',
        follow_redirects = true
    },
    
    -- Exporters
    exporters = {
        default_format = 'json',
        json = {
            pretty_print = false,
            include_metadata = true
        },
        csv = {
            delimiter = ',',
            quote_char = '"',
            include_header = true
        }
    },
    
    -- Logging
    logging = {
        level = 'INFO',
        file = nil,
        console = true
    },
    
    -- Paths
    paths = {
        exports = 'exports',
        logs = 'logs',
        cache = 'cache'
    }
}

-- Construtor
function Config:new(config_file)
    local instance = {
        config = {},
        config_file = config_file,
        loaded = false
    }
    
    setmetatable(instance, self)
    
    -- Carregar configuração padrão
    instance:_load_defaults()
    
    -- Carregar arquivo de configuração se especificado
    if config_file then
        instance:load_file(config_file)
    end
    
    return instance
end

-- Carregar configurações padrão
function Config:_load_defaults()
    self.config = self:_deep_copy(DEFAULT_CONFIG)
end

-- Carregar arquivo de configuração
function Config:load_file(filename)
    local file = io.open(filename, 'r')
    if not file then
        return false, 'Arquivo não encontrado: ' .. filename
    end
    
    local content = file:read('*a')
    file:close()
    
    -- Tentar carregar como Lua
    local success, config_data = pcall(function()
        local func = loadstring and loadstring(content) or load(content)
        if func then
            return func()
        else
            error('Falha ao compilar configuração')
        end
    end)
    
    if success and type(config_data) == 'table' then
        self:_merge_config(config_data)
        self.loaded = true
        return true
    else
        return false, 'Falha ao carregar configuração: ' .. tostring(config_data)
    end
end

-- Mesclar configurações
function Config:_merge_config(new_config)
    self:_deep_merge(self.config, new_config)
end

-- Obter valor de configuração
function Config:get(path, default_value)
    local keys = {}
    for key in path:gmatch('[^.]+') do
        table.insert(keys, key)
    end
    
    local current = self.config
    for _, key in ipairs(keys) do
        if type(current) == 'table' and current[key] ~= nil then
            current = current[key]
        else
            return default_value
        end
    end
    
    return current
end

-- Definir valor de configuração
function Config:set(path, value)
    local keys = {}
    for key in path:gmatch('[^.]+') do
        table.insert(keys, key)
    end
    
    local current = self.config
    for i = 1, #keys - 1 do
        local key = keys[i]
        if type(current[key]) ~= 'table' then
            current[key] = {}
        end
        current = current[key]
    end
    
    current[keys[#keys]] = value
end

-- Obter toda a configuração
function Config:get_all()
    return self:_deep_copy(self.config)
end

-- Salvar configuração em arquivo
function Config:save_file(filename)
    filename = filename or self.config_file
    if not filename then
        return false, 'Nenhum arquivo especificado'
    end
    
    local file = io.open(filename, 'w')
    if not file then
        return false, 'Não foi possível abrir arquivo para escrita'
    end
    
    local content = self:_serialize_config(self.config)
    file:write(content)
    file:close()
    
    return true
end

-- Serializar configuração para Lua
function Config:_serialize_config(config, indent)
    indent = indent or 0
    local spaces = string.rep('  ', indent)
    local lines = {}
    
    table.insert(lines, '{')
    
    for key, value in pairs(config) do
        local key_str = type(key) == 'string' and key:match('^[%a_][%w_]*$') and key or ('[' .. string.format('%q', key) .. ']')
        local value_str
        
        if type(value) == 'table' then
            value_str = self:_serialize_config(value, indent + 1)
        elseif type(value) == 'string' then
            value_str = string.format('%q', value)
        else
            value_str = tostring(value)
        end
        
        table.insert(lines, spaces .. '  ' .. key_str .. ' = ' .. value_str .. ',')
    end
    
    table.insert(lines, spaces .. '}')
    
    return table.concat(lines, '\n')
end

-- Cópia profunda
function Config:_deep_copy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for key, value in pairs(original) do
            copy[self:_deep_copy(key)] = self:_deep_copy(value)
        end
    else
        copy = original
    end
    return copy
end

-- Merge profundo
function Config:_deep_merge(target, source)
    for key, value in pairs(source) do
        if type(value) == 'table' and type(target[key]) == 'table' then
            self:_deep_merge(target[key], value)
        else
            target[key] = value
        end
    end
end

return Config