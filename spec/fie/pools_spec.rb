RSpec.describe Fie::Pools, type: :channel do
  context 'when subject == "chat"' do
    let(:pool_subject) { 'chat' }

    describe 'subscription' do
      subject { subscribe identifier: pool_subject }
      it { is_expected.to_not be_blank }
      it { is_expected.to be_a(Fie::Pools) }
    end

    describe '.pool_name' do
      subject { Fie::Pools.pool_name(pool_subject) }
      it { is_expected.to eq("pool_#{ pool_subject }") }
    end

    describe '.publish_lazy' do
      context 'when sender_uuid is "92dbabc7-60af-4658-9cc5-277846d1f813" && object is 123' do
        let(:sender_uuid) { '92dbabc7-60af-4658-9cc5-277846d1f813' }
        let(:object) { 123 }

        subject { Fie::Pools.publish_lazy(pool_subject, object, sender_uuid) }

        it do
          expect { subject }
            .to have_broadcasted_to("commander_#{ sender_uuid }")
            .with command: 'publish_to_pool_lazy', parameters: { subject: pool_subject, object: Marshal.dump(object) }
        end
      end
    end

    describe '.publish' do
      context 'when object == 123' do
        let(:object) { 123 }

        context 'when sender is not specified' do
          let(:sender_uuid) { nil }
          
          subject { Fie::Pools.publish(pool_subject, object, sender_uuid: sender_uuid) }

          it do
            expect { subject }
            .to have_broadcasted_to("pool_#{ pool_subject }")
            .with command: 'publish_to_pool', parameters: { subject: pool_subject, object: Marshal.dump(object), sender_uuid: sender_uuid }  
          end
        end

        context 'when sender is specified' do
          let(:sender_uuid) { '92dbabc7-60af-4658-9cc5-277846d1f813' }
          
          subject { Fie::Pools.publish(pool_subject, object, sender_uuid: sender_uuid) }

          it do
            expect { subject }
            .to have_broadcasted_to("pool_#{ pool_subject }")
            .with command: 'publish_to_pool', parameters: { subject: pool_subject, object: Marshal.dump(object), sender_uuid: sender_uuid }  
          end
        end
      end
    end

  end
end
