# -*- mode: ruby -*-

%w(
  awesome_print
  interactive_editor
  pp
).each do |library|
  begin
    require library
  rescue LoadError
    warn "library '#{library}' can not be loaded"
  end
end
