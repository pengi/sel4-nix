build_target() {
    echo
    echo "seL4      : $sel4"
    echo "microkit  : $microkit"
    echo
    make -C $src OUT=$out target
}

build() {
    build_target
}
