--[[
    JSONExporter - Exportação para formato JSON
    Desenvolvido por: Bypass-dev
    Ano: 2025
--]]

local JSONExporter = {}
JSONExporter.__index = JSONExporter

-- Construtor
function JSONExporter:new(config)
    local instance = {
        config = config or {},
        stats = {
            files_exported = 0,
            total_records = 0,
            total_size = 0
        }
    }
    
    setmetatable(instance, self)
    
    return instance
end

-- Exportar dados para JSON
function JSONExporter:export(data, filename)
    if not data or #data == 0 then
        error('Nenhum dado para exportar')
    end
    
    -- Preparar dados para exportação
    local export_data = {
        metadata = {
            exported_at = os.date('%Y-%m-%d %H:%M:%S'),
            total_records = #data,
            exporter = 'LuaCrapper JSONExporter v1.0',
            format_version = '1.0'
        },
        results = data
    }
    
    -- Converter para JSON
    local json_content = self:_to_json(export_data)
    
    -- Escrever arquivo
    local success = self:_write_file(filename, json_content)
    
    if success then
        self.stats.files_exported = self.stats.files_exported + 1
        self.stats.total_records = self.stats.total_records + #data
        self.stats.total_size = self.stats.total_size + #json_content
        
        return {
            success = true,
            filename = filename,
            records = #data,
            size = #json_content
        }
    else
        error('Falha ao escrever arquivo: ' .. filename)
    end
end

-- Converter dados para JSON
function JSONExporter:_to_json(data)
    -- Tentar usar lua-cjson se disponível
    local has_cjson, cjson = pcall(require, 'cjson')
    
    if has_cjson then
        return cjson.encode(data)
    else
        return self:_manual_json_encode(data)
    end
end

-- Codificação JSON manual (fallback)
function JSONExporter:_manual_json_encode(data)
    local function encode_value(value)
        local value_type = type(value)
        
        if value_type == 'nil' then
            return 'null'
        elseif value_type == 'boolean' then
            return value and 'true' or 'false'
        elseif value_type == 'number' then
            return tostring(value)
        elseif value_type == 'string' then
            return '"' .. self:_escape_json_string(value) .. '"'
        elseif value_type == 'table' then
            return self:_encode_table(value)
        else
            return '"' .. tostring(value) .. '"'
        end
    end
    
    self._encode_value = encode_value
    return encode_value(data)
end

-- Codificar tabela JSON
function JSONExporter:_encode_table(tbl)
    local is_array = self:_is_array(tbl)
    local parts = {}
    
    if is_array then
        for i = 1, #tbl do
            table.insert(parts, self._encode_value(tbl[i]))
        end
        return '[' .. table.concat(parts, ',') .. ']'
    else
        for key, value in pairs(tbl) do
            local encoded_key = '"' .. self:_escape_json_string(tostring(key)) .. '"'
            local encoded_value = self._encode_value(value)
            table.insert(parts, encoded_key .. ':' .. encoded_value)
        end
        return '{' .. table.concat(parts, ',') .. '}'
    end
end

-- Verificar se tabela é array
function JSONExporter:_is_array(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    
    for i = 1, count do
        if tbl[i] == nil then
            return false
        end
    end
    
    return count > 0
end

-- Escapar string JSON
function JSONExporter:_escape_json_string(str)
    local replacements = {
        ['\\'] = '\\\\',
        ['"'] = '\\"',
        ['/'] = '\\/',
        ['\b'] = '\\b',
        ['\f'] = '\\f',
        ['\n'] = '\\n',
        ['\r'] = '\\r',
        ['\t'] = '\\t'
    }
    
    return str:gsub('[\\"/%c]', replacements)
end

-- Escrever arquivo
function JSONExporter:_write_file(filename, content)
    local file = io.open(filename, 'w')
    if not file then
        return false
    end
    
    file:write(content)
    file:close()
    
    return true
end

-- Obter estatísticas
function JSONExporter:get_stats()
    return self.stats
end

return JSONExporter