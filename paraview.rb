class Paraview < Formula
  desc "ParaView: an open-source data analysis and visualization application"
  homepage "http://paraview.org"
  url "http://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.0&type=source&os=all&downloadFile=ParaView-v5.0.0-source.tar.gz"
  sha256 "b0ecfc8f590a696a4374752961abcf663acfc367ced8101ae4419cfbc6c60534"
  head "https://gitlab.kitware.com/paraview/paraview.git"

  bottle do
    sha256 "f3c77c1007faebe1294e72f6e431b654916ccfaa632411080932e827e5efa2bf" => :yosemite
    sha256 "ca240a0ce1d30fb2cfea1406e687b79c427b774c4a2d8539c0a4712754a03280" => :mavericks
    sha256 "1a8b184f3cfa7adf51c1cb43a8cf5a6b7297cca7da3741afa0b2074e204a744a" => :mountain_lion
  end

  option "without-opengl2", "Use legacy OpenGL 1.1 rendering backend."

  depends_on "cmake" => :build
  depends_on "boost" => :recommended
  depends_on "cgns" => :recommended
  depends_on "ffmpeg" => :recommended
  depends_on "qt" => :recommended
  depends_on :mpi => [:cc, :cxx, :optional]
  depends_on :python => :recommended

  depends_on "freetype"
  depends_on "hdf5"
  depends_on "jpeg"
  depends_on "libtiff"
  depends_on "fontconfig"
  depends_on "libpng"

  def install
    args = std_cmake_args + %W[
      -DBUILD_SHARED_LIBS=ON
      -DBUILD_TESTING=OFF
      -DMACOSX_APP_INSTALL_PREFIX:PATH=#{prefix}
      -DPARAVIEW_DO_UNIX_STYLE_INSTALLS:BOOL=OFF
      -DVTK_USE_SYSTEM_EXPAT:BOOL=ON
      -DVTK_USE_SYSTEM_FREETYPE:BOOL=ON
      -DVTK_USE_SYSTEM_HDF5:BOOL=ON
      -DVTK_USE_SYSTEM_JPEG:BOOL=ON
      -DVTK_USE_SYSTEM_LIBXML2:BOOL=ON
      -DVTK_USE_SYSTEM_PNG:BOOL=ON
      -DVTK_USE_SYSTEM_TIFF:BOOL=ON
      -DVTK_USE_SYSTEM_ZLIB:BOOL=ON
      -DVTK_LEGACY_REMOVE:BOOL=ON
      -DPARAVIEW_BUILD_PLUGIN_CDIReader:BOOL=OFF
    ]

    args << "-DPARAVIEW_BUILD_QT_GUI:BOOL=OFF" if build.without? "qt"
    args << "-DPARAVIEW_USE_MPI:BOOL=ON" if build.with? "mpi"
    args << "-DPARAVIEW_ENABLE_FFMPEG:BOOL=ON" if build.with? "ffmpeg"
    args << "-DPARAVIEW_USE_VISITBRIDGE:BOOL=ON" if build.with? "boost"
    args << "-DVISIT_BUILD_READER_CGNS:BOOL=ON" if build.with? "cgns"

    if build.without? "opengl2"
      args << "-DVTK_RENDERING_BACKEND:STRING=OpenGL"
    else
      args << "-DVTK_RENDERING_BACKEND:STRING=OpenGL2"
    end

    mkdir "build" do
      if build.with? "python"
        args << "-DPARAVIEW_ENABLE_PYTHON:BOOL=ON"
        # CMake picks up the system"s python dylib, even if we have a brewed one.
        args << "-DPYTHON_LIBRARY='#{`python-config --prefix`.chomp}/lib/libpython2.7.dylib'"
      else
        args << "-DPARAVIEW_ENABLE_PYTHON:BOOL=OFF"
      end
      args << ".."

      system "cmake", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    shell_output("#{prefix}/paraview.app/Contents/MacOS/paraview --version", 1)
  end
end
