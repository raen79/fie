module Fie
  class Railtie < Rails::Railtie
    initializer 'fie.load_layout_path', :after => :add_view_paths do |app|
      ActiveSupport.on_load(:action_controller) do
        append_view_path("#{Gem.loaded_specs['fie'].full_gem_path}/lib")
      end
    end

    initializer 'fie.load_javascript' do |app|
      Rails.application.config.assets.paths << "#{Gem.loaded_specs['fie'].full_gem_path}/vendor/javascript"
    end
  end
end
