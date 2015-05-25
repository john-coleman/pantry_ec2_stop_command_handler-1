module Wonga
  module Daemon
    class PantryEc2StopCommandHandler
      def initialize(publisher, aws_resource, logger)
        @publisher = publisher
        @aws_resource = aws_resource
        @logger = logger
      end

      def handle_message(message)
        @logger.info("Received stop message for instance: #{message['name']} - request_id: #{message['id']}")
        @publisher.publish message if @aws_resource.stop message
      end
    end
  end
end
