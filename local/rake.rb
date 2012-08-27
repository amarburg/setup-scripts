
require_relative "rake/partitions"

def sudosh(x); sudosh " #{x}"; end

def is_mounted( device )
  `mount | grep #{device}`.length > 0
end



