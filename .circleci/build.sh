#!/usr/bin/env bash
echo "Cloning dependencies"
git clone --depth=1 https://github.com/kdrag0n/proton-clang clang
git clone --depth=1 https://github.com/NotZeetaa/Flashable_Zip_lmi.git -b alioth AnyKernel
apt install sudo
sudo apt install cpio
sudo apt update && sudo apt upgrade && sudo apt install gcc-aarch64-linux-gnu &&
sudo apt install build-essential dkms linux-headers-$(uname -r) android-tools-adb android-tools-fastboot bc bison ca-certificates ccache clang cmake curl file flex gcc g++ git libelf-dev libssl-dev make ninja-build python3 texinfo u-boot-tools zlib1g-dev python vim repo
apt install cpio
apt update && apt upgrade && apt install gcc-aarch64-linux-gnu &&
apt install build-essential dkms linux-headers-$(uname -r) android-tools-adb android-tools-fastboot bc bison ca-certificates ccache clang cmake curl file flex gcc g++ git libelf-dev libssl-dev make ninja-build python3 texinfo u-boot-tools zlib1g-dev python vim repo
echo "Done"
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz
TANGGAL=$(date +"%F-%S")
START=$(date +"%s")
KERNEL_DIR=$(pwd)
PATH="${PWD}/clang/bin:$PATH"
export KBUILD_COMPILER_STRING="$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export ARCH=arm64
export KBUILD_BUILD_HOST=droneci
export KBUILD_BUILD_USER="thepsycopathlive"
# use ccache
export USE_CCACHE=1
#
#ccache variables
export CCACHE_DIR="$HOME/.ccache"
export CC="ccache gcc"
export CXX="ccache g++"
export PATH="/usr/lib/ccache:$PATH"
# sticker plox
function sticker() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendSticker" \
            -d sticker="CAADBQADmwEAAvQneFfl-dS0RNs7CQI" \
            -        -d chat_id=$chat_id
}
# Send info plox channel
function sendinfo() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
            -d chat_id="$chat_id" \
            -        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -        -d text="<b>• neXus Kernel •</b>%0ABuild started on <code>Drone CI</code>%0AFor device <b>Poco F2 Pro</b> (lmi)%0Abranch <code>$(git rev-parse --abbrev-ref HEAD)</code>(master)%0AUnder commit <code>$(git log --pretty=format:'"%h : %s"' -1)</code>%0AUsing compiler: <code>${KBUILD_COMPILER_STRING}</code>%0AStarted on <code>$(date)</code>%0A<b>Build Status:</b>#Stable"
}
# Push kernel to channel
function push() {
    cd AnyKernel
        ZIP=$(echo *.zip)
            curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
                    -F chat_id="$chat_id" \
                    -        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>Poco F2 Pro (lmi)</b> | <b>$(${GCC}gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</b>"
}
# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
            -d chat_id="$chat_id" \
            -        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -        -d text="Build throw an error(s)"
    exit 1
    }
    # Compile plox
    function compile() {
        export KBUILD_BUILD_USER=Rajat && export KBUILD_BUILD_HOST=LinuX
export ARCH=arm64 && export LD_LIBRARY_PATH="/home/runner/proton-clang/bin/../lib:$PATH" && export DTC_EXT=/home/runner/test/dtc-aosp && make -C $(pwd) -j$(nproc) AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip O=out t_defconfig && PATH="/home/runner/proton-clang/bin:${PATH}" && make -j$(nproc) O=out ARCH=arm64 CC=clang AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi-
    if ! [ -a "$IMAGE" ]; then
            finerr
                    exit 1
                        fi
                            cp out/arch/arm64/boot/Image.gz AnyKernel
                                cp out/arch/arm64/boot/dtbo.img AnyKernel
                                }
                                # Zipping
                                function zipping() {
                                    cd AnyKernel || exit 1
                                        zip -r9 tertis-BETA-kernel-alioth-${TANGGAL}.zip *
                                            cd ..
                                            }
                                            sticker
                                            sendinfo
                                            compile
                                            zipping
                                            END=$(date +"%s")
                                            DIFF=$(($END - $START))
                                            push

