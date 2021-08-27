ENV RUSTFLAGS='--codegen target-feature=-crt-static'

# Install opam switch & deps
WORKDIR /workspaces/ligolang
# COPY scripts/setup_switch.sh /ligo/scripts/setup_switch.sh
# COPY scripts/setup_dev_switch.sh /ligo/scripts/setup_dev_switch.sh
RUN opam update && sh scripts/setup_dev_switch.sh
# COPY scripts/install_opam_deps.sh /ligo/scripts/install_opam_deps.sh
# COPY ligo.opam /ligo
# COPY ligo.opam.locked /ligo
# copy all vendor .opams... this lets us install all transitive deps,
# but devs can change vendored code without invalidating the cache
# COPY vendors/ParserLib/ParserLib.opam /ligo/vendors/ParserLib/ParserLib.opam
# COPY vendors/Red-Black_Trees/RedBlackTrees.opam /ligo/vendors/Red-Black_Trees/RedBlackTrees.opam
# COPY vendors/UnionFind/UnionFind.opam /ligo/vendors/UnionFind/UnionFind.opam
# COPY vendors/Preprocessor/Preprocessor.opam /ligo/vendors/Preprocessor/Preprocessor.opam
# COPY vendors/Michelson/Michelson.opam /ligo/vendors/Michelson/Michelson.opam
# COPY vendors/LexerLib/LexerLib.opam /ligo/vendors/LexerLib/LexerLib.opam
# COPY vendors/ligo-utils/proto-alpha-utils/proto-alpha-utils.opam /ligo/vendors/ligo-utils/proto-alpha-utils/proto-alpha-utils.opam
# COPY vendors/ligo-utils/tezos-utils/tezos-utils.opam /ligo/vendors/ligo-utils/tezos-utils/tezos-utils.opam
# COPY vendors/ligo-utils/memory-proto-alpha/tezos-memory-proto-alpha.opam /ligo/vendors/ligo-utils/memory-proto-alpha/tezos-memory-proto-alpha.opam
# COPY vendors/ligo-utils/simple-utils/simple-utils.opam /ligo/vendors/ligo-utils/simple-utils/simple-utils.opam
# COPY vendors/ligo-utils/ligo_008_PtEdo2Zk_test_helpers/ligo-008-PtEdo2Zk-test-helpers.opam /ligo/vendors/ligo-utils/ligo_008_PtEdo2Zk_test_helpers/ligo-008-PtEdo2Zk-test-helpers.opam
RUN opam update && sh scripts/install_opam_deps.sh

# Now install vendor libs
# COPY vendors /ligo/vendors
# COPY scripts/install_vendors_deps.sh /ligo/scripts/install_vendors_deps.sh
# COPY ligo.opam /ligo
# COPY ligo.opam.locked /ligo
WORKDIR /ligo
RUN sh scripts/install_vendors_deps.sh
