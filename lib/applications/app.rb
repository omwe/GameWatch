# Handler for the GameWatch Application

module Applications
    class Application
        GOOD_RESPONSE_CODE = 200
        BAD_RESPONSE_CODE = 502

        #NOTE This is a required function by Thin Server
        def call( request_in )
            if incoming_request_valid?( request_in )
                response_out = get_response( request_in )
            else
                response_out = [BAD_RESPONSE_CODE, {'Content-Type' => 'text/plain'}, ["NOT AUTHORIZED\n"]]
            end
            return response_out
        end

        # Methods available to all
        def convert_json_to_hash( json )
            JSON.parse( json["rack.input"].read )
        end

        def convert_hash_to_json( hash )
            JSON.generate( hash )
        end

        private

        def incoming_request_valid?( request )
            request.has_key?( "CONTENT_TYPE" )
        end

        def get_response( foo )
            raise NotImplementedError
        end

    end
end # module
