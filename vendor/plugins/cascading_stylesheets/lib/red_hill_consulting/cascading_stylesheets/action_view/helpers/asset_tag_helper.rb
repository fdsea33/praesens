module RedHillConsulting::CascadingStylesheets::ActionView::Helpers
  module AssetTagHelper
    STYLESHEETS_DIR = File.join(RAILS_ROOT, 'public', 'stylesheets').freeze

    def self.included(base)
      base.class_eval do
        alias_method_chain :stylesheet_link_tag, :cascade
      end
    end

    def stylesheet_link_tag_with_cascade(*sources)
      if sources.include?(:defaults)
        defaults = []

        candidates = controller.class.controller_path.split("/").inject([nil, nil]) { |candidates, candidate| candidates << (candidates.last ? File.join(candidates.last, candidate) : candidate) }
        candidates[0] = "application"
        candidates[1] = RAILS_ENV
        candidates.insert(2, controller.active_layout) if controller.active_layout
        candidates << File.join(candidates.last, controller.action_name)

        candidates.each do |source|
          defaults << source if File.exists?(File.join(STYLESHEETS_DIR, source + '.css'))
        end

        sources = sources[0..(sources.index(:defaults))] +
          defaults +
          sources[(sources.index(:defaults) + 1)..sources.length]
        sources.delete(:defaults)
      end

      stylesheet_link_tag_without_cascade(*sources)
    end
  end
end
