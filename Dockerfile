# tag we gave to DockerfileKVM
FROM kvm:maven-3.5.2-jdk-8 
# debian based
 
ENV UDIDS=""

#=====================
# Install android sdk
#=====================
ARG ANDROID_SDK_VERSION=4333796
ENV ANDROID_SDK_VERSION=$ANDROID_SDK_VERSION
ARG ANDROID_PLATFORM="android-25"
ARG BUILD_TOOLS="29.0.2"
ENV ANDROID_PLATFORM=$ANDROID_PLATFORM
ENV BUILD_TOOLS=$BUILD_TOOLS
 
# install adk
RUN mkdir -p /opt/adk \
    && wget -q https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
    && unzip sdk-tools-linux-${ANDROID_SDK_VERSION}.zip -d /opt/adk \
    && rm sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
    && wget -q https://dl.google.com/android/repository/platform-tools-latest-linux.zip \
    && unzip platform-tools-latest-linux.zip -d /opt/adk \
    && rm platform-tools-latest-linux.zip \
    && yes | /opt/adk/tools/bin/sdkmanager --licenses \
    && /opt/adk/tools/bin/sdkmanager "emulator" "build-tools;${BUILD_TOOLS}" "platforms;${ANDROID_PLATFORM}" "system-images;${ANDROID_PLATFORM};google_apis;armeabi-v7a" \
    && echo no | /opt/adk/tools/bin/avdmanager create avd -n "Android" -k "system-images;${ANDROID_PLATFORM};google_apis;armeabi-v7a" \
    && mkdir -p ${HOME}/.android/ \
    && ln -s /root/.android/avd ${HOME}/.android/avd \
    && ln -s /opt/adk/tools/emulator /usr/bin \
    && ln -s /opt/adk/platform-tools/adb /usr/bin
ENV ANDROID_HOME /opt/adk
 
#====================================
# Install latest nodejs, npm, appium
#====================================
ARG NODE_VERSION=v8.11.3
ENV NODE_VERSION=$NODE_VERSION
ARG APPIUM_VERSION=1.9.1
ENV APPIUM_VERSION=$APPIUM_VERSION
 
# install appium
RUN wget -q https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.xz \
    && tar -xJf node-${NODE_VERSION}-linux-x64.tar.xz -C /opt/ \
    && ln -s /opt/node-${NODE_VERSION}-linux-x64/bin/npm /usr/bin/ \
    && ln -s /opt/node-${NODE_VERSION}-linux-x64/bin/node /usr/bin/ \
    && ln -s /opt/node-${NODE_VERSION}-linux-x64/bin/npx /usr/bin/ \
    && npm install -g appium@${APPIUM_VERSION} --allow-root --unsafe-perm=true \
    && ln -s /opt/node-${NODE_VERSION}-linux-x64/bin/appium /usr/bin/
 
EXPOSE [4723,2251,5555]
CMD ["docker-entrypoint.sh"]