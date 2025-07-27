--[[
    HTMLParser - Parser HTML com lua-gumbo
    Desenvolvido por: Bypass-dev
    Ano: 2025
--]]

local HTMLParser = {}
HTMLParser.__index = HTMLParser

-- Construtor
function HTMLParser:new(config)
    local instance = {
        config = config or {},
        stats = {
            documents_parsed = 0,
            total_elements = 0,
            parse_errors = 0
        }
    }
    
    setmetatable(instance, self)
    
    return instance
end

-- Analisar HTML
function HTMLParser:parse(html_content)
    if not html_content or html_content == '' then
        self.stats.parse_errors = self.stats.parse_errors + 1
        return nil
    end
    
    local success, result = pcall(function()
        return self:_parse_html(html_content)
    end)
    
    if success then
        self.stats.documents_parsed = self.stats.documents_parsed + 1
        return result
    else
        self.stats.parse_errors = self.stats.parse_errors + 1
        return self:_fallback_parse(html_content)
    end
end

-- Parser HTML principal (com fallback)
function HTMLParser:_parse_html(html_content)
    -- Tentar usar lua-gumbo se disponível
    local has_gumbo, gumbo = pcall(require, 'gumbo')
    
    if has_gumbo then
        return self:_parse_with_gumbo(html_content, gumbo)
    else
        return self:_parse_with_patterns(html_content)
    end
end

-- Parser usando lua-gumbo
function HTMLParser:_parse_with_gumbo(html_content, gumbo)
    local document = gumbo.parse(html_content)
    
    local result = {
        title = self:_extract_title(document),
        meta = self:_extract_meta(document),
        links = self:_extract_links(document),
        images = self:_extract_images(document),
        text = self:_extract_text(document),
        structure = self:_extract_structure(document)
    }
    
    self.stats.total_elements = self.stats.total_elements + self:_count_elements(document)
    
    return result
end

-- Parser usando padrões regex (fallback)
function HTMLParser:_parse_with_patterns(html_content)
    local result = {
        title = self:_extract_title_pattern(html_content),
        meta = self:_extract_meta_pattern(html_content),
        links = self:_extract_links_pattern(html_content),
        images = self:_extract_images_pattern(html_content),
        text = self:_extract_text_pattern(html_content),
        structure = { type = 'fallback_parse' }
    }
    
    return result
end

-- Extrair título usando padrões
function HTMLParser:_extract_title_pattern(html)
    local title = html:match('<title[^>]*>([^<]*)</title>')
    return title and title:gsub('^%s*(.-)%s*$', '%1') or ''
end

-- Extrair meta tags usando padrões
function HTMLParser:_extract_meta_pattern(html)
    local meta = {}
    
    for name, content in html:gmatch('<meta[^>]*name=["\']([^"\']*)["\''][^>]*content=["\']([^"\']*)["\''][^>]*>') do
        meta[name] = content
    end
    
    return meta
end

-- Extrair links usando padrões
function HTMLParser:_extract_links_pattern(html)
    local links = {}
    
    for href, text in html:gmatch('<a[^>]*href=["\']([^"\']*)["\''][^>]*>([^<]*)</a>') do
        table.insert(links, {
            href = href,
            text = text:gsub('^%s*(.-)%s*$', '%1')
        })
    end
    
    return links
end

-- Extrair imagens usando padrões
function HTMLParser:_extract_images_pattern(html)
    local images = {}
    
    for src, alt in html:gmatch('<img[^>]*src=["\']([^"\']*)["\''][^>]*alt=["\']([^"\']*)["\''][^>]*>') do
        table.insert(images, {
            src = src,
            alt = alt
        })
    end
    
    return images
end

-- Extrair texto usando padrões
function HTMLParser:_extract_text_pattern(html)
    -- Remover scripts e styles
    local clean_html = html:gsub('<script[^>]*>.-</script>', '')
    clean_html = clean_html:gsub('<style[^>]*>.-</style>', '')
    
    -- Remover tags HTML
    local text = clean_html:gsub('<[^>]*>', ' ')
    
    -- Limpar espaços extras
    text = text:gsub('%s+', ' ')
    text = text:gsub('^%s*(.-)%s*$', '%1')
    
    return text
end

-- Parser de fallback simples
function HTMLParser:_fallback_parse(html_content)
    return {
        title = '',
        meta = {},
        links = {},
        images = {},
        text = html_content:gsub('<[^>]*>', ' '):gsub('%s+', ' '),
        structure = { type = 'fallback', error = 'Parse failed' }
    }
end

-- Obter estatísticas
function HTMLParser:get_stats()
    return self.stats
end

return HTMLParser