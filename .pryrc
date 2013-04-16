# -*- mode: ruby -*-

def __require_maybe(lib)
  require lib
rescue LoadError
  warn "library '#{lib}' can not be loaded"
end

%w(pp awesome_print interactive_editor).each &method(:__require_maybe)

if defined? ::Hirb
  Hirb.enable
  Pry.config.print = proc do |output, value|
    Hirb::View.view_or_page_output(value) || Pry::DEFAULT_PRINT.call(output, value)
  end
end

Pry.prompt = [proc { |obj, nest_level| "#{RUBY_VERSION} (#{obj}):#{nest_level} > " },
              proc { |obj, nest_level| "#{RUBY_VERSION} (#{obj}):#{nest_level} * " }]
