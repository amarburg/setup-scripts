
@deploy_dir = "/mnt/usbstick/beaglebone"
@destination_dev = "/dev/sde"

@boot_mount = "/mnt/bootfs"
@root_mount = "/mnt/rootfs"

def dest_partition(i, device = @destination_dev )
  device + i.to_s
end

def boot_partition; dest_partition(1); end
def root_partition; dest_partition(2); end

def is_mounted( device )
  `mount | grep #{device}`.length > 0
end

desc "Format the SD card in #{@destination_dev}"
task :format_card do
  sh "sudo local-scripts/format_card.sh #{@destination_dev}"
end

task :mount_all => [ :mount_boot, :mount_root ]
task :umount_all => [ :umount_boot, :umount_root ]

file @boot_mount do
  sh "sudo mkdir #{@boot_mount}"
end

task :mount_boot => [ @boot_mount ] do
  sh "sudo mount -t vfat #{boot_partition} #{@boot_mount}" unless is_mounted boot_partition
end

task :umount_boot do
  sh "sudo umount #{@boot_mount}" if is_mounted root_partition
end

file @root_mount do
  sh "sudo mkdir #{@root_mount}"
end

task :mount_root => [ @root_mount ] do
  sh "sudo mount -t ext3 #{root_partition} #{@root_mount}" unless is_mounted root_partition
end

task :umount_root do
  sh "sudo umount #{@root_mount}"
end

task :copy_to_boot => [ :mount_boot ] do
  def copy_to_boot( infile, outfile )
      sh "sudo cp #{@deploy_dir}/#{infile} #{@boot_mount}/#{outfile}"
  end

  { "MLO" => "MLO",
    "u-boot.img" => "u-boot.img",
    "uImage-beaglebone.bin" => "uImage" }.each_pair { |k,v|
    copy_to_boot( k, v )
  }
  sh "sudo cp ./local-scripts/uEnv.txt #{@boot_mount}"
end

task :mk_boot => [ :copy_to_boot, :umount_boot] 

task :copy_to_root => [ :mount_root ] do
  sh "sudo tar -xjv -C #{@root_mount} -f #{@deploy_dir}/systemd-image-beaglebone.tar.bz2"
end

task :mk_root => [ :copy_to_root, :umount_root]

task :copy_all => [ :copy_to_boot, :copy_to_root ]

task :make_all => [ :copy_all, :umount_all ]
