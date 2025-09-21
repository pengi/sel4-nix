export PATH=
for i in $buildTools; do
    PATH=$PATH${PATH:+:}$i/bin
done
for i in $tools; do
    PATH=$PATH${PATH:+:}$i/bin
done
export PATH

source $buildScript

doBuild() {
    mkdir $out
    cd $out
    build
}