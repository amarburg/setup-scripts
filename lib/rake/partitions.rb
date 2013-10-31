

class Partition
  include Rake::DSL

  attr_accessor :name, :fs, :mkfs, :partition_number, :before_mkfs
  attr_writer :mountpoint

  def initialize( name )
    @name = name
    @mountpoint = nil
    @files = []
    yield self
    define_tasks
  end

  def define_tasks
    namespace :sd do
      namespace name do
        desc "Mount #{name}"
        task :mount do; mount; end

        desc "Unmount #{name}"
        task :unmount do; unmount; end

        desc "Make the filesystem"
        task :mkfs => [:unmount] do; makefs; end

        desc "Copy in files"
        task :copy => [:mount] do; copy_files; end

        desc "Make the FS and copy in the files"
        task :mkfs_then_copy => [ :mkfs, :copy ]
      end

      desc "Mount all partitions"
      task :mount_all => "#{name}:mount".to_s

      desc "Unmount all partitions"
      task :unmount_all => "#{name}:unmount".to_s
    end
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
    before_mkfs.call(partition) if before_mkfs
    
    sudosh [ @mkfs, partition ].join(' ')
  end

  def files( *f )
    @files.push( *f )
  end

  def copy_files
    @files.each { |file|
      src,dest = case file
                 when Hash
                   fname = file.keys.first
                   [fname, file[fname] ]
                 else
                   [file, File.basename(file)]
                 end
      dest = [mountpoint,dest].join('/')
      puts "Copying #{src} to #{dest}"
    }
  end

end

class RootPartition < Partition
  def copy_files
  sudosh "tar -xjv -C #{mountpoint} -f #{in_deploy_dir("systemd-image-beaglebone.tar.bz2")}"
  end
end

