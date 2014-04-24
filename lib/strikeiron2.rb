require 'savon'
require "strikeiron2/version"
require "strikeiron2/exceptions"
require "strikeiron2/configuration"
require "strikeiron2/client"
require 'strikeiron2/address'
require 'strikeiron2/jurisdiction'
require 'strikeiron2/tax_result'
require 'strikeiron2/tax_value'

module Strikeiron
  class << self
    attr_accessor :configuration
    
    def configure
      self.configuration ||= Configuration.new
      yield configuration
    end
    
    def client
      @@client ||= nil
      return @@client if !@@client.nil?
      raise Strikeiron::ConfigurationException, 'You must set up your configuration before making requests' if configuration.nil?
      @@client = Client.new configuration
    end
    
    def sales_tax(options={})
      options = options.inject({}) { |hsh,(k,v)| hsh[k.to_sym] = v; hsh }
      required_options = [:from, :to, :tax_values]
      
      # Raise an error if a required option is not defined
      raise ArgumentError, "You must pass all required options: #{required_options}" if (required_options - options.keys).length > 0
      
      data = {
        'ShipFrom' => options[:from].to_soap,
        'ShipTo' => options[:to].to_soap,
        'TaxValueRequests' => { 'TaxValueRequest' => options[:tax_values].collect(&:to_soap) }
      }
      
      response = self.client.request :get_sales_tax_value, data
      response_code = response.body[:get_sales_tax_value_response][:get_sales_tax_value_result][:service_status][:status_nbr].to_i
      
      case response_code
      when 401 then raise Strikeiron::AddressException, 'Invalid From address.'
      when 402 then raise Strikeiron::AddressException, 'Invalid To address.'
      when 403 then raise Strikeiron::TaxCategoryException, 'Invalid Taxability category.'
      when 500 then raise Strikeiron::InternalError, 'Internal Strikeiron server error.'
      end
      
      TaxResult.from_soap(response.body[:get_sales_tax_value_response][:get_sales_tax_value_result][:service_result])
    end
    
    def tax_categories
      response = self.client.request :get_sales_tax_categories
      
      # Return an empty array if the response was not successful
      return [] if response.body[:get_sales_tax_categories_response][:get_sales_tax_categories_result][:service_status][:status_nbr].to_i != 200
      
      response.body[:get_sales_tax_categories_response][:get_sales_tax_categories_result][:service_result][:sales_tax_category]
    end
    
    def remaining_hits
      response = self.client.request :get_remaining_hits
      response.body[:si_subscription_info][:remaining_hits].to_i
    end
  end
end