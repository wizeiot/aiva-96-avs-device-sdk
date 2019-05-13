#
# Copyright 2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#  http://aws.amazon.com/apache2.0
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.
#

if [ -z "$PLATFORM" ]; then
	echo "You should run the setup.sh script."
	exit 1
fi

SOUND_CONFIG="$HOME/.asoundrc"
START_SCRIPT="$INSTALL_BASE/startsample.sh"
CMAKE_PLATFORM_SPECIFIC=( \
    # Kitt.Ai (Snowboy)
    -Wno-dev \
    -DKITTAI_KEY_WORD_DETECTOR=ON \
    -DKITTAI_KEY_WORD_DETECTOR_LIB_PATH=$THIRD_PARTY_PATH/snowboy/lib/aarch64-ubuntu1604/libsnowboy-detect.a \
    -DKITTAI_KEY_WORD_DETECTOR_INCLUDE_DIR=$THIRD_PARTY_PATH/snowboy/include \
    # Common section
    -DGSTREAMER_MEDIA_PLAYER=ON -DPORTAUDIO=ON \
    -DPORTAUDIO_LIB_PATH="$THIRD_PARTY_PATH/portaudio/lib/.libs/libportaudio.$LIB_SUFFIX" \
    -DPORTAUDIO_INCLUDE_DIR="$THIRD_PARTY_PATH/portaudio/include" )

GSTREAMER_AUDIO_SINK="alsasink"

install_dependencies() {
  sudo apt-get update
  sudo apt-get -y install git gcc cmake build-essential libsqlite3-dev libcurl4-openssl-dev libfaad-dev libsoup2.4-dev libgcrypt20-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-good libasound2-dev sox gedit vim python3-pip libssl-dev
  # DH - added for DB410c 
  sudo apt-get -y install python-pip
  pip install flask commentjson
  # DH - added for Kitt.ai
  sudo apt-get -y install swig3.0 libatlas-base-dev python-pyaudio python3-pyaudio sox
}

run_os_specifics() {
  build_port_audio
  build_kwd_engine
  configure_sound
}

configure_sound() {
  echo
  echo "==============> SAVING AUDIO CONFIGURATION FILE =============="
  echo

  cat << EOF > "$SOUND_CONFIG"
  pcm.!default {
    type asym
     playback.pcm {
       type plug
       slave.pcm "hw:1,0"
     }
     capture.pcm {
       type plug
       slave.pcm "hw:1,0"
     }
  }
EOF
}

build_kwd_engine() {
  #get sensory or snowboy, and build
  echo
  echo "==============> CLONING AND BUILDING SNOWBOY =============="
  echo

  cd $THIRD_PARTY_PATH
  #git clone git://github.com/Sensory/alexa-rpi.git
  #bash ./alexa-rpi/bin/license.sh

  # Kitt.ai integration for DragonBoard 410c
  if [ ! -d snowboy ]; then
     git clone --depth 1 https://github.com/Kitt-AI/snowboy.git
  fi
  cd snowboy

  # Install models for tests
  mkdir -p "$SOURCE_PATH/avs-device-sdk/KWD/inputs/KittAiModels"
  cp ./resources/common.res "$SOURCE_PATH/avs-device-sdk/KWD/inputs/KittAiModels"
  cp ./resources/alexa/alexa-avs-sample-app/alexa.umdl "$SOURCE_PATH/avs-device-sdk/KWD/inputs/KittAiModels"

  mkdir -p "$SOURCE_PATH/avs-device-sdk/Integration/inputs/KittAiModels"
  cp ./resources/common.res "$SOURCE_PATH/avs-device-sdk/Integration/inputs/KittAiModels"
  cp ./resources/alexa/alexa-avs-sample-app/alexa.umdl "$SOURCE_PATH/avs-device-sdk/Integration/inputs/KittAiModels"

  # Install models for production
  cp ./resources/alexa/alexa-avs-sample-app/alexa.umdl ./resources/

  # Patch avs-device-sdk
  cd "$SOURCE_PATH/avs-device-sdk/"
  # 1. Patch KittAiKeyWordDetector for gcc 8.x compapatibility
  sed -i s/" msToPushPerIteration.count()"/" static_cast<unsigned int>(msToPushPerIteration.count())"/ ./KWD/KittAi/src/KittAiKeyWordDetector.cpp
  # 2. Patch CMakeList.txt for Kitt.Ai library linking error
  #sed -i s/"set(CMAKE_CXX_EXTENSIONS OFF)"/"set(CMAKE_CXX_EXTENSIONS OFF)\nadd_definitions(-D_GLIBCXX_USE_CXX11_ABI=0)"/ ./build/cmake/BuildOptions.cmake
  sed -i s/"cmake_minimum_required(VERSION 3.1 FATAL_ERROR)"/"cmake_minimum_required(VERSION 3.1 FATAL_ERROR)\nadd_definitions(-D_GLIBCXX_USE_CXX11_ABI=0)"/ ./CMakeLists.txt
  # 3. Patch rapidjson 1.1.0 "document.h" for gcc 8.x compatibility
  sed -i s/"memmove(\&\*pos,"/"memmove(static_cast<void*>(\&*pos),"/ ./ThirdParty/rapidjson/rapidjson-1.1.0/include/rapidjson/document.h
  sed -i s/"memmove(pos,"/"memmove(static_cast<void*>(pos),"/ ./ThirdParty/rapidjson/rapidjson-1.1.0/include/rapidjson/document.h
  sed -i s/"memcpy(e,"/"memcpy(static_cast<void*>(e),"/ ./ThirdParty/rapidjson/rapidjson-1.1.0/include/rapidjson/document.h
  sed -i s/"memcpy(m,"/"memcpy(static_cast<void*>(m),"/ ./ThirdParty/rapidjson/rapidjson-1.1.0/include/rapidjson/document.h
}

generate_start_script() {
  cat << EOF > "$START_SCRIPT"
  cd "$BUILD_PATH/SampleApp/src"

  ./SampleApp "$OUTPUT_CONFIG_FILE" "$THIRD_PARTY_PATH/snowboy/resources" DEBUG9
EOF
}
