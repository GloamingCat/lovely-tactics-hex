
return function(event)
  local func = event.param
  if type(func) == 'string' then
    func = loadfunction(event.param, 'event')
  end
  func(event)
end