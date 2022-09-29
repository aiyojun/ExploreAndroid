# ExploreAndroid

I want to explore the overall Android system by this project. In this README file, I will record some problems I have caught.

## development for cmdline

```shell
### 1. create project
android create project --name ExploreAndroid --path ExploreAndroid --package com.jpro --activity ExploreAndroid --target 32

### 2. R.java generation
mkdir gen
aapt2 compile ./src/main/res/layout/activity_main.xml -o ./gen
# ... compile other resource files
aapt2 link -o ExploreAndroid.res.apk -I $ANDROID_SDK_ROOT/platforms/android-32/android.jar ./gen/layout_activity_main.xml.flat --manifest ./src/main/AndroidManifest.xml --java ./gen

### 3. compilation - javac & dx
javac -classpath $ANDROID_SDK_ROOT/platforms/android-32/android.jar src/main/java/com/jpro/MainActivity.java ./gen/com/jpro/R.java -d ./build
### convert java bytecode to dex
# dx --dex --output=./classes.dex ./build  # dx is deprecated now in android-32
$ANDROID_SDK_ROOT/build-tools/32.0.0/d8 ./build/com/jpro/* --lib $ANDROID_SDK_ROOT/platforms/android-32/android.jar 

### 4. package
java -cp $ANDROID_SDK_ROOT/tools/lib/sdklib-26.0.0-dev.jar com.android/sdklib/build/ApkBuilderMain ExploreAndroid.apk -v -u -z ./ExploreAndroid.res.apk -f ./classes.dex

### align
# zipalign -v -p 4 my-app-unsigned.apk my-app-unsigned-aligned.apk

### keystore generation
# The 'keytool' command is provided by openssl.
keytool -genkey -alias xxx.keystore -keyalg RSA -validity 1000 -keystore xxx.keystore -dname "CN=w,OU=w,O=localhost,L=w,ST=w,C=CN" -keypass 123456 -storepass 123456

### 5. sign
apksigner sign --ks ./xxx.keystore ./ExploreAndroid.apk
```

## commands for sdk installation

```shell
### list
sdkmanager --sdk_root=/opt/android-sdk/sdk --proxy=http --proxy_host=127.0.0.1 --proxy_port=1081 list
### install
sdkmanager --sdk_root=/opt/android-sdk/sdk --proxy=http --proxy_host=127.0.0.1 --proxy_port=1081 "build-tools;30.0.3"
```

## commands for debugging

```shell
adb shell  # 开启android shell
adb logcat # 查看app运行时log
adb install ./ExploreAndroid.apk               # 安装apk命令
adb shell pm install ./ExploreAndroid.apk      # pm命令可用于安装卸载
adb shell pm uninstall com.jpro # 卸载
adb shell am start -n com.jpro/com.jpro.MainActivity # 运行app
adb shell pm list package # 列出安装的app包名


### 获取已安装应用的apk
adb logcat | grep -i activity                  # 打开app,查看app对应activity
adb shell pm list package | grep xxx           # 查看对应包名及完整路径
adb shell cat /data/app/.../xxx.apk >./app.apk # 拉取到本地系统
```

## commands for emulator

```shell
### 创建模拟器
$ANDROID_SDK_ROOT/tools/bin/avdmanager create avd -n the12 -k 'system-images;android-32;google_apis;x86_64' -d 29
### 启动模拟器
$ANDROID_SDK_ROOT/emulator/emulator @the12
### 删除模拟器
$ANDROID_SDK_ROOT/tools/bin/avdmanager delete avd -n the12
```

## 逆向
```shell
### apk解压
unzip xxx.apk
### dex反编译，dex2jar工具需要下载
dex2jar xxx.apk
```



## Android文件系统分析

```shell
/system  # 一般存在于vendor.img
  /bin   # 所有的命令行工具
  /lib64 # 所有系统级别的so库文件
/storage/emulator/0       # 内部存储
/storage/emulator/private # sdcard存储
/data/local/tmp # 目前发现就该目录有执行cpp程序的权限
# 系统文件系统一般都是制作的img,只有可读权限
# 一般存储空间，无法修改cpp程序的权限，chown/chmod即使root也无法修改(暂)
```

## 交叉编译

It's recommended to use default toolchain(ndk) in android sdk.

## FAQ

### Gradle下载com.android.application plugin(android开发插件)失败原因
答: 不要使用JDK8，最新android插件使用JDK11！Gradle报下载错误，需要查看详细日志，才能看到Jave版本不对。

### Android Emulator点击extended controls按钮后，模拟器日志出现--no-sandbox，并segmentation fault的原因
答：之前版本不会出现该问题，近期(2022.9)更新之后，需要导出环境变量 QTWEBENGINE_DISABLE_SANDBOX=1

