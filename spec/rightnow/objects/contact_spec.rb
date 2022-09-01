require "spec_helper"

describe RightNow::Objects::Contact do
  let(:contact) { RightNow::Objects::Contact.new(first_name: "Joe", last_name: "Tester", email: "joe.tester@apptentive.com") }

  describe "attributes" do
    %i[
      id
      email
      first_name
      last_name
    ]
      .each do |attr|
        specify "has #{attr}" do
          expect(contact.respond_to?(attr)).to be_truthy # responds to?
        end
      end
  end

  describe "#body" do
    context "for create" do
      it "should contain first name" do
        expect(contact.body(:create)).to include "Joe"
      end

      it "should contain last name" do
        expect(contact.body(:create)).to include "Tester"
      end

      it "should contain email" do
        expect(contact.body(:create)).to include "joe.tester@apptentive.com"
      end

      describe "strings" do
        it "encodes multibyte characters correctly" do
          contact.first_name = "日本語"
          expect(contact.body(:create)).to include("日本語")
        end
      end
    end

    context "for find" do
      it "should contain SQL" do
        expect(contact.body(:find)).to include "SELECT Contact FROM Contact c WHERE"
      end
    end
  end

  describe "#create_from_response" do
    context "when no name or email is provided" do
      it "should skip these attributes and not raise an error" do
        response = { id: { :@id => "123" } }

        expect { RightNow::Objects::Contact.create_from_response(response) }.to_not raise_error
      end
    end
  end
end
