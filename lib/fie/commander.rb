require 'fie/state'
require 'fie/pools'
require 'redis'

module Fie
  class Commander < ActionCable::Channel::Base
    @@pools_subjects = Set.new
    @@disable_override = false

    def subscribed
      stream_from Commander.commander_name(params['identifier'])
    end

    def initialize_state(params)
      self.state = State.new \
        view_variables: params['view_variables'],
        controller_name: params['controller_name'],
        action_name: params['action_name'],
        uuid: self.params[:identifier]
    end

    def unsubscribed
      redis.del Fie::Commander.commander_name(params[:identifier])
    end

    def initialize_pools
      ActionCable.server.broadcast \
        Fie::Commander.commander_name(params[:identifier]),
        command: 'subscribe_to_pools',
        parameters: {
          subjects: @@pools_subjects.to_a
        }
    end

    def publish(subject, object)
      Fie::Pools.publish_lazy(subject, object, params[:identifier])
    end

    def state
      Marshal.load redis.get(Fie::Commander.commander_name params[:identifier])
    end

    def state=(state)
      redis.set Fie::Commander.commander_name(params[:identifier]), Marshal.dump(state)
    end

    def modify_state_using_changelog(params)
      state.update_object_using_changelog(params['objects_changelog'])
    end

    def execute_js_function(name, *arguments)
      ActionCable.server.broadcast \
        Fie::Commander.commander_name(params[:identifier]),
        command: 'execute_function',
        parameters: {
          name: name,
          arguments: arguments
        }
    end

    private
      def redis
        $redis ||= Redis.new
      end

      def method_keywords_hash(method_name, params)
        method(method_name).parameters.map do |_, parameter_name|
          [parameter_name, params[parameter_name.to_s]]
        end.to_h
      end

    class << self
      def pool(subject, &block)
        @@pools_subjects.add(subject)

        pool_name = Fie::Pools.pool_name(subject)
        define_method("#{ pool_name }_callback") do |object:, sender_uuid: nil, lazy: false|
          @connection_uuid = self.params['identifier']

          unless @connection_uuid == sender_uuid
            @published_object = Marshal.load(object)
            instance_eval(&block)
          end

          if lazy
            Fie::Pools.publish subject, Marshal.load(object), sender_uuid: @connection_uuid
          end
        end
      end

      def commander_name(connection_uuid)
        "commander_#{ connection_uuid }"
      end

      def method_added(name)
        super_commander_method_names = [
          :subscribed,
          :refresh_view, 
          :identifier,
          :state,
          :unsubscribed,
          :modify_state_using_changelog,
          :execute_js_function,
          :initialize_pools,
          :publish
        ]

        unless @@disable_override || super_commander_method_names.include?(name)
          @@disable_override = true

          restructure_subclass_method_parameters(name)

          @@disable_override = false
        end
      end

      private
        def restructure_subclass_method_parameters(method_name)
          alias_method("sub_#{ method_name }", method_name)
          remove_method(method_name)
          define_method(method_name) do |params|
            if caller = params['caller']
              @caller = { value: caller['value'], id: caller['id'], class: caller['class'] }
            end
            
            @controller_name = params['controller_name']
            @action_name = params['action_name']
            @connection_uuid = self.params['identifier']

            ['caller', 'action', 'controller_name', 'action_name'].each { |param| params.delete param }

            if params.blank?
              self.send(:"sub_#{ method_name }")
            else
              method_keywords_hash = method_keywords_hash(:"sub_#{ method_name }", params)
              self.send(:"sub_#{ method_name }", method_keywords_hash)
            end
          end
        end
    end
  end
end
