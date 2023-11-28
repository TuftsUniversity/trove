# Some ideas on supporting different chrome/java versions

In trying this in trove it didn't work great because of the differences in ARM and x64 macs.

## alternative java installation
```
RUN wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public| apt-key add - \
    && apt-get update \
    && apt-get install -y temurin-8-jdk

RUN update-java-alternatives --set /usr/lib/jvm/temurin-8-jdk-amd64

RUN apt-get update && apt-get install -y wget unzip libatk1.0-0 libgtk-3-0 libgbm1
```
## Download and extract Google Chrome

attempts using thorium

```
RUN wget https://github.com/Alex313031/thorium/releases/download/M114.0.5735.134/thorium-browser_114.0.5735.134_amd64.zip && \
    unzip chrome-linux.zip -d /usr/local/bin/ && \
    rm chrome-linux.zip
```
## Create a symbolic link to the Chrome binary
```
RUN ln -s /usr/local/bin/thorium /usr/local/bin/google-chrome
RUN ln -s /usr/local/bin/thorium /usr/local/bin/chrome
RUN ln -s /usr/local/bin/thorium /usr/local/bin/chromium
```