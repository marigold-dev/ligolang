opam init --disable-sandboxing --bare -y 

echo "Setting up dev switch"
opam update 
./scripts/setup_dev_switch.sh 


export PATH=~/.cargo/bin:$PATH
#opam install -y --deps-only --with-test --locked=locked ./ligo.opam $(find vendors -name \*.opam) # looks redundant - actually isn't
                                                                                                 # or maybe it is...
opam install -y --deps-only --with-test --locked=locked $(find src/vendors -name \*.opam) ./ligo.opam 


setup_opam="eval \`opam config env\` "
echo $setup_opam >> ~/.bashrc
