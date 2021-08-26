opam init --disable-sandboxing --bare -y 

opam update 
sh ../scripts/setup_dev_switch.sh 
opam update 
sh ../scripts/install_opam_deps.sh 
opam update 
sh ../scripts/install_vendors_deps.sh
