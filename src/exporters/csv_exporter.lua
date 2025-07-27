--[[
    CSVExporter - Exportação para formato CSV
    Desenvolvido por: Bypass-dev
    Ano: 2025
--]]

local CSVExporter = {}
CSVExporter.__index = CSVExporter

-- Construtor
function CSVExporter:new(config)
    local instance = {
        config = config or {},
        delimiter = config.delimiter or ',',
        quote_char = config.quote_char or '"',
        escape_char = config.escape_char or '"',
        stats = {
            files_exported = 0,
            total_records = 0,
            total_size = 0
        }
    }
    
    setmetatable(instance, self)
    
    return instance
end

-- Exportar dados para CSV
function CSVExporter:export(data, filename)
    if not data or #data == 0 then
        error('Nenhum dado para exportar')
    end
    
    -- Preparar dados para CSV
    local csv_content = self:_to_csv(data)
    
    -- Escrever arquivo
    local success = self:_write_file(filename, csv_content)
    
    if success then
        self.stats.files_exported = self.stats.files_exported + 1
        self.stats.total_records = self.stats.total_records + #data
        self.stats.total_size = self.stats.total_size + #csv_content
        
        return {
            success = true,
            filename = filename,
            records = #data,
            size = #csv_content
        }
    else
        error('Falha ao escrever arquivo: ' .. filename)
    end
end

-- Converter dados para CSV
function CSVExporter:_to_csv(data)
    if #data == 0 then
        return ''
    end
    
    -- Extrair colunas do primeiro registro
    local columns = self:_extract_columns(data[1])
    
    -- Criar cabeçalho
    local csv_lines = { self:_create_header(columns) }
    
    -- Adicionar dados
    for _, record in ipairs(data) do
        table.insert(csv_lines, self:_create_row(record, columns))
    end
    
    return table.concat(csv_lines, '\n')
end

-- Extrair colunas dos dados
function CSVExporter:_extract_columns(sample_record)
    local columns = {
        'task_id', 'url', 'final_url', 'status_code', 'content_type',
        'size', 'scraped_at', 'title', 'description', 'word_count',
        'link_count', 'image_count', 'language'
    }
    
    return columns
end

-- Criar cabeçalho CSV
function CSVExporter:_create_header(columns)
    local header_parts = {}
    
    for _, column in ipairs(columns) do
        table.insert(header_parts, self:_escape_csv_value(column))
    end
    
    return table.concat(header_parts, self.delimiter)
end

-- Criar linha CSV
function CSVExporter:_create_row(record, columns)
    local row_parts = {}
    
    for _, column in ipairs(columns) do
        local value = self:_get_nested_value(record, column)
        table.insert(row_parts, self:_escape_csv_value(tostring(value or '')))
    end
    
    return table.concat(row_parts, self.delimiter)
end

-- Obter valor aninhado
function CSVExporter:_get_nested_value(record, path)
    local current = record
    
    -- Mapeamento de caminhos para valores
    local mappings = {
        task_id = 'task_id',
        url = 'url',
        final_url = 'final_url',
        status_code = 'status_code',
        content_type = 'content_type',
        size = 'size',
        scraped_at = 'scraped_at',
        title = function(r) return r.data and r.data.basic_info and r.data.basic_info.title or '' end,
        description = function(r) return r.data and r.data.basic_info and r.data.basic_info.description or '' end,
        word_count = function(r) return r.data and r.data.basic_info and r.data.basic_info.word_count or 0 end,
        link_count = function(r) return r.data and r.data.basic_info and r.data.basic_info.link_count or 0 end,
        image_count = function(r) return r.data and r.data.basic_info and r.data.basic_info.image_count or 0 end,
        language = function(r) return r.data and r.data.basic_info and r.data.basic_info.language or 'unknown' end
    }
    
    local mapping = mappings[path]
    
    if type(mapping) == 'function' then
        return mapping(record)
    elseif type(mapping) == 'string' then
        return record[mapping]
    else
        return ''
    end
end

-- Escapar valor CSV
function CSVExporter:_escape_csv_value(value)
    local str_value = tostring(value)
    
    -- Verificar se precisa de aspas
    local needs_quotes = str_value:find(self.delimiter) or 
                        str_value:find(self.quote_char) or 
                        str_value:find('\n') or 
                        str_value:find('\r')
    
    if needs_quotes then
        -- Escapar aspas internas
        str_value = str_value:gsub(self.quote_char, self.escape_char .. self.quote_char)
        -- Envolver em aspas
        str_value = self.quote_char .. str_value .. self.quote_char
    end
    
    return str_value
end

-- Escrever arquivo
function CSVExporter:_write_file(filename, content)
    local file = io.open(filename, 'w')
    if not file then
        return false
    end
    
    file:write(content)
    file:close()
    
    return true
end

-- Obter estatísticas
function CSVExporter:get_stats()
    return self.stats
end

return CSVExporter