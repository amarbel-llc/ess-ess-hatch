{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/3e20095fe3c6cbb1ddcef89b26969a69a1570776";
    nixpkgs-master.url = "github:NixOS/nixpkgs/e034e386767a6d00b65ac951821835bd977a08f7";
    utils.url = "https://flakehub.com/f/numtide/flake-utils/0.1.102";
  };

  outputs = { self, nixpkgs, utils, nixpkgs-master }:
    (utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
          # sssdNssLibPath = "${pkgs.sssd}/lib/libnss_sss.so.2";

        in
        {
          packages.default = with pkgs; symlinkJoin {
            name = "ssh";

            paths = [
              openssh
              sshfs
              # sshfs-fuse
            ];

            buildInputs = [
              makeWrapper
            ];
            # --set LD_PRELOAD "${sssdNssLibPath}" \

            postBuild = ''
              programsWithConfig=(
                scp
                sftp
                ssh
                ssh-copy-id
                sshfs
              )

              for prog in "''${programsWithConfig[@]}"; do
                wrapProgram "$out/bin/$prog" \
                  --add-flags -o \
                  --add-flags 'UserKnownHostsFile=$SSH_HOME/known_hosts' \
                  --add-flags -F \
                  --add-flags '$SSH_HOME/config' \
                  --prefix PATH : $out/bin
              done
            '';
          };
        }
      )
    );
}
