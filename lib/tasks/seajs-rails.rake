require 'seajs/rails/version'
require 'erubis'

namespace :seajs do
  desc "Check whether spm & spm-chaos-build is ok"
  task :test_env do
    `spm-chaos-build -h`
    unless $?.success?
      puts 'Please intall spm-chaos-build first.'
      exit 1
    end
  end

  desc 'init setup'
  task :setup => :test_env do
    # install seajs
    path = Rails.root.join('app', 'assets', 'javascripts')
    `cd #{path} && spm install seajs@#{Seajs::Rails::SEAJS_VERSION}`
    puts "installed seajs@#{Seajs::Rails::SEAJS_VERSION}"

    # generate seajs config file
    config_path = Rails.root.join('config', 'seajs_config.yml')
    File.open(config_path, 'w') do |f|
      config_temp = File.expand_path('../template/seajs_config.yml', __FILE__)
      templ = Erubis::Eruby.new(File.open(config_temp).read)
      f.write templ.result(:seajs_path => "seajs/seajs/#{Seajs::Rails::SEAJS_VERSION}/sea.js",
                           :family => Rails.application.class.parent_name.downcase)
    end
    puts "generated config file at #{config_path}"
  end

  namespace :compile do
    task :all => ["seajs:test_env",
                  "seajs:compile:prepare_dir",
                  "seajs:compile:generate_json",
                  "seajs:compile:build",
                  "seajs:compile:clean"]

    desc 'copy `app/assets/javascripts` to ``/public/assets/``'
    task :prepare_dir do
      cp_r Rails.root.join('app', 'assets', 'javascripts'), public_assets_path, :remove_destination => true
      cp File.expand_path('../template/Gruntfile.js', __FILE__), public_assets_path
    end

    desc 'generate package.json by seajs_config.yml'
    task :generate_json do
      File.open(File.join(Rails.public_path, 'assets', 'javascripts', 'package.json'), 'w') do |f|

        seajs_config = Rails.application.config.seajs
        seajs_config.load_config_from_file
        pkg = {:family => seajs_config.family, :spm => {:output => seajs_config.output, :alias => seajs_config.alias}}
        f.write pkg.to_json
      end
    end

    desc 'run chaos-build in assets for `javascripts` dir'
    task :build do
      path = File.join(Rails.public_path, 'assets')
      `cd #{path} && spm chaos-build javascripts`

      unless $?.success?
        raise RuntimeError, "spm chaos-build failed."
      end
    end

    task :clean do
      cp_r public_assets_path('javascripts', 'sea-modules', '.'), public_assets_path('sea-modules')
      rm_rf public_assets_path('javascripts')
      rm_rf public_assets_path('Gruntfile.js')
    end

    def public_assets_path(*path)
      File.join(Rails.public_path, Rails.application.config.assets.prefix, *path)
    end
  end
end

Rake::Task["assets:precompile:primary"].enhance do
  Rake::Task["seajs:compile:all"].invoke
end