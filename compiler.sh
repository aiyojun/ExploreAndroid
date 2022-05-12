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
dep_res=""
lib_dir="/opt/jpro/CustomLanguage/.gradle/caches"
deps="constraintlayout-2.1.3;jetified-appcompat-resources-1.4.1;appcompat-1.4.1;core-1.7.0"
libs="/opt/jpro/CustomLanguage/.gradle/caches/modules-2/files-2.1/androidx.constraintlayout/constraintlayout-core/1.0.3/e3b33a654966aaf882b869e9aad3fa2113264c61/constraintlayout-core-1.0.3.jar"

GetAllFiles() {
  files=$(find $1 -iname "*" | tr -s "\n" " ")
  for file_one in ${files}
  do
    if [ -f ${file_one} ]
    then
      echo -n " ${file_one}"
    fi
  done
}

GetFiles() {
  find $1 -iname "*\.$2" | grep -v "AndroidManifest\.xml" | tr -s "\n" " "
}

LogFailed() {
  echo -e "[\033[31;1mFailed\033[0m] $*"
}

LogOk() {
  echo -e "[\033[32;1m    Ok\033[0m] $*"
}

CheckPoint() {
    last=$?
    if [ $last -ne "0" ]
    then
      LogFailed $*
      exit $last
    fi
}

findModule() {
  module=$1
  pth=$(find ${lib_dir} -name "${module}" | tr -s "\n" " ")
  if [ "${pth}" = "" ]
  then
    return 1
  fi
  path_=""
  for _path in ${pth}
  do
    if [ -d ${_path} ]
    then
      path_=${_path}
      break
    fi
  done
  echo ${path_}
}

### @param $1: module name
compileLibraryResource() {
  module=$1
  path_=$(findModule ${module})
  if [ "${path_}" = "" ]
  then
    LogFailed "No [${module}] in ${lib_dir}"
    return 1
  elif [ ! -d ${path_}/res ]
  then
    return
  fi
  ## Execute resources compiling
  if [ ! -e build/tmp ]
  then
    mkdir -p build/tmp
  else
    rm -rf build/tmp/*
  fi
  $ANDROID_SDK_ROOT/build-tools/32.0.0/aapt2 compile $(GetAllFiles ${path_}/res) -o build/tmp
  CheckPoint aapt2 compile ${module}
  $ANDROID_SDK_ROOT/build-tools/32.0.0/aapt2 link \
    -o build/tmp/${module}.res.apk \
    -I $ANDROID_SDK_ROOT/platforms/${android_version}/android.jar \
    --manifest ${path_}/AndroidManifest.xml \
    --java build/res build/tmp/*flat
  LogOk "dep:${module}:res"
  rm -rf build/tmp
}

findLibraryJar() {
  deps=$(echo $1 | tr -s ";" " ")
  iter=0
  jars[0]=""
  for dep in ${deps}
  do
    path_=$(findModule ${dep})
    if [ "${path_}" = "" ]
    then
      LogFailed "No [${dep}] in ${lib_dir}"
      return 1
    elif [ ! -d ${path_}/jars ]
    then
      LogFailed "No jars in [${dep}]"
      return 1
    fi
    jars[${iter}]=${path_}/jars/classes.jar
    iter=$(expr ${iter} + 1)
  done
  echo $(echo ${jars[*]} | tr -s " " ":")
}

splitPath() {
  echo $(echo $1 | tr -s ":" " ")
}

compile() {
  if [ ! -e build ]; then mkdir -p build; fi;
  rm -rf build/*
  if [ ! -e build/res ]; then mkdir -p build/res; fi;
  if [ ! -e build/tmp ]; then mkdir -p build/tmp; fi;
  if [ ! -e build/intermediate/dex ]; then mkdir -p build/intermediate/dex; fi;
  if [ ! -e build/release/dex ]; then mkdir -p build/release/dex; fi;
  if [ ! -e build/classes ]; then mkdir -p build/classes; fi;

  $ANDROID_SDK_ROOT/build-tools/32.0.0/aapt2 compile $(GetAllFiles app/src/main/res) -o build/res
  CheckPoint "app:res:compile"
  $ANDROID_SDK_ROOT/build-tools/32.0.0/aapt2 link \
    -o build/res/${app}.res.apk \
    -I $ANDROID_SDK_ROOT/platforms/${android_version}/android.jar \
    --manifest app/src/main/AndroidManifest.xml \
    --java build/res build/res/*flat # $dep_res
  CheckPoint "app:res:link"
  LogOk "app:res"
  compileLibraryResource constraintlayout-2.1.3
  deppth=$(findLibraryJar $deps):$libs
  clspth=$ANDROID_SDK_ROOT/platforms/${android_version}/android.jar:${deppth}
  javac -classpath $clspth $(GetFiles app/src java) $(GetFiles build/res java) -d build/classes
  CheckPoint "app:java"
  LogOk "app:java"
  echo "------------------------------"
  echo "d8"
  echo "The stage will take long time."
  echo "Please wait ..."
  echo "------------------------------"
  ### The '--min-api' will force to replace the min-api of AndroidManifest.xml.
  $ANDROID_SDK_ROOT/build-tools/32.0.0/d8 \
    $(GetFiles build/classes class) $(splitPath $deppth) \
    --intermediate --file-per-class \
    --lib $ANDROID_SDK_ROOT/platforms/${android_version}/android.jar \
    --min-api 30 \
    --output build/intermediate/dex
  CheckPoint "app:dex:inc"
  $ANDROID_SDK_ROOT/build-tools/32.0.0/d8 $(GetFiles build/intermediate/dex dex) --release --output build/release/dex
  CheckPoint "app:dex:release"
  LogOk "app:dex"
  java -cp $ANDROID_SDK_ROOT/tools/lib/sdklib-26.0.0-dev.jar com.android/sdklib/build/ApkBuilderMain build/${app}.apk \
    -v -u -z build/res/${app}.res.apk -f build/release/dex/classes.dex >/dev/null 2>&1
  # APK in a kind of
  # zip -m /build/${app}.apk classes2.dex
  CheckPoint "app:package"
  LogOk "app:package"
  echo '123456' | $ANDROID_SDK_ROOT/build-tools/32.0.0/apksigner sign --ks ./xxx.keystore build/${app}.apk >/dev/null
  CheckPoint "app:sign"
  LogOk "app:sign"
  adb install build/${app}.apk >/dev/null 2>&1
  CheckPoint "app:install"
  LogOk "app:install"
}

compileAsset() {
  if [ ! -e build/res ]; then mkdir -p build/res; fi;
  $ANDROID_SDK_ROOT/build-tools/32.0.0/aapt2 compile $(GetFiles app/src xml) $(GetFiles app/src png) -o build/res
  CheckPoint "app:res"
  LogOk "app:res"
}

# main entry
if [ $# -eq "0" ]
then
  echo "${app}:"
  compile
elif [ $1 = "asset" ]
then
  echo "${app}:res"
  compileAsset
fi
