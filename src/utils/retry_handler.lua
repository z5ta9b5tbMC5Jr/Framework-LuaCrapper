--[[
    RetryHandler - Sistema de retry inteligente
    Desenvolvido por: Bypass-dev
    Ano: 2025
--]]

local RetryHandler = {}
RetryHandler.__index = RetryHandler

-- Construtor
function RetryHandler:new(config)
    local instance = {
        max_attempts = config.max_attempts or 3,
        base_delay = config.base_delay or 1,
        max_delay = config.max_delay or 60,
        backoff_factor = config.backoff_factor or 2,
        jitter = config.jitter or true,
        stats = {
            total_executions = 0,
            total_retries = 0,
            total_failures = 0
        }
    }
    
    setmetatable(instance, self)
    
    return instance
end

-- Executar função com retry
function RetryHandler:execute(func, context)
    local attempt = 1
    local last_error = nil
    
    self.stats.total_executions = self.stats.total_executions + 1
    
    while attempt <= self.max_attempts do
        local success, result = pcall(func)
        
        if success then
            return true, result
        else
            last_error = result
            
            if attempt < self.max_attempts then
                local delay = self:_calculate_delay(attempt)
                self:_sleep(delay)
                self.stats.total_retries = self.stats.total_retries + 1
            end
            
            attempt = attempt + 1
        end
    end
    
    self.stats.total_failures = self.stats.total_failures + 1
    return false, last_error
end

-- Calcular delay para retry
function RetryHandler:_calculate_delay(attempt)
    local delay = self.base_delay * math.pow(self.backoff_factor, attempt - 1)
    
    -- Aplicar limite máximo
    delay = math.min(delay, self.max_delay)
    
    -- Aplicar jitter se habilitado
    if self.jitter then
        local jitter_amount = delay * 0.1 * (math.random() - 0.5)
        delay = delay + jitter_amount
    end
    
    return math.max(0, delay)
end

-- Função auxiliar para sleep
function RetryHandler:_sleep(seconds)
    local start = os.clock()
    while os.clock() - start < seconds do
        -- Busy wait
    end
end

-- Obter estatísticas
function RetryHandler:get_stats()
    return self.stats
end

-- Resetar estatísticas
function RetryHandler:reset_stats()
    self.stats = {
        total_executions = 0,
        total_retries = 0,
        total_failures = 0
    }
end

return RetryHandler