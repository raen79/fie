module Fie
  module Changelog
    def update_object_using_changelog(changelog, object = self)
      unless changelog.blank?
        changelog.each do |node_name, _|
          changelog_node = changelog[node_name]
          is_not_end_of_tree = changelog_node.is_a? Hash

          if is_not_end_of_tree
            traverse \
              changelog: changelog,
              object: object,
              node_name: node_name,
              changelog_node: changelog_node
          else
            update_object_value \
              object: object,
              node_name:node_name,
              value: changelog_node
          end
        end
      end
    end

    private
      def traverse(changelog:, object:, node_name:, changelog_node:)
        if object.is_a?(Array)
          node_name = node_name.to_i
          object_node = object[node_name]
        elsif object.is_a?(Hash)
          string_in_hash = object.keys.include? node_name
          symbol_in_hash = object.keys.include? node_name.to_sym
          
          if string_in_hash
            object_node = object[node_name]
          elsif symbol_in_hash
            object_node = object[node_name.to_sym]
          end          
        else
          object_node = object.send(node_name)
        end

        update_object_using_changelog(changelog_node, object_node)
      end

      def update_object_value(object:, node_name:, value:)
        if object.is_a?(Array)
          node_name = node_name.to_i if object.is_a?(Array)
          object[node_name] = value
        elsif object.is_a?(Hash)
          string_in_hash = object.keys.include? node_name
          symbol_in_hash = object.keys.include? node_name.to_sym

          if string_in_hash
            object[node_name] = value
          elsif symbol_in_hash
            object[node_name.to_sym] = value
          end
        else
          object.send("#{node_name}=", value)
        end
      end
  end
end
