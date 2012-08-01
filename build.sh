# Cm Kernel Compiler.Set correct environment variables before executing!

echo " ====================== Kernel Compiler =========================== "

echo "Making config"
make msm7627a_defconfig

# Set kernel name in Phone Settings > Kernel Version
export KBUILD_BUILD_VERSION="cm2pico-cm7"

echo "Making the zImage-the real deal"
make -j16

echo "Copying output files"
mv arch/arm/boot/zImage boot.img-tools/unpack/boot.img-zImage
cp drivers/net/wireless/bcm4330b2/bcm4330.ko boot.img-tools/output/system/lib/modules
cp drivers/net/kineto_gan.ko boot.img-tools/output/system/lib/modules
cp fs/cifs/cifs.ko boot.img-tools/output/system/lib/modules

echo "Making boot.img"
cd boot.img-tools
tools/mkbootfs boot | gzip > unpack/boot.img-ramdisk-new.gz
mkdir -p target_img
tools/mkbootimg --kernel unpack/boot.img-zImage --ramdisk unpack/boot.img-ramdisk-new.gz -o target_img/boot.img --base `cat unpack/boot.img-base`
cp target_img/boot.img output

# Edit strip.sh path before running script
echo "Stripping Modules"
./strip.sh

echo "Make CWM-flashable zip"
cd output 
zip cm7-kernel-update.zip boot.img META-INF/com/google/android/updater-script META-INF/com/google/android/update-binary system/lib/modules/bcm4330.ko  system/lib/modules/kineto_gan.ko system/lib/modules/cifs.ko system/etc/init.d/93zram system/bin/compcache system/bin/handle_compcache system/bin/zram_stats system/bin/turbo
cd ../../
mv boot.img-tools/output/cm7-kernel-update.zip auto-sign

echo "Sign zip"
cd auto-sign
java -jar signapk.jar testkey.x509.pem testkey.pk8 cm7-kernel-update signed_cm7-kernel-update.zip

echo "=================== F.I.N.I.S.H ! ===================="

# Output is in auto-sign/cranium-kernel.zip.Boot into recovery mode and flash!
# Fastboot-compatible output is in boot.img-tools/target_img
