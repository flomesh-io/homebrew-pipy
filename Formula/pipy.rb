require "language/node"

class Pipy < Formula
  desc "Programmable network proxy for the cloud, edge and IoT"
  homepage "https://flomesh.io"
  url "https://github.com/flomesh-io/pipy/archive/refs/tags/0.30.0-23.tar.gz"
  sha256 "da72407e31f9dc5daccea17a88ae25c04fd904539cd2104b02a0ef1b36990ac7"
  license "MIT-Modern-Variant"
  head "https://github.com/flomesh-io/pipy.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "llvm" => :build
  depends_on "node" => :build
  depends_on "openssl@1.1" => :build

  def install
    openssl = Formula["openssl@1.1"]

    ENV["CI_COMMIT_SHA"] = "01e07372d15efb6cebd8723d612791c45c9f9dc4"
    ENV["CI_COMMIT_TAG"] = "0.30.0-23"
    ENV["CI_COMMIT_DATE"] = "Wed, 23 Mar 2022 12:51:52 +0800"

    system "npm", "install", *Language::Node.local_npm_install_args
    system "npm", "run", "build"

    mkdir "build" do
      system "cmake", "..", *std_cmake_args,
                            "-DCMAKE_C_COMPILER=clang",
                            "-DCMAKE_CXX_COMPILER=clang++",
                            "-DPIPY_GUI=ON",
                            "-DPIPY_TUTORIAL=ON",
                            "-DCMAKE_BUILD_TYPE=Release",
                            "-DPIPY_OPENSSL=#{openssl.opt_prefix}"
      system "make"
    end

    bin.install "bin/pipy"
  end

  test do
    (testpath/"hello.js").write <<~EOS
      pipy()

      .listen(8080)
        .serveHTTP(
          new Message('Hi, there!\n')
        )
    EOS
    system bin/"pipy", "--verify", testpath/"hello.js"
  end
end
