require 'spec_helper'
require_relative '../../pantry_ec2_stop_command_handler/pantry_ec2_stop_command_handler'
require 'wonga/daemon/publisher'
require 'logger'
require 'wonga/daemon/aws_resource'

RSpec.describe Wonga::Daemon::PantryEc2StopCommandHandler do
  let(:publisher) { instance_double('Wonga::Daemon::Publisher') }
  let(:logger) { instance_double('Logger').as_null_object }
  let(:aws_resource) { instance_double('Wonga::Daemon::AwsResource', stop: true) }

  let(:message) do
    {
      'pantry_request_id' => 1,
      'instance_id' => 'i-f4819cb9',
      'instance_name' => 'some-hostname',
      'domain' => 'some-domain.tld'
    }
  end

  subject do
    described_class.new(publisher, aws_resource, logger)
  end

  it_behaves_like 'handler'

  describe '#handle_message' do
    it 'sends message' do
      expect(publisher).to receive(:publish).with(message)
      subject.handle_message message
    end

    context 'when machine can not be stopped' do
      let(:aws_resource) { instance_double('Wonga::Daemon::AwsResource', stop: false) }
      it 'does nothing' do
        subject.handle_message message
      end
    end
  end
end
