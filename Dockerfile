
FROM openjdk:8-jdk
MAINTAINER Deepak Kumar <deepak.hebbar@gmail.com>

ENV VERSION_SDK_TOOLS "4333796"

ENV ANDROID_HOME "/sdk"
ENV PATH "$PATH:${ANDROID_HOME}/tools"
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update && \
    apt-get install -qqy --no-install-recommends \
      bzip2 \
      curl \
      git-core \
      build-essential \
      libc6-i386 \
      html2text \
      lib32stdc++6 \
      ruby \
      ruby-dev \
      lib32gcc1 \
      lib32ncurses5 \
      lib32z1 \
      unzip \
      locales \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# # ------------------------------------------------------
# # --- Android NDK

# # download
# RUN mkdir /opt/android-ndk-tmp
# RUN cd /opt/android-ndk-tmp && wget -q http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin
# # uncompress
# RUN cd /opt/android-ndk-tmp && chmod a+x ./android-ndk-r10e-linux-x86_64.bin
# RUN cd /opt/android-ndk-tmp && ./android-ndk-r10e-linux-x86_64.bin
# # move to it's final location
# RUN cd /opt/android-ndk-tmp && mv ./android-ndk-r10e /opt/android-ndk
# # remove temp dir
# RUN rm -rf /opt/android-ndk-tmp
# # add to PATH
# ENV PATH ${PATH}:${ANDROID_NDK_HOME}

# NDK

ENV NDK_ROOT $ANDROID_SDK_ROOT/ndk-bundle

RUN yes | sdkmanager \
        "cmake;3.6.4111459" \
        "cmake;3.10.2.4988404" \
        "ndk-bundle" >/dev/null \
    && rm -rf  \
        # Delete simpleperf tool
        $NDK_ROOT/simpleperf \
        # Delete STL version we don't care about
        $NDK_ROOT/sources/cxx-stl/stlport \
        $NDK_ROOT/sources/cxx-stl/gnu-libstdc++ \
        # Delete unused prebuild images
        $NDK_ROOT/prebuilt/android-mips* \
        # Delete obsolete Android platforms
        $NDK_ROOT/platforms/android-9 \
        $NDK_ROOT/platforms/android-12 \
        $NDK_ROOT/platforms/android-13 \
        $NDK_ROOT/platforms/android-15 \
        $NDK_ROOT/platforms/android-16 \
        # Delete unused platform sources
        $NDK_ROOT/sources/cxx-stl/gnu-libstdc++/4.9/libs/mips* \
        $NDK_ROOT/sources/cxx-stl/llvm-libc++/libs/mips* \
        # Delete LLVM STL tests
        $NDK_ROOT/sources/cxx-stl/llvm-libc++/test \
        # Delete unused toolchains
        $NDK_ROOT/toolchains/mips \
        $NDK_ROOT/build/core/toolchains/mips* \
    && sdkmanager --list | sed -e '/Available Packages/q'


# NDK


RUN curl -s https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip > /sdk.zip && \
    unzip /sdk.zip -d /sdk && \
    rm -v /sdk.zip

RUN mkdir -p $ANDROID_HOME/licenses/ \
  && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_HOME/licenses/android-sdk-license \
  && echo "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910" > $ANDROID_HOME/licenses/android-sdk-preview-license

ADD packages.txt /sdk
RUN mkdir -p /root/.android && \
  touch /root/.android/repositories.cfg && \
  ${ANDROID_HOME}/tools/bin/sdkmanager --update 

RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < /sdk/packages.txt && \
    ${ANDROID_HOME}/tools/bin/sdkmanager ${PACKAGES}

RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses

RUN gem install bundle
RUN gem install fastlane

