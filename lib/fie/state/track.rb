module Fie
  module Track
    def track_changes_in_objects(object)
      if object.is_a?(Array)
        track_changes_in_array(object)
      elsif object.is_a?(Hash)
        track_changes_in_hash(object)
      elsif !object.duplicable? || object.is_a?(String) || object.is_a?(Time)
        nil
      else
        track_changes_in_object(object)
      end
    end

    def untrack_changes_in_objects(object)
      if object.is_a? Hash
        untrack_changes_in_hash(object)
      elsif object.is_a? Array
        untrack_changes_in_array(object)
      elsif !object.duplicable? || object.is_a?(String) || object.is_a?(Time)
        nil
      else
        untrack_changes_in_object(object)
      end
    end

    private
      def track_changes_in_array(object)
        state = self

        unless object.frozen?
          object.class_eval do
            alias_method('previous_[]=', '[]=')
            alias_method('previous_<<', '<<')
            alias_method('previous_push', 'push')

            define_method('[]=') do |key, value|
              send('previous_[]=', key, value)
              state.permeate
            end

            define_method('<<') do |value|
              send('previous_<<', value)
              state.permeate
            end


            define_method('push') do |value|
              send('previous_push', value)
              state.permeate
            end
          end
        end

        object.each do |value|
          track_changes_in_objects(value)
        end
      end

      def track_changes_in_hash(object)
        state = self

        unless object.frozen?
          object.class_eval do
            alias_method('previous_[]=', '[]=')
            define_method('[]=') do |key, value|
              send('previous_[]=', key, value)
              state.permeate
            end
          end
        end

        object.each do |value|
          track_changes_in_objects(value)
        end
      end

      def track_changes_in_object(object)
        state = self

        object.methods.each do |attribute_name, attribute_value|
          is_setter = attribute_name.to_s.ends_with?('=') && attribute_name.to_s.match(/[A-Za-z]/)

          if is_setter
            unless object.frozen?
              object.class_eval do
                alias_method("previous_#{attribute_name}", attribute_name)
                define_method(attribute_name) do |setter_value|
                  send("previous_#{attribute_name}", setter_value)
                  state.permeate
                end
              end
            end

            getter_name = attribute_name.to_s.chomp('=').to_sym
            object_has_getter = object.methods.include?(getter_name)
            if object_has_getter
              track_changes_in_objects object.send(getter_name)
            end
          end
        end
      end

      def untrack_changes_in_hash(hash)
        unless hash.frozen?
          hash.class_eval do
            begin
              remove_method :'previous_[]='
              remove_method :'[]='
            rescue Exception => exception
              puts exception.message
            end
          end
        end

        hash.each do |key, value|
          untrack_changes_in_objects(value)
        end
      end

      def untrack_changes_in_array(array)
        unless array.frozen?
          array.class_eval do
            begin
              remove_method :'previous_[]='
              remove_method :'previous_<<'
              remove_method :previous_push
              remove_method :'[]='
              remove_method :'<<'
              remove_method :push
            rescue Exception => exception
              puts exception.message
            end
          end
        end

        array.each do |value|
          untrack_changes_in_objects(value)
        end
      end

      def untrack_changes_in_object(object)
        object.methods.each do |attribute_name, attribute_value|
          is_setter = attribute_name.to_s.ends_with?('=') &&
            attribute_name.to_s.match(/[A-Za-z]/) &&
            !attribute_name.to_s.start_with?('previous_')

          if is_setter
            remove_tracked_object_methods(object, attribute_name) unless object.frozen?

            getter_name = attribute_name.to_s.chomp('=').to_sym
            object_has_getter = object.methods.include?(getter_name)

            untrack_changes_in_objects object.send(getter_name) if object_has_getter
          end
        end
      end

      def remove_tracked_object_methods(object, attribute_name)
        object.class_eval do
          begin
            remove_method :"previous_#{ attribute_name }"
            remove_method :"#{ attribute_name }"
          rescue Exception => exception
            puts exception.message
          end
        end
      end
  end
end
