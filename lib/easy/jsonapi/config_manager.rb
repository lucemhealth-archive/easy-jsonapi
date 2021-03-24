# frozen_string_literal: true

require 'easy/jsonapi/config_manager/config'

module JSONAPI

  # Manages user configuration options
  class ConfigManager

    include Enumerable

    # Config Manager always has an internal global config
    def initialize
      @class_type = JSONAPI::ConfigManager::Config
      @config_manager = { global: JSONAPI::ConfigManager::Config.new }
    end

    # Yield the block given on all the config in the config_manager
    def each(&block)
      return @config_manager.each(&block) if block_given?
      to_enum(:each)
    end

    # Are any user configurations set?
    def default?
      (@config_manager.size == 1 && @config_manager[:global].default?) || all_configs_default?
    end

    # Does the config_manager's internal hash include this res_name?
    # @param res_name [String | Symbol]  The res_name to search for in the hash
    def include?(res_name)
      @config_manager.include?(res_name.to_sym)
    end

    # Add an config to the config_manager
    # @param config [Object]
    def add(res_name, config)
      raise "Cannot add a config that is not #{@class_type}" unless config.is_a? @class_type
      insert(res_name, config)
    end

    # Adds an config to config_manager's internal hash
    def insert(res_name, config)
      if include?(res_name.to_sym)
        raise "The resource type: #{res_name}, already has an config associated with it. " \
              'Remove existing config first.'
      end
      set(res_name, config)
    end

    # Overwrites the config associated w a given res_name, or adds an association if no config is already associated.
    def set(res_name, config)
      raise "Cannot add a config that is not #{@class_type}" unless config.is_a? @class_type
      @config_manager[res_name.to_sym] = config
    end

    # Alias to #set
    # @param (see #set)
    # @param (see #set)
    def []=(res_name, config)
      set(res_name, config)
    end

    # @param (see #remove)
    # @return [JSONAPI::ConfigManager::Config | nil] The appropriate Item object if it exists
    def get(res_name)
      @config_manager[res_name.to_sym]
    end

    # Alias to #get
    # @param (see #get)
    # @param (see #get)
    def [](res_name)
      get(res_name)
    end

    # Remove an config from the config_manager
    # @param (see #include)
    # @return [JSONAPI::ConfigManager::Config | nil] the deleted config object if it exists
    def remove(res_name)
      if res_name.to_s == 'global'
        raise "Cannot remove global config"
      end
      @config_manager.delete(res_name.to_sym)
    end

    # @return [Integer] The number of config in the config_manager
    def size
      configs.size
    end

    # @return [Array<Symbol>] The names of the resource types the configs belong to
    def configs
      c_arr = []
      @config_manager.each_key do |res_type|
        c = self[res_type]
        unless c.default?
          c_arr << res_type
        end
      end
      c_arr
    end

    # Used to print out the config_manager object with better formatting
    # return [String] The config_manager object contents represented as a formatted string
    def to_s
      to_return = '{ '
      is_first = true
      each do |k, config|
        if is_first
          to_return += "#{k}: #{config}"
          is_first = false
        else
          to_return += ", #{k}: #{config}"
        end
      end
      to_return += ' }'
    end

    private

    # Gets the config_manager object whose hash res_name matches the method_name called
    # @param method_name [Symbol] The name of the method called
    # @param args If any arguments were passed to the method called
    # @param block If a block was passed to the method called
    def method_missing(method_name, *args, &block)
      super unless @config_manager.include?(method_name)
      get(method_name)
    end

    # Whether or not method missing should be called.
    def respond_to_missing?(method_name, *)
      @config_manager.include?(method_name) || super
    end

    # All of the included configs are set to default?
    # @return [TrueClass | FalseClass]
    def all_configs_default?
      res = true
      @config_manager.each_value { |c| res &= c.default? }
      res
    end
  end
end
