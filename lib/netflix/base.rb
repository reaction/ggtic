module Netflix
  class Base
    
    #-----------------
    # Class Methods
    #-----------------
  
    class << self
      cattr_accessor :host, :protocol, :base_url, :debug, :consumer_key, :consumer_secret, :token_secret, :oauth_version, :retry_times

      # Non-Authenticated Calls (Consumer Key Only)
      def request method="GET", path="/", params={}
        params[:oauth_consumer_key] = consumer_key
        url = URI.escape "#{base_url}/#{path}?#{params.to_param}"

        response = nil
        seconds = Benchmark.realtime { response = open url }
        puts "  \e[4;36;1mREQUEST (#{sprintf("%f", seconds)})\e[0m   \e[0;1m#{url}\e[0m"# if debug
        response.is_a?(String) ? response : response.read
      rescue => e
        puts "  \e[4;36;1mERROR\e[0m   \e[0;1m#{url}\e[0m"# if debug
        raise e
      end

      # Signed Requests (Consumer Key plus Signature)
      def signed_request method="GET", path="/", params={}
        retries = 0
        begin
          params[:oauth_consumer_key]     ||= consumer_key
          params[:oauth_nonce]            ||= nonce
          params[:oauth_signature_method] ||= "HMAC-SHA1"
          params[:oauth_timestamp]        ||= Time.now.to_i + 5
          params[:oauth_version]          ||= oauth_version

          oauth_params = params.to_param # per oauth, automagically alphabetizes the params
          oauth_base_string = "#{e method}&#{e base_url}#{e '/'}#{e path}&#{e oauth_params}"
          signature = Base64.encode64(HMAC::SHA1.digest(secrets, oauth_base_string)).chomp.gsub(/\n/,'')
          url = "#{base_url}/#{path}?#{params.to_param}&oauth_signature=#{e signature}"

          response = nil
          seconds = Benchmark.realtime { response = open url }
          puts "  \e[4;36;1mREQUEST (#{sprintf("%f", seconds)})\e[0m   \e[0;1m#{url}\e[0m"# if debug
          response.is_a?(String) ? response : response.read
        rescue OpenURI::HTTPError => e
          puts "  \e[4;36;1mERROR\e[0m   \e[0;1m#{url}\e[0m"# if debug
          
          case e.message
          when "401 Unauthorized"
            if retries < self.retry_times
              sleep(rand(1))
              retries += 1
              retry 
            end
          end
          raise e
        end
      end
      
      # Protected Requests (Consumer Key, Signature, and Access Token)
      def protected_request
        # TODO
      end

    
      protected
        def e(str)
          CGI.escape(str)
        end

        def nonce
          rand(1_500_000_000)
        end

        def secrets
          "#{e consumer_secret}&#{e token_secret}" 
        end

        def settings
          @settings ||= YAML.load(File.open(File.dirname(__FILE__)+'/../../config/settings.yml'))
        end
    end
  
    # These are the default settings for the Base class. Change them, even per subclass if needed.
    self.host = "api.netflix.com"
    self.protocol = "http"
    self.base_url = "#{protocol}://#{host}" # just a shortcut
    self.oauth_version = 1.0
    self.consumer_key = settings['key'].strip
    self.consumer_secret = settings['secret'].strip
    self.token_secret = "" # get from an oauth request
    self.debug = true if ENV['DEBUG']
    self.retry_times = 0

    #-----------------
    # Instance Methods
    #-----------------
    def initialize(values={})
      values.each { |k, v| send "#{k}=", v }
    end

    # Copied from ActiveRecord::Base
    def attribute_for_inspect(attr_name)
      value = send(attr_name)

      if value.is_a?(String) && value.length > 50
        "#{value[0..50]}...".inspect
      elsif value.is_a?(Date) || value.is_a?(Time)
        %("#{value.to_s(:db)}")
      else
        value.inspect
      end
    end
  end
end
