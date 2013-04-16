# -*- mode: ruby -*-

def __require_maybe(lib)
  require lib
rescue LoadError
  warn "library '#{lib}' can not be loaded"
end

%w(pp awesome_print interactive_editor).each &method(:__require_maybe)
