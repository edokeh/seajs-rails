require 'active_support/ordered_options'
require 'yaml'

module Seajs::Rails
  class Config < ::ActiveSupport::OrderedOptions

    def initialize
      super
      # config/seajs_config.yml
      self.config_path = ::Rails.root.join('config', 'seajs_config.yml')
      # public/assets/seajs_map.json
      self.map_path = File.join(::Rails.public_path, ::Rails.application.config.assets.prefix, "seajs-map.json")
    end

    def load_config_from_file
      if File.exist?(self.config_path)
        self.merge! YAML.load_file(self.config_path).symbolize_keys
      end

      if File.exist?(self.map_path)
        self.map_json = File.open(map_path).read
        self.is_compiled = true
      else
        self.is_compiled = false
      end
    end

    def compiled?
      is_compiled
    end
  end
end
