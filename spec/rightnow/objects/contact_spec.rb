require 'spec_helper'

describe RightNow::Objects::Contact do
  describe '#body' do
    let(:contact) { RightNow::Objects::Contact.new(first_name: 'Joe', last_name: 'Tester', email: 'joe.tester@apptentive.com') }
    context 'for create' do
      it 'should contain first name' do
        expect(contact.body(:create)).to include 'Joe'
      end

      it 'should contain last name' do
        expect(contact.body(:create)).to include 'Tester'
      end

      it 'should contain email' do
        expect(contact.body(:create)).to include 'joe.tester@apptentive.com'
      end
    end
  end
end
