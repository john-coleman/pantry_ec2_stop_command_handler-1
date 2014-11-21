require 'spec_helper'
require_relative '../../pantry_ec2_stop_command_handler/pantry_ec2_stop_command_handler'

describe Wonga::Daemon::PantryEc2StopCommandHandler do
  let(:publisher) { instance_double('Wonga::Daemon::Publisher').as_null_object }
  let(:error_publisher) { instance_double('Wonga::Daemon::Publisher').as_null_object }
  let(:logger)    { instance_double('Logger').as_null_object }
  let(:instance)  { instance_double('AWS::EC2::Instance', instance_id: 'i-f4819cb9').as_null_object }
  let(:ec2)       { instance_double('AWS::EC2') }

  let(:message) do
    {
      'pantry_request_id' => 1,
      'instance_id' => 'i-f4819cb9',
      'instance_name' => 'some-hostname',
      'domain' => 'some-domain.tld'
    }
  end

  subject do
    described_class.new(publisher, error_publisher, logger)
  end
  it_behaves_like 'handler'

  describe '#handle_message' do
    before(:each) do
      AWS::EC2.stub(:new).and_return(ec2)
      ec2.stub(:instances).and_return('i-f4819cb9' => instance)
      publisher.stub(:publish)
    end

    context 'Machine stopped' do
      it 'should publish' do
        instance.stub(:status).and_return(:stopped)
        publisher.should_receive(:publish)
        subject.handle_message(message)
      end
    end

    context 'Machine running' do
      it 'Attempts to stop the instance' do
        instance.stub(:status).and_return(:running)
        expect { subject.handle_messsage(message) }.to raise_error
      end
    end

    context 'Otherwise(pending)' do
      it 'raises a benign error' do
        expect { subject.handle_messsage(message) }.to raise_error
      end
    end
  end

  describe '#handle_message publishes message to error topic for terminated instance' do
    let(:instance) { instance_double('AWS::EC2::Instance', instance_id: 'i-f4819cb9', status: :terminated).as_null_object }

    before(:each) do
      AWS::EC2.stub(:new).and_return(ec2)
      ec2.stub(:instances).and_return('i-f4819cb9' => instance)
    end

    it 'publishes message to error topic' do
      subject.handle_message(message)
      expect(error_publisher).to have_received(:publish).with(message)
    end

    it 'does not publish message to topic' do
      subject.handle_message(message)
      expect(publisher).to_not have_received(:publish)
    end
  end
end
