RSpec.describe Fie::State do
  before do
    credentials = {
      secret_key_base: 'c2c3f440e947a5592acaad052e756d87dd8db717275ef14ac794a3c2a07cbdaec8aa0df7a090c1bc83833736ee3f5209affe55639845871081d48598d57de3f7'
    }

    allow(Rails.application).to receive(:credentials) { credentials }

    @unencrypted_variables = {
      users: [
        { name: 'eran', age: '20' },
        User.new(name: 'eran', age: '20'),
        '120'
      ],
      primitive: '120',
      hash: {
        array: [1, 2, 3],
        primitive: '120'
      }
    }
  end

  let(:view_variables) do
    @unencrypted_variables.map do |key, value|
      [key, encrypt(value)]
    end.to_h
  end

  let(:controller_name) { 'home_controller' }
  let(:action_name) { 'index' }
  let(:uuid) { SecureRandom.uuid }
  let(:attributes) { nil }

  let(:state) do
    Fie::State.new \
      view_variables: view_variables,
      controller_name: controller_name,
      action_name: action_name,
      uuid: uuid,
      attributes: attributes
  end

  subject { state }

  context "when view_variables == #{ @unencrypted_variables.to_json }" do
    [:users, :primitive, :hash].each do |variable_name|
      it { is_expected.to respond_to(variable_name) }
      it { is_expected.to respond_to("#{ variable_name }=") }
    end

    describe 'marshalling' do
      let(:marshalled) { Marshal.dump state }
      let(:unmarshalled) { Marshal.load marshalled }

      subject { unmarshalled.attributes.keys }

      it { is_expected.to eq(state.attributes.keys) }
    end

    describe '#permeate' do
      it 'should render an html template which is then sent over action cable' do
        expect(ApplicationController).to receive(:render).with(
          "#{ controller_name }/#{ action_name }",
          assigns: state.attributes.merge(fie_controller_name: controller_name, fie_action_name: action_name),
          layout: 'fie'
        ).and_return('long HTML string')
        
        expect(ActionCable.server).to receive(:broadcast).with \
          "commander_#{ uuid }",
          command: 'refresh_view',
          parameters: {
            html: 'long HTML string'
          }

        state.permeate
      end
    end

    describe '#hash' do
      before { expect(state).to receive(:permeate) }

      context 'when setting value' do
        subject { state.hash }
        let!(:change_value) { state.hash = 'value' }

        it { is_expected.to eq('value') }
      end

      context 'when deleting value' do
        let(:delete_value) { state.hash.delete :primitive }
        it { expect { delete_value }.to change { state.hash.count }.by(-1) }
      end

      describe '#primitive' do
        context 'when setting value' do
          subject { state.hash[:primitive] }
          let!(:change_hash_value) { state.hash[:primitive] = 'value' }

          it { is_expected.to eq('value') }
        end
      end
    end

    describe '#users' do
      before { expect(state).to receive(:permeate) }

      context 'when setting value' do
        subject { state.users }
        let!(:change_value) { state.users = 'value' }

        it { is_expected.to eq('value') }
      end

      describe 'first index' do
        context 'when setting value' do
          subject { state.users[0] }
          let!(:change_array_value) { state.users[0] = 'value' }

          it { is_expected.to eq('value') }
        end
        
        describe '#name' do
          context 'when setting value' do
            subject { state.users[0][:name] }
            let!(:change_hash_value) { state.users[0][:name] = 'value' }

            it { expect(state.users[0][:name]).to eq('value') }
          end
        end

        context 'when appending' do
          let(:append1) { state.users << 'value' }
          let(:append2) { state.users.push('value') }

          it { expect { append1 }.to change { state.users.count }.by(1) }
          it { expect { append2 }.to change { state.users.count }.by(1) }
        end

        context 'when deleting a value' do
          let(:delete_value) { state.users.delete '120' }
          it { expect { delete_value }.to change { state.users.count }.by(-1) }
        end

        context 'when deleting an index' do
          let(:delete_value) { state.users.delete_at 1 }
          it { expect { delete_value }.to change { state.users.count }.by(-1) }
        end
      end
    end

    describe '#attributes' do
      describe '#users' do
        subject { state.attributes['users'] }
        
        it { is_expected.to include a_hash_including(name: 'eran', age: '20') }
        it { is_expected.to include an_object_having_attributes(name: 'eran', age: '20') }
        it { is_expected.to include '120' }
      end

      describe '#primitive' do
        subject { state.attributes['primitive'] }
        it { is_expected.to eq('120') }
      end

      describe '#hash' do
        subject { state.attributes['hash'] }

        it { is_expected.to include(array: [1, 2, 3]) }
        it { is_expected.to include(primitive: '120') }
      end
    end


    describe '#inspect' do
      subject { state.inspect }

      it { is_expected.to include(state.to_s[0..-2]) }
      it { is_expected.to include("users:") }
      it { is_expected.to include(state.users.inspect) }
      it { is_expected.to include("primitive:") }
      it { is_expected.to include(state.primitive.inspect) }
      it { is_expected.to include("hash:") }
      it { is_expected.to include(state.hash.inspect) }
      it { is_expected.to include('>') }
    end
  end
end
