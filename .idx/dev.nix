{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-23.11"; # or "unstable"
  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.flutter
    pkgs.cmake
  ];
  # Sets environment variables in the workspace
  env = {};
  # Fast way to see what's going on in the workspace
  pre-init = ''
    echo "Welcome to Project IDX!"
    ls -la
  '';
}
