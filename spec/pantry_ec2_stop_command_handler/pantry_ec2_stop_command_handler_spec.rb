require 'spec_helper'
require_relative '../../pantry_ec2_stop_command_handler/pantry_ec2_stop_command_handler'

describe Wonga::Daemon::PantryEc2StopCommandHandler do
  let(:publisher) { instance_double('Wonga::Publisher').as_null_object   }
  let(:logger)    { instance_double('Logger').as_null_object             }
  let(:instance)  { instance_double('AWS::EC2::Instance').as_null_object }
  let(:ec2)       { instance_double('AWS::EC2')                          }

  subject do 
    described_class.new(publisher, logger)
  end
  
  it_behaves_like 'handler'

  describe "#handle_message" do
    before(:each) do
      AWS::EC2.stub(:new).and_return(ec2)
      ec2.stub(:instances).and_return(instance)
      publisher.stub(:publish)
    end

    context "Machine stopped" do 
      it "should publish" do 
        instance.stub(:status).and_return(:stopped)
        publisher.should_receive(:publish)
        subject.handle_message({"instance_id"=>"i-3245243"})
      end
    end

    context "Machine terminated" do 
      it "should log an error" do 
        instance.stub(:status).and_return(:terminated)
        logger.should_receive(:error)
        subject.handle_message({"instance_id"=>"i-3245243"})
      end
    end

    context "Machine running" do 
      it "Attempts to stop the instance" do 
        instance.stub(:status).and_return(:running)
        expect{
          subject.handle_messsage({"instance_id"=>"i-3245243"})
        }.to raise_error
      end
    end

    context "Otherwise(pending)" do 
      it "raises a benign error" do 
        expect{
          subject.handle_messsage({"instance_id"=>"i-3245243"})
        }.to raise_error
      end
    end
  end
end