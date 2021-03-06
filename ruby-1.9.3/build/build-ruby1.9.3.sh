#!/bin/bash

function get_version {
  apt-cache show $1 | grep Version | cut -d' ' -f2 | tail -1
}

LIBSTDCPP_VER=$(get_version libstdc++6)
LIBC_VER=$(get_version libc6)
LIBFFI_VER=$(get_version libffi6)
LIBGDBM_VER=$(get_version libgdbm3)
LIBNCURSES_VER=$(get_version libncurses5)
LIBREADLINE_VER=$(get_version libreadline6)
LIBSSL_VER=$(get_version libssl1.0.0)
ZLIB_VER=$(get_version zlib1g)
LIBYAML_VER=$(get_version libyaml-0-2)
OPENSSL_VER=$(get_version openssl)

RUBY_VER_MAJOR=1
RUBY_VER_MINOR=9
RUBY_VER_MAJMIN="$RUBY_VER_MAJOR.$RUBY_VER_MINOR"
RUBY_VER_MIN=3
RUBY_VER_NUMBER="$RUBY_VER_MAJMIN.$RUBY_VER_MIN"
RUBY_VER_PATCH=448
RUBY_VER="$RUBY_VER_NUMBER-p$RUBY_VER_PATCH"
RUBY_VER_NAMED_STRING="ruby-$RUBY_VER_NUMBER"
RUBY_VER_FULL_STRING="ruby-$RUBY_VER"
TMP_DIR="/tmp/$RUBY_VER_NAMED_STRING"

echo libstdc++6: $LIBSTDCPP_VER
echo libc6: $LIBC_VER
echo libffi5: $LIBFFI_VER
echo libgdbm3: $LIBGDBM_VER
echo libncurses5: $LIBNCURSES_VER
echo libreadline6: $LIBREADLINE_VER
echo libssl1.0.0: $LIBSSL_VER
echo zlib1g: $ZLIB_VER
echo libyaml-0-2: $LIBYAML_VER
echo openssl: $OPENSSL_VER

if [[ ! -a "$RUBY_VER_STRING.tar.gz" ]]; then
	wget -c http://ftp.ruby-lang.org/pub/ruby/$RUBY_VER_MAJMIN/$RUBY_VER_FULL_STRING.tar.gz
fi
tar xzf $RUBY_VER_FULL_STRING.tar.gz

cd $RUBY_VER_FULL_STRING
rm -rf $TMP_DIR
time (./configure --prefix=/usr && make && make install DESTDIR=$TMP_DIR )
/usr/local/bin/fpm -s dir -t deb -n $RUBY_VER_NAMED_STRING -v $RUBY_VER --description "Self-packaged Ruby $RUBY_VER_NUMBER patch $RUBY_VER_PATCH" -C $TMP_DIR \
  -p "$RUBY_VER_NAMED_STRING"-VERSION_ARCH.deb -d "libstdc++6 (>= $LIBSTDCPP_VER)" \
  -d "libc6 (>= $LIBC_VER)" -d "libffi6 (>= $LIBFFI_VER)" -d "libgdbm3 (>= $LIBGDBM_VER)" \
  -d "libncurses5 (>= $LIBNCURSES_VER)" -d "libreadline6 (>= $LIBREADLINE_VER)" \
  -d "libssl1.0.0 (>= $LIBSSL_VER)" -d "zlib1g (>= $ZLIB_VER)" \
  -d "libyaml-0-2 (>= $LIBYAML_VER)" -d "openssl (>= $OPENSSL_VER)" \
  usr/bin usr/lib usr/share/man usr/include

cp *.deb ../
cd ..
rm -rf $RUBY_VER_FULL_STRING
rm -rf /tmp/$RUBY_VER
