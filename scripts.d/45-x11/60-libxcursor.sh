#!/bin/bash

LIBXCURSOR_REPO="https://cgit.freedesktop.org/xorg/lib/libxcursor.git"
LIBXCURSOR_COMMIT="801925839d26e7c8d942c5e02c4897652ead26c8"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBXCURSOR_REPO" "$LIBXCURSOR_COMMIT" libxcursor
    cd libxcursor

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-shared
        --disable-static
        --with-pic
    )

    if [[ $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAFS="$RAW_LDFLAGS"

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install

    gen-implib "$FFBUILD_PREFIX"/lib/{libXcursor.so.1,libXcursor.a}
    rm "$FFBUILD_PREFIX"/lib/libXcursor{.so*,.la}
}
