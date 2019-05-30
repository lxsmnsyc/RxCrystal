module Scheduler
  abstract def schedule(process : Proc(Void))
  abstract def schedule(process : Proc(Void), delay : Float64)
end
