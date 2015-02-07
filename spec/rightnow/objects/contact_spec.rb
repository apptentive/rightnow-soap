require 'spec_helper'

describe RightNow::Objects::Contact do
  let(:contact) { RightNow::Objects::Contact.new(first_name: 'Joe', last_name: 'Tester', email: 'joe.tester@apptentive.com') }

  describe 'attributes' do
    [
      :id,
      :email,
      :first_name,
      :last_name
    ].each do |attr|
      specify "has #{attr}" do
        expect(contact.respond_to?(attr)).to be_truthy # responds to?
      end
    end
  end

  describe '#body' do
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

    context 'for find' do
      it 'should contain SQL' do
        expect(contact.body(:find)).to include 'SELECT Contact FROM Contact c WHERE'
      end
    end
  end
end
