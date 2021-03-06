#!/bin/bash

# KJSL: macOS GStreamer builder

HERE=$PWD

export XML_CATALOG_FILES="/usr/local/etc/xml/catalog"
export PATH="/usr/local/opt/bison/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/bison/lib"

deps () {
  brew install glib gettext bison gobject-introspection graphene libogg libvorbis opus orc theora pango meson ninja pkg-config gnu-indent gtk-doc 
  #brew xquartz
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
