
@deploy_dir = "/mnt/usbstick/beaglebone"
@destination_dev = "/dev/sdd"

@bootfs_mount = "/mnt/bootfs"
@rootfs_mount = "/mnt/rootfs"

def dest_partition(i, device = @destination_dev )
  device + i.to_s
end

desc "Format the SD card in #{@destination_dev}"
task :format_card do
  sh "sudo local-scripts/format_card.sh #{@destination_dev}"
end

task :mount_all => [ :mount_bootfs, :mount_rootfs ]
task :umount_all => [ :umount_bootfs, :umount_rootfs ]

task :mount_bootfs do
  sh "sudo mount -t vfat #{dest_partition(1)} #{@bootfs_mount}"
end

task :umount_bootfs do
  sh "sudo umount #{@bootfs_mount}"
end

task :mount_rootfs do
  sh "sudo mount -t ext3 #{dest_partition(2)} #{@rootfs_mount}"
end

task :umount_rootfs do
  sh "sudo umount #{@rootfs_mount}"
end

task :copy_to_fat => [ :mount_bootfs ] do
  def copy_to_bootfs( infile, outfile )
      sh "sudo cp #{@deploy_dir}/#{infile} #{@bootfs_mount}/#{outfile}"
  end

  { "MLO" => "MLO",
    "u-boot.img" => "u-boot.img",
    "uImage-beaglebone.bin" => "uImage" }.each_pair { |k,v|
    copy_to_bootfs( k, v )
  }
  sh "sudo cp ./local-scripts/uEnv.txt #{@bootfs_mount}"
end

task :mk_bootfs => [ :copy_to_fat, :umount_bootfs] 

task :copy_to_ext3 => [ :mount_rootfs ] do
  sh "sudo tar -xjv -C #{@rootfs_mount} -f #{@deploy_dir}/systemd-image-beaglebone.tar.bz2"
end

task :mk_rootfs => [ :copy_to_ext3, :umount_rootfs]
