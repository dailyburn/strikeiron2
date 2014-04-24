module Strikeiron
  class Client
    # The location of the Strikeiron Online Sales Tax WSDL
    WSDL = 'https://wsparam.strikeiron.com/SpeedTaxSalesTax3?WSDL'
    
    def initialize(configuration)
      @configuration = configuration
      @savon_client = Savon::Client.new(:wsdl => WSDL, :ssl_version => @configuration.ssl_version, :ssl_verify_mode => @configuration.ssl_verify_mode)
    end
    
    def request(action, msg={})
      msg = { 'UserID' => @configuration.user_id, 'Password' => @configuration.password }.merge(msg)
      @savon_client.call action, :message => msg
    end
  end
end