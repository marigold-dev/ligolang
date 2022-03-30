#!/usr/bin/env node
/* eslint-disable max-len, flowtype/require-valid-file-annotation, flowtype/require-return-type */
/* global packageInformationStores, $$BLACKLIST, $$SETUP_STATIC_TABLES */

// Used for the resolveUnqualified part of the resolution (ie resolving folder/index.js & file extensions)
// Deconstructed so that they aren't affected by any fs monkeypatching occuring later during the execution
const {statSync, lstatSync, readlinkSync, readFileSync, existsSync, realpathSync} = require('fs');

const Module = require('module');
const path = require('path');
const StringDecoder = require('string_decoder');

const $$BLACKLIST = null;
const ignorePattern = $$BLACKLIST ? new RegExp($$BLACKLIST) : null;

const pnpFile = path.resolve(__dirname, __filename);
const builtinModules = new Set(Module.builtinModules || Object.keys(process.binding('natives')));

const topLevelLocator = {name: null, reference: null};
const blacklistedLocator = {name: NaN, reference: NaN};

// Used for compatibility purposes - cf setupCompatibilityLayer
const patchedModules = new Map();
const fallbackLocators = [topLevelLocator];

// Matches backslashes of Windows paths
const backwardSlashRegExp = /\\/g;

// Matches if the path must point to a directory (ie ends with /)
const isDirRegExp = /\/$/;

// Matches if the path starts with a valid path qualifier (./, ../, /)
// eslint-disable-next-line no-unused-vars
const isStrictRegExp = /^\.{0,2}/;

// Splits a require request into its components, or return null if the request is a file path
const pathRegExp = /^(?![A-Za-z]:)(?!\.{0,2}(?:\/|$))((?:@[^\/]+\/)?[^\/]+)\/?(.*|)$/;

// Keep a reference around ("module" is a common name in this context, so better rename it to something more significant)
const pnpModule = module;

/**
 * Used to disable the resolution hooks (for when we want to fallback to the previous resolution - we then need
 * a way to "reset" the environment temporarily)
 */

let enableNativeHooks = true;

/**
 * Simple helper function that assign an error code to an error, so that it can more easily be caught and used
 * by third-parties.
 */

function makeError(code, message, data = {}) {
  const error = new Error(message);
  return Object.assign(error, {code, data});
}

/**
 * Ensures that the returned locator isn't a blacklisted one.
 *
 * Blacklisted packages are packages that cannot be used because their dependencies cannot be deduced. This only
 * happens with peer dependencies, which effectively have different sets of dependencies depending on their parents.
 *
 * In order to deambiguate those different sets of dependencies, the Yarn implementation of PnP will generate a
 * symlink for each combination of <package name>/<package version>/<dependent package> it will find, and will
 * blacklist the target of those symlinks. By doing this, we ensure that files loaded through a specific path
 * will always have the same set of dependencies, provided the symlinks are correctly preserved.
 *
 * Unfortunately, some tools do not preserve them, and when it happens PnP isn't able anymore to deduce the set of
 * dependencies based on the path of the file that makes the require calls. But since we've blacklisted those paths,
 * we're able to print a more helpful error message that points out that a third-party package is doing something
 * incompatible!
 */

// eslint-disable-next-line no-unused-vars
function blacklistCheck(locator) {
  if (locator === blacklistedLocator) {
    throw makeError(
      `BLACKLISTED`,
      [
        `A package has been resolved through a blacklisted path - this is usually caused by one of your tools calling`,
        `"realpath" on the return value of "require.resolve". Since the returned values use symlinks to disambiguate`,
        `peer dependencies, they must be passed untransformed to "require".`,
      ].join(` `)
    );
  }

  return locator;
}

