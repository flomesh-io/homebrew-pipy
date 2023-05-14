require "language/node"

class Pipy < Formula
  desc "Programmable network proxy for the cloud, edge and IoT"
  homepage "https://flomesh.io"
  url "https://github.com/flomesh-io/pipy/archive/refs/tags/0.90.1-10.tar.gz"
  sha256 "9fcd22b5431e0f2ddb8ba9ba24e8df4c18a41e2e20c82c2ab4b643bbacc74fa1"
  license "MIT-Modern-Variant"
  head "https://github.com/flomesh-io/pipy.git", branch: "main"

  bottle do
    root_url "https://github.com/flomesh-io/homebrew-pipy/releases/download/pipy-0.70.0-2"
    sha256 big_sur:      "09582e83eb6433c6b7b06bbf492786d364493078286be9a1fb2eee50b20005f5"
    sha256 x86_64_linux: "889d03b735c4cc9eab78c0445e2770ec373a67130638fcfcb8955af70328ee24"
  end

  depends_on "cmake" => :build
  depends_on "llvm@14" => :build
  depends_on "node" => :build
  depends_on "openssl@1.1"
  depends_on "snappy"

  def install
    ENV.cxx11
    # link against system libc++ instead of llvm provided libc++
    ENV.remove "HOMEBREW_LIBRARY_PATHS", Formula["llvm"].opt_lib

    openssl = Formula["openssl@1.1"]
    snappy = Formula["snappy"]

    ENV["CI_COMMIT_SHA"] = "210802332365904374ca77b9a53f41eb911fe61b"
    ENV["CI_COMMIT_TAG"] = "0.70.0-2"
    ENV["CI_COMMIT_DATE"] = "Fri, 21 Oct 2022 11:00:52 +0800"

    system "npm", "install", *Language::Node.local_npm_install_args
    system "npm", "run", "build"

    args = %W[
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

  # test do
  #   (testpath/"hello.js").write <<~EOS
  #     pipy()
  #     .listen(8080)
  #       .serveHTTP(
  #         new Message('Hi, there!\n')
  #       )
  #   EOS
  #   system bin/"pipy", "--verify", testpath/"hello.js"
  # end
end
