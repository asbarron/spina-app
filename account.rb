module Spina
    class Account < ApplicationRecord
      # Simple validation for presence of name
      validates :name, presence: true
  
      # Use a hash for preferences, avoid custom serializers
      serialize :preferences, Hash
  
      # Method to access serialized attributes
      def self.serialized_attr_accessor(*args)
        args.each do |method_name|
          define_method method_name do
            self.preferences[method_name.to_sym] if self.preferences
          end
  
          define_method "#{method_name}=" do |value|
            self.preferences ||= {}
            self.preferences[method_name.to_sym] = value
          end
        end
      end
  
      # Define attributes you need to serialize
      serialized_attr_accessor :google_analytics, :google_site_verification, :facebook, :twitter, :instagram, :youtube, :linkedin, :google_plus, :theme
  
      private
  
      def bootstrap_website
        theme_config = ::Spina::Theme.find_by_name(theme)
        if theme_config
          bootstrap_navigations(theme_config)
          bootstrap_pages(theme_config)
          bootstrap_resources(theme_config)
        end
      end
    end
  end
  