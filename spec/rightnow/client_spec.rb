require 'spec_helper'
require 'pry'

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
          }.to raise_error(RightNow::InvalidClient)
        end
      end
    end
  end

  describe '#create' do
    context 'Incident' do
      context 'with valid parameters' do
        let(:incident_params) { { message: 'my new message', contact: 1 } }

        it 'should return success' do
          VCR.use_cassette('create_incident') do
            incident = RightNow::Objects::Incident.new(incident_params)
            response = client.create(incident)

            expect(response).to be_success
          end
        end

        it 'should return the ID of the newly created incident' do
          VCR.use_cassette("create_incident") do
            incident = RightNow::Objects::Incident.new(incident_params)
            body = client.create(incident).body

            expect(body[:create_response][:rn_objects_result][:rn_objects][:id][:@id]).to eq '54947325' # parse response body for id?
          end
        end
      end

      context 'with invalid parameters' do
        it 'should return failure' do
          VCR.use_cassette('failed_incident') do
            incident = RightNow::Objects::Incident.new(message: 'forgot a contact_id')
            expect { client.create(incident) }.to raise_error(Savon::SOAPFault)
          end
        end
      end
    end

    context 'Contact' do
      it 'should return success' do
        VCR.use_cassette("create_contact") do
          contact = RightNow::Objects::Contact.new(first_name: 'Mike', last_name: 'Tester', email: 'mike.tester@apptentive.com')
          response = client.create(contact)

          expect(response).to be_success
        end
      end

      it 'should return the ID of the newly created contact' do
        VCR.use_cassette("create_contact") do
          contact = RightNow::Objects::Contact.new(first_name: 'Mike', last_name: 'Tester', email: 'mike.tester@apptentive.com')
          body = client.create(contact).body

          expect(body[:create_response][:rn_objects_result][:rn_objects][:id][:@id]).to eq '27404747'
        end
      end
    end
  end

  describe '#update' do
    context 'Incident' do
      context 'with valid params' do
        it 'should return success' do
          VCR.use_cassette('update_incident') do
            incident = RightNow::Objects::Incident.new(message: 'new addition to Thread', id: '54947325')
            response = client.update(incident)

            expect(response).to be_success
          end
        end
      end
    end
  end
end
