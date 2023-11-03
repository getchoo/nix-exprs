alias b := build
alias dr := dry-run
alias sw := switch
alias t := test
alias u := update

rebuildArgs := "--verbose"
rebuild := if os() == "macos" { "darwin-rebuild" } else { "nixos-rebuild" }
asRoot := if os() == "linux" { "true" } else { "false" }

default:
    @just --choose

[private]
rebuild subcmd root="false":
    {{ if root == "true" { "sudo " } else { "" } }}{{ rebuild }} {{ subcmd }} {{ rebuildArgs }} --flake .

build:
    @just rebuild build

dry-run:
    @just rebuild dry-run

switch:
    @just rebuild switch {{ asRoot }}

test:
    @just rebuild test {{ asRoot }}

update:
    nix flake update --commit-lock-file
