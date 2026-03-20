{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/fea3b367d61c1a6592bc47c72f40a9f3e6a53e96";
    nixpkgs-master.url = "github:NixOS/nixpkgs/c7673e9a9a58dde446a5fe1d089d6cc12aa41238";
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
