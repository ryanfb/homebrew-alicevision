class Alembic < Formula
  desc "Open computer graphics interchange framework"
  homepage "http://alembic.io/"
  url "https://github.com/alembic/alembic/archive/1.7.12.tar.gz"
  sha256 "6c603b87c9a3eaa13618e577dd9ef5277018cdcd09ac82d3c196ad8bed6a1b48"

  depends_on "cmake" => :build
  depends_on "hdf5"
  depends_on "ilmbase"

  def install
    ENV.cxx11
    ENV.prepend "LDFLAGS", "-lmpi" if Tab.for_name("hdf5").with? "mpi"

    cmake_args = std_cmake_args + %w[
      -DUSE_PRMAN=OFF
      -DUSE_ARNOLD=OFF
      -DUSE_MAYA=OFF
      -DUSE_PYALEMBIC=OFF
      -DUSE_HDF5=ON
      -DUSE_EXAMPLES=ON
      -DALEMBIC_ILMBASE_LINK_STATIC=ON
      -DUSE_STATIC_HDF5=ON
    ]
    system "cmake", ".", *cmake_args
    system "make"
    system "make", "test"
    system "make", "install"

    pkgshare.install "prman/Tests/testdata/cube.abc"
  end

  test do
    assert_match "root", shell_output("#{bin}/abcls #{pkgshare}/cube.abc")
  end
end
