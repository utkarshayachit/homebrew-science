require 'formula'

class Paraview < Formula
  homepage 'http://paraview.org'
  url "http://www.paraview.org/files/v4.2/ParaView-v4.2.0-source.tar.gz"
  version '4.2.0'
  sha1 '77cf0e3804eb7bb91d2d94b10bd470f4'

  head 'git://paraview.org/ParaView.git', :using => :git, :tag => 'master'

  depends_on 'cmake' => :build

  depends_on 'boost' => :recommended
  depends_on 'cgns' => :recommended
  depends_on 'ffmpeg' => :recommended
  depends_on 'qt' => :recommended
  depends_on :mpi => [:cc, :cxx, :optional]
  depends_on :python => :recommended

  depends_on 'matplotlib' => [:python, :optional]

  depends_on 'freetype'
  depends_on 'hdf5'
  depends_on 'jpeg'
  depends_on 'libtiff'
  depends_on :fontconfig
  depends_on :libpng

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
    ]

    args << "-DPARAVIEW_BUILD_QT_GUI:BOOL=OFF" if !build.with? 'qt'
    args << '-DPARAVIEW_USE_MPI:BOOL=ON' if build.with? :mpi
    args << '-DPARAVIEW_ENABLE_FFMPEG:BOOL=ON' if build.with? 'ffmpeg'
    args << '-DPARAVIEW_USE_VISITBRIDGE:BOOL=ON' if build.with? 'boost'
    args << '-DVISIT_BUILD_READER_CGNS:BOOL=ON' if build.with? 'cgns'
    mkdir 'build' do
      if build.with? 'python'
        args << '-DPARAVIEW_ENABLE_PYTHON:BOOL=ON'
        # CMake picks up the system's python dylib, even if we have a brewed one.
        args << "-DPYTHON_LIBRARY='#{%x(python-config --prefix).chomp}/lib/libpython2.7.dylib'"
      else
        args << '-DPARAVIEW_ENABLE_PYTHON:BOOL=OFF'
      end
      args << '..'

      system 'cmake', *args
      system 'make'
      system 'make', 'install'
    end
  end

  test do
    system '#{prefix}/paraview.app/Contents/MacOS/paraview --version'
  end
end
