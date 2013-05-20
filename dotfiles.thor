require 'pathname'

class Dotfiles < Thor
  DOT_ROOT = Pathname.new(File.expand_path('..', __FILE__))
  HOME = Pathname.new(Dir.home)

  desc 'list', 'list managed files'
  def list
    Pathname.glob(DOT_ROOT + '**/*', File::FNM_DOTMATCH).select { |file|
      linking_valid?(HOME + file.relative_path_from(DOT_ROOT), file)
    }.each do |file|
      say "~/#{file.relative_path_from(DOT_ROOT)}"
    end
  end

  desc 'add FILENAME...', 'add files to repository'
  def add(*filenames)
    filenames.each do |fn|
      original = Pathname.new(File.expand_path(fn))
      new = DOT_ROOT + original.relative_path_from(HOME)

      move_and_link original, new
    end
  end

  desc 'remove FILENAME...', 'remove files from repository'
  def remove(*filenames)
    filenames.each do |fn|
      location = Pathname.new(File.expand_path(fn))
      old = HOME + location.relative_path_from(DOT_ROOT)

      remove_link old, location
    end
  end

  no_commands do
    # Delete start, then its parent, and so on.
    # Stop on first non-empty directory.
    def delete_empty_directories(start)
      start.ascend do |dir|
        begin
          dir.delete
        rescue SystemCallError
          break                           # not empty
        end
      end
    end

    def move_and_link(source, new_location)
      return unless source.exist?

      new_location.dirname.mkpath

      source.rename new_location
      source.make_symlink new_location
    end

    def remove_link(original, new)
      return unless linking_valid?(original, new)

      original.delete
      new.rename original

      delete_empty_directories new.dirname
    end

    def linking_valid?(from, to)
      return false unless to.exist? && from.exist?
      return false unless from.symlink? && from.readlink == to
      true
    end
  end
end
