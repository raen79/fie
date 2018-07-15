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
  let(:state_params) { { 'view_variables' => view_variables, 'controller_name' => controller_name, 'action_name' => action_name } }
  let(:view_variables) do
    {
      users: encrypt([
        { name: 'eran', age: '20' },
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

  before { subscription.singleton_class.class_variable_set(:@@pools_subjects, Set.new) }

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
    let!(:initialize_state) { subscription.initialize_state(state_params) }
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
      before { subscription.singleton_class.class_variable_set :@@pools_subjects, Set.new([:chat, :notifications]) }

      it do
        expect { subject }
          .to have_broadcasted_to("commander_#{ connection_uuid }")
          .with command: 'subscribe_to_pools', parameters: { subjects: ['chat', 'notifications']}
      end
    end
  end

  describe '#publish' do
    let(:pool_subject) { :chat }
    let(:object) { Object.new }
    
    before { expect(Fie::Pools).to receive(:publish_lazy).with(pool_subject, object, connection_uuid) }
    
    it { subscription.publish(pool_subject, object) }
  end

  describe '#state' do
    before { subscription.initialize_state state_params }

    let(:redis_state) { Marshal.load redis.get("commander_#{ connection_uuid }") }
    subject { subscription.state.attributes }

    it { is_expected.to eq(redis_state.attributes) }
  end

  describe '#state=' do
    let(:state_object) do 
      Fie::State.new \
        view_variables: view_variables,
        controller_name: controller_name,
        action_name: action_name,
        uuid: connection_uuid
    end

    before { subscription.state = state_object }

    it 'is expected to modify the state to the state object provided' do
      expect(subscription.state.attributes).to eq(state_object.attributes)
    end
  end

  describe '#modify_state_using_changelog' do
    let(:objects_changelog) { { key: 'value' } }
    let(:params) { { 'objects_changelog' => objects_changelog } }

    before { expect_any_instance_of(Fie::State).to receive(:update_object_using_changelog).with(objects_changelog) }

    it { subscription.modify_state_using_changelog(params) }
  end

  describe '#execute_js_function' do
    let(:function_name) { 'console.log' }
    let(:arguments) { ['print this in console.'] }

    subject { subscription.execute_js_function(function_name, *arguments) }

    it do
      expect { subject }
        .to have_broadcasted_to("commander_#{ connection_uuid }")
        .with command: 'execute_function', parameters: { name: function_name, arguments: arguments }
    end
  end

  describe '.commander_name' do
    subject { Fie::Commander.commander_name(connection_uuid) }
    it { is_expected.to eq("commander_#{ connection_uuid }") }
  end

  describe '.pool' do
    before do
      subscription.singleton_class.pool :chat do
        puts @connection_uuid
        puts @published_object
      end
    end

    describe 'created callback' do
      let(:object) { 123 }
      let(:dumped_object) { Marshal.dump object }
      subject { subscription.pool_chat_callback(object: dumped_object) }

      it 'is expected to output @connection_uuid and @published_object' do
        expect(STDOUT).to receive(:puts).with(connection_uuid)
        expect(STDOUT).to receive(:puts).with(object)
        subject
      end
    end
  end

  describe 'new method' do
    let(:caller) { { 'value' => '15', 'id' => 'id', 'class' => 'class' } }

    before do
      subscription.define_singleton_method(:new_method) do |arg1:, arg2:|
        puts @caller
        puts @controller_name
        puts @action_name
        puts @connection_uuid
        puts state.attributes
      end

      subscription.singleton_class.method_added(:new_method)
    end

    let(:new_method_parameters) do
      {
        'caller' => caller,
        'controller_name' => controller_name,
        'action_name' => action_name,
        'arg1' => 123,
        'arg2' => 123
      }
    end

    it 'should contain @caller, @controller_name, @action_name, and @connection_uuid instance variables and state method when called' do
      expect(STDOUT).to receive(:puts).with(caller.symbolize_keys)
      expect(STDOUT).to receive(:puts).with(controller_name)
      expect(STDOUT).to receive(:puts).with(action_name)
      expect(STDOUT).to receive(:puts).with(connection_uuid)
      expect(STDOUT).to receive(:puts).with(subscription.state.attributes)

      subscription.new_method(new_method_parameters)
    end
  end

  describe '#connected?' do
    context 'when connection exists' do
      subject { subscription.connected? }
      it { is_expected.to be_truthy }
    end

    context 'when connection does not exist' do
      before { subscription.unsubscribed }
      subject { subscription.connected? }
      it { is_expected.to be_falsy }
    end
  end
end