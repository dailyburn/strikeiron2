module Strikeiron #:nodoc:
  # Jurisdiction represents a breakdown of the tax calculations for the taxable region(s).
  #
  # === Attributes
  # * <tt>fips</tt> - The code assigned by the Federal Government or state agencies to uniquely identify a location.
  # * <tt>name</tt> - Name associated to the corresponding FIPS code.
  # * <tt>tax_amount</tt> - Sales tax rate for the corresponding FIPS code.
  class Jurisdiction
    attr_accessor :fips, :name, :tax_amount

    # Creates a Jurisdiction with the supplied attributes.
    def initialize(default_values = {})
      safe_keys = %w(fips name tax_amount)
      
      default_values.each do |key, value|
        next unless safe_keys.include? key.to_s # Only permit the keys defined in safe_keys
        self.send "#{key}=", value
      end
    end

    # Convert the SOAP response object to a Jurisdiction
    def self.from_soap(hash = {})
      default_values = {
        :fips       => hash['FIPS'],
        :name       => hash['Name'],
        :tax_amount => hash['SalesTaxAmount']
      }

      new(default_values)
    end
  end
end

