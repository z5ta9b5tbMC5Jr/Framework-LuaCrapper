--[[
    QueueManager - Sistema de filas de tarefas
    Desenvolvido por: Bypass-dev
    Ano: 2025
--]]

local QueueManager = {}
QueueManager.__index = QueueManager

-- Construtor
function QueueManager:new(config)
    local instance = {
        config = config or {},
        tasks = {},
        completed_tasks = {},
        failed_tasks = {},
        stats = {
            total_added = 0,
            total_completed = 0,
            total_failed = 0
        }
    }
    
    setmetatable(instance, self)
    
    return instance
end

-- Adicionar tarefa
function QueueManager:add_task(task)
    task.id = task.id or self:_generate_id()
    task.status = 'pending'
    task.created_at = task.created_at or os.time()
    
    table.insert(self.tasks, task)
    self.stats.total_added = self.stats.total_added + 1
    
    return task.id
end

-- Obter próxima tarefa
function QueueManager:get_next_task()
    if #self.tasks == 0 then
        return nil
    end
    
    -- Ordenar por prioridade
    table.sort(self.tasks, function(a, b)
        return (a.priority or 1) > (b.priority or 1)
    end)
    
    local task = table.remove(self.tasks, 1)
    if task then
        task.status = 'processing'
        task.started_at = os.time()
    end
    
    return task
end

-- Marcar tarefa como concluída
function QueueManager:complete_task(task_id, result)
    local task = self:_find_task_by_id(task_id)
    if task then
        task.status = 'completed'
        task.completed_at = os.time()
        task.result = result
        
        table.insert(self.completed_tasks, task)
        self.stats.total_completed = self.stats.total_completed + 1
    end
    
    return task ~= nil
end

-- Marcar tarefa como falhada
function QueueManager:fail_task(task_id, error_message)
    local task = self:_find_task_by_id(task_id)
    if task then
        task.status = 'failed'
        task.failed_at = os.time()
        task.error = error_message
        
        table.insert(self.failed_tasks, task)
        self.stats.total_failed = self.stats.total_failed + 1
    end
    
    return task ~= nil
end

-- Verificar se há tarefas pendentes
function QueueManager:has_tasks()
    return #self.tasks > 0
end

-- Obter estatísticas
function QueueManager:get_stats()
    local stats = {}
    for k, v in pairs(self.stats) do
        stats[k] = v
    end
    
    stats.pending_tasks = #self.tasks
    stats.completed_tasks = #self.completed_tasks
    stats.failed_tasks = #self.failed_tasks
    
    return stats
end

-- Limpar filas
function QueueManager:clear()
    self.tasks = {}
    self.completed_tasks = {}
    self.failed_tasks = {}
    
    self.stats = {
        total_added = 0,
        total_completed = 0,
        total_failed = 0
    }
end

-- Encontrar tarefa por ID
function QueueManager:_find_task_by_id(task_id)
    for _, task in ipairs(self.tasks) do
        if task.id == task_id then
            return task
        end
    end
    return nil
end

-- Gerar ID único
function QueueManager:_generate_id()
    return string.format('%d_%d', os.time(), math.random(1000, 9999))
end

return QueueManager