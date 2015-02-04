require 'spec_helper'

describe RightNow::Objects::Incident do
  describe '#body' do
    context 'for create' do
      let(:incident) { RightNow::Objects::Incident.new(contact_id: 1, message: 'new incident') }

      it 'should contain a contact_id' do
        expect(incident.body(:create)).to include('1')
      end

      it 'should contain a new thread' do
        expect(incident.body(:create)).to include('new incident')
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
    end
  end
end
