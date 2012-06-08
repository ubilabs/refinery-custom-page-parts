require 'refinerycms-base'
require 'json'

module Refinery
  module CustomPageParts

    class CustomPagePart
      attr_accessor :identifier, :fields
      
      def initialize
        self.fields = Array.new
      end
      
      def field(title, type)
        fields << { :type => type, :title => title }
        
        # Inject new methods
        PagePart.class_eval do
          
          define_method("#{title}") do
            if Refinery::CustomPageParts.is_custom?(self) && Refinery::CustomPageParts.has_field?(self, title)
              Refinery::CustomPageParts.get_field_value(self, title)
            else
              raise(NoMethodError, "undefined method #{title.to_s} for #{self.class.name}")
            end
          end
          
          define_method("#{title}=") do |value|
            if Refinery::CustomPageParts.is_custom?(self) && Refinery::CustomPageParts.has_field?(self, title)
              Refinery::CustomPageParts.set_field_value(self, title, value)
            else
              raise(NoMethodError, "undefined method #{title.to_s} for #{self.class.name}")
            end
          end
          
          attr_accessible title
          
        end
      end
      
    end

    class << self
      
      attr_accessor :root
      def root
        @root ||= Pathname.new(File.expand_path('../../', __FILE__))
      end
      
      def define_page_part(options = {}, &block)
        new_part = CustomPagePart.new
        new_part.identifier = options[:identifier]

        @@custom_page_parts ||= Array.new
        
        unless @@custom_page_parts.detect { |p| p.identifier == options[:identifier] }
          @@custom_page_parts << new_part
        end
        
        block.call(new_part)
      end
      
      def get_custom_part(part)
        part_identifier = get_identifier(part)
        @@custom_page_parts ||= Array.new
        return @@custom_page_parts.detect { |p| p.identifier.to_s == part_identifier }
      end
      
      def get_identifier(part)
        return "" if part.title.blank?
        part.title.downcase.gsub(/[0-9]/, "").strip.split(" ").join("_")
      end
      
      def custom_part_fields(part)
        get_custom_part(part).fields
      end
      
      def is_custom?(part)
        return !get_custom_part(part).blank?
      end
      
      def has_field?(part, field)
        get_custom_part(part).fields.detect { |f| 
          f[:title] == field
        }
      end
      
      def get_field_value(part, field)
        prepare_body(part)
        contents = JSON.parse(part.body)
        return (contents && contents.has_key?(field.to_s)) ? contents[field.to_s] : ""
      end
      
      def set_field_value(part, field, value)
        prepare_body(part)
        contents = JSON.parse(part.body)
        contents[field.to_s] = value
        part.body = contents.to_json
      end
      
      def prepare_body(part)
        if part.body.blank?
          part.body = "{}"
        end
      
        if part.body[0..0] != '{' && part.body[-1..-1] != '}'
          # Strip out the "<p>" and "</p>" that refinery slaps in
          part.body = part.body[3..-5]
        end
      end

      def get_custom_page_parts
        @@custom_page_parts.collect { |p|
          p.identifier.to_s.gsub(/_/, " ").capitalize
        }
      end
      
    end

    class Engine < Rails::Engine
      initializer "static assets" do |app|
        app.middleware.insert_after ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
      end
      
      refinery.after_inclusion do
        load("#{Rails.root}/config/custom_page_parts_config.rb")
        puts "Loaded custom page parts"
      end
      
      config.after_initialize do
        Refinery::Plugin.register do |plugin|
          plugin.name = "custom_page_parts"
          plugin.pathname = root
          plugin.hide_from_menu = true
        end
      end
    end
  end
end
