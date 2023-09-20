FROM ruby:2.7.7

ARG RAILS_ENV
ARG SECRET_KEY_BASE

# Necessary for bundler to operate properly
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# add nodejs and yarn dependencies for the frontend
# RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
#  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
#  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# --allow-unauthenticated needed for yarn package
RUN apt-get update && apt-get upgrade -y && \
  apt-get install --no-install-recommends -y ca-certificates nodejs \
  build-essential libpq-dev libreoffice imagemagick unzip ghostscript vim \
  libqt5webkit5-dev xvfb xauth default-jre-headless --fix-missing --allow-unauthenticated

RUN apt-get update && apt-get install -y wget gnupg
RUN apt-get install -y wget apt-transport-https gnupg
RUN echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list

RUN wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public| apt-key add - \
    && apt-get update \
    && apt-get install -y temurin-8-jdk

RUN update-java-alternatives --set /usr/lib/jvm/temurin-8-jdk-amd64

RUN apt-get update && apt-get install -y wget unzip libatk1.0-0 libgtk-3-0 libgbm1

# Download and extract Google Chrome
RUN wget https://github.com/Alex313031/thorium/releases/download/M114.0.5735.134/thorium-browser_114.0.5735.134_amd64.zip && \
    unzip chrome-linux.zip -d /usr/local/bin/ && \
    rm chrome-linux.zip

# Create a symbolic link to the Chrome binary
RUN ln -s /usr/local/bin/thorium /usr/local/bin/google-chrome
RUN ln -s /usr/local/bin/thorium /usr/local/bin/chrome
RUN ln -s /usr/local/bin/thorium /usr/local/bin/chromium

# Cleanup unnecessary files
RUN apt-get remove -y wget unzip && apt-get clean

# Verify the installation
RUN google-chrome --version

# Increase stack size limit to help working with large works
ENV RUBY_THREAD_MACHINE_STACK_SIZE 8388608

RUN gem update --system

RUN mkdir /data
WORKDIR /data

# Pre-install gems so we aren't reinstalling all the gems when literally any
# filesystem change happens
ADD Gemfile /data
ADD Gemfile.lock /data
RUN mkdir /data/build
ADD ./build/install_gems.sh /data/build
RUN ./build/install_gems.sh
RUN mkdir /data/pdfs


# Add the application code
ADD . /data

# install node dependencies, after there are some included
#RUN yarn install
