

class Partition
  include Rake::DSL

  attr_accessor :name, :fs, :mkfs, :partition_number
  attr_writer :mountpoint

  def initialize( name )
    @name = name
    @mountpoint = nil
    yield self
    define_tasks
  end

  def define_tasks
    namespace name do
      desc "Mount #{name}"
      task :mount do; mount; end

      desc "Unmount #{name}"
      task :unmount do; unmount; end

      desc "Make the filesystem"
      task :mkfs => [:unmount] do; makefs; end
    end

    desc "Mount all partitions"
    task :mount_all => "#{name}:mount".to_s

    desc "Unmount all partitions"
    task :unmount_all => "#{name}:unmount".to_s
  end

  def device 
    d = ENV['DEVICE']
    raise "Must set device for SD card.  Run as \"rake {taskname} DEVICE=sdx\"" unless d
    "/dev/#{d}"
  end

  def partition
    device + partition_number.to_s
  end

  def mountpoint
    @mountpoint ||= "/mnt/#{name}"
  end

  def mounted?
    is_mounted partition
  end

  def mount
    unless mounted?
      puts "Mounting #{name}"
      sudosh [ "mount -t", fs, partition, mountpoint ].join(' ')
    end
  end

  def unmount
    if mounted?
      puts "Unmounting #{name}"
      sudosh [ "umount", mountpoint ].join(' ') 
    end
  end

  def makefs
    raise "mkfs string not defined" unless @mkfs
    puts "Running #{@mkfs}"
    sudosh [ @mkfs, partition ].join(' ')
  end

end

