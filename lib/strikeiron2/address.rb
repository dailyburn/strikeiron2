module Strikeiron
  class Address
    attr_accessor :street_address, :city, :state, :zip_code

    # Creates an Address with the supplied attributes.
    def initialize(default_values = {})
      safe_keys = %w(street_address city state zip_code)
      
      default_values.each do |key, value|
        next unless safe_keys.include? key.to_s # Only permit the keys defined in safe_keys
        self.send "#{key}=", value
      end
    end

    # Convert the object to a Hash for SOAP
    def to_soap
      {
        'StreetAddress' => street_address,
        'City'          => city,
        'State'         => state,
        'ZIPCode'       => zip_code
      }
    end
        
    # Convert the object from a SOAP response to an Address object
    def self.from_soap(hash = {})
      default_values = {
        :street_address => hash['StreetAddress'],
        :city           => hash['City'],
        :state          => hash['State'],
        :zip_code       => hash['ZIPCode']
      }
      new(default_values)
    end
  end
end