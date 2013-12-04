module Wonga
  module Daemon
    class PantryEc2StopCommandHandler
      def initialize(publisher, logger)
        @publisher = publisher
        @logger = logger
      end

      def handle_message(message)
        @logger.info("Received stop message for instance: #{message["name"]} - request_id: #{message["id"]}")
        ec2 = AWS::EC2.new
        instance = ec2.instances[message['instance_id']]
        case instance.status
        when :stopped 
          @logger.info("Stopped instance: #{message["name"]} - request_id: #{message["id"]} - publishing")
          @publisher.publish message          
          return
        when :terminated
          @logger.error("Attempted to stop terminated instance: #{message["name"]} - id #{message["id"]}")
          return
        when :running
          @logger.info("Stopping instance: #{message["name"]} - request_id: #{message["id"]} - publishing")
          instance.stop
        end
        raise "Instance #{message['instance_id']} still pending"
      end
    end
  end
end
