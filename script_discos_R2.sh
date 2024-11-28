cat > comandos_fdisk.txt <<EOF
n
p


+3GB
n
p




t

8e

t
1
8e

w
EOF

cat > comandos_fdisk_sdd.txt <<EOF
n
p



t
8e

w
EOF

cat > comandos_disk_swap.txt <<EOF
n
p


+1GB
w
EOF

sudo fdisk /dev/sdc < comandos_fdisk.txt
sudo fdisk /dev/sdd < comandos_fdisk_sdd.txt
sudo fdisk /dev/sde < comandos_disk_swap.txt

sudo pvcreate4 /dev/sdc1
sudo pvcreate /dev/sdc2
sudo pvcreate /dev/sdd1

sudo vgcreate vg_datos /dev/sdc1 /dev/sdc2
sudo vgcreate vg_temp /dev/sdd1

sudo lvcreate -L +2.5GB -n lv_workareas vg_datos
sudo lvcreate -L +10mb -n lv_docker vg_datos
sudo lvcreate -L +2.5GB -n lv_swap vg_temp

sudo mkfs.ext4 /dev/vg_datos/lv_docker
sudo mkdir -p /var/lib/docker
sudo mount /dev/vg_datos/lv_docker /var/lib/docker


#sudo mkswap /dev/vg_temp/lv_swap
sudo mkswap /dev/sde1
sudo swapon /dev/sde1
#sudo swapon /dev/vg_temp/lv_swap


sudo mkfs.ext4 /dev/vg_datos/lv_workareas
sudo mkdir -p /work
sudo mount /dev/vg_datos/lv_workareas /work

echo "/dev/vg_datos/lv_docker /var/lib/docker ext4 defaults 0 0" | sudo tee -a /etc/fstab
echo "/dev/vg_datos/lv_workareas /work ext4 defaults 0 0" | sudo tee -a /etc/fstab
echo "/dev/vg_temp/lv_swap none swap sw 0 0" | sudo tee -a /etc/fstab

sudo mount -a


