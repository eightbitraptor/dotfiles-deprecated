# Defined in /var/folders/dw/07jw8__d1w58d1jh90cnp6j00000gn/T//fish.0T97BL/configure-rvargc.fish @ line 1
function configure-rvargc
  set -lx debugflags '-ggdb3'
  set -lx optflags '-O0'
  set -lx RUBY_DEVEL 'yes'
  ../ruby/configure --prefix=~../install --disable-install-doc --with-openssl-dir=(brew --prefix)/opt/openssl
end
