
require_relative "lib/rake"

bootfs = Partition.new( "boot" ) do |p|
  p.partition_number = 1
  p.fs = "vfat"
  p.before_mkfs = Proc.new { |partition| 
    sudosh "dd if=/dev/zero of=#{partition} bs=512 count=1" 
  }
  p.mkfs = "mkfs.vfat -F 32 -n \"boot\""
  p.mountpoint = "/tmp/beaglebone/bootfs"

  p.files in_deploy_dir( "MLO" ),
          in_deploy_dir( "u-boot.img" ),
#          { in_deploy_dir( "uImage-beaglebone.bin" ) => "uImage" },
          "lib/uEnv.txt"
 end

rootfs = RootPartition.new( "root" ) do |p|
  p.partition_number = 2
  p.fs = "ext3"
  p.mkfs = "mke2fs -j -L \"Angstrom\""
  p.mountpoint = "/tmp/beaglebone/rootfs"
  p.image = in_deploy_dir("systemd-image-beaglebone.tar.gz")
end

namespace :oe do

  task :machine do
    puts "Running with MACHINE=#{machine}"
    ENV['MACHINE'] = machine
  end

  desc "Configure the local environment."
  task :config do
    raise "For config, the machine must be set: MACHINE=beaglebone rake oe:setup" unless ENV['MACHINE']
    sh "./oebb.sh config #{ENV['MACHINE']}"
  end

  desc "Run oebb.sh reset"
  task :reset => [:machine] do
    sh "./oebb.sh reset"
  end

  desc "Update the layers"
  task :update => [:machine] do
    sh "./oebb.sh update"
  end

  namespace :bitbake do

    def bitbake(x)
      sh ". environment-angstrom-v2013.12; bitbake #{x}"
    end

    desc "Build the kernel"
    task :kernel do
      bitbake "virtual/kernel" 
    end

    desc "Build the systemd image"
    task :systemd_image do
      bitbake "systemd-image" 
    end
  end
end


####################

namespace :sd do

  desc "Format the SD card"
 task :format do
    sudosh "lib/format_card.sh #{device}"
    sudosh "sync"
    sudosh "sync"
    sudosh "sync"
    sleep(2)
    
    #sudosh "dmsetup remove #{File.basename(partition)}" if `sudo dmsetup ls | grep #{File.basename(partition)}`.length > 0
    [rootfs, bootfs].each { |fs|
      sudosh "dmsetup remove #{File.basename(fs.partition)}" if `sudo dmsetup ls | grep #{File.basename(fs.partition)}`.length > 0
    }
  end

  task :copy_all => ["boot", "root"].map { |partition|
                       "#{partition}:mkfs_then_copy".to_sym  }

  task :make_all => [ :copy_all, :unmount_all ]

  desc "Format, mkfs, and copy files to a card.  Destroys any existing data on the card without asking!"
  task :create => [ :unmount_all, :format, :make_all, :unmount_all ]
end
