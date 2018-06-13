RSpec.describe Fie::Changelog do
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
      'hash' => {
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

  context "when view_variables == #{ @unencrypted_variables.to_json }" do
    describe '#update_object_using_changelog' do
      subject { state.update_object_using_changelog(changelog) }

      context 'when changelog == { "users" => { 0 => { "name" => "New Name" } } }' do
        let(:changelog) do
          { 
            'users' => {
              0 => {
                'name' => 'New Name'
              }
            }
          }
        end

        it { expect { subject }.to change { state.users[0][:name] }.from('eran').to('New Name') }
      end

      context 'when changelog == { "hash" => { "array" => { 1 => 5 } }' do
        let(:changelog) do
          {
            'hash' => {
              'array' => {
                1 => 5
              }
            }
          }
        end

        it { expect { subject }.to change { state.hash[:array][1] }.from(2).to(5) }
      end
    end
  end
end
