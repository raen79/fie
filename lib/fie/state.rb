require 'redis'
require 'fie/state/track'
require 'fie/state/changelog'

module Fie
  class State
    include Fie::Track
    include Fie::Changelog

    def initialize(view_variables: nil, controller_name:, action_name:, uuid:, attributes: nil)
      @controller_name = controller_name
      @action_name = action_name
      @uuid = uuid
      @view_variables = view_variables
      
      if !view_variables.nil?
        initialize_getters_and_setters(view_variables)
      else
        initialize_getters_and_setters(attributes, variables_from_view: false)
      end

      track_changes_in_objects(self)
    end

    def attributes
      instance_variables_names = instance_variables - [ :@controller_name, :@action_name, :@uuid, :@view_variables ]

      attribute_entries_array = instance_variables_names.map do |instance_variable_name|
        attribute_name = instance_variable_name.to_s.gsub('@', '')
        attribute_value = instance_variable_get(instance_variable_name)

        [attribute_name, attribute_value]
      end

      attribute_entries_array.to_h
    end

    def inspect
      object_reference = self.to_s
      pretty_print = "\e[0;33m#{object_reference[0..-2]}\e[0m "

      attributes.each do |name, value|
        if value.is_a? String
          value = "\e[0;31m#{value.inspect}\e[0m"
        else
          value = "\e[1;34m#{value.inspect}\e[0m"
        end
        
        pretty_print += "\n #{name}: #{value}"
      end

      pretty_print += '>'

      pretty_print
    end

    def permeate
      redis.set Fie::Commander.commander_name(@uuid), Marshal.dump(self)

      rendered_view = ApplicationController.render \
        "#{@controller_name}/#{@action_name}",
        assigns: attributes.merge(fie_controller_name: @controller_name, fie_action_name: @action_name),
        layout: 'fie'

      ActionCable.server.broadcast \
        Fie::Commander.commander_name(@uuid),
        command: 'refresh_view',
        parameters: {
          html: rendered_view
        }
    end

    def _dump(level)
      untrack_changes_in_objects(self)

      Marshal.dump({
        controller_name: @controller_name,
        action_name: @action_name,
        uuid: @uuid,
        attributes: attributes
      })
    end

    def self._load(string_params)
      params = Marshal.load(string_params)
      new(params)
    end

    private
      def unmarshal_value(value)
        encryptor = ActiveSupport::MessageEncryptor.new Rails.application.credentials[:secret_key_base]
        decrypted_value = encryptor.decrypt_and_verify(value)
        Marshal.load(decrypted_value)
      end

      def initialize_getters_and_setters(variables, variables_from_view: true)
        variables.delete('fie_controller_name') if variables['fie_controller_name']
        variables.delete('fie_action_name') if variables['fie_action_name']

        variables.each do |variable_name, variable_value|
          self.class_eval do
            define_method(variable_name) do
              instance_variable_get("@#{variable_name}")
            end
  
            define_method("#{variable_name}=") do |value|
              instance_variable_set("@#{variable_name}", value)
            end
          end
  
          if variables_from_view
            instance_variable_set("@#{variable_name}", unmarshal_value(variable_value))
          else
            instance_variable_set("@#{variable_name}", variable_value)
          end
        end
      end

      def redis
        $redis ||= Redis.new
      end

      def initialize_from_attributes(attributes)
        unless attributes.blank?
          attributes.each do |attribute_name, attribute_value|
            instance_variable_set("@#{attribute_name}", attribute_value)
          end
        end
      end
  end
end
