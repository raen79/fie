require 'fie/state'
require 'fie/pools'
require 'redis'

module Fie
  class Commander < ActionCable::Channel::Base
    @@pools_subjects = Set.new
    @@disable_override = false

    def subscribed
      stream_from Commander.commander_name(params['identifier'])
      initialize_pools
    end

    def initialize_state(params)
      self.state = State.new \
        view_variables: params['view_variables'],
        controller_name: params['controller_name'],
        action_name: params['action_name'],
        uuid: self.params[:identifier]
    end

    def handle_pool_callbacks(params)
      subject = params['subject']
      object = Marshal.load(params['object'])

      run_hook :"#{subject}_pool", object
    end

    def unsubscribed
      redis.del Fie::Commander.commander_name(params[:identifier])
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

      def initialize_pools
        ActionCable.server.broadcast \
          Fie::Commander.commander_name(params[:identifier]),
          command: 'subscribe_to_pools',
          parameters: {
            subjects: @@pools_subjects.to_a
          }
      end

    class << self
      def pool(subject, &block)
        @@pools_subjects.add(subject)

        pool_name = Fie::Pools.pool_name(subject)
        define_method("#{pool_name}_callback") do |object:|
          @published_object = Marshal.load(object)
          instance_eval(&block)
        end
      end

      def commander_name(connection_uuid)
        "commander_#{connection_uuid}"
      end

      def method_added(name)
        super_commander_method_names = [:subscribed, :refresh_view, :identifier, :state, :unsubscribed, :modify_state_using_changelog]

        unless @@disable_override || super_commander_method_names.include?(name)
          @@disable_override = true

          restructure_subclass_method_parameters(name)

          @@disable_override = false
        end
      end

      private
        def restructure_subclass_method_parameters(name)
          alias_method("sub_#{name}", name)
          remove_method(name)
          define_method(name) do |params|
            @caller = params['caller'].symbolize_keys
            @controller_name = params['controller_name']
            @action_name = params['action_name']
            @connection_uuid = self.params['identifier']

            ['caller', 'action', 'controller_name', 'action_name'].each { |param| params.delete param }

            if params.blank?
              self.send(:"sub_#{name}")
            else
              self.send(:"sub_#{name}", params.symbolize_keys)
            end
          end
        end
    end
  end
end
