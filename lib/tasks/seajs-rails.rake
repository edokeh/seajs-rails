require 'seajs/rails/version'

namespace :seajs do
  desc "Check whether spm & spm-chaos-build is ok"
  task :test_env do
    begin
      `spm-chaos-build -h`
    rescue Errno::ENOENT
      puts 'Please intall spm-chaos-build first.'
      exit 1
    end
  end

  desc 'init setup'
  task :setup => :test_env do
    # install seajs
    path = Rails.root.join('app', 'assets', 'javascripts')
    `cd #{path} && spm install seajs@#{Seajs::Rails::SEAJS_VERSION}`

    # generate seajs config file
    File.open(Rails.root.join('config', 'seajs_config.yml'), 'w') do |f|
      config_temp = File.expand_path('../template/seajs_config.yml', __FILE__)
      templ = Erubis::Eruby.new(File.open(config_temp).read)
      f.write templ.result(:seajs_path => "seajs/seajs/#{Seajs::Rails::SEAJS_VERSION}/sea.js",
                           :family => Rails.application.class.parent_name.downcase)
    end
  end

  namespace :compile do
    task :external do
      ruby_rake_task "seajs:compile:all"
    end

    task :all => ["seajs:compile:prepare_dir",
                  "seajs:compile:generate_json",
                  "seajs:compile:build",
                  "seajs:compile:clean"]

    desc 'copy `app/assets/javascripts` to ``/public/assets/``'
    task :prepare_dir do
      cp_r Rails.root.join('app', 'assets', 'javascripts'), File.join(Rails.public_path, 'assets'), :remove_destination => true
      cp File.expand_path('../template/Gruntfile.js', __FILE__), File.join(Rails.public_path, 'assets')
    end

    desc 'generate package.json by seajs_config.yml'
    task :generate_json do
      File.open(File.join(Rails.public_path, 'assets', 'javascripts', 'package.json'), 'w') do |f|

        seajs_config = Rails.application.config.seajs
        seajs_config.load_config_from_file
        pkg = {:family => seajs_config.family, :spm => {:output => seajs_config.output}}
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
      cp_r File.join(Rails.public_path, 'assets', 'javascripts', 'sea-modules', '.'), File.join(Rails.public_path, 'assets', 'sea-modules')
      rm_rf File.join(Rails.public_path, 'assets', 'javascripts')
      rm_rf File.join(Rails.public_path, 'assets', 'Gruntfile.js')
    end
  end
end

Rake::Task["assets:precompile"].enhance do
  Rake::Task["seajs:compile:external"].invoke
end