class HelperTestClass
  include Fie::Helper
end

RSpec.describe Fie::Helper do
  describe '#redis' do
    subject{ HelperTestClass.new }
    context 'when ENV["REDIS_URL"] is present' do
      it do
        allow(ENV).to receive(:[]).with("REDIS_URL").and_return("redis://")
        allow(Redis).to receive(:new).and_return('success_env')
        expect(subject.redis).to be_eql('success_env')
      end
    end

    context 'when ENV["REDIS_URL"] is absent' do
      it do
        allow(ENV).to receive(:[]).with("REDIS_URL").and_return(nil)
        allow(ActionCable).to receive_message_chain(
          :server, :pubsub, :redis_connection_for_subscriptions
        ).and_return('success_without_env')
        expect(subject.redis).to be_eql('success_without_env')
      end
    end
  end
end
