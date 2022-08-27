self: super: {
  zig = super.zig.overrideAttrs (old: {
    version = "0.10.0";

    src = super.fetchFromGitHub {
      owner = "ziglang";
      repo = "zig";
      rev = "8bcb962ada2ea5cfeeff303e1063937ee13af6ad";
      sha256 = "sha256-DPv/Y/b867lbWBHNMUxTfNClSnck9hz/JNWZFVcDI8U=";
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
      rev = "2ac8ab6ce92869c71aaf774417e02ed5bc753c52";
      sha256 = "sha256-KeBmn/fXFMleWheGouLrMmbUrb8zgvXeG9hELlEJqM4=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [ self.zig ];
  });
}
