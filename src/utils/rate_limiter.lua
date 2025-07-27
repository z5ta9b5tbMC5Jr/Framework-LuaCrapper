--[[
    RateLimiter - Controle de taxa de requisições
    Desenvolvido por: Bypass-dev
    Ano: 2025
--]]

local RateLimiter = {}
RateLimiter.__index = RateLimiter

-- Construtor
function RateLimiter:new(config)
    local instance = {
        requests_per_second = config.requests_per_second or 1,
        burst_size = config.burst_size or 5,
        tokens = config.burst_size or 5,
        last_refill = os.clock(),
        stats = {
            total_requests = 0,
            total_waits = 0,
            total_wait_time = 0
        }
    }
    
    setmetatable(instance, self)
    
    return instance
end

-- Aguardar se necessário antes de fazer requisição
function RateLimiter:wait()
    local start_time = os.clock()
    
    -- Reabastecer tokens
    self:_refill_tokens()
    
    -- Se não há tokens disponíveis, aguardar
    while self.tokens < 1 do
        self:_sleep(0.1)
        self:_refill_tokens()
        self.stats.total_waits = self.stats.total_waits + 1
    end
    
    -- Consumir um token
    self.tokens = self.tokens - 1
    self.stats.total_requests = self.stats.total_requests + 1
    
    local wait_time = os.clock() - start_time
    self.stats.total_wait_time = self.stats.total_wait_time + wait_time
    
    return wait_time
end

-- Reabastecer tokens baseado no tempo
function RateLimiter:_refill_tokens()
    local now = os.clock()
    local time_passed = now - self.last_refill
    
    -- Calcular quantos tokens adicionar
    local tokens_to_add = time_passed * self.requests_per_second
    
    if tokens_to_add > 0 then
        self.tokens = math.min(self.burst_size, self.tokens + tokens_to_add)
        self.last_refill = now
    end
end

-- Função auxiliar para sleep
function RateLimiter:_sleep(seconds)
    local start = os.clock()
    while os.clock() - start < seconds do
        -- Busy wait
    end
end

-- Obter estatísticas
function RateLimiter:get_stats()
    return self.stats
end

-- Resetar estatísticas
function RateLimiter:reset_stats()
    self.stats = {
        total_requests = 0,
        total_waits = 0,
        total_wait_time = 0
    }
end

return RateLimiter