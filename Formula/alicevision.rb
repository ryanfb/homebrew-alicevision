class Alicevision < Formula
  desc "Photogrammetric Computer Vision Framework"
  homepage "https://alicevision.github.io"
  url "https://github.com/alicevision/AliceVision/archive/v2.2.0.tar.gz"
  sha256 "157d06d472ffef29f08a781c9df82daa570a49bb009e56a2924a3bd2f555ef50"

  option "without-cuda", "Disable CUDA support"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "ceres-solver"
  depends_on "eigen"
  depends_on "flann"
  depends_on "geogram"
  depends_on "glpk"
  depends_on "open-mesh"
  depends_on "openexr"
  depends_on "openimageio"
  depends_on "ryanfb/alicevision/alembic"
  depends_on "zlib"

  resource "osi_clp" do
    url "https://github.com/alicevision/osi_clp/archive/38ab28d1c5a53de13c8684cdc272b1deb8cef459.tar.gz"
    sha256 "3c088a54e920a168ce994933728be914659edac67d85ecc67e19502c64567f09"
  end

  resource "MeshSDFilter" do
    url "https://github.com/ryanfb/MeshSDFilter/archive/fa1f0c6c6e2f1c2f4ee03873d6205877603fe968.tar.gz"
    sha256 "4604e0b8ca0835441e4deaf83d71387a7240734c5f6eadac0c78858024b40e6b"
  end

  resource "nanoflann" do
    url "https://github.com/alicevision/nanoflann/archive/cc77e17934441dc82b33fd00e0a8a1398f24c928.tar.gz"
    sha256 "c39a2c2d6faa6b693e795ce483a8aea2e8e487c19e17cc2c83cbe4961c9df963"
  end

  patch :DATA

  def install
    ENV.cxx11

    args = std_cmake_args

    args << "-DCMAKE_BUILD_TYPE=Release"
    args << "-DBoost_NO_BOOST_CMAKE=ON"
    args << "-DALICEVISION_USE_OPENMP:BOOL=OFF"
    args << "-DALICEVISION_USE_ALEMBIC:BOOL=ON"
    args << "-DALICEVISION_USE_MESHSDFILTER:BOOL=OFF"
    args << "-DALICEVISION_USE_CUDA:BOOL=OFF" if build.without? "cuda" 
    args << "-DALICEVISION_BUILD_DOC:BOOL=OFF"
    args << "-DFLANN_INCLUDE_DIR_HINTS:PATH=#{Formula["flann"].opt_include}"
    args << "-DCMAKE_INSTALL_PREFIX=#{prefix}"

    resource("osi_clp").stage buildpath/"src/dependencies/osi_clp"
    resource("MeshSDFilter").stage buildpath/"src/dependencies/MeshSDFilter"
    resource("nanoflann").stage buildpath/"src/dependencies/nanoflann"

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end
  end

  test do
    system "#{bin}/aliceVision_cameraInit"
  end
end

__END__
diff --git a/src/CMakeLists.txt b/src/CMakeLists.txt
index 7ea43b50..af902308 100644
--- a/src/CMakeLists.txt
+++ b/src/CMakeLists.txt
@@ -195,12 +195,19 @@ endif()
 # ==============================================================================
 # Check C++11 support
 # ==============================================================================
-include(CXX11)
-check_for_cxx11_compiler(CXX11_COMPILER)
+#include(CXX11)
+#check_for_cxx11_compiler(CXX11_COMPILER)
+
+if(APPLE)
+  set(CMAKE_C_ARCHIVE_CREATE   "<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>")
+  set(CMAKE_CXX_ARCHIVE_CREATE "<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>")
+  set(CMAKE_C_ARCHIVE_FINISH   "<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>")
+  set(CMAKE_CXX_ARCHIVE_FINISH "<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>")
+endif(APPLE)

-if(NOT CXX11_COMPILER)
-  message(FATAL_ERROR "The compiler does not support the CXX11 standard.")
-endif(NOT CXX11_COMPILER)
+#if(NOT CXX11_COMPILER)
+#  message(FATAL_ERROR "The compiler does not support the CXX11 standard.")
+#endif(NOT CXX11_COMPILER)
 set(CMAKE_CXX_STANDARD 11)
 set(CMAKE_CXX_STANDARD_REQUIRED ON)
 
@@ -794,6 +794,7 @@ set(ALICEVISION_INCLUDE_DIRS
         ${CMAKE_CURRENT_SOURCE_DIR}
         ${generatedDir}
         ${CMAKE_CURRENT_SOURCE_DIR}/dependencies
+        ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/MeshSDFilter
         ${LEMON_INCLUDE_DIRS}
         ${EIGEN_INCLUDE_DIRS}
         ${CERES_INCLUDE_DIRS}
diff --git a/src/software/convert/main_convertLDRToHDR.cpp b/src/software/convert/main_convertLDRToHDR.cpp
index 68204b61..a2cc97ae 100644
--- a/src/software/convert/main_convertLDRToHDR.cpp
+++ b/src/software/convert/main_convertLDRToHDR.cpp
@@ -288,7 +288,7 @@ void recoverSourceImage(const image::Image<image::RGBfColor>& hdrImage, hdr::rgb
     float offset[3];
     for(int i=0; i<3; ++i)
         offset[i] = std::abs(meanRecovered[i] - meanVal[i]);
-    ALICEVISION_LOG_INFO("Offset between target source image and recovered from hdr = " << offset);
+    ALICEVISION_LOG_INFO("Offset between target source image and recovered from hdr = " << boost::lexical_cast<std::string>(offset));
 }
 
 
