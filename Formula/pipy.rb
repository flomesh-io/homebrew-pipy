require "language/node"

class Pipy < Formula
  desc "Programmable network proxy for the cloud, edge and IoT"
  homepage "https://flomesh.io"
  url "https://github.com/flomesh-io/pipy/archive/refs/tags/0.50.0-18.tar.gz"
  sha256 "baddaca193eb371ef854f07f00a9542bd675f3e21b29d99f7c0968deb3ad3811"
  license "MIT-Modern-Variant"
  head "https://github.com/flomesh-io/pipy.git", branch: "main"

  bottle do
    root_url "https://github.com/flomesh-io/homebrew-pipy/releases/download/pipy-0.50.0-18"
    rebuild 1
    sha256 big_sur:      "d61ef9965fa00d3863cb7904c17cda76cab7f1308b8f0396a92df4d9d4629a40"
    sha256 x86_64_linux: "b8c75a6ec85a468103e5b84ce6e2ea51aae5c4276c7d448d5611633fb06114bf"
  end

  depends_on "cmake" => :build
  depends_on "llvm" => :build
  depends_on "node" => :build
  depends_on "openssl@1.1"
  depends_on "snappy"

  def install
    ENV.cxx11
    # link against system libc++ instead of llvm provided libc++
    ENV.remove "HOMEBREW_LIBRARY_PATHS", Formula["llvm"].opt_lib

    openssl = Formula["openssl@1.1"]
    snappy = Formula["snappy"]

    ENV["CI_COMMIT_SHA"] = "95eaf9f8e263b775e98167ec94ad5458a230c527"
    ENV["CI_COMMIT_TAG"] = "0.50.0-18"
    ENV["CI_COMMIT_DATE"] = "Mon, 18 Jul 2022 15:35:52 +0800"

    system "npm", "install", *Language::Node.local_npm_install_args
    system "npm", "run", "build"

    args = %W[
      -DCMAKE_C_COMPILER=clang
      -DCMAKE_CXX_COMPILER=clang++
      -DPIPY_GUI=ON
      -DPIPY_TUTORIAL=ON
      -DCMAKE_BUILD_TYPE=Release
      -DPIPY_OPENSSL=#{openssl.opt_prefix}
      -DCMAKE_CXX_FLAGS=-I#{snappy.opt_include}
    ]

    mkdir "build" do
      system "cmake", "..", *std_cmake_args, *args
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
