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

      describe 'status' do
        context 'with a status' do
          it 'should have a key set' do
            incident.status_id = 1
            expect(incident.body(:create)).to include('StatusWithType')
          end
        end

        context 'without a status' do
          it 'should not have a key set' do
            expect(incident.body(:create)).to_not include('StatusWithType')
          end
        end
      end

      describe 'message' do
        it 'encodes multibyte characters correctly' do
          incident.message = '日本語'
          expect(incident.body(:create)).to include('日本語')
        end
      end

      describe 'queue' do
        context 'with a queue' do
          it 'should have a key set' do
            incident.queue_id = 1
            expect(incident.body(:create)).to include('Queue')
          end
        end

        context 'without a queue' do
          it 'should not have a key set' do
            expect(incident.body(:create)).to_not include('Queue')
          end
        end
      end

      describe 'channel' do
        context 'with a channel' do
          it 'should have a key set' do
            incident.channel_id = 1
            expect(incident.body(:create)).to include('Channel')
          end
        end

        context 'without a channel' do
          it 'should not have a key set' do
            expect(incident.body(:create)).to_not include('Channel')
          end
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

      describe 'status' do
        context 'with a status' do
          it 'should have a key set' do
            incident.status_id = 1
            expect(incident.body(:update)).to include('StatusWithType')
          end
        end

        context 'without a status' do
          it 'should not have a key set' do
            expect(incident.body(:update)).to_not include('StatusWithType')
          end
        end
      end

      describe 'message' do
        it 'encodes multibyte characters correctly' do
          incident.message = '日本語'
          expect(incident.body(:update)).to include('日本語')
        end
      end

      describe 'queue' do
        context 'with a queue' do
          it 'should have a key set' do
            incident.queue_id = 1
            expect(incident.body(:update)).to include('Queue')
          end
        end

        context 'without a queue' do
          it 'should not have a key set' do
            expect(incident.body(:update)).to_not include('Queue')
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

  describe '#most_recent_thread' do
    let(:incident) { RightNow::Objects::Incident.new(contact_id: 1, message: 'new incident', app_id: 'ab123c') }
    let(:thread1) { RightNow::Objects::Incident::Thread.new(text: 'first', display_order: "2") }
    let(:thread2) { RightNow::Objects::Incident::Thread.new(text: 'last', display_order: "11") }

    context 'with threads' do
      it 'should return the highest in the display order' do
        incident.threads = [thread1, thread2]
        expect(incident.most_recent_thread).to eq thread2
      end
    end

    context 'with no threads' do
      it 'should return nil' do
        expect(incident.most_recent_thread).to be_nil
      end
    end
  end

  describe '#create_from_response' do
    context 'when no name or email is provided' do
      it 'should skip these attributes and not raise an error' do
        response = {id: { :@id => '123'}}

        expect { RightNow::Objects::Incident.create_from_response(response) }.to_not raise_error
      end
    end
  end
end
