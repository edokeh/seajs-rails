require 'seajs/rails/config'

module Seajs
  module Rails
    class Engine < ::Rails::Engine

      config.before_configuration do
        config.seajs = Seajs::Rails::Config.new
      end

      config.before_initialize do |app|
        config = app.config

        # find the default precompile filter and modify it
        index = config.assets.precompile.find_index do |filter|
          filter.respond_to?(:call) && filter.call('sea.js.map')
        end

        if index
          # add filter，don't precompile app/javascripts/sea-modules/
          filter = Proc.new do |path|
            !File.extname(path).in?(['.js', '.css']) and !path.start_with?('sea-modules/')
          end
          config.assets.precompile[index] = filter
        end

        config.seajs.load_config_from_file
      end
    end
  end
end
