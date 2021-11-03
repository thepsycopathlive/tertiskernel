git clone --depth=1 https://gitlab.com/Panchajanya1999/azure-clang azure-clang
git clone --depth=1 https://github.com/Farizmaul/AnyKernel3.git

TANGGAL=$(TZ=Asia/Jakarta date "+%Y%m%d-%H%M")
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz
DTBO=$(pwd)/out/arch/arm64/boot/dtbo.img
VERSION=AOSP
DEVICES=Alioth
KERNELNAME=HyperX-${VERSION}-${DEVICES}-${TANGGAL}
START=$(date +"%s")
BRANCH=$(git rev-parse --abbrev-ref HEAD)
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=FarizMaulana
export KBUILD_BUILD_HOST=$DRONE_SYSTEM_HOST
export chat_id="-1001726996867"
export DEF="vendor/alioth_defconfig"
TC_DIR=${PWD}
export PATH="$TC_DIR/azure-clang/bin:$PATH"
BUILD_DTBO=0
SIGN_BUILD=0

curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d text="HyperX kernel ${BRANCH} build has started" -d chat_id=${chat_id} -d parse_mode=HTML

   make O=out ARCH=arm64 $DEF
       make -j$(nproc --all) O=out \
				ARCH=arm64 \
				LOCALVERSION=-${VERSION}-${DEVICES}-${TANGGAL} \
				CC=clang \
				LD=ld.lld \
				AR="llvm-ar" \
				NM="llvm-nm" \OBJCOPY="llvm-objcopy" \
				OBJDUMP="llvm-objdump" \
				STRIP="llvm-strip" \
				CROSS_COMPILE=aarch64-linux-gnu- \
				CROSS_COMPILE_ARM32=arm-linux-gnueabi- 2>&1 | tee build.log

END=$(date +"%s")
DIFF=$((END - START))

if [ -f $(pwd)/out/arch/arm64/boot/Image.gz ]
	then
        if [ BUILD_DTBO = 1 ]
        then
		git clone --depth=1 https://android.googlesource.com/platform/system/libufdt libufdt
                python2 "libufdt/utils/src/mkdtboimg.py" \
					        create "out/arch/arm64/boot/dtbo.img" --page_size=4096 $(pwd)/out/arch/arm64/boot/dts/qcom/*.dtbo
        fi
# Post to CI channel
curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d text="Branch: <code>$(git rev-parse --abbrev-ref HEAD)</code>
Compiler Used : <code>Azure clang 14.0.0</code>
Latest Commit: <code>$(git log --pretty=format:'%h : %s' -1)</code>
<i>Build compiled successfully in $((DIFF / 60)) minute(s) and $((DIFF % 60)) seconds</i>" -d chat_id=${chat_id} -d parse_mode=HTML

cp $(pwd)/out/arch/arm64/boot/Image.gz $(pwd)/AnyKernel3
cp $(pwd)/out/arch/arm64/boot/dtbo.img $(pwd)/AnyKernel3

        if [ -f ${DTBO} ]
        then
                cp ${DTBO} $(pwd)/AnyKernel3
        fi

        cd AnyKernel3
        zip -r9 ${KERNELNAME}.zip * --exclude *.jar

        if [ SIGN_BUILD = 1 ]
        then
                java -jar zipsigner-4.0.jar  ${KERNELNAME}.zip ${KERNELNAME}-signed.zip

        curl -F chat_id="${chat_id}"  \
                    -F caption="sha1sum: $(sha1sum Hyper*-signed.zip | awk '{ print $1 }')" \
                    -F document=@"$(pwd)/${KERNELNAME}-signed.zip" \
                    https://api.telegram.org/bot${TOKEN}/sendDocument

        else

        curl -F chat_id="${chat_id}"  \
                    -F caption="sha1sum: $(sha1sum HyperX*.zip | awk '{ print $1 }')" \
                    -F document=@"$(pwd)/${KERNELNAME}.zip" \
                    https://api.telegram.org/bot${TOKEN}/sendDocument
	fi
cd ..
else
        curl -F chat_id="${chat_id}"  \
                    -F caption="Build ended with an error, F in the chat plox" \
                    -F document=@"build.log" \
                    https://api.telegram.org/bot${TOKEN}/sendDocument

fi

if [[ -f ${IMAGE} &&  ${DTBO} ]]
then
   mv -f $IMAGE ${DTBO} AnyKernel3
fi
