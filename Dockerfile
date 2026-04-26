FROM eclipse-temurin:17-jdk-jammy

ARG ANDROID_COMPILE_SDK=34
ARG ANDROID_BUILD_TOOLS=34.0.0
ARG ANDROID_NDK=26.1.10909125
ARG ANDROID_CMAKE=3.22.1
ARG LOVE_ANDROID_REF=11.5a

ENV ANDROID_HOME=/opt/android-sdk \
    ANDROID_SDK_ROOT=/opt/android-sdk \
    LOVE_ANDROID_HOME=/opt/love-android \
    ANDROID_BUILD_TOOLS_VERSION=${ANDROID_BUILD_TOOLS} \
    PATH=/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:/opt/android-sdk/build-tools/${ANDROID_BUILD_TOOLS}:$PATH

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        imagemagick \
        python3 \
        unzip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p "$ANDROID_HOME/cmdline-tools" \
    && curl -fsSL -o /tmp/android-commandlinetools.zip \
        https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
    && unzip -q /tmp/android-commandlinetools.zip -d "$ANDROID_HOME/cmdline-tools" \
    && mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest" \
    && rm /tmp/android-commandlinetools.zip \
    && yes | sdkmanager --licenses >/dev/null \
    && sdkmanager \
        "platform-tools" \
        "platforms;android-${ANDROID_COMPILE_SDK}" \
        "build-tools;${ANDROID_BUILD_TOOLS}" \
        "ndk;${ANDROID_NDK}" \
        "cmake;${ANDROID_CMAKE}"

RUN git clone --depth 1 --branch "$LOVE_ANDROID_REF" --recurse-submodules \
        https://github.com/love2d/love-android.git "$LOVE_ANDROID_HOME" \
    && cd "$LOVE_ANDROID_HOME" \
    && git submodule update --init --force --recursive --depth 1 \
    && chmod +x gradlew \
    && ./gradlew --no-daemon help >/dev/null

COPY bin/build-love-android /usr/local/bin/build-love-android
RUN chmod +x /usr/local/bin/build-love-android

ENTRYPOINT ["build-love-android"]
