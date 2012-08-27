

class Partition
  include Rake::DSL

  attr_accessor :name, :fs, :mkfs_flags, :partition_number
  attr_writer :mountpoint

  def initialize( name )
    @name = name
    @mountpoint = nil
    yield self

    namespace name do
      desc "Mount #{name}"
      task :mount do; mount; end

      desc "Unmount #{name}"
      task :unmount do; unmount; end
    end

    desc "Mount all partitions"
    task :mount_all => "#{name}:mount".to_s

    desc "Unmount all partitions"
    task :unmount_all => "#{name}:unmount".to_s
  end

  def device 
    d = ENV['DEVICE']
    raise "Must set device for SD card" unless d
    "/dev/#{d}"
  end

  def partition
    device + partition_number.to_s
  end

  def mountpoint
    @mountpoint ||= "/mnt/#{name}"
  end

  def mount
    puts "Mounting #{name}"
    sudosh [ "mount -t", fs, partition, mountpoint ].join(' ')
  end

  def unmount
    puts "Unmounting #{name}"
    sudosh [ "umount", mountpoint ].join(' ')
  end

end

