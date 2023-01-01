curl https://gw.alipayobjects.com/os/bmw-prod/9e8d0874-56d7-41fd-aaf5-f5e6edfec8fe.zip -o alipay.zip
unzip alipay.zip -d alipay-standard


curl https://gw.alipayobjects.com/os/bmw-prod/f50bde0b-252a-4234-bf0a-f84ec2d4be2e.zip -o alipay-noutdid.zip
unzip alipay-noutdid.zip -d alipay-noutdid


function process {
    L_PATH=$1
    OUTPUT_PATH=$2
    lipo $L_PATH/AlipaySDK.framework/AlipaySDK -thin arm64 -output $L_PATH/AlipaySDK-arm64
    lipo $L_PATH/AlipaySDK.framework/AlipaySDK -thin armv7 -output $L_PATH/AlipaySDK-armv7
    lipo $L_PATH/AlipaySDK.framework/AlipaySDK -thin x86_64 -output $L_PATH/AlipaySDK-x86_64
    lipo $L_PATH/AlipaySDK.framework/AlipaySDK -thin arm64 -output $L_PATH/AlipaySDK-sim-arm64

    arm64-to-sim $L_PATH/AlipaySDK-sim-arm64

    lipo -create -output $L_PATH/AlipaySDK-armv7_arm64 $L_PATH/AlipaySDK-armv7 $L_PATH/AlipaySDK-arm64
    lipo -create -output $L_PATH/AlipaySDK-arm64_x86_64 $L_PATH/AlipaySDK-sim-arm64 $L_PATH/AlipaySDK-x86_64

    mkdir $L_PATH/iphone-os $L_PATH/iphone-sim
    cp -r $L_PATH/AlipaySDK.framework $L_PATH/iphone-os
    cp -r $L_PATH/AlipaySDK.framework $L_PATH/iphone-sim

    cp $L_PATH/AlipaySDK-armv7_arm64 $L_PATH/iphone-os/AlipaySDK.framework/AlipaySDK
    cp $L_PATH/AlipaySDK-arm64_x86_64 $L_PATH/iphone-sim/AlipaySDK.framework/AlipaySDK

    rm -rf $OUTPUT_PATH/*

    xcodebuild -create-xcframework -framework $L_PATH/iphone-os/AlipaySDK.framework -framework $L_PATH/iphone-sim/AlipaySDK.framework -output $OUTPUT_PATH/AlipaySDK.xcframework
    cp -r $L_PATH/AlipaySDK.bundle $OUTPUT_PATH
    zip -r $OUTPUT_PATH.zip $OUTPUT_PATH 
}

process 'alipay-standard/iOS_SDK' './output/alipay-standard'
process 'alipay-noutdid/iOS' './output/alipay-noutdid'