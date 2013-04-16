# -*- mode: ruby -*-

[
  'awesome_print',
  'interactive_editor',
  'pp',
].each do |library|
  begin
    require library
  rescue LoadError
    warn "library '#{lib}' can not be loaded"
  end
end
