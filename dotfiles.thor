require 'pathname'

class Dotfiles < Thor
  DOT_ROOT = Pathname.new(File.expand_path('..', __FILE__))
  HOME = Pathname.new(Dir.home)

  desc 'list', 'list managed files'
  def list
    Pathname.glob(DOT_ROOT + '**/*', File::FNM_DOTMATCH).select { |file|
      rel_path = file.relative_path_from(DOT_ROOT)
      link = HOME + rel_path
      link.symlink? && link.readlink == file
    }.each do |file|
      puts "~/#{file.relative_path_from(DOT_ROOT)}"
    end
  end

  desc 'add FILENAME...', 'add files to repository'
  def add(*filenames)
    original_locations = filenames.map do |fn|
      Pathname.new(File.expand_path(fn))
    end

    check_if_all_exist original_locations

    new_locations = original_locations.map do |ol|
      DOT_ROOT + ol.relative_path_from(HOME)
    end

    original_locations.zip(new_locations) do |o, n|
      n.dirname.mkpath unless n.dirname.exist?

      o.rename n
      o.make_symlink n
    end
  end

  desc 'remove FILENAME...', 'remove files from repository'
  def remove(*filenames)
    locations = filenames.map do |fn|
      Pathname.new(File.expand_path(fn))
    end

    check_if_all_exist locations
    check_if_all_managed locations

    old_locations = locations.map do |loc|
      HOME + loc.relative_path_from(DOT_ROOT)
    end

    check_all_symlinks(old_locations, locations)

    locations.zip(old_locations) do |l, o|
      o.delete
      l.rename o

      l.dirname.ascend do |dir|
        begin
          dir.delete
        rescue SystemCallError
          break                           # not empty
        end
      end
    end
  end


  no_commands do

    def check_if_all_exist(pathnames)
      non_existant_files = pathnames.reject(&:exist?)

      unless non_existant_files.empty?
        die "following files do not exist:\n" +
          non_existant_files.join("\n")
      end
    end

    def check_if_all_managed(pathnames)
      non_managed_files = pathnames.reject { |l|
        parents = []
        l.ascend { |d| parents << d }

        parents.include?(DOT_ROOT)
      }

      unless non_managed_files.empty?
        die "following files are not managed:\n" +
          non_managed_files_files.join("\n")
      end
    end

    def check_all_symlinks(from, to)
      non_symlinks = from.reject(&:symlink?)

      unless non_symlinks.empty?
        die "following files are not symlinks:\n" +
          non_symlinks.join("\n")
      end

      invalid_symlinks = from.zip(to).each_with_object([]) do |(f, t), ary|
        ary << f unless f.readlink == t
      end

      unless invalid_symlinks.empty?
        die "following symlinks are pointing to the wrong place:\n" +
          invalid_symlinks.join("\n")
      end
    end

    def die(message)
      warn message
      exit 1
    end

  end
end
