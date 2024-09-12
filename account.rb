# app/models/spina/account.rb

module Spina
    class Account < ApplicationRecord
      include AttrJson::Record
      include AttrJson::NestedAttributes
      include Partable
      include TranslatedContent
  
      serialize :preferences, JSON
  
      after_save :bootstrap_website
  
      validates :name, presence: true
  
      def to_s
        name
      end
  
      def self.serialized_attr_accessor(*args)
        args.each do |method_name|
          define_method method_name do
            self.preferences.try(:[], method_name.to_sym)
          end
  
          define_method "#{method_name}=" do |value|
            self.preferences ||= {}
            self.preferences[method_name.to_sym] = value
          end
        end
      end
  
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
  