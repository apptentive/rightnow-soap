class RightNow::Objects::Contact < RightNow::RNObject
  attr_accessor :first_name, :last_name, :email

  def initialize(params)
    @type = 'Contact'

    @first_name = params[:first_name]
    @last_name  = params[:last_name]
    @email      = params[:email]
  end

  def body(action)
    contact_body + processing_options
  end

  private

  def contact_body
    Nokogiri::XML::Builder.new do |xml|
      xml.RNObjects('xsi:type' => "object:#{type}", 'xmlns:object' => 'urn:objects.ws.rightnow.com/v1_2', 'xmlns:base' => 'urn:base.ws.rightnow.com/v1_2') do
        # TODO: what if no email is provided?
        # we should be providing a default email address in the #on_message method
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
    end.doc.root.to_xml
  end

  def processing_options
    Nokogiri::XML::Builder.new do |xml|
      # Q: What do these do again? This is keeping me from moving the RNObjects block out of each method
      xml.ProcessingOptions do
        xml.SuppressExternalEvents('true')
        xml.SuppressRules('true')
      end
    end.doc.root.to_xml
  end
end
