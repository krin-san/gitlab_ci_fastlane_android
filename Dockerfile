FROM openjdk:8-jdk-slim-buster
LABEL Deepak Kumar <deepak.hebbar@gmail.com>

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
      lib32ncurses6 \
      lib32z1 \
      unzip \
      locales \
      sudo \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
RUN locale-gen && update-locale LANG=en_US.UTF-8

# Install Firebase CLI Tools

RUN curl -sL firebase.tools | analytics=false bash

# Install Android SDK

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
