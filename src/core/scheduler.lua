--[[
    Scheduler - Sistema de agendamento com rate limiting
    Desenvolvido por: Bypass-dev
    Ano: 2025
--]]

local Scheduler = {}
Scheduler.__index = Scheduler

local RateLimiter = require('src.utils.rate_limiter')
local RetryHandler = require('src.utils.retry_handler')

-- Construtor
function Scheduler:new(config)
    local instance = {
        config = config or {},
        rate_limiter = nil,
        retry_handler = nil,
        running = false,
        workers = {},
        task_queue = {},
        processing_callback = nil,
        stats = {
            tasks_scheduled = 0,
            tasks_completed = 0,
            tasks_failed = 0,
            active_workers = 0
        }
    }
    
    setmetatable(instance, self)
    
    -- Inicializar componentes
    instance.rate_limiter = RateLimiter:new({
        requests_per_second = config.rate_limit or 1,
        burst_size = config.burst_size or 5
    })
    
    instance.retry_handler = RetryHandler:new({
        max_attempts = config.retry_attempts or 3,
        base_delay = config.retry_delay or 1,
        max_delay = config.max_retry_delay or 60,
        backoff_factor = config.backoff_factor or 2
    })
    
    return instance
end

-- Iniciar o scheduler
function Scheduler:start(processing_callback)
    if self.running then
        return false
    end
    
    self.running = true
    self.processing_callback = processing_callback
    
    -- Criar workers
    local max_workers = self.config.max_concurrent or 5
    for i = 1, max_workers do
        self:_create_worker(i)
    end
    
    print(string.format('[Scheduler] Iniciado com %d workers', max_workers))
    
    return true
end

-- Parar o scheduler
function Scheduler:stop()
    if not self.running then
        return false
    end
    
    self.running = false
    
    -- Aguardar workers terminarem
    for _, worker in pairs(self.workers) do
        if coroutine.status(worker.coroutine) ~= 'dead' then
            coroutine.resume(worker.coroutine)
        end
    end
    
    self.workers = {}
    
    print('[Scheduler] Parado')
    
    return true
end

-- Adicionar tarefa à fila
function Scheduler:add_task(task)
    task.id = task.id or self:_generate_task_id()
    task.priority = task.priority or 1
    task.attempts = 0
    task.created_at = task.created_at or os.time()
    
    -- Inserir na fila ordenada por prioridade
    local inserted = false
    for i, queued_task in ipairs(self.task_queue) do
        if task.priority > queued_task.priority then
            table.insert(self.task_queue, i, task)
            inserted = true
            break
        end
    end
    
    if not inserted then
        table.insert(self.task_queue, task)
    end
    
    self.stats.tasks_scheduled = self.stats.tasks_scheduled + 1
    
    return task.id
end

-- Obter próxima tarefa
function Scheduler:get_next_task()
    if #self.task_queue == 0 then
        return nil
    end
    
    return table.remove(self.task_queue, 1)
end

-- Verificar se há tarefas pendentes
function Scheduler:has_pending_tasks()
    return #self.task_queue > 0
end

-- Criar worker
function Scheduler:_create_worker(worker_id)
    local worker = {
        id = worker_id,
        coroutine = nil,
        active = false,
        current_task = nil
    }
    
    worker.coroutine = coroutine.create(function()
        self:_worker_loop(worker)
    end)
    
    self.workers[worker_id] = worker
    
    -- Iniciar worker
    coroutine.resume(worker.coroutine)
    
    return worker
end

-- Loop principal do worker
function Scheduler:_worker_loop(worker)
    while self.running do
        local task = self:get_next_task()
        
        if task then
            worker.active = true
            worker.current_task = task
            self.stats.active_workers = self.stats.active_workers + 1
            
            -- Aplicar rate limiting
            self.rate_limiter:wait()
            
            -- Processar tarefa
            local success, result = self:_process_task_with_retry(task)
            
            if success then
                self.stats.tasks_completed = self.stats.tasks_completed + 1
            else
                self.stats.tasks_failed = self.stats.tasks_failed + 1
            end
            
            worker.active = false
            worker.current_task = nil
            self.stats.active_workers = self.stats.active_workers - 1
        else
            -- Não há tarefas, aguardar
            coroutine.yield()
        end
    end
end

-- Processar tarefa com retry
function Scheduler:_process_task_with_retry(task)
    return self.retry_handler:execute(function()
        task.attempts = task.attempts + 1
        task.last_attempt = os.time()
        
        if self.processing_callback then
            return self.processing_callback(task)
        else
            error('Nenhum callback de processamento definido')
        end
    end, task)
end

-- Gerar ID único para tarefa
function Scheduler:_generate_task_id()
    return string.format('%d_%d', os.time(), math.random(1000, 9999))
end

-- Obter estatísticas
function Scheduler:get_stats()
    local stats = {}
    for k, v in pairs(self.stats) do
        stats[k] = v
    end
    
    stats.pending_tasks = #self.task_queue
    stats.total_workers = #self.workers
    
    return stats
end

-- Obter status dos workers
function Scheduler:get_worker_status()
    local status = {}
    
    for worker_id, worker in pairs(self.workers) do
        status[worker_id] = {
            active = worker.active,
            current_task = worker.current_task and worker.current_task.id or nil,
            coroutine_status = coroutine.status(worker.coroutine)
        }
    end
    
    return status
end

-- Limpar fila de tarefas
function Scheduler:clear_queue()
    self.task_queue = {}
    return true
end

return Scheduler