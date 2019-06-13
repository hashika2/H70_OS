
if test "`whoami`" != "root" ; then
	echo "You must be logged in as root to build (for loopback mounting)"
	echo "Enter 'su' or 'sudo bash' to switch to root"
	exit
fi


if [ ! -e disk_images/h70oS.flp ]
then
	echo ">>> Creating new MikeOS floppy image..."
	mkdosfs -C disk_images/h70oS.flp 1440 || exit
fi


echo ">>> Assembling bootloader..."

nasm -O0 -w+orphan-labels -f bin -o source/bootload/bootload.bin source/bootload/bootload.asm || exit


echo ">>> Assembling h70 OS kernel..."

cd source
nasm -O0 -w+orphan-labels -f bin -o kernel.bin kernel.asm || exit
cd ..



echo ">>> Adding bootloader to floppy image..."

dd status=noxfer conv=notrunc if=source/bootload/bootload.bin of=disk_images/h70oS.flp || exit


echo ">>> Copying Aqua_Seven_OS kernel and programs..."

rm -rf tmp-loop

mkdir tmp-loop && mount -o loop -t vfat disk_images/h70oS.flp tmp-loop && cp source/kernel.bin tmp-loop/

cp programs/sample.pcx tmp-loop

sleep 0.2

echo ">>> Unmounting loopback floppy..."

umount tmp-loop || exit

rm -rf tmp-loop


echo ">>> Creating CD-ROM ISO image..."

rm -f disk_images/h70oS.iso
mkisofs -quiet -V 'H70 OS' -input-charset iso8859-1 -o disk_images/h70oS.iso -b h70oS.flp disk_images/ || exit

echo '>>> Done!'

