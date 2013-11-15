module Wonga
  module Daemon
    class PantryEc2StopCommandHandler
      def initialize(publisher, logger)
        @publisher = publisher
        @logger = logger
      end

      def handle_message(message)
        ec2 = AWS::EC2.new
        instance = ec2.instances[message['instance_id']]
        instance.stop 
        @publisher.publish message
      end
    end
  end
end