let packageInformationStores = new Map([
["@esy-ocaml/libffi",
new Map([["archive:https://github.com/libffi/libffi/releases/download/v3.3/libffi-3.3.tar.gz#sha1:8df6cb570c8d6596a67d1c0773bf00650154f7aa",
         {
           packageLocation: "/home/pavel/.esy/source/i/esy_ocaml__s__libffi__897034bd/",
           packageDependencies: new Map([["@esy-ocaml/libffi",
                                         "archive:https://github.com/libffi/libffi/releases/download/v3.3/libffi-3.3.tar.gz#sha1:8df6cb570c8d6596a67d1c0773bf00650154f7aa"]])}]])],
  ["@esy-ocaml/substs",
  new Map([["0.0.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/esy_ocaml__s__substs__0.0.1__19de1ee1/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"]])}]])],
  ["@opam/alcotest",
  new Map([["opam:1.5.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__alcotest__opam__c__1.5.0__1b47fefa/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/alcotest", "opam:1.5.0"],
                                             ["@opam/astring", "opam:0.8.5"],
                                             ["@opam/cmdliner", "opam:1.1.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/fmt", "opam:0.9.0"],
                                             ["@opam/ocaml-syntax-shims",
                                             "opam:1.0.0"],
                                             ["@opam/re", "opam:1.10.3"],
                                             ["@opam/stdlib-shims",
                                             "opam:0.3.0"],
                                             ["@opam/uutf", "opam:1.0.3"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/alcotest-lwt",
  new Map([["opam:1.5.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__alcotest_lwt__opam__c__1.5.0__6458fe54/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/alcotest", "opam:1.5.0"],
                                             ["@opam/alcotest-lwt",
                                             "opam:1.5.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/fmt", "opam:0.9.0"],
                                             ["@opam/logs", "opam:0.7.0"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/angstrom",
  new Map([["opam:0.15.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__angstrom__opam__c__0.15.0__c5dca2a1/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/angstrom",
                                             "opam:0.15.0"],
                                             ["@opam/bigstringaf",
                                             "opam:0.8.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ocaml-syntax-shims",
                                             "opam:1.0.0"],
                                             ["@opam/result", "opam:1.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/asn1-combinators",
  new Map([["opam:0.2.6",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__asn1_combinators__opam__c__0.2.6__360f29b1/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/asn1-combinators",
                                             "opam:0.2.6"],
                                             ["@opam/cstruct", "opam:6.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ptime", "opam:1.0.0"],
                                             ["@opam/zarith", "opam:1.12"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/astring",
  new Map([["opam:0.8.5",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__astring__opam__c__0.8.5__471b9e4a/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/astring", "opam:0.8.5"],
                                             ["@opam/ocamlbuild",
                                             "opam:0.14.1"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["@opam/topkg", "opam:1.0.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/base",
  new Map([["opam:v0.14.3",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__base__opam__c__v0.14.3__475a58ae/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base", "opam:v0.14.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/dune-configurator",
                                             "opam:2.9.3"],
                                             ["@opam/sexplib0",
                                             "opam:v0.14.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/base-bigarray",
  new Map([["opam:base",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__base_bigarray__opam__c__base__37a71828/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-bigarray",
                                             "opam:base"]])}]])],
  ["@opam/base-bytes",
  new Map([["opam:base",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__base_bytes__opam__c__base__48b6019a/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-bytes",
                                             "opam:base"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/base-threads",
  new Map([["opam:base",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__base_threads__opam__c__base__f282958b/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-threads",
                                             "opam:base"]])}]])],
  ["@opam/base-unix",
  new Map([["opam:base",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__base_unix__opam__c__base__93427a57/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-unix", "opam:base"]])}]])],
  ["@opam/base64",
  new Map([["opam:3.5.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__base64__opam__c__3.5.0__7cc64a98/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base64", "opam:3.5.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/bheap",
  new Map([["opam:2.0.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__bheap__opam__c__2.0.0__d188ae92/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/bheap", "opam:2.0.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/bigarray-compat",
  new Map([["opam:1.1.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__bigarray_compat__opam__c__1.1.0__ec432e34/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/bigarray-compat",
                                             "opam:1.1.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/bigstring",
  new Map([["opam:0.3",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__bigstring__opam__c__0.3__d6f3b8e8/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-bigarray",
                                             "opam:base"],
                                             ["@opam/base-bytes",
                                             "opam:base"],
                                             ["@opam/bigstring", "opam:0.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/bigstringaf",
  new Map([["opam:0.8.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__bigstringaf__opam__c__0.8.0__e5d3dc84/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/bigarray-compat",
                                             "opam:1.1.0"],
                                             ["@opam/bigstringaf",
                                             "opam:0.8.0"],
                                             ["@opam/conf-pkg-config",
                                             "opam:2"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/biniou",
  new Map([["opam:1.2.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__biniou__opam__c__1.2.1__9a37384b/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/biniou", "opam:1.2.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/easy-format",
                                             "opam:1.3.2"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/bisect_ppx",
  new Map([["opam:2.7.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__bisect__ppx__opam__c__2.7.0__2dc0970c/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-unix", "opam:base"],
                                             ["@opam/bisect_ppx",
                                             "opam:2.7.0"],
                                             ["@opam/cmdliner", "opam:1.1.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ppxlib", "opam:0.25.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/bls12-381",
  new Map([["opam:1.0.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__bls12_381__opam__c__1.0.1__9d8f1dec/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/bls12-381",
                                             "opam:1.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ff-sig", "opam:0.6.2"],
                                             ["@opam/zarith", "opam:1.12"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/bls12-381-gen",
  new Map([["opam:0.4.3",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__bls12_381_gen__opam__c__0.4.3__933c08e0/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/bls12-381-gen",
                                             "opam:0.4.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ff-sig", "opam:0.6.2"],
                                             ["@opam/zarith", "opam:1.12"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/bls12-381-legacy",
  new Map([["archive:https://gitlab.com/dannywillems/ocaml-bls12-381/-/archive/0.4.3-legacy/ocaml-bls12-381-0.4.3-legacy.tar.bz2#sha512:0102db9dcab07c788291e9f799a4cf7a480716f18da6833587381e88ecc699d6e6bb0f44afef0ec7cd14a742d8ec6efc7900b45b0bcdeba409a89420465c0a25",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__bls12_381_legacy__b7c6908b/",
             packageDependencies: new Map([["@opam/bls12-381-gen",
                                           "opam:0.4.3"],
                                             ["@opam/bls12-381-legacy",
                                             "archive:https://gitlab.com/dannywillems/ocaml-bls12-381/-/archive/0.4.3-legacy/ocaml-bls12-381-0.4.3-legacy.tar.bz2#sha512:0102db9dcab07c788291e9f799a4cf7a480716f18da6833587381e88ecc699d6e6bb0f44afef0ec7cd14a742d8ec6efc7900b45b0bcdeba409a89420465c0a25"],
                                             ["@opam/conf-rust",
                                             "no-source:"],
                                             ["@opam/ctypes", "opam:0.18.0"],
                                             ["@opam/ctypes-foreign",
                                             "opam:0.18.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ff-sig", "opam:0.6.2"],
                                             ["@opam/tezos-rust-libs",
                                             "opam:1.1"],
                                             ["@opam/zarith", "opam:1.12"]])}]])],
  ["@opam/bls12-381-unix",
  new Map([["archive:https://gitlab.com/dannywillems/ocaml-bls12-381/-/archive/1.0.1/ocaml-bls12-381-1.0.1.tar.bz2#sha512:f69d611deb6132d07f0a8ecde7bb118f733de802e241056c5e2b194579c5723a12d58e93410bd56f68a608568de035b61f018d1fea52388f54875d77b8f386c2",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__bls12_381_unix__3487ded7/",
             packageDependencies: new Map([["@opam/bls12-381", "opam:1.0.1"],
                                             ["@opam/bls12-381-gen",
                                             "opam:0.4.3"],
                                             ["@opam/bls12-381-unix",
                                             "archive:https://gitlab.com/dannywillems/ocaml-bls12-381/-/archive/1.0.1/ocaml-bls12-381-1.0.1.tar.bz2#sha512:f69d611deb6132d07f0a8ecde7bb118f733de802e241056c5e2b194579c5723a12d58e93410bd56f68a608568de035b61f018d1fea52388f54875d77b8f386c2"],
                                             ["@opam/conf-rust",
                                             "no-source:"],
                                             ["@opam/ctypes", "opam:0.18.0"],
                                             ["@opam/ctypes-foreign",
                                             "opam:0.18.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ff-sig", "opam:0.6.2"],
                                             ["@opam/hex", "opam:1.4.0"],
                                             ["@opam/tezos-rust-libs",
                                             "opam:1.1"],
                                             ["@opam/zarith", "opam:1.12"]])}]])],
  ["@opam/bos",
  new Map([["opam:0.2.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__bos__opam__c__0.2.1__a8387b1a/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/astring", "opam:0.8.5"],
                                             ["@opam/base-unix", "opam:base"],
                                             ["@opam/bos", "opam:0.2.1"],
                                             ["@opam/fmt", "opam:0.9.0"],
                                             ["@opam/fpath", "opam:0.7.3"],
                                             ["@opam/logs", "opam:0.7.0"],
                                             ["@opam/ocamlbuild",
                                             "opam:0.14.1"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["@opam/rresult", "opam:0.7.0"],
                                             ["@opam/topkg", "opam:1.0.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ca-certs",
  new Map([["opam:0.2.2",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ca_certs__opam__c__0.2.2__4c7191a2/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/astring", "opam:0.8.5"],
                                             ["@opam/bos", "opam:0.2.1"],
                                             ["@opam/ca-certs", "opam:0.2.2"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/fpath", "opam:0.7.3"],
                                             ["@opam/logs", "opam:0.7.0"],
                                             ["@opam/mirage-crypto",
                                             "opam:0.10.5"],
                                             ["@opam/ptime", "opam:1.0.0"],
                                             ["@opam/x509", "opam:0.16.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/cmdliner",
  new Map([["opam:1.1.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__cmdliner__opam__c__1.1.0__cce4f854/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/cmdliner", "opam:1.1.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/cohttp",
  new Map([["opam:4.0.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__cohttp__opam__c__4.0.0__9d317795/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base64", "opam:3.5.0"],
                                             ["@opam/cohttp", "opam:4.0.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/jsonm", "opam:1.0.1"],
                                             ["@opam/ppx_sexp_conv",
                                             "opam:v0.14.3"],
                                             ["@opam/re", "opam:1.10.3"],
                                             ["@opam/sexplib0",
                                             "opam:v0.14.0"],
                                             ["@opam/stringext",
                                             "opam:1.6.0"],
                                             ["@opam/uri", "opam:4.2.0"],
                                             ["@opam/uri-sexp", "opam:4.2.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/cohttp-lwt",
  new Map([["opam:4.0.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__cohttp_lwt__opam__c__4.0.0__b9ddef0a/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/cohttp", "opam:4.0.0"],
                                             ["@opam/cohttp-lwt",
                                             "opam:4.0.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/logs", "opam:0.7.0"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/ppx_sexp_conv",
                                             "opam:v0.14.3"],
                                             ["@opam/sexplib0",
                                             "opam:v0.14.0"],
                                             ["@opam/uri", "opam:4.2.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/cohttp-lwt-unix",
  new Map([["opam:4.0.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__cohttp_lwt_unix__opam__c__4.0.0__9431e1c3/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-unix", "opam:base"],
                                             ["@opam/cmdliner", "opam:1.1.0"],
                                             ["@opam/cohttp-lwt",
                                             "opam:4.0.0"],
                                             ["@opam/cohttp-lwt-unix",
                                             "opam:4.0.0"],
                                             ["@opam/conduit-lwt",
                                             "opam:4.0.1"],
                                             ["@opam/conduit-lwt-unix",
                                             "opam:4.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/fmt", "opam:0.9.0"],
                                             ["@opam/logs", "opam:0.7.0"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/magic-mime",
                                             "opam:1.2.0"],
                                             ["@opam/ppx_sexp_conv",
                                             "opam:v0.14.3"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/conduit",
  new Map([["opam:4.0.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__conduit__opam__c__4.0.1__c40888fb/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/astring", "opam:0.8.5"],
                                             ["@opam/conduit", "opam:4.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ipaddr", "opam:5.2.0"],
                                             ["@opam/ipaddr-sexp",
                                             "opam:5.2.0"],
                                             ["@opam/logs", "opam:0.7.0"],
                                             ["@opam/ppx_sexp_conv",
                                             "opam:v0.14.3"],
                                             ["@opam/sexplib",
                                             "opam:v0.14.0"],
                                             ["@opam/uri", "opam:4.2.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/conduit-lwt",
  new Map([["opam:4.0.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__conduit_lwt__opam__c__4.0.1__065bfb9a/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-unix", "opam:base"],
                                             ["@opam/conduit", "opam:4.0.1"],
                                             ["@opam/conduit-lwt",
                                             "opam:4.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/ppx_sexp_conv",
                                             "opam:v0.14.3"],
                                             ["@opam/sexplib",
                                             "opam:v0.14.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/conduit-lwt-unix",
  new Map([["opam:4.0.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__conduit_lwt_unix__opam__c__4.0.1__261f5f03/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-unix", "opam:base"],
                                             ["@opam/ca-certs", "opam:0.2.2"],
                                             ["@opam/conduit-lwt",
                                             "opam:4.0.1"],
                                             ["@opam/conduit-lwt-unix",
                                             "opam:4.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ipaddr", "opam:5.2.0"],
                                             ["@opam/ipaddr-sexp",
                                             "opam:5.2.0"],
                                             ["@opam/logs", "opam:0.7.0"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/ppx_sexp_conv",
                                             "opam:v0.14.3"],
                                             ["@opam/uri", "opam:4.2.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/conf-findutils",
  new Map([["opam:1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__conf_findutils__opam__c__1__67e3d251/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/conf-findutils",
                                             "opam:1"]])}]])],
  ["@opam/conf-gmp",
  new Map([["opam:4",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__conf_gmp__opam__c__4__9b495a09/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/conf-gmp", "opam:4"],
                                             ["esy-gmp",
                                             "archive:https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz#sha1:0578d48607ec0e272177d175fd1807c30b00fdf2"]])}]])],
  ["@opam/conf-gmp-powm-sec",
  new Map([["opam:3",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__conf_gmp_powm_sec__opam__c__3__0ac687f9/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/conf-gmp", "opam:4"],
                                             ["@opam/conf-gmp-powm-sec",
                                             "opam:3"]])}]])],
  ["@opam/conf-libev",
  new Map([["opam:4-12",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__conf_libev__opam__c__4_12__28fea866/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/conf-libev",
                                             "opam:4-12"],
                                             ["esy-libev", "4.33.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/conf-libffi",
  new Map([["no-source:",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__conf_libffi__e1651d90/",
             packageDependencies: new Map([["@esy-ocaml/libffi",
                                           "archive:https://github.com/libffi/libffi/releases/download/v3.3/libffi-3.3.tar.gz#sha1:8df6cb570c8d6596a67d1c0773bf00650154f7aa"],
                                             ["@opam/conf-libffi",
                                             "no-source:"]])}]])],
  ["@opam/conf-pkg-config",
  new Map([["opam:2",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__conf_pkg_config__opam__c__2__f94434f0/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/conf-pkg-config",
                                             "opam:2"],
                                             ["yarn-pkg-config",
                                             "github:esy-ocaml/yarn-pkg-config#db3a0b63883606dd57c54a7158d560d6cba8cd79"]])}]])],
  ["@opam/conf-rust",
  new Map([["no-source:",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__conf_rust__9fe9e0f4/",
             packageDependencies: new Map([["@opam/conf-rust", "no-source:"],
                                             ["esy-rustup",
                                             "archive:https://github.com/rust-lang/rustup/archive/refs/tags/1.24.2.tar.gz#sha1:979e8139734d39313b0147e0db3bfd2675f49507"]])}]])],
  ["@opam/conf-texinfo",
  new Map([["github:esy-packages/esy-texinfo:package.json#4a05feafbbcc4c57d5d25899fbdab98961b9a69c",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__conf_texinfo__358d35e6/",
             packageDependencies: new Map([["@opam/conf-texinfo",
                                           "github:esy-packages/esy-texinfo:package.json#4a05feafbbcc4c57d5d25899fbdab98961b9a69c"]])}]])],
  ["@opam/coq",
  new Map([["opam:8.13.2",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__coq__opam__c__8.13.2__099adf7d/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/conf-findutils",
                                             "opam:1"],
                                             ["@opam/coq", "opam:8.13.2"],
                                             ["@opam/num", "opam:1.4"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["@opam/zarith", "opam:1.12"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/cppo",
  new Map([["opam:1.6.8",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__cppo__opam__c__1.6.8__e84e8b55/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-unix", "opam:base"],
                                             ["@opam/cppo", "opam:1.6.8"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/csexp",
  new Map([["opam:1.5.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__csexp__opam__c__1.5.1__a5d42d7e/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/csexp", "opam:1.5.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/cstruct",
  new Map([["opam:6.0.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__cstruct__opam__c__6.0.1__5cf69c9a/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/bigarray-compat",
                                             "opam:1.1.0"],
                                             ["@opam/cstruct", "opam:6.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ctypes",
  new Map([["opam:0.18.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ctypes__opam__c__0.18.0__4e45a5f4/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/bigarray-compat",
                                             "opam:1.1.0"],
                                             ["@opam/ctypes", "opam:0.18.0"],
                                             ["@opam/ctypes-foreign",
                                             "opam:0.18.0"],
                                             ["@opam/integers", "opam:0.6.0"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ctypes-foreign",
  new Map([["opam:0.18.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ctypes_foreign__opam__c__0.18.0__299576b9/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/conf-libffi",
                                             "no-source:"],
                                             ["@opam/conf-pkg-config",
                                             "opam:2"],
                                             ["@opam/ctypes-foreign",
                                             "opam:0.18.0"],
                                             ["esy-libffi", "3.3.1"]])}]])],
  ["@opam/data-encoding",
  new Map([["opam:0.4",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__data_encoding__opam__c__0.4__6a850d0d/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/data-encoding",
                                             "opam:0.4"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ezjsonm", "opam:1.3.0"],
                                             ["@opam/hex", "opam:1.4.0"],
                                             ["@opam/json-data-encoding",
                                             "opam:0.11"],
                                             ["@opam/json-data-encoding-bson",
                                             "opam:0.11"],
                                             ["@opam/zarith", "opam:1.12"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/digestif",
  new Map([["opam:1.1.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__digestif__opam__c__1.1.0__10cff702/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-bytes",
                                             "opam:base"],
                                             ["@opam/bigarray-compat",
                                             "opam:1.1.0"],
                                             ["@opam/conf-pkg-config",
                                             "opam:2"],
                                             ["@opam/digestif", "opam:1.1.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/eqaf", "opam:0.8"],
                                             ["@opam/stdlib-shims",
                                             "opam:0.3.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/domain-name",
  new Map([["opam:0.4.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__domain_name__opam__c__0.4.0__b4a896fa/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/domain-name",
                                             "opam:0.4.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/dune",
  new Map([["opam:2.9.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__dune__opam__c__2.9.1__b7828aa9/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-threads",
                                             "opam:base"],
                                             ["@opam/base-unix", "opam:base"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/dune-build-info",
  new Map([["opam:2.9.3",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__dune_build_info__opam__c__2.9.3__7579f938/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/dune-build-info",
                                             "opam:2.9.3"]])}]])],
  ["@opam/dune-configurator",
  new Map([["opam:2.9.3",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__dune_configurator__opam__c__2.9.3__f0e2382a/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/csexp", "opam:1.5.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/dune-configurator",
                                             "opam:2.9.3"],
                                             ["@opam/result", "opam:1.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/duration",
  new Map([["opam:0.2.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__duration__opam__c__0.2.0__cfdb8027/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/duration", "opam:0.2.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/easy-format",
  new Map([["opam:1.3.2",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__easy_format__opam__c__1.3.2__2be19d18/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/easy-format",
                                             "opam:1.3.2"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/either",
  new Map([["opam:1.0.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__either__opam__c__1.0.0__29ca51fc/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/either", "opam:1.0.0"]])}]])],
  ["@opam/eqaf",
  new Map([["opam:0.8",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__eqaf__opam__c__0.8__584a1628/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/cstruct", "opam:6.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/eqaf", "opam:0.8"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ezjsonm",
  new Map([["opam:1.3.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ezjsonm__opam__c__1.3.0__390a4fa7/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ezjsonm", "opam:1.3.0"],
                                             ["@opam/hex", "opam:1.4.0"],
                                             ["@opam/jsonm", "opam:1.0.1"],
                                             ["@opam/sexplib0",
                                             "opam:v0.14.0"],
                                             ["@opam/uutf", "opam:1.0.3"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ff-sig",
  new Map([["opam:0.6.2",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ff_sig__opam__c__0.6.2__3288d46a/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ff-sig", "opam:0.6.2"],
                                             ["@opam/zarith", "opam:1.12"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/fix",
  new Map([["opam:20220121",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__fix__opam__c__20220121__091098a7/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/fix", "opam:20220121"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/fmt",
  new Map([["opam:0.9.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__fmt__opam__c__0.9.0__2f7f274d/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-unix", "opam:base"],
                                             ["@opam/cmdliner", "opam:1.1.0"],
                                             ["@opam/fmt", "opam:0.9.0"],
                                             ["@opam/ocamlbuild",
                                             "opam:0.14.1"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["@opam/topkg", "opam:1.0.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/fpath",
  new Map([["opam:0.7.3",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__fpath__opam__c__0.7.3__18652e33/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/astring", "opam:0.8.5"],
                                             ["@opam/fpath", "opam:0.7.3"],
                                             ["@opam/ocamlbuild",
                                             "opam:0.14.1"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["@opam/topkg", "opam:1.0.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/functoria-runtime",
  new Map([["opam:4.0.0~beta3",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__functoria_runtime__opam__c__4.0.0~beta3__d982ef6f/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/cmdliner", "opam:1.1.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/fmt", "opam:0.9.0"],
                                             ["@opam/functoria-runtime",
                                             "opam:4.0.0~beta3"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/getopt",
  new Map([["opam:20120615",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__getopt__opam__c__20120615__2097709f/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/getopt",
                                             "opam:20120615"],
                                             ["@opam/ocamlbuild",
                                             "opam:0.14.1"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/gmap",
  new Map([["opam:0.3.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__gmap__opam__c__0.3.0__4ff017bd/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/gmap", "opam:0.3.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/hacl-star",
  new Map([["opam:0.4.5",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__hacl_star__opam__c__0.4.5__8c74c063/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/cppo", "opam:1.6.8"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/hacl-star",
                                             "opam:0.4.5"],
                                             ["@opam/hacl-star-raw",
                                             "archive:https://github.com/project-everest/hacl-star/releases/download/ocaml-v0.4.3/hacl-star.0.4.3.tar.gz#sha512:bfb2ddf125a345deb361483aedf9d79837e9ee18b0bc31644588f8409a0fe0c50db2fc1e6b20a07e02fb9f393d2fc9968fd9d2aa9f506f4e23ca8b6ed4036870"],
                                             ["@opam/zarith", "opam:1.12"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/hacl-star-raw",
  new Map([["archive:https://github.com/project-everest/hacl-star/releases/download/ocaml-v0.4.3/hacl-star.0.4.3.tar.gz#sha512:bfb2ddf125a345deb361483aedf9d79837e9ee18b0bc31644588f8409a0fe0c50db2fc1e6b20a07e02fb9f393d2fc9968fd9d2aa9f506f4e23ca8b6ed4036870",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__hacl_star_raw__5df079f5/",
             packageDependencies: new Map([["@esy-ocaml/libffi",
                                           "archive:https://github.com/libffi/libffi/releases/download/v3.3/libffi-3.3.tar.gz#sha1:8df6cb570c8d6596a67d1c0773bf00650154f7aa"],
                                             ["@opam/ctypes", "opam:0.18.0"],
                                             ["@opam/ctypes-foreign",
                                             "opam:0.18.0"],
                                             ["@opam/hacl-star-raw",
                                             "archive:https://github.com/project-everest/hacl-star/releases/download/ocaml-v0.4.3/hacl-star.0.4.3.tar.gz#sha512:bfb2ddf125a345deb361483aedf9d79837e9ee18b0bc31644588f8409a0fe0c50db2fc1e6b20a07e02fb9f393d2fc9968fd9d2aa9f506f4e23ca8b6ed4036870"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"]])}]])],
  ["@opam/hex",
  new Map([["opam:1.4.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__hex__opam__c__1.4.0__5566ecb7/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/bigarray-compat",
                                             "opam:1.1.0"],
                                             ["@opam/cstruct", "opam:6.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/hex", "opam:1.4.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/index",
  new Map([["opam:1.4.2",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__index__opam__c__1.4.2__9119aef0/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/cmdliner", "opam:1.1.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/fmt", "opam:0.9.0"],
                                             ["@opam/index", "opam:1.4.2"],
                                             ["@opam/jsonm", "opam:1.0.1"],
                                             ["@opam/logs", "opam:0.7.0"],
                                             ["@opam/mtime", "opam:1.4.0"],
                                             ["@opam/optint", "opam:0.1.0"],
                                             ["@opam/ppx_repr", "opam:0.5.0"],
                                             ["@opam/progress", "opam:0.2.1"],
                                             ["@opam/repr", "opam:0.5.0"],
                                             ["@opam/semaphore-compat",
                                             "opam:1.0.1"],
                                             ["@opam/stdlib-shims",
                                             "opam:0.3.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/integers",
  new Map([["opam:0.6.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__integers__opam__c__0.6.0__8ab08c03/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/integers", "opam:0.6.0"],
                                             ["@opam/stdlib-shims",
                                             "opam:0.3.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ipaddr",
  new Map([["opam:5.2.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ipaddr__opam__c__5.2.0__6f21a08d/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/domain-name",
                                             "opam:0.4.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ipaddr", "opam:5.2.0"],
                                             ["@opam/macaddr", "opam:5.2.0"],
                                             ["@opam/stdlib-shims",
                                             "opam:0.3.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ipaddr-sexp",
  new Map([["opam:5.2.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ipaddr_sexp__opam__c__5.2.0__e69a5ce6/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ipaddr", "opam:5.2.0"],
                                             ["@opam/ipaddr-sexp",
                                             "opam:5.2.0"],
                                             ["@opam/ppx_sexp_conv",
                                             "opam:v0.14.3"],
                                             ["@opam/sexplib0",
                                             "opam:v0.14.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/irmin",
  new Map([["opam:2.8.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__irmin__opam__c__2.8.0__7e55f2be/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/astring", "opam:0.8.5"],
                                             ["@opam/bheap", "opam:2.0.0"],
                                             ["@opam/digestif", "opam:1.1.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/fmt", "opam:0.9.0"],
                                             ["@opam/irmin", "opam:2.8.0"],
                                             ["@opam/jsonm", "opam:1.0.1"],
                                             ["@opam/logs", "opam:0.7.0"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/ocamlgraph",
                                             "opam:2.0.0"],
                                             ["@opam/ppx_irmin",
                                             "opam:2.8.0"],
                                             ["@opam/repr", "opam:0.5.0"],
                                             ["@opam/uri", "opam:4.2.0"],
                                             ["@opam/uutf", "opam:1.0.3"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/irmin-layers",
  new Map([["opam:2.8.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__irmin_layers__opam__c__2.8.0__5336a328/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/irmin", "opam:2.8.0"],
                                             ["@opam/irmin-layers",
                                             "opam:2.8.0"],
                                             ["@opam/logs", "opam:0.7.0"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/mtime", "opam:1.4.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/irmin-pack",
  new Map([["opam:2.8.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__irmin_pack__opam__c__2.8.0__866d3d34/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/cmdliner", "opam:1.1.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/fmt", "opam:0.9.0"],
                                             ["@opam/index", "opam:1.4.2"],
                                             ["@opam/irmin", "opam:2.8.0"],
                                             ["@opam/irmin-layers",
                                             "opam:2.8.0"],
                                             ["@opam/irmin-pack",
                                             "opam:2.8.0"],
                                             ["@opam/logs", "opam:0.7.0"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/mtime", "opam:1.4.0"],
                                             ["@opam/optint", "opam:0.1.0"],
                                             ["@opam/ppx_irmin",
                                             "opam:2.8.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/jane-street-headers",
  new Map([["opam:v0.14.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__jane_street_headers__opam__c__v0.14.0__2ed620b8/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/jane-street-headers",
                                             "opam:v0.14.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/json-data-encoding",
  new Map([["opam:0.11",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__json_data_encoding__opam__c__0.11__ebd7f5ee/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/json-data-encoding",
                                             "opam:0.11"],
                                             ["@opam/uri", "opam:4.2.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/json-data-encoding-bson",
  new Map([["opam:0.11",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__json_data_encoding_bson__opam__c__0.11__0ca0d3d3/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/json-data-encoding",
                                             "opam:0.11"],
                                             ["@opam/json-data-encoding-bson",
                                             "opam:0.11"],
                                             ["@opam/ocplib-endian",
                                             "opam:1.2"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/jsonm",
  new Map([["opam:1.0.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__jsonm__opam__c__1.0.1__0f41f896/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/jsonm", "opam:1.0.1"],
                                             ["@opam/ocamlbuild",
                                             "opam:0.14.1"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["@opam/topkg", "opam:1.0.5"],
                                             ["@opam/uchar", "opam:0.0.2"],
                                             ["@opam/uutf", "opam:1.0.3"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/jst-config",
  new Map([["opam:v0.14.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__jst_config__opam__c__v0.14.1__d0762df8/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base", "opam:v0.14.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/dune-configurator",
                                             "opam:2.9.3"],
                                             ["@opam/jst-config",
                                             "opam:v0.14.1"],
                                             ["@opam/ppx_assert",
                                             "opam:v0.14.0"],
                                             ["@opam/stdio", "opam:v0.14.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/linenoise",
  new Map([["opam:1.3.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__linenoise__opam__c__1.3.1__87689145/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/linenoise",
                                             "opam:1.3.1"],
                                             ["@opam/result", "opam:1.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/logs",
  new Map([["opam:0.7.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__logs__opam__c__0.7.0__da3c2fe0/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-threads",
                                             "opam:base"],
                                             ["@opam/cmdliner", "opam:1.1.0"],
                                             ["@opam/fmt", "opam:0.9.0"],
                                             ["@opam/logs", "opam:0.7.0"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/ocamlbuild",
                                             "opam:0.14.1"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["@opam/topkg", "opam:1.0.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/lwt",
  new Map([["opam:5.4.2",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__lwt__opam__c__5.4.2__8d2eee21/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-threads",
                                             "opam:base"],
                                             ["@opam/base-unix", "opam:base"],
                                             ["@opam/conf-libev",
                                             "opam:4-12"],
                                             ["@opam/cppo", "opam:1.6.8"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/dune-configurator",
                                             "opam:2.9.3"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/mmap", "opam:1.2.0"],
                                             ["@opam/ocaml-syntax-shims",
                                             "opam:1.0.0"],
                                             ["@opam/ocplib-endian",
                                             "opam:1.2"],
                                             ["@opam/result", "opam:1.5"],
                                             ["@opam/seq", "opam:base"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/lwt-canceler",
  new Map([["opam:0.3",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__lwt_canceler__opam__c__0.3__5feaf254/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/lwt-canceler",
                                             "opam:0.3"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/lwt_log",
  new Map([["opam:1.1.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__lwt__log__opam__c__1.1.1__7f54b5d1/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/lwt_log", "opam:1.1.1"]])}]])],
  ["@opam/macaddr",
  new Map([["opam:5.2.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__macaddr__opam__c__5.2.0__0f64d946/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/macaddr", "opam:5.2.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/magic-mime",
  new Map([["opam:1.2.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__magic_mime__opam__c__1.2.0__c9733c05/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/magic-mime",
                                             "opam:1.2.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/menhir",
  new Map([["opam:20211012",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__menhir__opam__c__20211012__2b709e04/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/menhir",
                                             "opam:20211012"],
                                             ["@opam/menhirLib",
                                             "opam:20211012"],
                                             ["@opam/menhirSdk",
                                             "opam:20211012"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/menhirLib",
  new Map([["opam:20211012",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__menhirlib__opam__c__20211012__07d77bc1/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/menhirLib",
                                             "opam:20211012"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/menhirSdk",
  new Map([["opam:20211012",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__menhirsdk__opam__c__20211012__6ed84af4/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/menhirSdk",
                                             "opam:20211012"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/mirage-crypto",
  new Map([["opam:0.10.5",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__mirage_crypto__opam__c__0.10.5__aca19556/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/conf-pkg-config",
                                             "opam:2"],
                                             ["@opam/cstruct", "opam:6.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/dune-configurator",
                                             "opam:2.9.3"],
                                             ["@opam/eqaf", "opam:0.8"],
                                             ["@opam/mirage-crypto",
                                             "opam:0.10.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/mirage-crypto-ec",
  new Map([["opam:0.10.5",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__mirage_crypto_ec__opam__c__0.10.5__05fbc674/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/conf-pkg-config",
                                             "opam:2"],
                                             ["@opam/cstruct", "opam:6.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/dune-configurator",
                                             "opam:2.9.3"],
                                             ["@opam/eqaf", "opam:0.8"],
                                             ["@opam/mirage-crypto",
                                             "opam:0.10.5"],
                                             ["@opam/mirage-crypto-ec",
                                             "opam:0.10.5"],
                                             ["@opam/mirage-crypto-rng",
                                             "opam:0.10.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/mirage-crypto-pk",
  new Map([["opam:0.10.5",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__mirage_crypto_pk__opam__c__0.10.5__94bc17e2/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/conf-gmp-powm-sec",
                                             "opam:3"],
                                             ["@opam/cstruct", "opam:6.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/eqaf", "opam:0.8"],
                                             ["@opam/mirage-crypto",
                                             "opam:0.10.5"],
                                             ["@opam/mirage-crypto-pk",
                                             "opam:0.10.5"],
                                             ["@opam/mirage-crypto-rng",
                                             "opam:0.10.5"],
                                             ["@opam/mirage-runtime",
                                             "opam:4.0.0~beta3"],
                                             ["@opam/sexplib0",
                                             "opam:v0.14.0"],
                                             ["@opam/zarith", "opam:1.12"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/mirage-crypto-rng",
  new Map([["opam:0.10.5",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__mirage_crypto_rng__opam__c__0.10.5__91d3de4d/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/cstruct", "opam:6.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/dune-configurator",
                                             "opam:2.9.3"],
                                             ["@opam/duration", "opam:0.2.0"],
                                             ["@opam/logs", "opam:0.7.0"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/mirage-crypto",
                                             "opam:0.10.5"],
                                             ["@opam/mirage-crypto-rng",
                                             "opam:0.10.5"],
                                             ["@opam/mtime", "opam:1.4.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/mirage-runtime",
  new Map([["opam:4.0.0~beta3",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__mirage_runtime__opam__c__4.0.0~beta3__8cfae177/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/fmt", "opam:0.9.0"],
                                             ["@opam/functoria-runtime",
                                             "opam:4.0.0~beta3"],
                                             ["@opam/ipaddr", "opam:5.2.0"],
                                             ["@opam/logs", "opam:0.7.0"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/mirage-runtime",
                                             "opam:4.0.0~beta3"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/mmap",
  new Map([["opam:1.2.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__mmap__opam__c__1.2.0__d90cd9e6/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/bigarray-compat",
                                             "opam:1.1.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/mmap", "opam:1.2.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/mtime",
  new Map([["opam:1.4.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__mtime__opam__c__1.4.0__c21271fe/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/mtime", "opam:1.4.0"],
                                             ["@opam/ocamlbuild",
                                             "opam:0.14.1"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["@opam/topkg", "opam:1.0.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/num",
  new Map([["opam:1.4",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__num__opam__c__1.4__a26086aa/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/num", "opam:1.4"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ocaml-compiler-libs",
  new Map([["opam:v0.12.4",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ocaml_compiler_libs__opam__c__v0.12.4__35cddb8b/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ocaml-compiler-libs",
                                             "opam:v0.12.4"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ocaml-lsp-server",
  new Map([["opam:1.9.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ocaml_lsp_server__opam__c__1.9.0__342ea46d/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/csexp", "opam:1.5.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/dune-build-info",
                                             "opam:2.9.3"],
                                             ["@opam/ocaml-lsp-server",
                                             "opam:1.9.0"],
                                             ["@opam/ocamlformat-rpc-lib",
                                             "opam:0.19.0"],
                                             ["@opam/pp", "opam:1.1.2"],
                                             ["@opam/ppx_yojson_conv_lib",
                                             "opam:v0.14.0"],
                                             ["@opam/re", "opam:1.10.3"],
                                             ["@opam/result", "opam:1.5"],
                                             ["@opam/spawn", "opam:v0.15.0"],
                                             ["@opam/yojson", "opam:1.7.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ocaml-migrate-parsetree",
  new Map([["opam:2.3.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ocaml_migrate_parsetree__opam__c__2.3.0__af9afb57/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ocaml-migrate-parsetree",
                                             "opam:2.3.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ocaml-recovery-parser",
  new Map([["github:serokell/ocaml-recovery-parser:ocaml-recovery-parser.opam#7a759aed307f986d43006c50b8ced677e18b5a6d",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ocaml_recovery_parser__f891872c/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base", "opam:v0.14.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/fix", "opam:20220121"],
                                             ["@opam/menhir",
                                             "opam:20211012"],
                                             ["@opam/ocaml-recovery-parser",
                                             "github:serokell/ocaml-recovery-parser:ocaml-recovery-parser.opam#7a759aed307f986d43006c50b8ced677e18b5a6d"]])}]])],
  ["@opam/ocaml-syntax-shims",
  new Map([["opam:1.0.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ocaml_syntax_shims__opam__c__1.0.0__cb8d5a09/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ocaml-syntax-shims",
                                             "opam:1.0.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ocamlbuild",
  new Map([["opam:0.14.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ocamlbuild__opam__c__0.14.1__3fd19d31/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/ocamlbuild",
                                             "opam:0.14.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ocamlfind",
  new Map([["opam:1.9.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ocamlfind__opam__c__1.9.1__492060b0/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ocamlformat",
  new Map([["opam:0.19.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ocamlformat__opam__c__0.19.0__07a0fa1b/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base", "opam:v0.14.3"],
                                             ["@opam/base-unix", "opam:base"],
                                             ["@opam/cmdliner", "opam:1.1.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/dune-build-info",
                                             "opam:2.9.3"],
                                             ["@opam/fix", "opam:20220121"],
                                             ["@opam/fpath", "opam:0.7.3"],
                                             ["@opam/menhir",
                                             "opam:20211012"],
                                             ["@opam/menhirLib",
                                             "opam:20211012"],
                                             ["@opam/menhirSdk",
                                             "opam:20211012"],
                                             ["@opam/ocamlformat",
                                             "opam:0.19.0"],
                                             ["@opam/ocp-indent",
                                             "opam:1.8.1"],
                                             ["@opam/odoc-parser",
                                             "opam:0.9.0"],
                                             ["@opam/re", "opam:1.10.3"],
                                             ["@opam/stdio", "opam:v0.14.0"],
                                             ["@opam/uuseg", "opam:14.0.0"],
                                             ["@opam/uutf", "opam:1.0.3"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ocamlformat-rpc-lib",
  new Map([["opam:0.19.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ocamlformat_rpc_lib__opam__c__0.19.0__a218b2b0/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/csexp", "opam:1.5.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ocamlformat-rpc-lib",
                                             "opam:0.19.0"],
                                             ["@opam/sexplib0",
                                             "opam:v0.14.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ocamlgraph",
  new Map([["opam:2.0.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ocamlgraph__opam__c__2.0.0__32ec120a/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ocamlgraph",
                                             "opam:2.0.0"],
                                             ["@opam/stdlib-shims",
                                             "opam:0.3.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ocp-indent",
  new Map([["opam:1.8.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ocp_indent__opam__c__1.8.1__2297d668/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-bytes",
                                             "opam:base"],
                                             ["@opam/cmdliner", "opam:1.1.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["@opam/ocp-indent",
                                             "opam:1.8.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ocplib-endian",
  new Map([["opam:1.2",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ocplib_endian__opam__c__1.2__572dceaf/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-bytes",
                                             "opam:base"],
                                             ["@opam/cppo", "opam:1.6.8"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ocplib-endian",
                                             "opam:1.2"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/octavius",
  new Map([["opam:1.2.2",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__octavius__opam__c__1.2.2__96807fc5/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/octavius", "opam:1.2.2"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/odoc",
  new Map([["opam:1.5.3",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__odoc__opam__c__1.5.3__1831f8b7/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/astring", "opam:0.8.5"],
                                             ["@opam/cmdliner", "opam:1.1.0"],
                                             ["@opam/cppo", "opam:1.6.8"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/fpath", "opam:0.7.3"],
                                             ["@opam/odoc", "opam:1.5.3"],
                                             ["@opam/result", "opam:1.5"],
                                             ["@opam/tyxml", "opam:4.5.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/odoc-parser",
  new Map([["opam:0.9.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__odoc_parser__opam__c__0.9.0__81142933/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/astring", "opam:0.8.5"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/odoc-parser",
                                             "opam:0.9.0"],
                                             ["@opam/result", "opam:1.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/optint",
  new Map([["opam:0.1.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__optint__opam__c__0.1.0__9b8335d7/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/optint", "opam:0.1.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ounit2",
  new Map([["opam:2.2.6",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ounit2__opam__c__2.2.6__a70bc055/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-bytes",
                                             "opam:base"],
                                             ["@opam/base-unix", "opam:base"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ounit2", "opam:2.2.6"],
                                             ["@opam/seq", "opam:base"],
                                             ["@opam/stdlib-shims",
                                             "opam:0.3.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/parsexp",
  new Map([["opam:v0.14.2",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__parsexp__opam__c__v0.14.2__97598992/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base", "opam:v0.14.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/parsexp",
                                             "opam:v0.14.2"],
                                             ["@opam/sexplib0",
                                             "opam:v0.14.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/pbkdf",
  new Map([["opam:1.2.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__pbkdf__opam__c__1.2.0__a9031749/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/cstruct", "opam:6.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/mirage-crypto",
                                             "opam:0.10.5"],
                                             ["@opam/pbkdf", "opam:1.2.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/pp",
  new Map([["opam:1.1.2",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__pp__opam__c__1.1.2__ebad31ff/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/pp", "opam:1.1.2"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/pprint",
  new Map([["opam:20211129",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__pprint__opam__c__20211129__fc16ea22/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/pprint",
                                             "opam:20211129"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ppx_assert",
  new Map([["opam:v0.14.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppx__assert__opam__c__v0.14.0__41578bf1/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base", "opam:v0.14.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ppx_assert",
                                             "opam:v0.14.0"],
                                             ["@opam/ppx_cold",
                                             "opam:v0.14.0"],
                                             ["@opam/ppx_compare",
                                             "opam:v0.14.0"],
                                             ["@opam/ppx_here",
                                             "opam:v0.14.0"],
                                             ["@opam/ppx_sexp_conv",
                                             "opam:v0.14.3"],
                                             ["@opam/ppxlib", "opam:0.25.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ppx_base",
  new Map([["opam:v0.14.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppx__base__opam__c__v0.14.0__69130302/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ppx_base",
                                             "opam:v0.14.0"],
                                             ["@opam/ppx_cold",
                                             "opam:v0.14.0"],
                                             ["@opam/ppx_compare",
                                             "opam:v0.14.0"],
                                             ["@opam/ppx_enumerate",
                                             "opam:v0.14.0"],
                                             ["@opam/ppx_hash",
                                             "opam:v0.14.0"],
                                             ["@opam/ppx_js_style",
                                             "opam:v0.14.1"],
                                             ["@opam/ppx_sexp_conv",
                                             "opam:v0.14.3"],
                                             ["@opam/ppxlib", "opam:0.25.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ppx_cold",
  new Map([["opam:v0.14.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppx__cold__opam__c__v0.14.0__20831c56/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base", "opam:v0.14.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ppx_cold",
                                             "opam:v0.14.0"],
                                             ["@opam/ppxlib", "opam:0.25.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ppx_compare",
  new Map([["opam:v0.14.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppx__compare__opam__c__v0.14.0__d8a7262e/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base", "opam:v0.14.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ppx_compare",
                                             "opam:v0.14.0"],
                                             ["@opam/ppxlib", "opam:0.25.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ppx_derivers",
  new Map([["opam:1.2.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppx__derivers__opam__c__1.2.1__136a746e/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ppx_derivers",
                                             "opam:1.2.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ppx_deriving",
  new Map([["opam:5.2.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppx__deriving__opam__c__5.2.1__7dc03006/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/cppo", "opam:1.6.8"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["@opam/ppx_derivers",
                                             "opam:1.2.1"],
                                             ["@opam/ppx_deriving",
                                             "opam:5.2.1"],
                                             ["@opam/ppxlib", "opam:0.25.0"],
                                             ["@opam/result", "opam:1.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ppx_deriving_yojson",
  new Map([["opam:3.6.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppx__deriving__yojson__opam__c__3.6.1__f7812344/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ppx_deriving",
                                             "opam:5.2.1"],
                                             ["@opam/ppx_deriving_yojson",
                                             "opam:3.6.1"],
                                             ["@opam/ppxlib", "opam:0.25.0"],
                                             ["@opam/result", "opam:1.5"],
                                             ["@opam/yojson", "opam:1.7.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ppx_enumerate",
  new Map([["opam:v0.14.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppx__enumerate__opam__c__v0.14.0__5fc8f5bc/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base", "opam:v0.14.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ppx_enumerate",
                                             "opam:v0.14.0"],
                                             ["@opam/ppxlib", "opam:0.25.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ppx_expect",
  new Map([["opam:v0.14.2",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppx__expect__opam__c__v0.14.2__339f33b8/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base", "opam:v0.14.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ppx_expect",
                                             "opam:v0.14.2"],
                                             ["@opam/ppx_here",
                                             "opam:v0.14.0"],
                                             ["@opam/ppx_inline_test",
                                             "opam:v0.14.1"],
                                             ["@opam/ppxlib", "opam:0.25.0"],
                                             ["@opam/re", "opam:1.10.3"],
                                             ["@opam/stdio", "opam:v0.14.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ppx_hash",
  new Map([["opam:v0.14.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppx__hash__opam__c__v0.14.0__84fc2573/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base", "opam:v0.14.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ppx_compare",
                                             "opam:v0.14.0"],
                                             ["@opam/ppx_hash",
                                             "opam:v0.14.0"],
                                             ["@opam/ppx_sexp_conv",
                                             "opam:v0.14.3"],
                                             ["@opam/ppxlib", "opam:0.25.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ppx_here",
  new Map([["opam:v0.14.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppx__here__opam__c__v0.14.0__fefd8712/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base", "opam:v0.14.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ppx_here",
                                             "opam:v0.14.0"],
                                             ["@opam/ppxlib", "opam:0.25.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ppx_inline_test",
  new Map([["opam:v0.14.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppx__inline__test__opam__c__v0.14.1__ba73c193/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base", "opam:v0.14.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ppx_inline_test",
                                             "opam:v0.14.1"],
                                             ["@opam/ppxlib", "opam:0.25.0"],
                                             ["@opam/time_now",
                                             "opam:v0.14.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ppx_irmin",
  new Map([["opam:2.8.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppx__irmin__opam__c__2.8.0__874483c2/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ppx_irmin",
                                             "opam:2.8.0"],
                                             ["@opam/ppx_repr", "opam:0.5.0"]])}]])],
  ["@opam/ppx_js_style",
  new Map([["opam:v0.14.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppx__js__style__opam__c__v0.14.1__927575a1/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base", "opam:v0.14.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/octavius", "opam:1.2.2"],
                                             ["@opam/ppx_js_style",
                                             "opam:v0.14.1"],
                                             ["@opam/ppxlib", "opam:0.25.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ppx_optcomp",
  new Map([["opam:v0.14.3",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppx__optcomp__opam__c__v0.14.3__a8348810/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base", "opam:v0.14.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ppx_optcomp",
                                             "opam:v0.14.3"],
                                             ["@opam/ppxlib", "opam:0.25.0"],
                                             ["@opam/stdio", "opam:v0.14.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ppx_repr",
  new Map([["opam:0.5.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppx__repr__opam__c__0.5.0__6dbade65/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/fmt", "opam:0.9.0"],
                                             ["@opam/ppx_deriving",
                                             "opam:5.2.1"],
                                             ["@opam/ppx_repr", "opam:0.5.0"],
                                             ["@opam/ppxlib", "opam:0.25.0"],
                                             ["@opam/repr", "opam:0.5.0"]])}]])],
  ["@opam/ppx_sexp_conv",
  new Map([["opam:v0.14.3",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppx__sexp__conv__opam__c__v0.14.3__c785b6cc/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base", "opam:v0.14.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ppx_sexp_conv",
                                             "opam:v0.14.3"],
                                             ["@opam/ppxlib", "opam:0.25.0"],
                                             ["@opam/sexplib0",
                                             "opam:v0.14.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ppx_yojson_conv_lib",
  new Map([["opam:v0.14.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppx__yojson__conv__lib__opam__c__v0.14.0__dc949ddc/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ppx_yojson_conv_lib",
                                             "opam:v0.14.0"],
                                             ["@opam/yojson", "opam:1.7.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ppxlib",
  new Map([["opam:0.25.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ppxlib__opam__c__0.25.0__b65257ff/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ocaml-compiler-libs",
                                             "opam:v0.12.4"],
                                             ["@opam/ppx_derivers",
                                             "opam:1.2.1"],
                                             ["@opam/ppxlib", "opam:0.25.0"],
                                             ["@opam/sexplib0",
                                             "opam:v0.14.0"],
                                             ["@opam/stdlib-shims",
                                             "opam:0.3.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/progress",
  new Map([["opam:0.2.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__progress__opam__c__0.2.1__2dd32233/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/fmt", "opam:0.9.0"],
                                             ["@opam/logs", "opam:0.7.0"],
                                             ["@opam/mtime", "opam:1.4.0"],
                                             ["@opam/optint", "opam:0.1.0"],
                                             ["@opam/progress", "opam:0.2.1"],
                                             ["@opam/terminal", "opam:0.2.1"],
                                             ["@opam/uucp", "opam:14.0.0"],
                                             ["@opam/uutf", "opam:1.0.3"],
                                             ["@opam/vector", "opam:1.0.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ptime",
  new Map([["opam:1.0.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ptime__opam__c__1.0.0__86dcc7f6/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/ocamlbuild",
                                             "opam:0.14.1"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["@opam/ptime", "opam:1.0.0"],
                                             ["@opam/topkg", "opam:1.0.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/qcheck",
  new Map([["opam:0.18",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__qcheck__opam__c__0.18__07c4a33e/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-bytes",
                                             "opam:base"],
                                             ["@opam/base-unix", "opam:base"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/qcheck", "opam:0.18"],
                                             ["@opam/qcheck-core",
                                             "opam:0.18"],
                                             ["@opam/qcheck-ounit",
                                             "opam:0.18"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/qcheck-alcotest",
  new Map([["opam:0.18",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__qcheck_alcotest__opam__c__0.18__93899ba9/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/alcotest", "opam:1.5.0"],
                                             ["@opam/base-bytes",
                                             "opam:base"],
                                             ["@opam/base-unix", "opam:base"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/qcheck-alcotest",
                                             "opam:0.18"],
                                             ["@opam/qcheck-core",
                                             "opam:0.18"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/qcheck-core",
  new Map([["opam:0.18",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__qcheck_core__opam__c__0.18__9d052a60/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-bytes",
                                             "opam:base"],
                                             ["@opam/base-unix", "opam:base"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/qcheck-core",
                                             "opam:0.18"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/qcheck-ounit",
  new Map([["opam:0.18",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__qcheck_ounit__opam__c__0.18__0311abc9/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-bytes",
                                             "opam:base"],
                                             ["@opam/base-unix", "opam:base"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ounit2", "opam:2.2.6"],
                                             ["@opam/qcheck-core",
                                             "opam:0.18"],
                                             ["@opam/qcheck-ounit",
                                             "opam:0.18"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/re",
  new Map([["opam:1.10.3",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__re__opam__c__1.10.3__f85af983/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/re", "opam:1.10.3"],
                                             ["@opam/seq", "opam:base"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/repr",
  new Map([["opam:0.5.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__repr__opam__c__0.5.0__465d8699/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base64", "opam:3.5.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/either", "opam:1.0.0"],
                                             ["@opam/fmt", "opam:0.9.0"],
                                             ["@opam/jsonm", "opam:1.0.1"],
                                             ["@opam/optint", "opam:0.1.0"],
                                             ["@opam/repr", "opam:0.5.0"],
                                             ["@opam/uutf", "opam:1.0.3"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/resto",
  new Map([["opam:0.6.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__resto__opam__c__0.6.1__edcb84c5/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/resto", "opam:0.6.1"],
                                             ["@opam/uri", "opam:4.2.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/resto-acl",
  new Map([["opam:0.6.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__resto_acl__opam__c__0.6.1__5b5dc6c3/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/resto", "opam:0.6.1"],
                                             ["@opam/resto-acl",
                                             "opam:0.6.1"],
                                             ["@opam/uri", "opam:4.2.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/resto-cohttp",
  new Map([["opam:0.6.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__resto_cohttp__opam__c__0.6.1__6c876dbf/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/cohttp-lwt",
                                             "opam:4.0.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/resto-cohttp",
                                             "opam:0.6.1"],
                                             ["@opam/resto-directory",
                                             "opam:0.6.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/resto-cohttp-client",
  new Map([["opam:0.6.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__resto_cohttp_client__opam__c__0.6.1__2dcdc3fe/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/cohttp-lwt",
                                             "opam:4.0.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/resto-cohttp",
                                             "opam:0.6.1"],
                                             ["@opam/resto-cohttp-client",
                                             "opam:0.6.1"],
                                             ["@opam/uri", "opam:4.2.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/resto-cohttp-self-serving-client",
  new Map([["opam:0.6.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__resto_cohttp_self_serving_client__opam__c__0.6.1__c49182a6/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/cohttp-lwt",
                                             "opam:4.0.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/resto-cohttp-client",
                                             "opam:0.6.1"],
                                             ["@opam/resto-cohttp-self-serving-client",
                                             "opam:0.6.1"],
                                             ["@opam/resto-cohttp-server",
                                             "opam:0.6.1"],
                                             ["@opam/uri", "opam:4.2.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/resto-cohttp-server",
  new Map([["opam:0.6.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__resto_cohttp_server__opam__c__0.6.1__8ff39605/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/cohttp-lwt-unix",
                                             "opam:4.0.0"],
                                             ["@opam/conduit-lwt-unix",
                                             "opam:4.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/resto-acl",
                                             "opam:0.6.1"],
                                             ["@opam/resto-cohttp",
                                             "opam:0.6.1"],
                                             ["@opam/resto-cohttp-server",
                                             "opam:0.6.1"],
                                             ["@opam/resto-directory",
                                             "opam:0.6.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/resto-directory",
  new Map([["opam:0.6.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__resto_directory__opam__c__0.6.1__a80e55f7/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/resto", "opam:0.6.1"],
                                             ["@opam/resto-directory",
                                             "opam:0.6.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/result",
  new Map([["opam:1.5",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__result__opam__c__1.5__74485f30/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/result", "opam:1.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ringo",
  new Map([["opam:0.5",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ringo__opam__c__0.5__9546a50b/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ringo", "opam:0.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/ringo-lwt",
  new Map([["opam:0.5",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__ringo_lwt__opam__c__0.5__4dc50021/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/ringo", "opam:0.5"],
                                             ["@opam/ringo-lwt", "opam:0.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/rresult",
  new Map([["opam:0.7.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__rresult__opam__c__0.7.0__46070e80/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/ocamlbuild",
                                             "opam:0.14.1"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["@opam/rresult", "opam:0.7.0"],
                                             ["@opam/topkg", "opam:1.0.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/secp256k1-internal",
  new Map([["opam:0.3.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__secp256k1_internal__opam__c__0.3.1__fe0b1f25/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/bigstring", "opam:0.3"],
                                             ["@opam/conf-gmp", "opam:4"],
                                             ["@opam/conf-pkg-config",
                                             "opam:2"],
                                             ["@opam/cstruct", "opam:6.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/dune-configurator",
                                             "opam:2.9.3"],
                                             ["@opam/secp256k1-internal",
                                             "opam:0.3.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/semaphore-compat",
  new Map([["opam:1.0.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__semaphore_compat__opam__c__1.0.1__251c8dd0/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/semaphore-compat",
                                             "opam:1.0.1"]])}]])],
  ["@opam/seq",
  new Map([["opam:base",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__seq__opam__c__base__a0c677b1/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/seq", "opam:base"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/sexplib",
  new Map([["opam:v0.14.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__sexplib__opam__c__v0.14.0__0ac5a13c/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/num", "opam:1.4"],
                                             ["@opam/parsexp",
                                             "opam:v0.14.2"],
                                             ["@opam/sexplib",
                                             "opam:v0.14.0"],
                                             ["@opam/sexplib0",
                                             "opam:v0.14.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/sexplib0",
  new Map([["opam:v0.14.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__sexplib0__opam__c__v0.14.0__b1448c97/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/sexplib0",
                                             "opam:v0.14.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/spawn",
  new Map([["opam:v0.15.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__spawn__opam__c__v0.15.0__11dda031/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/spawn", "opam:v0.15.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/stdio",
  new Map([["opam:v0.14.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__stdio__opam__c__v0.14.0__16c0aeaf/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base", "opam:v0.14.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/stdio", "opam:v0.14.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/stdlib-shims",
  new Map([["opam:0.3.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__stdlib_shims__opam__c__0.3.0__513c478f/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/stdlib-shims",
                                             "opam:0.3.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/stringext",
  new Map([["opam:1.6.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__stringext__opam__c__1.6.0__69baaaa5/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-bytes",
                                             "opam:base"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/stringext",
                                             "opam:1.6.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/terminal",
  new Map([["opam:0.2.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__terminal__opam__c__0.2.1__e617d075/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/stdlib-shims",
                                             "opam:0.3.0"],
                                             ["@opam/terminal", "opam:0.2.1"],
                                             ["@opam/uucp", "opam:14.0.0"],
                                             ["@opam/uutf", "opam:1.0.3"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/terminal_size",
  new Map([["opam:0.1.4",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__terminal__size__opam__c__0.1.4__0d7b0fb2/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/terminal_size",
                                             "opam:0.1.4"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/tezos-base",
  new Map([["opam:11.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__tezos_base__opam__c__11.1__56d791ab/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/bls12-381-unix",
                                             "archive:https://gitlab.com/dannywillems/ocaml-bls12-381/-/archive/1.0.1/ocaml-bls12-381-1.0.1.tar.bz2#sha512:f69d611deb6132d07f0a8ecde7bb118f733de802e241056c5e2b194579c5723a12d58e93410bd56f68a608568de035b61f018d1fea52388f54875d77b8f386c2"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ipaddr", "opam:5.2.0"],
                                             ["@opam/ptime", "opam:1.0.0"],
                                             ["@opam/tezos-base",
                                             "opam:11.1"],
                                             ["@opam/tezos-clic",
                                             "opam:11.1"],
                                             ["@opam/tezos-crypto",
                                             "opam:11.1"],
                                             ["@opam/tezos-hacl-glue-unix",
                                             "opam:11.1"],
                                             ["@opam/tezos-micheline",
                                             "opam:11.1"]])}]])],
  ["@opam/tezos-clic",
  new Map([["opam:11.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__tezos_clic__opam__c__11.1__46f3ea99/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/tezos-clic",
                                             "opam:11.1"],
                                             ["@opam/tezos-stdlib-unix",
                                             "opam:11.1"]])}]])],
  ["@opam/tezos-crypto",
  new Map([["opam:11.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__tezos_crypto__opam__c__11.1__6fa64d9e/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ringo", "opam:0.5"],
                                             ["@opam/secp256k1-internal",
                                             "opam:0.3.1"],
                                             ["@opam/tezos-crypto",
                                             "opam:11.1"],
                                             ["@opam/tezos-hacl-glue",
                                             "opam:11.1"],
                                             ["@opam/tezos-rpc", "opam:11.1"]])}]])],
  ["@opam/tezos-error-monad",
  new Map([["opam:11.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__tezos_error_monad__opam__c__11.1__b14e49ce/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/data-encoding",
                                             "opam:0.4"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/lwt-canceler",
                                             "opam:0.3"],
                                             ["@opam/tezos-error-monad",
                                             "opam:11.1"],
                                             ["@opam/tezos-lwt-result-stdlib",
                                             "opam:11.1"],
                                             ["@opam/tezos-stdlib",
                                             "opam:11.1"]])}]])],
  ["@opam/tezos-event-logging",
  new Map([["opam:11.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__tezos_event_logging__opam__c__11.1__a6f9a708/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/lwt_log", "opam:1.1.1"],
                                             ["@opam/tezos-error-monad",
                                             "opam:11.1"],
                                             ["@opam/tezos-event-logging",
                                             "opam:11.1"]])}]])],
  ["@opam/tezos-hacl-glue",
  new Map([["opam:11.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__tezos_hacl_glue__opam__c__11.1__bab83aab/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/tezos-hacl-glue",
                                             "opam:11.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/tezos-hacl-glue-unix",
  new Map([["opam:11.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__tezos_hacl_glue_unix__opam__c__11.1__f7b6cdb8/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/hacl-star",
                                             "opam:0.4.5"],
                                             ["@opam/tezos-hacl-glue",
                                             "opam:11.1"],
                                             ["@opam/tezos-hacl-glue-unix",
                                             "opam:11.1"]])}]])],
  ["@opam/tezos-lwt-result-stdlib",
  new Map([["opam:11.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__tezos_lwt_result_stdlib__opam__c__11.1__d8795b24/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/tezos-lwt-result-stdlib",
                                             "opam:11.1"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/tezos-micheline",
  new Map([["opam:11.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__tezos_micheline__opam__c__11.1__e067d707/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ppx_inline_test",
                                             "opam:v0.14.1"],
                                             ["@opam/tezos-error-monad",
                                             "opam:11.1"],
                                             ["@opam/tezos-micheline",
                                             "opam:11.1"],
                                             ["@opam/uutf", "opam:1.0.3"]])}]])],
  ["@opam/tezos-rpc",
  new Map([["opam:11.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__tezos_rpc__opam__c__11.1__413fd1d6/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/resto", "opam:0.6.1"],
                                             ["@opam/resto-directory",
                                             "opam:0.6.1"],
                                             ["@opam/tezos-error-monad",
                                             "opam:11.1"],
                                             ["@opam/tezos-rpc", "opam:11.1"]])}]])],
  ["@opam/tezos-rust-libs",
  new Map([["opam:1.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__tezos_rust_libs__opam__c__1.1__a14a843a/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/conf-rust",
                                             "no-source:"],
                                             ["@opam/tezos-rust-libs",
                                             "opam:1.1"]])}]])],
  ["@opam/tezos-stdlib",
  new Map([["opam:11.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__tezos_stdlib__opam__c__11.1__2aa4b183/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/hex", "opam:1.4.0"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/ppx_inline_test",
                                             "opam:v0.14.1"],
                                             ["@opam/tezos-stdlib",
                                             "opam:11.1"],
                                             ["@opam/zarith", "opam:1.12"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/tezos-stdlib-unix",
  new Map([["opam:11.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__tezos_stdlib_unix__opam__c__11.1__42d039fa/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base-unix", "opam:base"],
                                             ["@opam/conf-libev",
                                             "opam:4-12"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ezjsonm", "opam:1.3.0"],
                                             ["@opam/fmt", "opam:0.9.0"],
                                             ["@opam/ipaddr", "opam:5.2.0"],
                                             ["@opam/mtime", "opam:1.4.0"],
                                             ["@opam/ptime", "opam:1.0.0"],
                                             ["@opam/re", "opam:1.10.3"],
                                             ["@opam/tezos-event-logging",
                                             "opam:11.1"],
                                             ["@opam/tezos-stdlib-unix",
                                             "opam:11.1"]])}]])],
  ["@opam/time_now",
  new Map([["opam:v0.14.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__time__now__opam__c__v0.14.0__d582831e/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/base", "opam:v0.14.3"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/jane-street-headers",
                                             "opam:v0.14.0"],
                                             ["@opam/jst-config",
                                             "opam:v0.14.1"],
                                             ["@opam/ppx_base",
                                             "opam:v0.14.0"],
                                             ["@opam/ppx_optcomp",
                                             "opam:v0.14.3"],
                                             ["@opam/time_now",
                                             "opam:v0.14.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/topkg",
  new Map([["opam:1.0.5",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__topkg__opam__c__1.0.5__82377b68/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/ocamlbuild",
                                             "opam:0.14.1"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["@opam/topkg", "opam:1.0.5"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/tyxml",
  new Map([["opam:4.5.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__tyxml__opam__c__4.5.0__0b0b6820/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/re", "opam:1.10.3"],
                                             ["@opam/seq", "opam:base"],
                                             ["@opam/tyxml", "opam:4.5.0"],
                                             ["@opam/uutf", "opam:1.0.3"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/uchar",
  new Map([["opam:0.0.2",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__uchar__opam__c__0.0.2__0292ad2f/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/ocamlbuild",
                                             "opam:0.14.1"],
                                             ["@opam/uchar", "opam:0.0.2"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/uri",
  new Map([["opam:4.2.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__uri__opam__c__4.2.0__9b4b8867/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/angstrom",
                                             "opam:0.15.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/stringext",
                                             "opam:1.6.0"],
                                             ["@opam/uri", "opam:4.2.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/uri-sexp",
  new Map([["opam:4.2.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__uri_sexp__opam__c__4.2.0__2007821d/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/ppx_sexp_conv",
                                             "opam:v0.14.3"],
                                             ["@opam/sexplib0",
                                             "opam:v0.14.0"],
                                             ["@opam/uri", "opam:4.2.0"],
                                             ["@opam/uri-sexp", "opam:4.2.0"]])}]])],
  ["@opam/uucp",
  new Map([["opam:14.0.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__uucp__opam__c__14.0.0__e45d1234/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/cmdliner", "opam:1.1.0"],
                                             ["@opam/ocamlbuild",
                                             "opam:0.14.1"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["@opam/topkg", "opam:1.0.5"],
                                             ["@opam/uucp", "opam:14.0.0"],
                                             ["@opam/uutf", "opam:1.0.3"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/uuseg",
  new Map([["opam:14.0.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__uuseg__opam__c__14.0.0__ae751ed3/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/cmdliner", "opam:1.1.0"],
                                             ["@opam/ocamlbuild",
                                             "opam:0.14.1"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["@opam/topkg", "opam:1.0.5"],
                                             ["@opam/uucp", "opam:14.0.0"],
                                             ["@opam/uuseg", "opam:14.0.0"],
                                             ["@opam/uutf", "opam:1.0.3"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/uutf",
  new Map([["opam:1.0.3",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__uutf__opam__c__1.0.3__8c042452/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/cmdliner", "opam:1.1.0"],
                                             ["@opam/ocamlbuild",
                                             "opam:0.14.1"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["@opam/topkg", "opam:1.0.5"],
                                             ["@opam/uutf", "opam:1.0.3"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/vector",
  new Map([["opam:1.0.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__vector__opam__c__1.0.0__929e876d/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/vector", "opam:1.0.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/x509",
  new Map([["opam:0.16.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__x509__opam__c__0.16.0__aa7e3e37/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/asn1-combinators",
                                             "opam:0.2.6"],
                                             ["@opam/base64", "opam:3.5.0"],
                                             ["@opam/cstruct", "opam:6.0.1"],
                                             ["@opam/domain-name",
                                             "opam:0.4.0"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/fmt", "opam:0.9.0"],
                                             ["@opam/gmap", "opam:0.3.0"],
                                             ["@opam/ipaddr", "opam:5.2.0"],
                                             ["@opam/logs", "opam:0.7.0"],
                                             ["@opam/mirage-crypto",
                                             "opam:0.10.5"],
                                             ["@opam/mirage-crypto-ec",
                                             "opam:0.10.5"],
                                             ["@opam/mirage-crypto-pk",
                                             "opam:0.10.5"],
                                             ["@opam/mirage-crypto-rng",
                                             "opam:0.10.5"],
                                             ["@opam/pbkdf", "opam:1.2.0"],
                                             ["@opam/ptime", "opam:1.0.0"],
                                             ["@opam/x509", "opam:0.16.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/yojson",
  new Map([["opam:1.7.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__yojson__opam__c__1.7.0__5bfab1af/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/biniou", "opam:1.2.1"],
                                             ["@opam/cppo", "opam:1.6.8"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/easy-format",
                                             "opam:1.3.2"],
                                             ["@opam/yojson", "opam:1.7.0"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["@opam/zarith",
  new Map([["opam:1.12",
           {
             packageLocation: "/home/pavel/.esy/source/i/opam__s__zarith__opam__c__1.12__0eb91e89/",
             packageDependencies: new Map([["@esy-ocaml/substs", "0.0.1"],
                                             ["@opam/conf-gmp", "opam:4"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["@opam/zarith", "opam:1.12"],
                                             ["ocaml", "4.12.0"]])}]])],
  ["esy-gmp",
  new Map([["archive:https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz#sha1:0578d48607ec0e272177d175fd1807c30b00fdf2",
           {
             packageLocation: "/home/pavel/.esy/source/i/esy_gmp__9e80dad6/",
             packageDependencies: new Map([["esy-gmp",
                                           "archive:https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz#sha1:0578d48607ec0e272177d175fd1807c30b00fdf2"]])}]])],
  ["esy-libev",
  new Map([["4.33.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/esy_libev__4.33.1__f46619d4/",
             packageDependencies: new Map([["esy-libev", "4.33.1"]])}]])],
  ["esy-libffi",
  new Map([["3.3.1",
           {
             packageLocation: "/home/pavel/.esy/source/i/esy_libffi__3.3.1__6659ddae/",
             packageDependencies: new Map([["@opam/conf-texinfo",
                                           "github:esy-packages/esy-texinfo:package.json#4a05feafbbcc4c57d5d25899fbdab98961b9a69c"],
                                             ["esy-libffi", "3.3.1"]])}]])],
  ["esy-rustup",
  new Map([["archive:https://github.com/rust-lang/rustup/archive/refs/tags/1.24.2.tar.gz#sha1:979e8139734d39313b0147e0db3bfd2675f49507",
           {
             packageLocation: "/home/pavel/.esy/source/i/esy_rustup__4bd172d0/",
             packageDependencies: new Map([["esy-rustup",
                                           "archive:https://github.com/rust-lang/rustup/archive/refs/tags/1.24.2.tar.gz#sha1:979e8139734d39313b0147e0db3bfd2675f49507"]])}]])],
  ["ocaml",
  new Map([["4.12.0",
           {
             packageLocation: "/home/pavel/.esy/source/i/ocaml__4.12.0__2b5694e6/",
             packageDependencies: new Map([["ocaml", "4.12.0"]])}]])],
  ["yarn-pkg-config",
  new Map([["github:esy-ocaml/yarn-pkg-config#db3a0b63883606dd57c54a7158d560d6cba8cd79",
           {
             packageLocation: "/home/pavel/.esy/source/i/yarn_pkg_config__9829fc81/",
             packageDependencies: new Map([["yarn-pkg-config",
                                           "github:esy-ocaml/yarn-pkg-config#db3a0b63883606dd57c54a7158d560d6cba8cd79"]])}]])],
  [null,
  new Map([[null,
           {
             packageLocation: "/home/pavel/ligo/",
             packageDependencies: new Map([["@opam/alcotest", "opam:1.5.0"],
                                             ["@opam/alcotest-lwt",
                                             "opam:1.5.0"],
                                             ["@opam/bisect_ppx",
                                             "opam:2.7.0"],
                                             ["@opam/bls12-381-legacy",
                                             "archive:https://gitlab.com/dannywillems/ocaml-bls12-381/-/archive/0.4.3-legacy/ocaml-bls12-381-0.4.3-legacy.tar.bz2#sha512:0102db9dcab07c788291e9f799a4cf7a480716f18da6833587381e88ecc699d6e6bb0f44afef0ec7cd14a742d8ec6efc7900b45b0bcdeba409a89420465c0a25"],
                                             ["@opam/coq", "opam:8.13.2"],
                                             ["@opam/dune", "opam:2.9.1"],
                                             ["@opam/getopt",
                                             "opam:20120615"],
                                             ["@opam/irmin", "opam:2.8.0"],
                                             ["@opam/irmin-pack",
                                             "opam:2.8.0"],
                                             ["@opam/linenoise",
                                             "opam:1.3.1"],
                                             ["@opam/lwt", "opam:5.4.2"],
                                             ["@opam/menhir",
                                             "opam:20211012"],
                                             ["@opam/ocaml-lsp-server",
                                             "opam:1.9.0"],
                                             ["@opam/ocaml-migrate-parsetree",
                                             "opam:2.3.0"],
                                             ["@opam/ocaml-recovery-parser",
                                             "github:serokell/ocaml-recovery-parser:ocaml-recovery-parser.opam#7a759aed307f986d43006c50b8ced677e18b5a6d"],
                                             ["@opam/ocamlfind",
                                             "opam:1.9.1"],
                                             ["@opam/ocamlformat",
                                             "opam:0.19.0"],
                                             ["@opam/ocamlgraph",
                                             "opam:2.0.0"],
                                             ["@opam/odoc", "opam:1.5.3"],
                                             ["@opam/pprint",
                                             "opam:20211129"],
                                             ["@opam/ppx_deriving",
                                             "opam:5.2.1"],
                                             ["@opam/ppx_deriving_yojson",
                                             "opam:3.6.1"],
                                             ["@opam/ppx_expect",
                                             "opam:v0.14.2"],
                                             ["@opam/ppx_inline_test",
                                             "opam:v0.14.1"],
                                             ["@opam/qcheck", "opam:0.18"],
                                             ["@opam/qcheck-alcotest",
                                             "opam:0.18"],
                                             ["@opam/resto-cohttp-self-serving-client",
                                             "opam:0.6.1"],
                                             ["@opam/ringo-lwt", "opam:0.5"],
                                             ["@opam/terminal_size",
                                             "opam:0.1.4"],
                                             ["@opam/tezos-base",
                                             "opam:11.1"],
                                             ["@opam/tezos-clic",
                                             "opam:11.1"],
                                             ["@opam/tezos-crypto",
                                             "opam:11.1"],
                                             ["@opam/tezos-micheline",
                                             "opam:11.1"],
                                             ["@opam/tezos-rust-libs",
                                             "opam:1.1"],
                                             ["@opam/yojson", "opam:1.7.0"],
                                             ["ocaml", "4.12.0"]])}]])]]);

let topLevelLocatorPath = "../../";
let locatorsByLocations = new Map([
["../../", topLevelLocator],
  ["../../../.esy/source/i/esy_gmp__9e80dad6/",
  {
    name: "esy-gmp",
    reference: "archive:https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz#sha1:0578d48607ec0e272177d175fd1807c30b00fdf2"}],
  ["../../../.esy/source/i/esy_libev__4.33.1__f46619d4/",
  {
    name: "esy-libev",
    reference: "4.33.1"}],
  ["../../../.esy/source/i/esy_libffi__3.3.1__6659ddae/",
  {
    name: "esy-libffi",
    reference: "3.3.1"}],
  ["../../../.esy/source/i/esy_ocaml__s__libffi__897034bd/",
  {
    name: "@esy-ocaml/libffi",
    reference: "archive:https://github.com/libffi/libffi/releases/download/v3.3/libffi-3.3.tar.gz#sha1:8df6cb570c8d6596a67d1c0773bf00650154f7aa"}],
  ["../../../.esy/source/i/esy_ocaml__s__substs__0.0.1__19de1ee1/",
  {
    name: "@esy-ocaml/substs",
    reference: "0.0.1"}],
  ["../../../.esy/source/i/esy_rustup__4bd172d0/",
  {
    name: "esy-rustup",
    reference: "archive:https://github.com/rust-lang/rustup/archive/refs/tags/1.24.2.tar.gz#sha1:979e8139734d39313b0147e0db3bfd2675f49507"}],
  ["../../../.esy/source/i/ocaml__4.12.0__2b5694e6/",
  {
    name: "ocaml",
    reference: "4.12.0"}],
  ["../../../.esy/source/i/opam__s__alcotest__opam__c__1.5.0__1b47fefa/",
  {
    name: "@opam/alcotest",
    reference: "opam:1.5.0"}],
  ["../../../.esy/source/i/opam__s__alcotest_lwt__opam__c__1.5.0__6458fe54/",
  {
    name: "@opam/alcotest-lwt",
    reference: "opam:1.5.0"}],
  ["../../../.esy/source/i/opam__s__angstrom__opam__c__0.15.0__c5dca2a1/",
  {
    name: "@opam/angstrom",
    reference: "opam:0.15.0"}],
  ["../../../.esy/source/i/opam__s__asn1_combinators__opam__c__0.2.6__360f29b1/",
  {
    name: "@opam/asn1-combinators",
    reference: "opam:0.2.6"}],
  ["../../../.esy/source/i/opam__s__astring__opam__c__0.8.5__471b9e4a/",
  {
    name: "@opam/astring",
    reference: "opam:0.8.5"}],
  ["../../../.esy/source/i/opam__s__base64__opam__c__3.5.0__7cc64a98/",
  {
    name: "@opam/base64",
    reference: "opam:3.5.0"}],
  ["../../../.esy/source/i/opam__s__base__opam__c__v0.14.3__475a58ae/",
  {
    name: "@opam/base",
    reference: "opam:v0.14.3"}],
  ["../../../.esy/source/i/opam__s__base_bigarray__opam__c__base__37a71828/",
  {
    name: "@opam/base-bigarray",
    reference: "opam:base"}],
  ["../../../.esy/source/i/opam__s__base_bytes__opam__c__base__48b6019a/",
  {
    name: "@opam/base-bytes",
    reference: "opam:base"}],
  ["../../../.esy/source/i/opam__s__base_threads__opam__c__base__f282958b/",
  {
    name: "@opam/base-threads",
    reference: "opam:base"}],
  ["../../../.esy/source/i/opam__s__base_unix__opam__c__base__93427a57/",
  {
    name: "@opam/base-unix",
    reference: "opam:base"}],
  ["../../../.esy/source/i/opam__s__bheap__opam__c__2.0.0__d188ae92/",
  {
    name: "@opam/bheap",
    reference: "opam:2.0.0"}],
  ["../../../.esy/source/i/opam__s__bigarray_compat__opam__c__1.1.0__ec432e34/",
  {
    name: "@opam/bigarray-compat",
    reference: "opam:1.1.0"}],
  ["../../../.esy/source/i/opam__s__bigstring__opam__c__0.3__d6f3b8e8/",
  {
    name: "@opam/bigstring",
    reference: "opam:0.3"}],
  ["../../../.esy/source/i/opam__s__bigstringaf__opam__c__0.8.0__e5d3dc84/",
  {
    name: "@opam/bigstringaf",
    reference: "opam:0.8.0"}],
  ["../../../.esy/source/i/opam__s__biniou__opam__c__1.2.1__9a37384b/",
  {
    name: "@opam/biniou",
    reference: "opam:1.2.1"}],
  ["../../../.esy/source/i/opam__s__bisect__ppx__opam__c__2.7.0__2dc0970c/",
  {
    name: "@opam/bisect_ppx",
    reference: "opam:2.7.0"}],
  ["../../../.esy/source/i/opam__s__bls12_381__opam__c__1.0.1__9d8f1dec/",
  {
    name: "@opam/bls12-381",
    reference: "opam:1.0.1"}],
  ["../../../.esy/source/i/opam__s__bls12_381_gen__opam__c__0.4.3__933c08e0/",
  {
    name: "@opam/bls12-381-gen",
    reference: "opam:0.4.3"}],
  ["../../../.esy/source/i/opam__s__bls12_381_legacy__b7c6908b/",
  {
    name: "@opam/bls12-381-legacy",
    reference: "archive:https://gitlab.com/dannywillems/ocaml-bls12-381/-/archive/0.4.3-legacy/ocaml-bls12-381-0.4.3-legacy.tar.bz2#sha512:0102db9dcab07c788291e9f799a4cf7a480716f18da6833587381e88ecc699d6e6bb0f44afef0ec7cd14a742d8ec6efc7900b45b0bcdeba409a89420465c0a25"}],
  ["../../../.esy/source/i/opam__s__bls12_381_unix__3487ded7/",
  {
    name: "@opam/bls12-381-unix",
    reference: "archive:https://gitlab.com/dannywillems/ocaml-bls12-381/-/archive/1.0.1/ocaml-bls12-381-1.0.1.tar.bz2#sha512:f69d611deb6132d07f0a8ecde7bb118f733de802e241056c5e2b194579c5723a12d58e93410bd56f68a608568de035b61f018d1fea52388f54875d77b8f386c2"}],
  ["../../../.esy/source/i/opam__s__bos__opam__c__0.2.1__a8387b1a/",
  {
    name: "@opam/bos",
    reference: "opam:0.2.1"}],
  ["../../../.esy/source/i/opam__s__ca_certs__opam__c__0.2.2__4c7191a2/",
  {
    name: "@opam/ca-certs",
    reference: "opam:0.2.2"}],
  ["../../../.esy/source/i/opam__s__cmdliner__opam__c__1.1.0__cce4f854/",
  {
    name: "@opam/cmdliner",
    reference: "opam:1.1.0"}],
  ["../../../.esy/source/i/opam__s__cohttp__opam__c__4.0.0__9d317795/",
  {
    name: "@opam/cohttp",
    reference: "opam:4.0.0"}],
  ["../../../.esy/source/i/opam__s__cohttp_lwt__opam__c__4.0.0__b9ddef0a/",
  {
    name: "@opam/cohttp-lwt",
    reference: "opam:4.0.0"}],
  ["../../../.esy/source/i/opam__s__cohttp_lwt_unix__opam__c__4.0.0__9431e1c3/",
  {
    name: "@opam/cohttp-lwt-unix",
    reference: "opam:4.0.0"}],
  ["../../../.esy/source/i/opam__s__conduit__opam__c__4.0.1__c40888fb/",
  {
    name: "@opam/conduit",
    reference: "opam:4.0.1"}],
  ["../../../.esy/source/i/opam__s__conduit_lwt__opam__c__4.0.1__065bfb9a/",
  {
    name: "@opam/conduit-lwt",
    reference: "opam:4.0.1"}],
  ["../../../.esy/source/i/opam__s__conduit_lwt_unix__opam__c__4.0.1__261f5f03/",
  {
    name: "@opam/conduit-lwt-unix",
    reference: "opam:4.0.1"}],
  ["../../../.esy/source/i/opam__s__conf_findutils__opam__c__1__67e3d251/",
  {
    name: "@opam/conf-findutils",
    reference: "opam:1"}],
  ["../../../.esy/source/i/opam__s__conf_gmp__opam__c__4__9b495a09/",
  {
    name: "@opam/conf-gmp",
    reference: "opam:4"}],
  ["../../../.esy/source/i/opam__s__conf_gmp_powm_sec__opam__c__3__0ac687f9/",
  {
    name: "@opam/conf-gmp-powm-sec",
    reference: "opam:3"}],
  ["../../../.esy/source/i/opam__s__conf_libev__opam__c__4_12__28fea866/",
  {
    name: "@opam/conf-libev",
    reference: "opam:4-12"}],
  ["../../../.esy/source/i/opam__s__conf_libffi__e1651d90/",
  {
    name: "@opam/conf-libffi",
    reference: "no-source:"}],
  ["../../../.esy/source/i/opam__s__conf_pkg_config__opam__c__2__f94434f0/",
  {
    name: "@opam/conf-pkg-config",
    reference: "opam:2"}],
  ["../../../.esy/source/i/opam__s__conf_rust__9fe9e0f4/",
  {
    name: "@opam/conf-rust",
    reference: "no-source:"}],
  ["../../../.esy/source/i/opam__s__conf_texinfo__358d35e6/",
  {
    name: "@opam/conf-texinfo",
    reference: "github:esy-packages/esy-texinfo:package.json#4a05feafbbcc4c57d5d25899fbdab98961b9a69c"}],
  ["../../../.esy/source/i/opam__s__coq__opam__c__8.13.2__099adf7d/",
  {
    name: "@opam/coq",
    reference: "opam:8.13.2"}],
  ["../../../.esy/source/i/opam__s__cppo__opam__c__1.6.8__e84e8b55/",
  {
    name: "@opam/cppo",
    reference: "opam:1.6.8"}],
  ["../../../.esy/source/i/opam__s__csexp__opam__c__1.5.1__a5d42d7e/",
  {
    name: "@opam/csexp",
    reference: "opam:1.5.1"}],
  ["../../../.esy/source/i/opam__s__cstruct__opam__c__6.0.1__5cf69c9a/",
  {
    name: "@opam/cstruct",
    reference: "opam:6.0.1"}],
  ["../../../.esy/source/i/opam__s__ctypes__opam__c__0.18.0__4e45a5f4/",
  {
    name: "@opam/ctypes",
    reference: "opam:0.18.0"}],
  ["../../../.esy/source/i/opam__s__ctypes_foreign__opam__c__0.18.0__299576b9/",
  {
    name: "@opam/ctypes-foreign",
    reference: "opam:0.18.0"}],
  ["../../../.esy/source/i/opam__s__data_encoding__opam__c__0.4__6a850d0d/",
  {
    name: "@opam/data-encoding",
    reference: "opam:0.4"}],
  ["../../../.esy/source/i/opam__s__digestif__opam__c__1.1.0__10cff702/",
  {
    name: "@opam/digestif",
    reference: "opam:1.1.0"}],
  ["../../../.esy/source/i/opam__s__domain_name__opam__c__0.4.0__b4a896fa/",
  {
    name: "@opam/domain-name",
    reference: "opam:0.4.0"}],
  ["../../../.esy/source/i/opam__s__dune__opam__c__2.9.1__b7828aa9/",
  {
    name: "@opam/dune",
    reference: "opam:2.9.1"}],
  ["../../../.esy/source/i/opam__s__dune_build_info__opam__c__2.9.3__7579f938/",
  {
    name: "@opam/dune-build-info",
    reference: "opam:2.9.3"}],
  ["../../../.esy/source/i/opam__s__dune_configurator__opam__c__2.9.3__f0e2382a/",
  {
    name: "@opam/dune-configurator",
    reference: "opam:2.9.3"}],
  ["../../../.esy/source/i/opam__s__duration__opam__c__0.2.0__cfdb8027/",
  {
    name: "@opam/duration",
    reference: "opam:0.2.0"}],
  ["../../../.esy/source/i/opam__s__easy_format__opam__c__1.3.2__2be19d18/",
  {
    name: "@opam/easy-format",
    reference: "opam:1.3.2"}],
  ["../../../.esy/source/i/opam__s__either__opam__c__1.0.0__29ca51fc/",
  {
    name: "@opam/either",
    reference: "opam:1.0.0"}],
  ["../../../.esy/source/i/opam__s__eqaf__opam__c__0.8__584a1628/",
  {
    name: "@opam/eqaf",
    reference: "opam:0.8"}],
  ["../../../.esy/source/i/opam__s__ezjsonm__opam__c__1.3.0__390a4fa7/",
  {
    name: "@opam/ezjsonm",
    reference: "opam:1.3.0"}],
  ["../../../.esy/source/i/opam__s__ff_sig__opam__c__0.6.2__3288d46a/",
  {
    name: "@opam/ff-sig",
    reference: "opam:0.6.2"}],
  ["../../../.esy/source/i/opam__s__fix__opam__c__20220121__091098a7/",
  {
    name: "@opam/fix",
    reference: "opam:20220121"}],
  ["../../../.esy/source/i/opam__s__fmt__opam__c__0.9.0__2f7f274d/",
  {
    name: "@opam/fmt",
    reference: "opam:0.9.0"}],
  ["../../../.esy/source/i/opam__s__fpath__opam__c__0.7.3__18652e33/",
  {
    name: "@opam/fpath",
    reference: "opam:0.7.3"}],
  ["../../../.esy/source/i/opam__s__functoria_runtime__opam__c__4.0.0~beta3__d982ef6f/",
  {
    name: "@opam/functoria-runtime",
    reference: "opam:4.0.0~beta3"}],
  ["../../../.esy/source/i/opam__s__getopt__opam__c__20120615__2097709f/",
  {
    name: "@opam/getopt",
    reference: "opam:20120615"}],
  ["../../../.esy/source/i/opam__s__gmap__opam__c__0.3.0__4ff017bd/",
  {
    name: "@opam/gmap",
    reference: "opam:0.3.0"}],
  ["../../../.esy/source/i/opam__s__hacl_star__opam__c__0.4.5__8c74c063/",
  {
    name: "@opam/hacl-star",
    reference: "opam:0.4.5"}],
  ["../../../.esy/source/i/opam__s__hacl_star_raw__5df079f5/",
  {
    name: "@opam/hacl-star-raw",
    reference: "archive:https://github.com/project-everest/hacl-star/releases/download/ocaml-v0.4.3/hacl-star.0.4.3.tar.gz#sha512:bfb2ddf125a345deb361483aedf9d79837e9ee18b0bc31644588f8409a0fe0c50db2fc1e6b20a07e02fb9f393d2fc9968fd9d2aa9f506f4e23ca8b6ed4036870"}],
  ["../../../.esy/source/i/opam__s__hex__opam__c__1.4.0__5566ecb7/",
  {
    name: "@opam/hex",
    reference: "opam:1.4.0"}],
  ["../../../.esy/source/i/opam__s__index__opam__c__1.4.2__9119aef0/",
  {
    name: "@opam/index",
    reference: "opam:1.4.2"}],
  ["../../../.esy/source/i/opam__s__integers__opam__c__0.6.0__8ab08c03/",
  {
    name: "@opam/integers",
    reference: "opam:0.6.0"}],
  ["../../../.esy/source/i/opam__s__ipaddr__opam__c__5.2.0__6f21a08d/",
  {
    name: "@opam/ipaddr",
    reference: "opam:5.2.0"}],
  ["../../../.esy/source/i/opam__s__ipaddr_sexp__opam__c__5.2.0__e69a5ce6/",
  {
    name: "@opam/ipaddr-sexp",
    reference: "opam:5.2.0"}],
  ["../../../.esy/source/i/opam__s__irmin__opam__c__2.8.0__7e55f2be/",
  {
    name: "@opam/irmin",
    reference: "opam:2.8.0"}],
  ["../../../.esy/source/i/opam__s__irmin_layers__opam__c__2.8.0__5336a328/",
  {
    name: "@opam/irmin-layers",
    reference: "opam:2.8.0"}],
  ["../../../.esy/source/i/opam__s__irmin_pack__opam__c__2.8.0__866d3d34/",
  {
    name: "@opam/irmin-pack",
    reference: "opam:2.8.0"}],
  ["../../../.esy/source/i/opam__s__jane_street_headers__opam__c__v0.14.0__2ed620b8/",
  {
    name: "@opam/jane-street-headers",
    reference: "opam:v0.14.0"}],
  ["../../../.esy/source/i/opam__s__json_data_encoding__opam__c__0.11__ebd7f5ee/",
  {
    name: "@opam/json-data-encoding",
    reference: "opam:0.11"}],
  ["../../../.esy/source/i/opam__s__json_data_encoding_bson__opam__c__0.11__0ca0d3d3/",
  {
    name: "@opam/json-data-encoding-bson",
    reference: "opam:0.11"}],
  ["../../../.esy/source/i/opam__s__jsonm__opam__c__1.0.1__0f41f896/",
  {
    name: "@opam/jsonm",
    reference: "opam:1.0.1"}],
  ["../../../.esy/source/i/opam__s__jst_config__opam__c__v0.14.1__d0762df8/",
  {
    name: "@opam/jst-config",
    reference: "opam:v0.14.1"}],
  ["../../../.esy/source/i/opam__s__linenoise__opam__c__1.3.1__87689145/",
  {
    name: "@opam/linenoise",
    reference: "opam:1.3.1"}],
  ["../../../.esy/source/i/opam__s__logs__opam__c__0.7.0__da3c2fe0/",
  {
    name: "@opam/logs",
    reference: "opam:0.7.0"}],
  ["../../../.esy/source/i/opam__s__lwt__log__opam__c__1.1.1__7f54b5d1/",
  {
    name: "@opam/lwt_log",
    reference: "opam:1.1.1"}],
  ["../../../.esy/source/i/opam__s__lwt__opam__c__5.4.2__8d2eee21/",
  {
    name: "@opam/lwt",
    reference: "opam:5.4.2"}],
  ["../../../.esy/source/i/opam__s__lwt_canceler__opam__c__0.3__5feaf254/",
  {
    name: "@opam/lwt-canceler",
    reference: "opam:0.3"}],
  ["../../../.esy/source/i/opam__s__macaddr__opam__c__5.2.0__0f64d946/",
  {
    name: "@opam/macaddr",
    reference: "opam:5.2.0"}],
  ["../../../.esy/source/i/opam__s__magic_mime__opam__c__1.2.0__c9733c05/",
  {
    name: "@opam/magic-mime",
    reference: "opam:1.2.0"}],
  ["../../../.esy/source/i/opam__s__menhir__opam__c__20211012__2b709e04/",
  {
    name: "@opam/menhir",
    reference: "opam:20211012"}],
  ["../../../.esy/source/i/opam__s__menhirlib__opam__c__20211012__07d77bc1/",
  {
    name: "@opam/menhirLib",
    reference: "opam:20211012"}],
  ["../../../.esy/source/i/opam__s__menhirsdk__opam__c__20211012__6ed84af4/",
  {
    name: "@opam/menhirSdk",
    reference: "opam:20211012"}],
  ["../../../.esy/source/i/opam__s__mirage_crypto__opam__c__0.10.5__aca19556/",
  {
    name: "@opam/mirage-crypto",
    reference: "opam:0.10.5"}],
  ["../../../.esy/source/i/opam__s__mirage_crypto_ec__opam__c__0.10.5__05fbc674/",
  {
    name: "@opam/mirage-crypto-ec",
    reference: "opam:0.10.5"}],
  ["../../../.esy/source/i/opam__s__mirage_crypto_pk__opam__c__0.10.5__94bc17e2/",
  {
    name: "@opam/mirage-crypto-pk",
    reference: "opam:0.10.5"}],
  ["../../../.esy/source/i/opam__s__mirage_crypto_rng__opam__c__0.10.5__91d3de4d/",
  {
    name: "@opam/mirage-crypto-rng",
    reference: "opam:0.10.5"}],
  ["../../../.esy/source/i/opam__s__mirage_runtime__opam__c__4.0.0~beta3__8cfae177/",
  {
    name: "@opam/mirage-runtime",
    reference: "opam:4.0.0~beta3"}],
  ["../../../.esy/source/i/opam__s__mmap__opam__c__1.2.0__d90cd9e6/",
  {
    name: "@opam/mmap",
    reference: "opam:1.2.0"}],
  ["../../../.esy/source/i/opam__s__mtime__opam__c__1.4.0__c21271fe/",
  {
    name: "@opam/mtime",
    reference: "opam:1.4.0"}],
  ["../../../.esy/source/i/opam__s__num__opam__c__1.4__a26086aa/",
  {
    name: "@opam/num",
    reference: "opam:1.4"}],
  ["../../../.esy/source/i/opam__s__ocaml_compiler_libs__opam__c__v0.12.4__35cddb8b/",
  {
    name: "@opam/ocaml-compiler-libs",
    reference: "opam:v0.12.4"}],
  ["../../../.esy/source/i/opam__s__ocaml_lsp_server__opam__c__1.9.0__342ea46d/",
  {
    name: "@opam/ocaml-lsp-server",
    reference: "opam:1.9.0"}],
  ["../../../.esy/source/i/opam__s__ocaml_migrate_parsetree__opam__c__2.3.0__af9afb57/",
  {
    name: "@opam/ocaml-migrate-parsetree",
    reference: "opam:2.3.0"}],
  ["../../../.esy/source/i/opam__s__ocaml_recovery_parser__f891872c/",
  {
    name: "@opam/ocaml-recovery-parser",
    reference: "github:serokell/ocaml-recovery-parser:ocaml-recovery-parser.opam#7a759aed307f986d43006c50b8ced677e18b5a6d"}],
  ["../../../.esy/source/i/opam__s__ocaml_syntax_shims__opam__c__1.0.0__cb8d5a09/",
  {
    name: "@opam/ocaml-syntax-shims",
    reference: "opam:1.0.0"}],
  ["../../../.esy/source/i/opam__s__ocamlbuild__opam__c__0.14.1__3fd19d31/",
  {
    name: "@opam/ocamlbuild",
    reference: "opam:0.14.1"}],
  ["../../../.esy/source/i/opam__s__ocamlfind__opam__c__1.9.1__492060b0/",
  {
    name: "@opam/ocamlfind",
    reference: "opam:1.9.1"}],
  ["../../../.esy/source/i/opam__s__ocamlformat__opam__c__0.19.0__07a0fa1b/",
  {
    name: "@opam/ocamlformat",
    reference: "opam:0.19.0"}],
  ["../../../.esy/source/i/opam__s__ocamlformat_rpc_lib__opam__c__0.19.0__a218b2b0/",
  {
    name: "@opam/ocamlformat-rpc-lib",
    reference: "opam:0.19.0"}],
  ["../../../.esy/source/i/opam__s__ocamlgraph__opam__c__2.0.0__32ec120a/",
  {
    name: "@opam/ocamlgraph",
    reference: "opam:2.0.0"}],
  ["../../../.esy/source/i/opam__s__ocp_indent__opam__c__1.8.1__2297d668/",
  {
    name: "@opam/ocp-indent",
    reference: "opam:1.8.1"}],
  ["../../../.esy/source/i/opam__s__ocplib_endian__opam__c__1.2__572dceaf/",
  {
    name: "@opam/ocplib-endian",
    reference: "opam:1.2"}],
  ["../../../.esy/source/i/opam__s__octavius__opam__c__1.2.2__96807fc5/",
  {
    name: "@opam/octavius",
    reference: "opam:1.2.2"}],
  ["../../../.esy/source/i/opam__s__odoc__opam__c__1.5.3__1831f8b7/",
  {
    name: "@opam/odoc",
    reference: "opam:1.5.3"}],
  ["../../../.esy/source/i/opam__s__odoc_parser__opam__c__0.9.0__81142933/",
  {
    name: "@opam/odoc-parser",
    reference: "opam:0.9.0"}],
  ["../../../.esy/source/i/opam__s__optint__opam__c__0.1.0__9b8335d7/",
  {
    name: "@opam/optint",
    reference: "opam:0.1.0"}],
  ["../../../.esy/source/i/opam__s__ounit2__opam__c__2.2.6__a70bc055/",
  {
    name: "@opam/ounit2",
    reference: "opam:2.2.6"}],
  ["../../../.esy/source/i/opam__s__parsexp__opam__c__v0.14.2__97598992/",
  {
    name: "@opam/parsexp",
    reference: "opam:v0.14.2"}],
  ["../../../.esy/source/i/opam__s__pbkdf__opam__c__1.2.0__a9031749/",
  {
    name: "@opam/pbkdf",
    reference: "opam:1.2.0"}],
  ["../../../.esy/source/i/opam__s__pp__opam__c__1.1.2__ebad31ff/",
  {
    name: "@opam/pp",
    reference: "opam:1.1.2"}],
  ["../../../.esy/source/i/opam__s__pprint__opam__c__20211129__fc16ea22/",
  {
    name: "@opam/pprint",
    reference: "opam:20211129"}],
  ["../../../.esy/source/i/opam__s__ppx__assert__opam__c__v0.14.0__41578bf1/",
  {
    name: "@opam/ppx_assert",
    reference: "opam:v0.14.0"}],
  ["../../../.esy/source/i/opam__s__ppx__base__opam__c__v0.14.0__69130302/",
  {
    name: "@opam/ppx_base",
    reference: "opam:v0.14.0"}],
  ["../../../.esy/source/i/opam__s__ppx__cold__opam__c__v0.14.0__20831c56/",
  {
    name: "@opam/ppx_cold",
    reference: "opam:v0.14.0"}],
  ["../../../.esy/source/i/opam__s__ppx__compare__opam__c__v0.14.0__d8a7262e/",
  {
    name: "@opam/ppx_compare",
    reference: "opam:v0.14.0"}],
  ["../../../.esy/source/i/opam__s__ppx__derivers__opam__c__1.2.1__136a746e/",
  {
    name: "@opam/ppx_derivers",
    reference: "opam:1.2.1"}],
  ["../../../.esy/source/i/opam__s__ppx__deriving__opam__c__5.2.1__7dc03006/",
  {
    name: "@opam/ppx_deriving",
    reference: "opam:5.2.1"}],
  ["../../../.esy/source/i/opam__s__ppx__deriving__yojson__opam__c__3.6.1__f7812344/",
  {
    name: "@opam/ppx_deriving_yojson",
    reference: "opam:3.6.1"}],
  ["../../../.esy/source/i/opam__s__ppx__enumerate__opam__c__v0.14.0__5fc8f5bc/",
  {
    name: "@opam/ppx_enumerate",
    reference: "opam:v0.14.0"}],
  ["../../../.esy/source/i/opam__s__ppx__expect__opam__c__v0.14.2__339f33b8/",
  {
    name: "@opam/ppx_expect",
    reference: "opam:v0.14.2"}],
  ["../../../.esy/source/i/opam__s__ppx__hash__opam__c__v0.14.0__84fc2573/",
  {
    name: "@opam/ppx_hash",
    reference: "opam:v0.14.0"}],
  ["../../../.esy/source/i/opam__s__ppx__here__opam__c__v0.14.0__fefd8712/",
  {
    name: "@opam/ppx_here",
    reference: "opam:v0.14.0"}],
  ["../../../.esy/source/i/opam__s__ppx__inline__test__opam__c__v0.14.1__ba73c193/",
  {
    name: "@opam/ppx_inline_test",
    reference: "opam:v0.14.1"}],
  ["../../../.esy/source/i/opam__s__ppx__irmin__opam__c__2.8.0__874483c2/",
  {
    name: "@opam/ppx_irmin",
    reference: "opam:2.8.0"}],
  ["../../../.esy/source/i/opam__s__ppx__js__style__opam__c__v0.14.1__927575a1/",
  {
    name: "@opam/ppx_js_style",
    reference: "opam:v0.14.1"}],
  ["../../../.esy/source/i/opam__s__ppx__optcomp__opam__c__v0.14.3__a8348810/",
  {
    name: "@opam/ppx_optcomp",
    reference: "opam:v0.14.3"}],
  ["../../../.esy/source/i/opam__s__ppx__repr__opam__c__0.5.0__6dbade65/",
  {
    name: "@opam/ppx_repr",
    reference: "opam:0.5.0"}],
  ["../../../.esy/source/i/opam__s__ppx__sexp__conv__opam__c__v0.14.3__c785b6cc/",
  {
    name: "@opam/ppx_sexp_conv",
    reference: "opam:v0.14.3"}],
  ["../../../.esy/source/i/opam__s__ppx__yojson__conv__lib__opam__c__v0.14.0__dc949ddc/",
  {
    name: "@opam/ppx_yojson_conv_lib",
    reference: "opam:v0.14.0"}],
  ["../../../.esy/source/i/opam__s__ppxlib__opam__c__0.25.0__b65257ff/",
  {
    name: "@opam/ppxlib",
    reference: "opam:0.25.0"}],
  ["../../../.esy/source/i/opam__s__progress__opam__c__0.2.1__2dd32233/",
  {
    name: "@opam/progress",
    reference: "opam:0.2.1"}],
  ["../../../.esy/source/i/opam__s__ptime__opam__c__1.0.0__86dcc7f6/",
  {
    name: "@opam/ptime",
    reference: "opam:1.0.0"}],
  ["../../../.esy/source/i/opam__s__qcheck__opam__c__0.18__07c4a33e/",
  {
    name: "@opam/qcheck",
    reference: "opam:0.18"}],
  ["../../../.esy/source/i/opam__s__qcheck_alcotest__opam__c__0.18__93899ba9/",
  {
    name: "@opam/qcheck-alcotest",
    reference: "opam:0.18"}],
  ["../../../.esy/source/i/opam__s__qcheck_core__opam__c__0.18__9d052a60/",
  {
    name: "@opam/qcheck-core",
    reference: "opam:0.18"}],
  ["../../../.esy/source/i/opam__s__qcheck_ounit__opam__c__0.18__0311abc9/",
  {
    name: "@opam/qcheck-ounit",
    reference: "opam:0.18"}],
  ["../../../.esy/source/i/opam__s__re__opam__c__1.10.3__f85af983/",
  {
    name: "@opam/re",
    reference: "opam:1.10.3"}],
  ["../../../.esy/source/i/opam__s__repr__opam__c__0.5.0__465d8699/",
  {
    name: "@opam/repr",
    reference: "opam:0.5.0"}],
  ["../../../.esy/source/i/opam__s__resto__opam__c__0.6.1__edcb84c5/",
  {
    name: "@opam/resto",
    reference: "opam:0.6.1"}],
  ["../../../.esy/source/i/opam__s__resto_acl__opam__c__0.6.1__5b5dc6c3/",
  {
    name: "@opam/resto-acl",
    reference: "opam:0.6.1"}],
  ["../../../.esy/source/i/opam__s__resto_cohttp__opam__c__0.6.1__6c876dbf/",
  {
    name: "@opam/resto-cohttp",
    reference: "opam:0.6.1"}],
  ["../../../.esy/source/i/opam__s__resto_cohttp_client__opam__c__0.6.1__2dcdc3fe/",
  {
    name: "@opam/resto-cohttp-client",
    reference: "opam:0.6.1"}],
  ["../../../.esy/source/i/opam__s__resto_cohttp_self_serving_client__opam__c__0.6.1__c49182a6/",
  {
    name: "@opam/resto-cohttp-self-serving-client",
    reference: "opam:0.6.1"}],
  ["../../../.esy/source/i/opam__s__resto_cohttp_server__opam__c__0.6.1__8ff39605/",
  {
    name: "@opam/resto-cohttp-server",
    reference: "opam:0.6.1"}],
  ["../../../.esy/source/i/opam__s__resto_directory__opam__c__0.6.1__a80e55f7/",
  {
    name: "@opam/resto-directory",
    reference: "opam:0.6.1"}],
  ["../../../.esy/source/i/opam__s__result__opam__c__1.5__74485f30/",
  {
    name: "@opam/result",
    reference: "opam:1.5"}],
  ["../../../.esy/source/i/opam__s__ringo__opam__c__0.5__9546a50b/",
  {
    name: "@opam/ringo",
    reference: "opam:0.5"}],
  ["../../../.esy/source/i/opam__s__ringo_lwt__opam__c__0.5__4dc50021/",
  {
    name: "@opam/ringo-lwt",
    reference: "opam:0.5"}],
  ["../../../.esy/source/i/opam__s__rresult__opam__c__0.7.0__46070e80/",
  {
    name: "@opam/rresult",
    reference: "opam:0.7.0"}],
  ["../../../.esy/source/i/opam__s__secp256k1_internal__opam__c__0.3.1__fe0b1f25/",
  {
    name: "@opam/secp256k1-internal",
    reference: "opam:0.3.1"}],
  ["../../../.esy/source/i/opam__s__semaphore_compat__opam__c__1.0.1__251c8dd0/",
  {
    name: "@opam/semaphore-compat",
    reference: "opam:1.0.1"}],
  ["../../../.esy/source/i/opam__s__seq__opam__c__base__a0c677b1/",
  {
    name: "@opam/seq",
    reference: "opam:base"}],
  ["../../../.esy/source/i/opam__s__sexplib0__opam__c__v0.14.0__b1448c97/",
  {
    name: "@opam/sexplib0",
    reference: "opam:v0.14.0"}],
  ["../../../.esy/source/i/opam__s__sexplib__opam__c__v0.14.0__0ac5a13c/",
  {
    name: "@opam/sexplib",
    reference: "opam:v0.14.0"}],
  ["../../../.esy/source/i/opam__s__spawn__opam__c__v0.15.0__11dda031/",
  {
    name: "@opam/spawn",
    reference: "opam:v0.15.0"}],
  ["../../../.esy/source/i/opam__s__stdio__opam__c__v0.14.0__16c0aeaf/",
  {
    name: "@opam/stdio",
    reference: "opam:v0.14.0"}],
  ["../../../.esy/source/i/opam__s__stdlib_shims__opam__c__0.3.0__513c478f/",
  {
    name: "@opam/stdlib-shims",
    reference: "opam:0.3.0"}],
  ["../../../.esy/source/i/opam__s__stringext__opam__c__1.6.0__69baaaa5/",
  {
    name: "@opam/stringext",
    reference: "opam:1.6.0"}],
  ["../../../.esy/source/i/opam__s__terminal__opam__c__0.2.1__e617d075/",
  {
    name: "@opam/terminal",
    reference: "opam:0.2.1"}],
  ["../../../.esy/source/i/opam__s__terminal__size__opam__c__0.1.4__0d7b0fb2/",
  {
    name: "@opam/terminal_size",
    reference: "opam:0.1.4"}],
  ["../../../.esy/source/i/opam__s__tezos_base__opam__c__11.1__56d791ab/",
  {
    name: "@opam/tezos-base",
    reference: "opam:11.1"}],
  ["../../../.esy/source/i/opam__s__tezos_clic__opam__c__11.1__46f3ea99/",
  {
    name: "@opam/tezos-clic",
    reference: "opam:11.1"}],
  ["../../../.esy/source/i/opam__s__tezos_crypto__opam__c__11.1__6fa64d9e/",
  {
    name: "@opam/tezos-crypto",
    reference: "opam:11.1"}],
  ["../../../.esy/source/i/opam__s__tezos_error_monad__opam__c__11.1__b14e49ce/",
  {
    name: "@opam/tezos-error-monad",
    reference: "opam:11.1"}],
  ["../../../.esy/source/i/opam__s__tezos_event_logging__opam__c__11.1__a6f9a708/",
  {
    name: "@opam/tezos-event-logging",
    reference: "opam:11.1"}],
  ["../../../.esy/source/i/opam__s__tezos_hacl_glue__opam__c__11.1__bab83aab/",
  {
    name: "@opam/tezos-hacl-glue",
    reference: "opam:11.1"}],
  ["../../../.esy/source/i/opam__s__tezos_hacl_glue_unix__opam__c__11.1__f7b6cdb8/",
  {
    name: "@opam/tezos-hacl-glue-unix",
    reference: "opam:11.1"}],
  ["../../../.esy/source/i/opam__s__tezos_lwt_result_stdlib__opam__c__11.1__d8795b24/",
  {
    name: "@opam/tezos-lwt-result-stdlib",
    reference: "opam:11.1"}],
  ["../../../.esy/source/i/opam__s__tezos_micheline__opam__c__11.1__e067d707/",
  {
    name: "@opam/tezos-micheline",
    reference: "opam:11.1"}],
  ["../../../.esy/source/i/opam__s__tezos_rpc__opam__c__11.1__413fd1d6/",
  {
    name: "@opam/tezos-rpc",
    reference: "opam:11.1"}],
  ["../../../.esy/source/i/opam__s__tezos_rust_libs__opam__c__1.1__a14a843a/",
  {
    name: "@opam/tezos-rust-libs",
    reference: "opam:1.1"}],
  ["../../../.esy/source/i/opam__s__tezos_stdlib__opam__c__11.1__2aa4b183/",
  {
    name: "@opam/tezos-stdlib",
    reference: "opam:11.1"}],
  ["../../../.esy/source/i/opam__s__tezos_stdlib_unix__opam__c__11.1__42d039fa/",
  {
    name: "@opam/tezos-stdlib-unix",
    reference: "opam:11.1"}],
  ["../../../.esy/source/i/opam__s__time__now__opam__c__v0.14.0__d582831e/",
  {
    name: "@opam/time_now",
    reference: "opam:v0.14.0"}],
  ["../../../.esy/source/i/opam__s__topkg__opam__c__1.0.5__82377b68/",
  {
    name: "@opam/topkg",
    reference: "opam:1.0.5"}],
  ["../../../.esy/source/i/opam__s__tyxml__opam__c__4.5.0__0b0b6820/",
  {
    name: "@opam/tyxml",
    reference: "opam:4.5.0"}],
  ["../../../.esy/source/i/opam__s__uchar__opam__c__0.0.2__0292ad2f/",
  {
    name: "@opam/uchar",
    reference: "opam:0.0.2"}],
  ["../../../.esy/source/i/opam__s__uri__opam__c__4.2.0__9b4b8867/",
  {
    name: "@opam/uri",
    reference: "opam:4.2.0"}],
  ["../../../.esy/source/i/opam__s__uri_sexp__opam__c__4.2.0__2007821d/",
  {
    name: "@opam/uri-sexp",
    reference: "opam:4.2.0"}],
  ["../../../.esy/source/i/opam__s__uucp__opam__c__14.0.0__e45d1234/",
  {
    name: "@opam/uucp",
    reference: "opam:14.0.0"}],
  ["../../../.esy/source/i/opam__s__uuseg__opam__c__14.0.0__ae751ed3/",
  {
    name: "@opam/uuseg",
    reference: "opam:14.0.0"}],
  ["../../../.esy/source/i/opam__s__uutf__opam__c__1.0.3__8c042452/",
  {
    name: "@opam/uutf",
    reference: "opam:1.0.3"}],
  ["../../../.esy/source/i/opam__s__vector__opam__c__1.0.0__929e876d/",
  {
    name: "@opam/vector",
    reference: "opam:1.0.0"}],
  ["../../../.esy/source/i/opam__s__x509__opam__c__0.16.0__aa7e3e37/",
  {
    name: "@opam/x509",
    reference: "opam:0.16.0"}],
  ["../../../.esy/source/i/opam__s__yojson__opam__c__1.7.0__5bfab1af/",
  {
    name: "@opam/yojson",
    reference: "opam:1.7.0"}],
  ["../../../.esy/source/i/opam__s__zarith__opam__c__1.12__0eb91e89/",
  {
    name: "@opam/zarith",
    reference: "opam:1.12"}],
  ["../../../.esy/source/i/yarn_pkg_config__9829fc81/",
  {
    name: "yarn-pkg-config",
    reference: "github:esy-ocaml/yarn-pkg-config#db3a0b63883606dd57c54a7158d560d6cba8cd79"}]]);


  exports.findPackageLocator = function findPackageLocator(location) {
    let relativeLocation = normalizePath(path.relative(__dirname, location));

    if (!relativeLocation.match(isStrictRegExp))
      relativeLocation = `./${relativeLocation}`;

    if (location.match(isDirRegExp) && relativeLocation.charAt(relativeLocation.length - 1) !== '/')
      relativeLocation = `${relativeLocation}/`;

    let match;

  
      if (relativeLocation.length >= 91 && relativeLocation[90] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 91)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 83 && relativeLocation[82] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 83)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 82 && relativeLocation[81] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 82)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 81 && relativeLocation[80] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 81)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 80 && relativeLocation[79] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 80)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 79 && relativeLocation[78] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 79)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 78 && relativeLocation[77] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 78)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 77 && relativeLocation[76] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 77)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 76 && relativeLocation[75] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 76)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 75 && relativeLocation[74] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 75)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 74 && relativeLocation[73] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 74)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 73 && relativeLocation[72] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 73)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 72 && relativeLocation[71] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 72)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 71 && relativeLocation[70] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 71)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 70 && relativeLocation[69] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 70)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 69 && relativeLocation[68] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 69)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 68 && relativeLocation[67] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 68)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 67 && relativeLocation[66] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 67)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 66 && relativeLocation[65] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 66)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 65 && relativeLocation[64] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 65)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 64 && relativeLocation[63] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 64)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 63 && relativeLocation[62] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 63)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 62 && relativeLocation[61] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 62)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 61 && relativeLocation[60] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 61)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 60 && relativeLocation[59] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 60)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 59 && relativeLocation[58] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 59)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 57 && relativeLocation[56] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 57)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 56 && relativeLocation[55] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 56)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 55 && relativeLocation[54] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 55)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 54 && relativeLocation[53] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 54)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 52 && relativeLocation[51] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 52)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 51 && relativeLocation[50] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 51)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 49 && relativeLocation[48] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 49)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 47 && relativeLocation[46] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 47)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 44 && relativeLocation[43] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 44)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 41 && relativeLocation[40] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 41)))
          return blacklistCheck(match);
      

      if (relativeLocation.length >= 6 && relativeLocation[5] === '/')
        if (match = locatorsByLocations.get(relativeLocation.substr(0, 6)))
          return blacklistCheck(match);
      

    /*
      this can only happen if inside the _esy
      as any other path will implies the opposite

      topLevelLocatorPath = ../../

      | folder              | relativeLocation |
      | ------------------- | ---------------- |
      | /workspace/app      | ../../           |
      | /workspace          | ../../../        |
      | /workspace/app/x    | ../../x/         |
      | /workspace/app/_esy | ../              |

    */
    if (!relativeLocation.startsWith(topLevelLocatorPath)) {
      return topLevelLocator;
    }
    return null;
  };
  

/**
 * Returns the module that should be used to resolve require calls. It's usually the direct parent, except if we're
 * inside an eval expression.
 */

function getIssuerModule(parent) {
  let issuer = parent;

  while (issuer && (issuer.id === '[eval]' || issuer.id === '<repl>' || !issuer.filename)) {
    issuer = issuer.parent;
  }

  return issuer;
}

/**
 * Returns information about a package in a safe way (will throw if they cannot be retrieved)
 */

function getPackageInformationSafe(packageLocator) {
  const packageInformation = exports.getPackageInformation(packageLocator);

  if (!packageInformation) {
    throw makeError(
      `INTERNAL`,
      `Couldn't find a matching entry in the dependency tree for the specified parent (this is probably an internal error)`
    );
  }

  return packageInformation;
}

/**
 * Implements the node resolution for folder access and extension selection
 */

function applyNodeExtensionResolution(unqualifiedPath, {extensions}) {
  // We use this "infinite while" so that we can restart the process as long as we hit package folders
  while (true) {
    let stat;

    try {
      stat = statSync(unqualifiedPath);
    } catch (error) {}

    // If the file exists and is a file, we can stop right there

    if (stat && !stat.isDirectory()) {
      // If the very last component of the resolved path is a symlink to a file, we then resolve it to a file. We only
      // do this first the last component, and not the rest of the path! This allows us to support the case of bin
      // symlinks, where a symlink in "/xyz/pkg-name/.bin/bin-name" will point somewhere else (like "/xyz/pkg-name/index.js").
      // In such a case, we want relative requires to be resolved relative to "/xyz/pkg-name/" rather than "/xyz/pkg-name/.bin/".
      //
      // Also note that the reason we must use readlink on the last component (instead of realpath on the whole path)
      // is that we must preserve the other symlinks, in particular those used by pnp to deambiguate packages using
      // peer dependencies. For example, "/xyz/.pnp/local/pnp-01234569/.bin/bin-name" should see its relative requires
      // be resolved relative to "/xyz/.pnp/local/pnp-0123456789/" rather than "/xyz/pkg-with-peers/", because otherwise
      // we would lose the information that would tell us what are the dependencies of pkg-with-peers relative to its
      // ancestors.

      if (lstatSync(unqualifiedPath).isSymbolicLink()) {
        unqualifiedPath = path.normalize(path.resolve(path.dirname(unqualifiedPath), readlinkSync(unqualifiedPath)));
      }

      return unqualifiedPath;
    }

    // If the file is a directory, we must check if it contains a package.json with a "main" entry

    if (stat && stat.isDirectory()) {
      let pkgJson;

      try {
        pkgJson = JSON.parse(readFileSync(`${unqualifiedPath}/package.json`, 'utf-8'));
      } catch (error) {}

      let nextUnqualifiedPath;

      if (pkgJson && pkgJson.main) {
        nextUnqualifiedPath = path.resolve(unqualifiedPath, pkgJson.main);
      }

      // If the "main" field changed the path, we start again from this new location

      if (nextUnqualifiedPath && nextUnqualifiedPath !== unqualifiedPath) {
        const resolution = applyNodeExtensionResolution(nextUnqualifiedPath, {extensions});

        if (resolution !== null) {
          return resolution;
        }
      }
    }

    // Otherwise we check if we find a file that match one of the supported extensions

    const qualifiedPath = extensions
      .map(extension => {
        return `${unqualifiedPath}${extension}`;
      })
      .find(candidateFile => {
        return existsSync(candidateFile);
      });

    if (qualifiedPath) {
      return qualifiedPath;
    }

    // Otherwise, we check if the path is a folder - in such a case, we try to use its index

    if (stat && stat.isDirectory()) {
      const indexPath = extensions
        .map(extension => {
          return `${unqualifiedPath}/index${extension}`;
        })
        .find(candidateFile => {
          return existsSync(candidateFile);
        });

      if (indexPath) {
        return indexPath;
      }
    }

    // Otherwise there's nothing else we can do :(

    return null;
  }
}

/**
 * This function creates fake modules that can be used with the _resolveFilename function.
 * Ideally it would be nice to be able to avoid this, since it causes useless allocations
 * and cannot be cached efficiently (we recompute the nodeModulePaths every time).
 *
 * Fortunately, this should only affect the fallback, and there hopefully shouldn't be a
 * lot of them.
 */

function makeFakeModule(path) {
  const fakeModule = new Module(path, false);
  fakeModule.filename = path;
  fakeModule.paths = Module._nodeModulePaths(path);
  return fakeModule;
}

/**
 * Normalize path to posix format.
 */

// eslint-disable-next-line no-unused-vars
function normalizePath(fsPath) {
  fsPath = path.normalize(fsPath);

  if (process.platform === 'win32') {
    fsPath = fsPath.replace(backwardSlashRegExp, '/');
  }

  return fsPath;
}

/**
 * Forward the resolution to the next resolver (usually the native one)
 */

function callNativeResolution(request, issuer) {
  if (issuer.endsWith('/')) {
    issuer += 'internal.js';
  }

  try {
    enableNativeHooks = false;

    // Since we would need to create a fake module anyway (to call _resolveLookupPath that
    // would give us the paths to give to _resolveFilename), we can as well not use
    // the {paths} option at all, since it internally makes _resolveFilename create another
    // fake module anyway.
    return Module._resolveFilename(request, makeFakeModule(issuer), false);
  } finally {
    enableNativeHooks = true;
  }
}

/**
 * This key indicates which version of the standard is implemented by this resolver. The `std` key is the
 * Plug'n'Play standard, and any other key are third-party extensions. Third-party extensions are not allowed
 * to override the standard, and can only offer new methods.
 *
 * If an new version of the Plug'n'Play standard is released and some extensions conflict with newly added
 * functions, they'll just have to fix the conflicts and bump their own version number.
 */

exports.VERSIONS = {std: 1};

/**
 * Useful when used together with getPackageInformation to fetch information about the top-level package.
 */

exports.topLevel = {name: null, reference: null};

/**
 * Gets the package information for a given locator. Returns null if they cannot be retrieved.
 */

exports.getPackageInformation = function getPackageInformation({name, reference}) {
  const packageInformationStore = packageInformationStores.get(name);

  if (!packageInformationStore) {
    return null;
  }

  const packageInformation = packageInformationStore.get(reference);

  if (!packageInformation) {
    return null;
  }

  return packageInformation;
};

/**
 * Transforms a request (what's typically passed as argument to the require function) into an unqualified path.
 * This path is called "unqualified" because it only changes the package name to the package location on the disk,
 * which means that the end result still cannot be directly accessed (for example, it doesn't try to resolve the
 * file extension, or to resolve directories to their "index.js" content). Use the "resolveUnqualified" function
 * to convert them to fully-qualified paths, or just use "resolveRequest" that do both operations in one go.
 *
 * Note that it is extremely important that the `issuer` path ends with a forward slash if the issuer is to be
 * treated as a folder (ie. "/tmp/foo/" rather than "/tmp/foo" if "foo" is a directory). Otherwise relative
 * imports won't be computed correctly (they'll get resolved relative to "/tmp/" instead of "/tmp/foo/").
 */

exports.resolveToUnqualified = function resolveToUnqualified(request, issuer, {considerBuiltins = true} = {}) {
  // The 'pnpapi' request is reserved and will always return the path to the PnP file, from everywhere

  if (request === `pnpapi`) {
    return pnpFile;
  }

  // Bailout if the request is a native module

  if (considerBuiltins && builtinModules.has(request)) {
    return null;
  }

  // We allow disabling the pnp resolution for some subpaths. This is because some projects, often legacy,
  // contain multiple levels of dependencies (ie. a yarn.lock inside a subfolder of a yarn.lock). This is
  // typically solved using workspaces, but not all of them have been converted already.

  if (ignorePattern && ignorePattern.test(normalizePath(issuer))) {
    const result = callNativeResolution(request, issuer);

    if (result === false) {
      throw makeError(
        `BUILTIN_NODE_RESOLUTION_FAIL`,
        `The builtin node resolution algorithm was unable to resolve the module referenced by "${request}" and requested from "${issuer}" (it didn't go through the pnp resolver because the issuer was explicitely ignored by the regexp "$$BLACKLIST")`,
        {
          request,
          issuer
        }
      );
    }

    return result;
  }

  let unqualifiedPath;

  // If the request is a relative or absolute path, we just return it normalized

  const dependencyNameMatch = request.match(pathRegExp);

  if (!dependencyNameMatch) {
    if (path.isAbsolute(request)) {
      unqualifiedPath = path.normalize(request);
    } else if (issuer.match(isDirRegExp)) {
      unqualifiedPath = path.normalize(path.resolve(issuer, request));
    } else {
      unqualifiedPath = path.normalize(path.resolve(path.dirname(issuer), request));
    }
  }

  // Things are more hairy if it's a package require - we then need to figure out which package is needed, and in
  // particular the exact version for the given location on the dependency tree

  if (dependencyNameMatch) {
    const [, dependencyName, subPath] = dependencyNameMatch;

    const issuerLocator = exports.findPackageLocator(issuer);

    // If the issuer file doesn't seem to be owned by a package managed through pnp, then we resort to using the next
    // resolution algorithm in the chain, usually the native Node resolution one

    if (!issuerLocator) {
      const result = callNativeResolution(request, issuer);

      if (result === false) {
        throw makeError(
          `BUILTIN_NODE_RESOLUTION_FAIL`,
          `The builtin node resolution algorithm was unable to resolve the module referenced by "${request}" and requested from "${issuer}" (it didn't go through the pnp resolver because the issuer doesn't seem to be part of the Yarn-managed dependency tree)`,
          {
            request,
            issuer
          },
        );
      }

      return result;
    }

    const issuerInformation = getPackageInformationSafe(issuerLocator);

    // We obtain the dependency reference in regard to the package that request it

    let dependencyReference = issuerInformation.packageDependencies.get(dependencyName);

    // If we can't find it, we check if we can potentially load it from the packages that have been defined as potential fallbacks.
    // It's a bit of a hack, but it improves compatibility with the existing Node ecosystem. Hopefully we should eventually be able
    // to kill this logic and become stricter once pnp gets enough traction and the affected packages fix themselves.

    if (issuerLocator !== topLevelLocator) {
      for (let t = 0, T = fallbackLocators.length; dependencyReference === undefined && t < T; ++t) {
        const fallbackInformation = getPackageInformationSafe(fallbackLocators[t]);
        dependencyReference = fallbackInformation.packageDependencies.get(dependencyName);
      }
    }

    // If we can't find the path, and if the package making the request is the top-level, we can offer nicer error messages

    if (!dependencyReference) {
      if (dependencyReference === null) {
        if (issuerLocator === topLevelLocator) {
          throw makeError(
            `MISSING_PEER_DEPENDENCY`,
            `You seem to be requiring a peer dependency ("${dependencyName}"), but it is not installed (which might be because you're the top-level package)`,
            {request, issuer, dependencyName},
          );
        } else {
          throw makeError(
            `MISSING_PEER_DEPENDENCY`,
            `Package "${issuerLocator.name}@${issuerLocator.reference}" is trying to access a peer dependency ("${dependencyName}") that should be provided by its direct ancestor but isn't`,
            {request, issuer, issuerLocator: Object.assign({}, issuerLocator), dependencyName},
          );
        }
      } else {
        if (issuerLocator === topLevelLocator) {
          throw makeError(
            `UNDECLARED_DEPENDENCY`,
            `You cannot require a package ("${dependencyName}") that is not declared in your dependencies (via "${issuer}")`,
            {request, issuer, dependencyName},
          );
        } else {
          const candidates = Array.from(issuerInformation.packageDependencies.keys());
          throw makeError(
            `UNDECLARED_DEPENDENCY`,
            `Package "${issuerLocator.name}@${issuerLocator.reference}" (via "${issuer}") is trying to require the package "${dependencyName}" (via "${request}") without it being listed in its dependencies (${candidates.join(
              `, `,
            )})`,
            {request, issuer, issuerLocator: Object.assign({}, issuerLocator), dependencyName, candidates},
          );
        }
      }
    }

    // We need to check that the package exists on the filesystem, because it might not have been installed

    const dependencyLocator = {name: dependencyName, reference: dependencyReference};
    const dependencyInformation = exports.getPackageInformation(dependencyLocator);
    const dependencyLocation = path.resolve(__dirname, dependencyInformation.packageLocation);

    if (!dependencyLocation) {
      throw makeError(
        `MISSING_DEPENDENCY`,
        `Package "${dependencyLocator.name}@${dependencyLocator.reference}" is a valid dependency, but hasn't been installed and thus cannot be required (it might be caused if you install a partial tree, such as on production environments)`,
        {request, issuer, dependencyLocator: Object.assign({}, dependencyLocator)},
      );
    }

    // Now that we know which package we should resolve to, we only have to find out the file location

    if (subPath) {
      unqualifiedPath = path.resolve(dependencyLocation, subPath);
    } else {
      unqualifiedPath = dependencyLocation;
    }
  }

  return path.normalize(unqualifiedPath);
};

/**
 * Transforms an unqualified path into a qualified path by using the Node resolution algorithm (which automatically
 * appends ".js" / ".json", and transforms directory accesses into "index.js").
 */

exports.resolveUnqualified = function resolveUnqualified(
  unqualifiedPath,
  {extensions = Object.keys(Module._extensions)} = {},
) {
  const qualifiedPath = applyNodeExtensionResolution(unqualifiedPath, {extensions});

  if (qualifiedPath) {
    return path.normalize(qualifiedPath);
  } else {
    throw makeError(
      `QUALIFIED_PATH_RESOLUTION_FAILED`,
      `Couldn't find a suitable Node resolution for unqualified path "${unqualifiedPath}"`,
      {unqualifiedPath},
    );
  }
};

/**
 * Transforms a request into a fully qualified path.
 *
 * Note that it is extremely important that the `issuer` path ends with a forward slash if the issuer is to be
 * treated as a folder (ie. "/tmp/foo/" rather than "/tmp/foo" if "foo" is a directory). Otherwise relative
 * imports won't be computed correctly (they'll get resolved relative to "/tmp/" instead of "/tmp/foo/").
 */

exports.resolveRequest = function resolveRequest(request, issuer, {considerBuiltins, extensions} = {}) {
  let unqualifiedPath;

  try {
    unqualifiedPath = exports.resolveToUnqualified(request, issuer, {considerBuiltins});
  } catch (originalError) {
    // If we get a BUILTIN_NODE_RESOLUTION_FAIL error there, it means that we've had to use the builtin node
    // resolution, which usually shouldn't happen. It might be because the user is trying to require something
    // from a path loaded through a symlink (which is not possible, because we need something normalized to
    // figure out which package is making the require call), so we try to make the same request using a fully
    // resolved issuer and throws a better and more actionable error if it works.
    if (originalError.code === `BUILTIN_NODE_RESOLUTION_FAIL`) {
      let realIssuer;

      try {
        realIssuer = realpathSync(issuer);
      } catch (error) {}

      if (realIssuer) {
        if (issuer.endsWith(`/`)) {
          realIssuer = realIssuer.replace(/\/?$/, `/`);
        }

        try {
          exports.resolveToUnqualified(request, realIssuer, {extensions});
        } catch (error) {
          // If an error was thrown, the problem doesn't seem to come from a path not being normalized, so we
          // can just throw the original error which was legit.
          throw originalError;
        }

        // If we reach this stage, it means that resolveToUnqualified didn't fail when using the fully resolved
        // file path, which is very likely caused by a module being invoked through Node with a path not being
        // correctly normalized (ie you should use "node $(realpath script.js)" instead of "node script.js").
        throw makeError(
          `SYMLINKED_PATH_DETECTED`,
          `A pnp module ("${request}") has been required from what seems to be a symlinked path ("${issuer}"). This is not possible, you must ensure that your modules are invoked through their fully resolved path on the filesystem (in this case "${realIssuer}").`,
          {
            request,
            issuer,
            realIssuer
          },
        );
      }
    }
    throw originalError;
  }

  if (unqualifiedPath === null) {
    return null;
  }

  try {
    return exports.resolveUnqualified(unqualifiedPath);
  } catch (resolutionError) {
    if (resolutionError.code === 'QUALIFIED_PATH_RESOLUTION_FAILED') {
      Object.assign(resolutionError.data, {request, issuer});
    }
    throw resolutionError;
  }
};

/**
 * Setups the hook into the Node environment.
 *
 * From this point on, any call to `require()` will go through the "resolveRequest" function, and the result will
 * be used as path of the file to load.
 */

exports.setup = function setup() {
  // A small note: we don't replace the cache here (and instead use the native one). This is an effort to not
  // break code similar to "delete require.cache[require.resolve(FOO)]", where FOO is a package located outside
  // of the Yarn dependency tree. In this case, we defer the load to the native loader. If we were to replace the
  // cache by our own, the native loader would populate its own cache, which wouldn't be exposed anymore, so the
  // delete call would be broken.

  const originalModuleLoad = Module._load;

  Module._load = function(request, parent, isMain) {
    if (!enableNativeHooks) {
      return originalModuleLoad.call(Module, request, parent, isMain);
    }

    // Builtins are managed by the regular Node loader

    if (builtinModules.has(request)) {
      try {
        enableNativeHooks = false;
        return originalModuleLoad.call(Module, request, parent, isMain);
      } finally {
        enableNativeHooks = true;
      }
    }

    // The 'pnpapi' name is reserved to return the PnP api currently in use by the program

    if (request === `pnpapi`) {
      return pnpModule.exports;
    }

    // Request `Module._resolveFilename` (ie. `resolveRequest`) to tell us which file we should load

    const modulePath = Module._resolveFilename(request, parent, isMain);

    // Check if the module has already been created for the given file

    const cacheEntry = Module._cache[modulePath];

    if (cacheEntry) {
      return cacheEntry.exports;
    }

    // Create a new module and store it into the cache

    const module = new Module(modulePath, parent);
    Module._cache[modulePath] = module;

    // The main module is exposed as global variable

    if (isMain) {
      process.mainModule = module;
      module.id = '.';
    }

    // Try to load the module, and remove it from the cache if it fails

    let hasThrown = true;

    try {
      module.load(modulePath);
      hasThrown = false;
    } finally {
      if (hasThrown) {
        delete Module._cache[modulePath];
      }
    }

    // Some modules might have to be patched for compatibility purposes

    if (patchedModules.has(request)) {
      module.exports = patchedModules.get(request)(module.exports);
    }

    return module.exports;
  };

  const originalModuleResolveFilename = Module._resolveFilename;

  Module._resolveFilename = function(request, parent, isMain, options) {
    if (!enableNativeHooks) {
      return originalModuleResolveFilename.call(Module, request, parent, isMain, options);
    }

    const issuerModule = getIssuerModule(parent);
    const issuer = issuerModule ? issuerModule.filename : process.cwd() + '/';

    const resolution = exports.resolveRequest(request, issuer);
    return resolution !== null ? resolution : request;
  };

  const originalFindPath = Module._findPath;

  Module._findPath = function(request, paths, isMain) {
    if (!enableNativeHooks) {
      return originalFindPath.call(Module, request, paths, isMain);
    }

    for (const path of paths || []) {
      let resolution;

      try {
        resolution = exports.resolveRequest(request, path);
      } catch (error) {
        continue;
      }

      if (resolution) {
        return resolution;
      }
    }

    return false;
  };

  process.versions.pnp = String(exports.VERSIONS.std);

  if (process.env.ESY__NODE_BIN_PATH != null) {
    const delimiter = require('path').delimiter;
    process.env.PATH = `${process.env.ESY__NODE_BIN_PATH}${delimiter}${process.env.PATH}`;
  }
};

exports.setupCompatibilityLayer = () => {
  // see https://github.com/browserify/resolve/blob/master/lib/caller.js
  const getCaller = () => {
    const origPrepareStackTrace = Error.prepareStackTrace;

    Error.prepareStackTrace = (_, stack) => stack;
    const stack = new Error().stack;
    Error.prepareStackTrace = origPrepareStackTrace;

    return stack[2].getFileName();
  };

  // ESLint currently doesn't have any portable way for shared configs to specify their own
  // plugins that should be used (https://github.com/eslint/eslint/issues/10125). This will
  // likely get fixed at some point, but it'll take time and in the meantime we'll just add
  // additional fallback entries for common shared configs.

  for (const name of [`react-scripts`]) {
    const packageInformationStore = packageInformationStores.get(name);
    if (packageInformationStore) {
      for (const reference of packageInformationStore.keys()) {
        fallbackLocators.push({name, reference});
      }
    }
  }

  // We need to shim the "resolve" module, because Liftoff uses it in order to find the location
  // of the module in the dependency tree. And Liftoff is used to power Gulp, which doesn't work
  // at all unless modulePath is set, which we cannot configure from any other way than through
  // the Liftoff pipeline (the key isn't whitelisted for env or cli options).

  patchedModules.set(/^resolve$/, realResolve => {
    const mustBeShimmed = caller => {
      const callerLocator = exports.findPackageLocator(caller);

      return callerLocator && callerLocator.name === 'liftoff';
    };

    const attachCallerToOptions = (caller, options) => {
      if (!options.basedir) {
        options.basedir = path.dirname(caller);
      }
    };

    const resolveSyncShim = (request, {basedir}) => {
      return exports.resolveRequest(request, basedir, {
        considerBuiltins: false,
      });
    };

    const resolveShim = (request, options, callback) => {
      setImmediate(() => {
        let error;
        let result;

        try {
          result = resolveSyncShim(request, options);
        } catch (thrown) {
          error = thrown;
        }

        callback(error, result);
      });
    };

    return Object.assign(
      (request, options, callback) => {
        if (typeof options === 'function') {
          callback = options;
          options = {};
        } else if (!options) {
          options = {};
        }

        const caller = getCaller();
        attachCallerToOptions(caller, options);

        if (mustBeShimmed(caller)) {
          return resolveShim(request, options, callback);
        } else {
          return realResolve.sync(request, options, callback);
        }
      },
      {
        sync: (request, options) => {
          if (!options) {
            options = {};
          }

          const caller = getCaller();
          attachCallerToOptions(caller, options);

          if (mustBeShimmed(caller)) {
            return resolveSyncShim(request, options);
          } else {
            return realResolve.sync(request, options);
          }
        },
        isCore: request => {
          return realResolve.isCore(request);
        }
      }
    );
  });
};

if (module.parent && module.parent.id === 'internal/preload') {
  exports.setupCompatibilityLayer();

  exports.setup();
}

if (process.mainModule === module) {
  exports.setupCompatibilityLayer();

  const reportError = (code, message, data) => {
    process.stdout.write(`${JSON.stringify([{code, message, data}, null])}\n`);
  };

  const reportSuccess = resolution => {
    process.stdout.write(`${JSON.stringify([null, resolution])}\n`);
  };

  const processResolution = (request, issuer) => {
    try {
      reportSuccess(exports.resolveRequest(request, issuer));
    } catch (error) {
      reportError(error.code, error.message, error.data);
    }
  };

  const processRequest = data => {
    try {
      const [request, issuer] = JSON.parse(data);
      processResolution(request, issuer);
    } catch (error) {
      reportError(`INVALID_JSON`, error.message, error.data);
    }
  };

  if (process.argv.length > 2) {
    if (process.argv.length !== 4) {
      process.stderr.write(`Usage: ${process.argv[0]} ${process.argv[1]} <request> <issuer>\n`);
      process.exitCode = 64; /* EX_USAGE */
    } else {
      processResolution(process.argv[2], process.argv[3]);
    }
  } else {
    let buffer = '';
    const decoder = new StringDecoder.StringDecoder();

    process.stdin.on('data', chunk => {
      buffer += decoder.write(chunk);

      do {
        const index = buffer.indexOf('\n');
        if (index === -1) {
          break;
        }

        const line = buffer.slice(0, index);
        buffer = buffer.slice(index + 1);

        processRequest(line);
      } while (true);
    });
  }
}
