self: super: {
  zig = super.zig.overrideAttrs (old: {
    version = "0.10.0";

    src = super.fetchFromGitHub {
      owner = "ziglang";
      repo = "zig";
      rev = "fdaf9c40d6a351477aacb1af27871f3de12d485e";
      sha256 = "sha256-tV6vGH1rBB9I5blcMVS+P4uL/nOx/HCag8ooLNgJ6o4=";
    };

    nativeBuildInputs = [ super.cmake super.llvmPackages_14.llvm.dev ];

    buildInputs = [ super.libxml2 super.zlib ]
      ++ (with super.llvmPackages_14; [ libclang lld llvm ]);
  });
  zls = super.zls.overrideAttrs (old: {
    version = "0.10.0";

    src = super.fetchFromGitHub {
      owner = "zigtools";
      repo = "zls";
      rev = "cf8baa35860b1cf0ed970e160a80f5be390b0835";
      sha256 = "sha256-1UP9+OM0eBaHZ7Y8f1qtA8xc1YF158TMWN1NjyCx6SE=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [ self.zig ];
  });
}
