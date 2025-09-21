build_target() {
    make -C $src OUT=$out target
}

build() {
    build_target
}
