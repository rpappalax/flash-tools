# http://www.imajeenyus.com/computer/20130301_android_tablet/android/unpack_repack_recovery_image.html
# http://www.omappedia.com/wiki/Android_eMMC_Booting
TOOLS_PATH="$HOME/bin"
OEM_BUILD_ZIP="my_build.zip"
SERIAL_DEFAULT="XXXXXXXX"  # this will be replaced by a unique one
SERIAL_NEW=`$TOOLS_PATH/serial_generator.sh`
echo "SERIAL_NEW=$SERIAL_NEW"
DIR="OEM"


function unzip_base_build() {

    echo
    echo "--------------------------------------"
    echo "unzipping base build"
    echo "--------------------------------------"

    if [[ ! -d $DIR ]]
    then
	mkdir $DIR
    fi

    cp *.zip $DIR;
    cd $DIR 
    echo "BEFORE..."
    ls -la
    unzip $OEM_BUILD_ZIP 
    echo "AFTER..."
    ls -la
}


function unpack_img() {

    echo
    echo "--------------------------------------"
    echo "unpack: recovery img!"
    echo "--------------------------------------"

    echo "$TOOLS_PATH/recovery/unmkbootimg recovery*.img > output.txt"
    cd *v
    $TOOLS_PATH/recovery/unmkbootimg recovery*.img > output.txt
    exit 0
    mkdir ramdisk
    cd ramdisk

    gunzip -c ../initramfs.cpio.gz | cpio -i
    cp default.prop default.prop.bak
    echo "You are here:"
    pwd
    ls -la

}

function replace_default_serial_num() {

    echo
    echo "--------------------------------------"
    echo "replace default serial #"
    echo "--------------------------------------"
    echo "default serial #:    $SERIAL_DEFAULT"
    echo "new serial #:        $SERIAL_NEW"

    find . -type f -exec sed -i "s/$SERIAL_DEFAULT/$SERIAL_NEW/" {} +
}


function re_pack_img() {

    echo
    echo "--------------------------------------"
    echo "re-pack: recovery img!"
    echo "--------------------------------------"

    echo "creating ramdisk-new.gz..."
    cd ..
    echo "You are here:"
    pwd

    $TOOLS_PATH/recovery/tools/mkbootfs ramdisk | gzip > ramdisk-new.gz
    ls -la
    cd ramdisk
    echo "You are here:"
    pwd
    echo "creating ../newramdisk.cpio.gz..."

    find . | cpio -o -H newc | gzip > ../newramdisk.cpio.gz
    ls -la

    cd ..
    echo "You are here:"
    pwd
    echo "BEFORE"
    ls -la
    echo "creating recovery.new.img..."
    $TOOLS_PATH/recovery/tools/mkbootimg --kernel zImage --ramdisk newramdisk.cpio.gz --base 0x40000000 --cmdline 'console=ttyS0,115200 rw init=/init loglevel=8' -o recovery.new.img
    read -p "press enter"
    echo "AFTER"
    ls -la
}


function cleanup() {

    echo 
    echo "--------------------------------------"
    echo "cleanup!"
    echo "--------------------------------------"

    rm recovery.2knand.img

    mv recovery.new.img recovery.2knand.img
    rm -rf ramdisk
    rm output


    cd ..
    ls -la
    read -p "out dir"
    rm -rf *.zip __*
    cd *v
    ls -la
}

unzip_base_build
unpack_img
replace_default_serial_num
re_pack_img
cleanup
