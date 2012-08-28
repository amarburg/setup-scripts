
require_relative "local/rake"

bootfs = Partition.new( "boot" ) do |p|
  p.partition_number = 1
  p.fs = "vfat"
  p.before_mkfs = Proc.new { |partition| 
    sudosh "dd if=/dev/zero of=#{partition} bs=512 count=1" 
  }
  p.mkfs = "mkfs.vfat -F 32 -n \"boot\""
  p.mountpoint = "/mnt/bootfs"

  p.files in_deploy_dir( "MLO" ),
          in_deploy_dir( "u-boot.img" ),
          { in_deploy_dir( "uImage-beaglebone.bin" ) => "uImage" },
          "local/uEnv.txt"

 end

rootfs = RootPartition.new( "root" ) do |p|
  p.partition_number = 2
  p.fs = "ext3"
  p.mkfs = "mke2fs -j -L \"Angstrom\""
  p.mountpoint = "/mnt/rootfs"
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

  desc "Update the layers"
  task :update => [:machine] do
    sh "./oebb.sh update"
  end

  namespace :bitbake do

    def bitbake(x)
      sh ". ~/.oe/environment-angstromv2012.05; bitbake #{x}"
    end

    task :kernel do
      bitbake "virtual/kernel" 
    end

    task :systemd_image do
      bitbake "systemd-image" 
    end
  end
end


####################

desc "Format the SD card"
task :format_card do
  sudosh "local/format_card.sh #{device}"
  sudosh "sync"
  sudosh "sync"
  sudosh "sync"
  #sudosh "dmsetup remove #{File.basename(partition)}" if `sudo dmsetup ls | grep #{File.basename(partition)}`.length > 0
  [rootfs, bootfs].each { |fs|
    sudosh "dmsetup remove #{File.basename(fs.partition)}" if `sudo dmsetup ls | grep #{File.basename(fs.partition)}`.length > 0
  }
end

task :copy_all => [ "boot:make_and_copy".to_sym, "root:make_and_copy".to_sym ]
task :make_all => [ :copy_all, :unmount_all ]

desc "Format, mkfs, and copy files to a card.  Destroys any existing data on the card without asking!"
task :create_card => [ :unmount_all, :format_card, :make_all, :unmount_all ]
