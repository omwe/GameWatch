# This class will be the parent class for subclasses
require 'json'
require 'daemons'

module Applications

    class Application
        # The response codes must be sent as part of the response
        GOOD_RESPONSE_CODE  = 200
        BAD_RESPONSE_CODE   = 502    
        
        # call()
        # Inputs:
        #   [+request_in+ (CLASS)] = raw request to the app server
        # Outputs:
        #   (Array) = The response code, content type, and response body
        #NOTE DO NOT CHANGE THE NAME OF THIS FUNCTION
        def call(request_in)
            if incoming_request_valid?( request_in )
                # Send request to subclass
                response_out = get_response(request_in)
                # Return response to the application server
            else
                # Respond with 502 if this was accessed by an invalid user
                response_out = [BAD_RESPONSE_CODE, {'Content-Type' => 'text/plain'}, ["NOT AUTHORIZED\n"]]
            end
            return response_out
        end
        
        # These methods will be available to all classes ===========================
        
        # convert_json_to_hash
        # Description:  Convert JSON format to Ruby hash
        # Inputs:       json => string of JSON structure
        # Outputs:      Hash
        def convert_json_to_hash( json )
            JSON.parse( json["rack.input"].read )
        end # convert_json_to_hash

        # convert_hash_to_json
        # Description:  Convert Hash to JSON format
        # Inputs:       Hash to be converted
        # Outputs:      String in JSON format
        def convert_hash_to_json( hash )
            JSON.generate( hash )
        end

        #===========================================================================

        private

        # incoming_request_valid?
        # Description:  Verify that the JSON request was issued by Amazon
        # Inputs:       request => Hash of the request
        # Outputs:      Boolean
        def incoming_request_valid?( request )
            request.has_key?( "CONTENT_TYPE" )
        end # incoming_request_valid?

        def get_response( foo )
            raise NotImplementedError
        end
    end
end
