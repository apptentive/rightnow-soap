class RightNow::Objects::Contact < RightNow::RNObject
  attr_accessor :first_name, :last_name, :email, :id

  def initialize(params)
    @type = 'Contact'

    @id         = params[:id]
    @email      = params[:email]
    @first_name = params[:first_name]
    @last_name  = params[:last_name]
  end

  def self.create_from_response(contact_params)
    RightNow::Objects::Contact.new(
            id: contact_params[:id][:@id],
    first_name: (contact_params[:name][:first] if contact_params[:name]),
     last_name: (contact_params[:name][:last] if contact_params[:name]),
         email: (email_from_response(contact_params.fetch(:emails){{}}[:email_list]) if contact_params[:emails]) # TODO what if there are two addresses?
    )
  end

  def body(action)
    case action
    when :create
      create_contact
    when :find
      find_contact
    end
  end

  private

  def self.email_from_response(list)
    if list.is_a?(Array)
      list.detect { |address| address[:address_type][:id][:@id] == '0' }[:address]
    else
      list[:address]
    end
  end

  def create_contact
    Nokogiri::XML::Builder.new do |xml|
      xml[:message].Batch('xmlns:message' => 'urn:messages.ws.rightnow.com/v1_2') do
        xml[:message].BatchRequestItem do
          xml << contact_body
        end
        xml[:message].BatchRequestItem do
          xml[:message].GetMsg do
            xml[:message].RNObjects('xmlns:object' => 'urn:objects.ws.rightnow.com/v1_2', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:type' => 'object:Contact') do
              xml.ID('xmlns' => 'urn:base.ws.rightnow.com/v1_2', 'xsi:type' => 'ChainDestinationID', 'id' => '0', 'variableName' => 'MyNewContact')
              xml[:object].Emails
            end
            xml[:message].ProcessingOptions do
              xml[:message].FetchAllNames('false')
            end
          end
        end
      end
    end.doc.root.to_xml
  end

  def contact_body
    Nokogiri::XML::Builder.new do |xml|
      xml.CreateMsg('xmlns' => 'urn:messages.ws.rightnow.com/v1_2') do
        xml.RNObjects('xsi:type' => 'object:Contact', 'xmlns:object' => 'urn:objects.ws.rightnow.com/v1_2', 'xmlns:base' => 'urn:base.ws.rightnow.com/v1_2') do
          # TODO: what if no email is provided?
          # we should be providing a default email address in the #on_message method
          xml[:base].ID('xsi:type' => 'ChainSourceID', 'id' => '0', 'variableName' => 'MyNewContact')
          xml[:object].Emails do
            xml[:object].EmailList('action' => 'add') do
              xml[:object].Address(email)
              xml[:object].AddressType do
                xml[:base].ID(id: '0')
              end
            end
          end
          xml[:object].Name do
            xml[:object].First(first_name)
            xml[:object].Last(last_name)
          end
        end

        xml.ProcessingOptions do
          xml.SuppressExternalEvents('false')
          xml.SuppressRules('false')
        end
      end
    end.doc.root.to_xml
  end

  def find_contact
    Nokogiri::XML::Builder.new do |xml|
      xml.QueryObjects('xmlns' => "urn:messages.ws.rightnow.com/v1_2") do
        xml.Query("SELECT Contact FROM Contact c WHERE c.Emails.EmailList.Address = '#{email}' ORDER BY id ASC LIMIT 1")
        xml.ObjectTemplates('xmlns:object' => 'urn:objects.ws.rightnow.com/v1_2', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:type' => 'object:Contact') do
          xml[:object].Emails
        end
        xml.PageSize('100')
      end
    end.doc.root.to_xml
  end
end
