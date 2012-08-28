
require_relative "local/rake"

@deploy_dir = ENV['DEPLOY_DIR'] || File::dirname(__FILE__) + "/build/tmp-angstrom_v2012_05-eglibc/deploy/images/beaglebone/"

Partition.new( "boot" ) do |p|
  p.partition_number = 1
  p.fs = "vfat"
  p.mkfs = "mkfs.vfat -F 32 -n \"boot\""
  p.mountpoint = "/mnt/bootfs"
end

Partition.new( "root" ) do |p|
  p.partition_number = 2
  p.fs = "ext3"
  p.mkfs = "mke2fs -j -L \"Angstrom\""
  p.mountpoint = "/mnt/rootfs"
end

def machine
  `grep MACHINE conf/auto.conf`.split('"')[1]
end

namespace :oe do

  task :machine do
    puts "Running with MACHINE=#{machine}"
    ENV['MACHINE'] = machine
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
      bitbake( "virtual/kernel" )
    end

    task :systemd_image do
      bitbake( "systemd-image" )
    end
  end
end


####################

desc "Format the SD card in #{@destination_dev}"
task :format_card do
  sudosh "local/format_card.sh #{@destination_dev}"
end

task :copy_to_boot => [ :mount_boot ] do
  def copy_to_boot( infile, outfile )
      sudosh "cp #{@deploy_dir}/#{infile} #{@boot_mount}/#{outfile}"
  end

  { "MLO" => "MLO",
    "u-boot.img" => "u-boot.img",
    "uImage-beaglebone.bin" => "uImage" }.each_pair { |k,v|
    copy_to_boot( k, v )
  }
  sudosh "cp ./local/uEnv.txt #{@boot_mount}"
end

task :mk_boot => [ :copy_to_boot, :umount_boot] 

task :copy_to_root => [ :mount_root ] do
  sudosh "tar -xjv -C #{@root_mount} -f #{@deploy_dir}/systemd-image-beaglebone.tar.bz2"
end

task :mk_root => [ :copy_to_root, :umount_root]

task :copy_all => [ :copy_to_boot, :copy_to_root ]

task :make_all => [ :copy_all, :umount_all ]
