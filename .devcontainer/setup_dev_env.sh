opam init --disable-sandboxing --bare -y 

echo "Setting up dev switch"
opam update 
./scripts/setup_dev_switch.sh 


echo "Installing opam dependencies"
opam update 
./scripts/install_opam_deps.sh 


echo "Installing vendor dependencies"
opam update 
./scripts/install_vendors_deps.sh
