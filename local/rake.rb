
require_relative "rake/partitions"

def sudosh(x); sh "sudo #{x}"; end

def machine
  @machine ||= (ENV['MACHINE'] || `grep MACHINE conf/auto.conf`.split('"')[1])
end



def device 
  d = ENV['DEVICE']
  raise "Must set device for SD card.  Run as \"rake {taskname} DEVICE=sdx\"" unless d
  "/dev/#{d}"
end

def is_mounted( device )
  `mount | grep #{device}`.length > 0
end


def deploy_dir
  @deploy_dir ||= (ENV['DEPLOY_DIR'] || File::dirname(__FILE__) + "/../build/tmp-angstrom_v2012_05-eglibc/deploy/images/beaglebone")
end

def in_deploy_dir( fname )
  deploy_dir + "/" + fname
end

