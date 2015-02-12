require 'spec_helper'

describe RightNow::Objects::Incident do
  describe '#body' do
    context 'for create' do
      let(:incident) { RightNow::Objects::Incident.new(contact_id: 1, message: 'new incident', app_id: 'ab123c', subject: 'New Incident Subject') }

      {
        contact_id: '1',
        message: 'new incident',
        app_id: 'ab123c',
        subject: 'New Incident Subject'
      }.each do |attr, value|
        it "should contain a #{attr}" do
          expect(incident.body(:create)).to include(value)
        end
      end

      context 'without an app id' do
        it 'should raise an error' do
          incident = RightNow::Objects::Incident.new(contact_id: '27404751', message: 'test')
          expect { incident.body(:create) }.to raise_error(RightNow::InvalidObjectError)
        end
      end
    end

    context 'for update' do
      let(:incident) { RightNow::Objects::Incident.new(id: 123, message: 'new incident') }

      it 'should contain an ID' do
        expect(incident.body(:update)).to include('123')
      end

      it 'should contain a new thread' do
        expect(incident.body(:update)).to include('new incident')
      end

      describe 'entry type' do
        context 'when sent by an agent' do
          it 'should tag the thread to the agent' do
            incident.from_agent = true
            expect(incident.body(:update)).to include('<base:ID id="2"/>')
          end
        end

        context 'when sent by a customer' do
          it 'should tag the thread to the customer' do
            expect(incident.body(:update)).to include('<base:ID id="3"/>')
          end
        end
      end
    end

    context 'for find' do
      let(:incident) { RightNow::Objects::Incident.new(id: 123) }

      it 'should contain SQL' do
        expect(incident.body(:find)).to include('SELECT Incident FROM Incident i WHERE i.ID')
      end

      it 'should request the Threads in the return template' do
        expect(incident.body(:find)).to include('<object:Threads/>')
      end
    end
  end

  describe 'response' do
    describe 'threads' do
      # TODO: extract this to its own test and class
      # we can also pull it out of the Incident XML builder
      it 'should assign data to the right attributes' do
        attributes = { id: 1, display_order: 2, text: 'testing' }
        thread = RightNow::Objects::Incident::Thread.new(attributes)

        attributes.each do |key, val|
          expect(thread.public_send(key)).to eq val
        end
      end
    end
  end
end
