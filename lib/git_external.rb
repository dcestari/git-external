require 'fileutils'

class GitExternal

  def initialize
    @root_dir       = `git rev-parse --show-toplevel`.chomp
    @externals_file = "#{@root_dir}/.gitexternals"
    @ignore_file    = "#{@root_dir}/.gitignore"
    @configurations = {}
  end

  def usage
    puts "Usage: git external add <repository-url> <path> [<branch>]"
    puts "   or: git external init [--] [<path>...]"
    puts "   or: git external update [--] [<path>...]"
    puts "   or: git external cmd '<command>'"
  end

  def load_configuration
    if File.file? @externals_file
      lines = `git config -l -f #{@externals_file}`.split(/\n/)
      @configurations = parse_configuration lines
    end
  end

  def parse_configuration(lines)
    config = {}
    lines.each do |line|
      if line =~ /^external\.(.*)\.(.*)=(.*)$/
        config[$1.chomp] ||= {}
        config[$1.chomp][$2.chomp] = $3.chomp
      end
    end

    config
  end

  def print_configuration
    @configurations.each do |name, config|
      puts name
      config.each do |key, value|
        puts "\t#{key}: #{value}"
      end
    end
  end

  def normalize_url(url)
    if url =~ /^\./
      origin_url = `git config --get remote.origin.url`.chomp

      unless origin_url =~ /^\w+:\/\//
        if origin_url =~ /^([^:\/]+):([^:]+)/
          origin_url = "ssh://#{$1}/#{$2}"
        end
      end

      require 'uri'
      uri = URI.parse URI.encode origin_url
      uri.path = File.expand_path(url, uri.path)
      uri.to_s
    else
      url
    end
  end

  def init_external(url, path, branch='master')
    unless File.directory? "#{path}/.git"
      FileUtils.makedirs File.dirname(path)
      url = normalize_url url
      system "git clone #{url} #{path}"
      system "cd #{path}; git checkout --track -b #{branch} origin/#{branch}" unless branch == 'master'
    end
  end

  def update_external(url, path, branch='master')
    if File.directory? "#{path}/.git"
     `cd #{path}; git pull origin #{branch}`
    end
  end

  def command_add(url, path, branch='master')
    `git config -f #{@externals_file} --add external.#{path}.path #{path}`
    `git config -f #{@externals_file} --add external.#{path}.url #{url}`
    `git config -f #{@externals_file} --add external.#{path}.branch #{branch}`
    `echo "#{path}" >> #{@ignore_file}`
  end

  def command_rm(path)
    `git config -f #{@externals_file} --unset external.#{path}.path`
    `git config -f #{@externals_file} --unset external.#{path}.url`
    `git config -f #{@externals_file} --unset external.#{path}.branch`
    `git config -f #{@externals_file} --remove-section external.#{path}`
    `perl -pi -e 's/\\Q#{path.gsub(/\//, '\/')}\\E\n//g' #{@ignore_file}`
    File.delete @externals_file if `wc -l #{@externals_file}`.chomp.to_i == 0
  end

  def command_init
    @configurations.each do |name, config|
      puts name
      init_external config["url"], config["path"], config["branch"]
    end
  end

  def command_update
    @configurations.each do |name, config|
      update_external config["url"], config["path"], config["branch"]
    end
  end

  def command_cmd(cmd)
    @configurations.each do |name, config|
      path = config['path']
      system("echo #{path}; cd #{path}; #{cmd}")
    end
  end
end
