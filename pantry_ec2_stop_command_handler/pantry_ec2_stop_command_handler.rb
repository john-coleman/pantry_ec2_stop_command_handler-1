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
        instance.stop 
        @logger.info("Stopped instance: #{message["name"]} - request_id: #{message["id"]} - publishing")
        @publisher.publish message
      end
    end
  end
end
