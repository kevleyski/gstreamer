#!/bin/bash

# KJSL: NVIDIA Jetson GStreamer builder

HERE=$PWD
NPROC=$(nproc)

export XML_CATALOG_FILES="/usr/local/etc/xml/catalog"
export PATH="/usr/local/opt/bison/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/bison/lib"

export PKG_CONFIG_PATH=$HERE/out/lib/pkgconfig
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/lib/aarch64-linux-gnu/pkgconfig
export LD_LIBRARY_PATH=$HERE/out/lib/

deps () {
  sudo apt-get install build-essential dpkg-dev flex bison autotools-dev \
       automake autopoint libtool gtk-doc-tools libgstreamer1.0-dev libxv-dev libasound2-dev \
       libtheora-dev libogg-dev libvorbis-dev libbz2-dev libv4l-dev libvpx-dev libjack-jackd2-dev \
       libsoup2.4-dev libpulse-dev faad libfaad-dev libgl1-mesa-dev libgles2-mesa-dev libx264-dev libmad0-dev
}

install_gstreamer () {
  cd "$HERE" || exit 1
  meson build
  ninja -C build
  sudo ninja -C build install
}

install_plugins_base () {
  cd "$HERE/../gst-plugins-base" || exit 1
  ./autogen.sh
  ./configure
  make -j $(nproc)
  sudo make install

  meson build -Dglib:iconv=native -Dgst-plugins-base:examples=disabled -Dgst-plugins-bad:rtmp=disabled
  ninja -C build
  sudo ninja -C build install
}

install_plugins_good () {
  cd "$HERE/../gst-plugins-good" || exit 1
  meson build
  ninja -C build
  sudo ninja -C build install
}

install_plugins () {
  install_plugins_base
}

deps
install_gstreamer
install_plugins
