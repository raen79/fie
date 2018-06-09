require 'securerandom'

RSpec.describe Fie::Commander, type: :channel do
  before do
    credentials = {
      secret_key_base: 'c2c3f440e947a5592acaad052e756d87dd8db717275ef14ac794a3c2a07cbdaec8aa0df7a090c1bc83833736ee3f5209affe55639845871081d48598d57de3f7'
    }

    allow(Rails.application).to receive(:credentials) { credentials }
  end

  let(:controller_name) { 'home_controller' }
  let(:action_name) { 'index' }
  let(:view_variables) do
    {
      users: encrypt([
        { name: 'eran', age: '20' },
        User.new(name: 'eran', age: '20'),
        '120'
      ]),
      primitive: encrypt('120'),
      hash: encrypt({
        array: [1, 2, 3],
        primitive: '120'
      })
    }
  end

  let!(:connection) { stub_connection }
  let!(:connection_uuid) { '92dbabc7-60af-4658-9cc5-277846d1f813' }
  let!(:subscription) { subscribe identifier: connection_uuid }

  describe '#params' do
    describe ':identifier' do
      context 'when connection_uuid == 92dbabc7-60af-4658-9cc5-277846d1f813' do
        subject { subscription.params[:identifier] }
        it { is_expected.to eq(connection_uuid) }
      end
    end
  end

  describe 'streams' do
    context 'when connection_uuid == 92dbabc7-60af-4658-9cc5-277846d1f813' do
      subject { streams }
      it { is_expected.to include("commander_#{ connection_uuid }") }
    end
  end

  describe '#initialize_state' do
    let(:params) { { 'view_variables' => view_variables, 'controller_name' => controller_name, 'action_name' => action_name } }
    let!(:initialize_state) { subscription.initialize_state(params) }
    let(:redis_state) { redis.get("commander_#{ connection_uuid }") }

    subject { subscription.state }
    
    it { is_expected.to be_a(Fie::State) }
    it { expect(redis_state).to_not be_blank }
  end

  describe '#unsubscribed' do
    before { subscription.unsubscribed }
    subject { redis.get("commander_#{ connection_uuid }") }
    
    it('deletes state') { is_expected.to be_blank }
  end
  
  describe '#initialize_pools' do
    subject { subscription.initialize_pools }

    context 'when subjects are :chat and :notifications' do
      before { subscription.singleton_class.class_variable_set :@@pools_subjects, [:chat, :notifications] }

      it do
        expect { subject }
          .to have_broadcasted_to("commander_#{ connection_uuid }")
          .with command: 'subscribe_to_pools', parameters: { subjects: ['chat', 'notifications']}
      end
    end
  end
end