class Glibmm < Formula
  desc "C++ interface to glib"
  homepage "https://www.gtkmm.org/"
  url "https://download.gnome.org/sources/glibmm/2.64/glibmm-2.64.4.tar.xz"
  sha256 "405040ab257cef0c8f1b14fdf9f3f92d6e6403715b64f1b75e4b6f04dfb56284"
  license "LGPL-2.1-or-later"

  livecheck do
    url :stable
  end

  bottle do
    cellar :any
    sha256 "aaff9671885e0337aeeee7bf5c3b18a87c88fd79323bbce01f79c648a0531c87" => :big_sur
    sha256 "8b39f15570f8ec9281554ec8db93e4011ad2e13a1248047c18c7f8570a548d53" => :catalina
    sha256 "316a5f0f84491a62cf1c48a12cd4f8d9b7f7de9aa8092f72256f5114aa8730d3" => :mojave
    sha256 "7d224a2283e08715a1f7f286fcdc3e1c5cc277101bb3e2cc4bce488ec776cc02" => :high_sierra
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "libsigc++@2"

  # submitted upstream at https://gitlab.gnome.org/GNOME/glibmm/-/merge_requests/43
  patch :DATA

  def install
    ENV.cxx11

    mkdir "build" do
      system "meson", *std_meson_args, ".."
      system "ninja"
      system "ninja", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <glibmm.h>

      int main(int argc, char *argv[])
      {
         Glib::ustring my_string("testing");
         return 0;
      }
    EOS
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    libsigcxx = Formula["libsigc++@2"]
    flags = %W[
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/glibmm-2.4
      -I#{libsigcxx.opt_include}/sigc++-2.0
      -I#{libsigcxx.opt_lib}/sigc++-2.0/include
      -I#{lib}/glibmm-2.4/include
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{libsigcxx.opt_lib}
      -L#{lib}
      -lglib-2.0
      -lglibmm-2.4
      -lgobject-2.0
      -lintl
      -lsigc-2.0
    ]
    system ENV.cxx, "-std=c++11", "test.cpp", "-o", "test", *flags
    system "./test"
  end
end

__END__
diff --git a/meson.build b/meson.build
index 4d2c13a6..fd253a60 100644
--- a/meson.build
+++ b/meson.build
@@ -45,21 +45,7 @@ project_build_root = meson.current_build_dir()
 cpp_compiler = meson.get_compiler('cpp')
 is_msvc = cpp_compiler.get_id() == 'msvc'
 is_host_windows = host_machine.system() == 'windows'
-
-is_os_cocoa = false
-if not is_host_windows
-  # This test for Mac OS is copied from glib. If the result of glib's test
-  # is ever made available outside glib, use glib's result instead of this test.
-  # glib: https://bugzilla.gnome.org/show_bug.cgi?id=780309
-  # glibmm: https://bugzilla.gnome.org/show_bug.cgi?id=781947
-  is_os_cocoa = cpp_compiler.compiles(
-    '''#include <Cocoa/Cocoa.h>
-    #ifdef GNUSTEP_BASE_VERSION
-    #error "Detected GNUstep, not Cocoa"
-    #endif''',
-    name: 'Mac OS X Cocoa support'
-  )
-endif
+is_os_cocoa = host_machine.system() == 'darwin'

 python3 = import('python').find_installation()
 python_version = python3.language_version()

