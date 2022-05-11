#!/bin/bash

fRed="\033[31;1m"
fGreen="\033[32;1m"
fClose="\033[0m"

workspace=$(dirname $0 | pwd)
cd ${workspace}
project_name=${workspace##*/}

app=StarsPicking

export ANDROID_SDK_ROOT=/opt/android-sdk/sdk

api_level=30
android_version="android-${api_level}"

getAllFiles() {
  files=$(find $1 -iname "*" | tr -s "\n" " ")
  for file_one in ${files}
  do
    if [ -f ${file_one} ]
    then
      echo -n " ${file_one}"
    fi
  done
}

getFiles() {
  find $1 -iname "*\.$2" | grep -v "AndroidManifest\.xml" | tr -s "\n" " "
}

wordGreen() {
  echo "${fGreen}$1${fClose}"
}

workRed() {
  echo "${fRed}$1${fClose}"
}

justExit() {
  last=$?
  if [ $last -ne "0" ]
  then
    echo -e "[`workRed Failed`] $*"
    exit $last
  fi
}

#getAllFiles /opt/jpro/CustomLanguage/.gradle/caches/transforms-3/8e6f36622ff6c3a5ea9233143dd40220/transformed/core-1.3.1/res
#
#exit 0

dep_res=""

compileDependencyAsset() {
  rm -rf build/res_$1 && mkdir -p build/res_$1
  $ANDROID_SDK_ROOT/build-tools/32.0.0/aapt2 compile $(getAllFiles $2/$1/res) -o build/res_$1
  dep_res="${dep_res} build/res_$1/*flat"
}

compile() {
  if [ ! -e build ]; then mkdir -p build; fi;
  rm -rf build/*
  if [ ! -e build/res ]; then mkdir -p build/res; fi;
  if [ ! -e build/res2 ]; then mkdir -p build/res2; fi;
  if [ ! -e build/intermediate/dex ]; then mkdir -p build/intermediate/dex; fi;
  if [ ! -e build/release/dex ]; then mkdir -p build/release/dex; fi;
  if [ ! -e build/classes ]; then mkdir -p build/classes; fi;

  $ANDROID_SDK_ROOT/build-tools/32.0.0/aapt2 compile $(getAllFiles app/src/main/res) -o build/res


  $ANDROID_SDK_ROOT/build-tools/32.0.0/aapt2 compile /opt/jpro/CustomLanguage/.gradle/caches/transforms-3/61c5724454d5ffd2ace5939227514eca/transformed/constraintlayout-2.1.3/res/values/values.xml -o build/res2
  $ANDROID_SDK_ROOT/build-tools/32.0.0/aapt2 link \
    -o build/res2/tmp.apk \
    -I $ANDROID_SDK_ROOT/platforms/${android_version}/android.jar \
    --manifest /opt/jpro/CustomLanguage/.gradle/caches/transforms-3/61c5724454d5ffd2ace5939227514eca/transformed/constraintlayout-2.1.3/AndroidManifest.xml \
    --java build/res2 build/res2/*flat

#  compileDependencyAsset coordinatorlayout-1.1.0 /opt/jpro/CustomLanguage/.gradle/caches/transforms-3/e286723fc23b2e35939f865049cd40ce/transformed/
#  compileDependencyAsset core-1.3.1 /opt/jpro/CustomLanguage/.gradle/caches/transforms-3/8e6f36622ff6c3a5ea9233143dd40220/transformed/

  clspth=$ANDROID_SDK_ROOT/platforms/${android_version}/android.jar:/opt/jpro/CustomLanguage/.gradle/caches/transforms-3/61c5724454d5ffd2ace5939227514eca/transformed/constraintlayout-2.1.3/jars/classes.jar:/opt/jpro/CustomLanguage/.gradle/caches/modules-2/files-2.1/androidx.constraintlayout/constraintlayout-core/1.0.3/e3b33a654966aaf882b869e9aad3fa2113264c61/constraintlayout-core-1.0.3.jar:/opt/jpro/CustomLanguage/.gradle/caches/transforms-3/28c6a91d12d44416af8f697ca7782e2f/transformed/jetified-appcompat-resources-1.4.1/jars/classes.jar:/opt/jpro/CustomLanguage/.gradle/caches/transforms-3/896fc82cff1391796143b731da45c467/transformed/appcompat-1.4.1/jars/classes.jar:/opt/jpro/CustomLanguage/.gradle/caches/transforms-3/0f42d7801b9b97fa5d0c4c25ce103af0/transformed/core-1.7.0/jars/classes.jar

  justExit compile resources
  echo -e "[`wordGreen success`] compile resources."
  $ANDROID_SDK_ROOT/build-tools/32.0.0/aapt2 link \
    -o build/res/${app}.res.apk \
    -I $ANDROID_SDK_ROOT/platforms/${android_version}/android.jar \
    --manifest app/src/main/AndroidManifest.xml \
    --java build/res build/res/*flat # $dep_res
  justExit package resources
  echo -e "[`wordGreen success`] package resources."
  javac -classpath ${clspth} $(getFiles app/src java) $(getFiles build/res java) $(getFiles build/res2 java) -d build/classes
  justExit compile java source code
  echo -e "[`wordGreen success`] compile java source code."

#  $ANDROID_SDK_ROOT/build-tools/32.0.0/d8 $(getFiles build/classes class) \
#    --lib $ANDROID_SDK_ROOT/platforms/${android_version}/android.jar \
#    --output build
#
#  $ANDROID_SDK_ROOT/build-tools/32.0.0/d8 /opt/jpro/CustomLanguage/.gradle/caches/transforms-3/e286723fc23b2e35939f865049cd40ce/transformed/coordinatorlayout-1.1.0/jars/classes.jar \
#    --lib $ANDROID_SDK_ROOT/platforms/${android_version}/android.jar \
#    --classpath /opt/jpro/CustomLanguage/.gradle/caches/transforms-3/8e6f36622ff6c3a5ea9233143dd40220/transformed/core-1.3.1/jars/classes.jar \
#    --classpath /opt/jpro/CustomLanguage/.gradle/caches/transforms-3/1e4ae66e8b832f24d37e7ef25a1cb3ad/transformed/customview-1.0.0/jars/classes.jar \
#    --output .

  $ANDROID_SDK_ROOT/build-tools/32.0.0/d8 \
    $(getFiles build/classes class) \
    /opt/jpro/CustomLanguage/.gradle/caches/transforms-3/61c5724454d5ffd2ace5939227514eca/transformed/constraintlayout-2.1.3/jars/classes.jar \
    /opt/jpro/CustomLanguage/.gradle/caches/transforms-3/28c6a91d12d44416af8f697ca7782e2f/transformed/jetified-appcompat-resources-1.4.1/jars/classes.jar \
    /opt/jpro/CustomLanguage/.gradle/caches/transforms-3/896fc82cff1391796143b731da45c467/transformed/appcompat-1.4.1/jars/classes.jar \
    /opt/jpro/CustomLanguage/.gradle/caches/transforms-3/0f42d7801b9b97fa5d0c4c25ce103af0/transformed/core-1.7.0/jars/classes.jar \
    /opt/jpro/CustomLanguage/.gradle/caches/modules-2/files-2.1/androidx.constraintlayout/constraintlayout-core/1.0.3/e3b33a654966aaf882b869e9aad3fa2113264c61/constraintlayout-core-1.0.3.jar \
    --intermediate --file-per-class \
    --lib $ANDROID_SDK_ROOT/platforms/${android_version}/android.jar \
    --min-api 30 \
    --output build/intermediate/dex
#    --classpath /opt/jpro/CustomLanguage/.gradle/caches/transforms-3/28c6a91d12d44416af8f697ca7782e2f/transformed/jetified-appcompat-resources-1.4.1/jars/classes.jar \
#    --classpath /opt/jpro/CustomLanguage/.gradle/caches/transforms-3/896fc82cff1391796143b731da45c467/transformed/appcompat-1.4.1/jars/classes.jar \
#    --classpath /opt/jpro/CustomLanguage/.gradle/caches/transforms-3/0f42d7801b9b97fa5d0c4c25ce103af0/transformed/core-1.7.0/jars/classes.jar \
#    --classpath /opt/jpro/CustomLanguage/.gradle/caches/modules-2/files-2.1/androidx.constraintlayout/constraintlayout-core/1.0.3/e3b33a654966aaf882b869e9aad3fa2113264c61/constraintlayout-core-1.0.3.jar \
#    --classpath /opt/jpro/CustomLanguage/.gradle/caches/transforms-3/61c5724454d5ffd2ace5939227514eca/transformed/constraintlayout-2.1.3/jars/classes.jar \

  $ANDROID_SDK_ROOT/build-tools/32.0.0/d8 $(getFiles build/intermediate/dex dex) --release --output build/release/dex

#  echo -e "[`wordGreen stopped`] d8 compile."
#
#  exit 2

#  mv classes.dex build/classes2.dex
#  if [ -f build/classes.dex ]; then mv build/classes.dex build/classes2.dex; fi

#  $ANDROID_SDK_ROOT/build-tools/32.0.0/d8 /opt/jpro/CustomLanguage/.gradle/caches/transforms-3/e286723fc23b2e35939f865049cd40ce/transformed/coordinatorlayout-1.1.0/jars/classes.jar \
#    --lib $ANDROID_SDK_ROOT/platforms/${android_version}/android.jar \
#    --lib /opt/jpro/CustomLanguage/.gradle/caches/transforms-3/8e6f36622ff6c3a5ea9233143dd40220/transformed/core-1.3.1/jars/classes.jar \
#    --output build

  justExit compile hex code
  echo -e "[`wordGreen success`] compile hex code."
  java -cp $ANDROID_SDK_ROOT/tools/lib/sdklib-26.0.0-dev.jar com.android/sdklib/build/ApkBuilderMain build/${app}.apk \
    -v -u -z build/res/${app}.res.apk -f build/release/dex/classes.dex >/dev/null 2>&1
#  java -cp $ANDROID_SDK_ROOT/tools/lib/sdklib-26.0.0-dev.jar com.android/sdklib/build/ApkBuilderMain build/${app}.apk \
#    -v -u -z build/res/${app}.res.apk -f build/classes2.dex
#  zip -m /build/${app}.apk classes2.dex
  justExit package hex code
  echo -e "[`wordGreen success`] package hex code."
  echo '123456' | $ANDROID_SDK_ROOT/build-tools/32.0.0/apksigner sign --ks ./xxx.keystore build/${app}.apk >/dev/null
  justExit sign apk
  echo -e "[`wordGreen success`] sign apk."
  adb install build/${app}.apk >/dev/null 2>&1
  justExit install apk
  echo -e "[`wordGreen success`] install apk."
}

compileAsset() {
  if [ ! -e build/res ]; then mkdir -p build/res; fi;

  $ANDROID_SDK_ROOT/build-tools/32.0.0/aapt2 compile $(getFiles app/src xml) $(getFiles app/src png) -o build/res
  justExit compile resources
  echo -e "[`wordGreen success`] compile resources."
}

if [ $# -eq "0" ]
then
  echo "Compile all:"
  compile
elif [ $1 = "asset" ]
then
  echo "Compile asset:"
  compileAsset
fi
