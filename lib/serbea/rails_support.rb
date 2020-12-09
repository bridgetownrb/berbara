# frozen_string_literal: true

require "hash_with_dot_access"

module Serbea
  module Rails
    module FrontmatterHelpers
      def set_page_frontmatter=(data)
        @frontmatter ||= HashWithDotAccess::Hash.new
        @frontmatter.update(data)
      end
    end

    module FrontmatterControllerActions
      extend ActiveSupport::Concern

      included do
        Serbea::TemplateEngine.front_matter_preamble = "self.set_page_frontmatter = local_frontmatter = YAML.load"
    
        before_action { @frontmatter ||= HashWithDotAccess::Hash.new }

        helper Serbea::Rails::FrontmatterHelpers
      end
    end

    class TemplateHandler
      def handles_encoding?; true; end

      def compile(template, source)
        "self.class.include(Serbea::Helpers);" + Tilt::SerbeaTemplate.new { source }.precompiled_template([])
      end

      def self.call(template, source = nil)
        source ||= template.source

        new.compile(template, source)
      end
    end
  end
end

Serbea::TemplateEngine.directive :form, ->(code, buffer) do
  buffer << "{%= form_with model:"
  buffer << code
  buffer << " %}"
end

Serbea::TemplateEngine.directive :_, ->(code, buffer) do
  tag_name, space, params = code.lstrip.partition(%r(\s)m)

  if tag_name.end_with?(":")
    tag_name.chomp!(":")
    tag_name = ":#{tag_name}" unless tag_name.start_with?(":")
  end

  buffer << "{%= tag.tag_string "
  buffer << tag_name << ", " << params
  buffer << " %}"
end

ActionView::Template.register_template_handler(:serb, Serbea::Rails::TemplateHandler)
