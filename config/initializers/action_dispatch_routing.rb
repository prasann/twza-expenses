# encoding: utf-8

require 'action_dispatch/routing/route_set'

module ActionDispatch
  module Routing
    class RouteSet
      def url_for_with_anchor(options = nil)
        if options.present? && options.is_a?(Hash)
          options.symbolize_keys! if options.respond_to?(:symbolize_keys!)
          options.merge!(:anchor => options[:controller]) if options.has_key?(:action) && options[:action] == 'index'
        end
        url_for_without_anchor(options)
      end

      alias_method_chain :url_for, :anchor
    end
  end
end
