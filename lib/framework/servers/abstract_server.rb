module Framework
    class AbstractServer
        attr_reader :stopping, :running

        # Allow clean interrupt
        def initialize(&block)
            @stopping = false
            @running = false
            shutdown_on_interrupt
            yield(configuration) if block.given?
        end #initialize

        def configuration
            @configuration ||= {}
        end

        def start
            @running = true
            start_server
            @running = false
            @stopping = false
        end

        def daemonize
            daemonize_server
        end

        def stop
            @stopping = true
            stop_server
        end

        def log(message, level=:info)
            fail NotImplementedError
        end

        private

        def daemonize_server
            fail NotImplementedError
        end

        def start_server
            fail NotImplementedError
        end

        def stop_server
            fail NotImplementedError
        end
        
        def shutdown_on_interrupt
            trap('SIGINT') {shutdown unless @stopping if @running}
        end

        def shutdown
            print "\r"
            log('Shutdown signal received!')
            stop
        end

    end # class
end # module
