
@deploy_dir = "/mnt/usbstick/beaglebone"
@destination_dev = "/dev/sde"

@boot_mount = "/mnt/bootfs"
@root_mount = "/mnt/rootfs"

def dest_partition(i, device = @destination_dev )
  device + i.to_s
end

def boot_partition; dest_partition(1); end
def root_partition; dest_partition(2); end

def sudosh(x); sudosh " #{x}"; end

def is_mounted( device )
  `mount | grep #{device}`.length > 0
end

####################


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

task :mount_all => [ :mount_boot, :mount_root ]
task :umount_all => [ :umount_boot, :umount_root ]

file @boot_mount do
  sudosh "mkdir #{@boot_mount}"
end

task :mount_boot => [ @boot_mount ] do
  sudosh" mount -t vfat #{boot_partition} #{@boot_mount}" unless is_mounted boot_partition
end

task :umount_boot do
  sudosh "umount #{@boot_mount}" if is_mounted root_partition
end

file @root_mount do
  sudosh "mkdir #{@root_mount}"
end

task :mount_root => [ @root_mount ] do
  sudosh "mount -t ext3 #{root_partition} #{@root_mount}" unless is_mounted root_partition
end

task :umount_root do
  sudosh "umount #{@root_mount}"
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
