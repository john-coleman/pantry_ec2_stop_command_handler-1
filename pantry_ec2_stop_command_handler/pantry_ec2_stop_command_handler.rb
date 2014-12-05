module Wonga
  module Daemon
    class PantryEc2StopCommandHandler
      def initialize(publisher, error_publisher, logger)
        @publisher = publisher
        @error_publisher = error_publisher
        @logger = logger
      end

      def handle_message(message)
        @logger.info("Received stop message for instance: #{message['name']} - request_id: #{message['id']}")
        ec2 = AWS::EC2.new
        begin
          instance = ec2.instances[message['instance_id']]
          status = instance.status
        rescue
          @logger.error("ERROR: machine not found #{message['name']} - request_id: #{message['id']}")
          return
        end
        case status
        when :stopped
          @logger.info("Stopped instance: #{message['name']} - request_id: #{message['id']}")
          @publisher.publish message
          return
        when :terminated
          send_error_message(message)
          return
        when :running
          @logger.info("Stopping instance: #{message['name']} - request_id: #{message['id']}")
          instance.stop
        end
        fail "Instance #{message['instance_id']} still pending"
      end

      def send_error_message(message)
        @logger.info 'Send request to cleanup an instance'
        @error_publisher.publish(message)
      end
    end
  end
end
