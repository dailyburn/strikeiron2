module Strikeiron
  class Configuration
    attr_accessor :user_id, :password, :ssl_version, :ssl_verify_mode
    
    def initialize
      # set default options (can be overwritten in configure block)
      self.ssl_version = :TLSv1
      self.ssl_verify_mode = :none
    end
  end
end
