require 'spec_helper'

describe RightNow::Client do
  let(:client) { RightNow::Client.new("https://apptentive-test.custhelp.com/cgi-bin/apptentive-test.cfg/services/soap?wsdl",
                            "Apptentive", "AppPassword") }

  describe '#new' do
    it 'sets up a new client object' do
      expect(RightNow::Client.new('http://url.com', 'user', 'pass')).to_not be_nil
    end

    context 'with blank username or password' do
      it 'should raise a setup error' do
        [
          [nil, nil],
          ['user', nil],
          [nil, 'pass']
        ].each do |user, pass|
          expect {
            RightNow::Client.new('http://url.com', user, pass)
          }.to raise_error(RightNow::InvalidClientError)
        end
      end
    end
  end

  describe '#connected?' do
    context 'when connected' do
      it 'should return true' do
        VCR.use_cassette('successful_connection', match_requests_on: [:method, :uri, :body]) do
          expect(client.connected?).to be_truthy
        end
      end
    end

    context 'when not connected' do
      let(:client) { RightNow::Client.new("https://apptentive-test.custhelp.com/cgi-bin/apptentive-test.cfg/services/soap?wsdl",
                            "Apptentive", "WrongPassword") }
      it 'should return false' do
        VCR.use_cassette('failed_connection', match_requests_on: [:method, :uri, :body]) do
          expect(client.connected?).to be_falsy
        end
      end

      it 'should set an error message on the client' do
        VCR.use_cassette('failed_connection', match_requests_on: [:method, :uri, :body]) do
          expect(client.connected?).to be_falsy
          expect(client.error_message).to eq 'Access Denied'
        end
      end
    end
  end

  describe '#create' do
    context 'Incident' do
      context 'with valid parameters' do
        it 'should return an Incident with full attributes' do
          VCR.use_cassette('create_incident', match_requests_on: [:method, :uri, :body]) do
            incident = RightNow::Objects::Incident.new(contact_id: '27404751', message: 'test', app_id: 'ab123c', subject: 'Apptentive Message', status_id: 1, queue_id: 31)
            response = client.create(incident)

            expect(response).to be_a(RightNow::Objects::Incident)
            expect(response.id).to eq '54947476'
            expect(response.subject).to eq 'Apptentive Message'
            expect(response.threads.length).to eq 1
          end
        end
      end

      context 'with invalid parameters' do
        it 'should return failure' do
          VCR.use_cassette('failed_incident') do
            incident = RightNow::Objects::Incident.new(message: 'forgot a contact_id', app_id: 'ab123c', subject: 'Apptentive Message')
            expect { client.create(incident) }.to raise_error(RightNow::InvalidObjectError)
          end
        end
      end
    end

    context 'Contact' do
      it 'should return a Contact object' do
        VCR.use_cassette('create_contact', match_requests_on: [:method, :uri, :body]) do
          contact = RightNow::Objects::Contact.new(first_name: 'Mike', last_name: 'Tester', email: 'mike+tester4@apptentive.com.invalid')
          response = client.create(contact)

          expect(response).to be_a(RightNow::Objects::Contact)
          expect(response.email).to eq 'mike+tester4@apptentive.com.invalid'
          expect(response.id).to eq '27404760'
          expect(response.first_name).to eq 'Mike'
          expect(response.last_name).to eq 'Tester'
        end
      end

      context 'with duplicate email' do
        it 'should raise a duplicate error' do
          VCR.use_cassette('create_duplicate_contact', match_requests_on: [:method, :uri, :body]) do
            contact = RightNow::Objects::Contact.new(first_name: 'Mike', last_name: 'Tester', email: 'mike+tester4@apptentive.com.invalid')
            expect { client.create(contact) }.to raise_error(RightNow::DuplicateObjectError)
          end
        end
      end
    end
  end

  describe '#update' do
    context 'Incident' do
      context 'with valid params' do
        it 'should return an Incident with full attributes' do
          VCR.use_cassette('update_incident', match_requests_on: [:method, :uri, :body]) do
            incident = RightNow::Objects::Incident.new(id: '54947325', message: 'new thread entry', status_id: 1, queue_id: 31)
            response = client.update(incident)

            expect(response).to be_a(RightNow::Objects::Incident)
            expect(response.id).to eq '54947325'
            expect(response.subject).to eq 'Apptentive Message'
            expect(response.threads.length).to eq 21
          end
        end
      end

      context 'with invalid params' do
        it 'should raise an error' do
          VCR.use_cassette('update_invalid_incident', match_requests_on: [:method, :uri, :body]) do
            # left off a message for the new thread
            incident = RightNow::Objects::Incident.new(id: '54947325')
            expect { client.update(incident) }.to raise_error(RightNow::InvalidObjectError)
          end
        end
      end
    end
  end

  describe '#find' do
    context 'Incident' do
      it 'should return an Incident object' do
        VCR.use_cassette('find_incident', match_requests_on: [:method, :uri, :body]) do
          incident = RightNow::Objects::Incident.new(id: '54947325')
          response = client.find(incident)

          expect(response).to be_a(RightNow::Objects::Incident)
          expect(response.id).to eq '54947325'
          expect(response.threads.length).to eq 8
        end
      end

      context 'when incident is not in Oracle' do
        it 'should return nil' do
          VCR.use_cassette('no_incident_found', match_requests_on: [:method, :uri, :body]) do
            incident = RightNow::Objects::Incident.new(id: '1')
            response = client.find(incident)

            expect(response).to be_nil
          end
        end
      end
    end

    context 'Contact' do
      it 'should return a Contact object' do
        VCR.use_cassette('find_contact', match_requests_on: [:method, :uri, :body]) do
          contact = RightNow::Objects::Contact.new(email: 'mike+tester1@apptentive.com')
          response = client.find(contact)

          expect(response).to be_a(RightNow::Objects::Contact)
          expect(response.email).to eq 'mike+tester1@apptentive.com'
          expect(response.id).to eq '27404755'
          expect(response.first_name).to eq 'Mike'
          expect(response.last_name).to eq 'Tester'
        end
      end

      context 'when user is not in Oracle' do
        it 'should return nil' do
          VCR.use_cassette('no_contact_found', match_requests_on: [:method, :uri, :body]) do
            contact = RightNow::Objects::Contact.new(email: 'testeroni@apptentive.com')
            response = client.find(contact)

            expect(response).to be_nil
          end
        end
      end
    end
  end
end
