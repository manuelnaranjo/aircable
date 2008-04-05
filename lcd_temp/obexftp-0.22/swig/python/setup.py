from distutils.core import setup, Extension
import string

setup(name		= 'obexftp',
      version		= '0.22',
      author		= 'Christian Zuckschwerdt',
      author_email	= 'zany@triq.net',
      url		= 'http://www.openobex.org/',
      description	= 'ObexFTP python bindings',
      download_url	= 'http://triq.net/obexftp/',
      package_dir	= {'obexftp': '.'},
      packages		= [ 'obexftp' ],
      ext_package	= 'obexftp',
      ext_modules	= [Extension('_obexftp', ['python_wrap.c'],
					include_dirs=['../..'],
					extra_link_args = string.split('-L../../obexftp/.libs -lobexftp -L../../multicobex/.libs -lmulticobex -L../../bfb/.libs -lbfb -lopenobex -lbluetooth   -lbluetooth   '),
# static:				extra_link_args = string.split('../../obexftp/.libs/libobexftp.a ../../multicobex/.libs/libmulticobex.a ../../bfb/.libs/libbfb.a -lopenobex -lbluetooth   -lbluetooth   '),
			)],
      )
