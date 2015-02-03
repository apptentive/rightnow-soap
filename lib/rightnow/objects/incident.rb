class RightNow::Objects::Incident < RightNow::RNObject
  attr_accessor :primary_contact, :message, :id

  def initialize(params)
    @type = 'Incident'

    @primary_contact = params[:primary_contact]
    @message = params[:message]
    @id = params[:id]
  end

  def body(action)
    soap_envelope(action) do |xml|
      case action
      when :create
        create_incident(xml)
      when :update
        update_incident(xml)
      end
    end
  end

  private

  def create_incident(xml)
    xml.RNObjects('xsi:type' => "object:#{type}", 'xmlns:object' => 'urn:objects.ws.rightnow.com/v1_2', 'xmlns:base' => 'urn:base.ws.rightnow.com/v1_2') do
      xml[:object].PrimaryContact do
        xml[:object].Contact do
          xml[:base].ID(id: primary_contact)
        end
      end
      # TODO: this is settable in other integrations
      xml[:object].Subject('Apptentive Message')
      # NOTE: what if there is a nil or blank message sent to Oracle?
      xml[:object].Threads do
        xml[:object].ThreadList(action: 'add') do
          xml[:object].EntryType do
            xml[:base].ID(id: '2')
          end
          xml[:object].Text(message)
        end
      end
    end
  end

  def update_incident(xml)
    xml.RNObjects('xsi:type' => "object:#{type}", 'xmlns:object' => 'urn:objects.ws.rightnow.com/v1_2', 'xmlns:base' => 'urn:base.ws.rightnow.com/v1_2') do
      xml[:base].ID(id: id)
      xml[:object].Threads do
        xml[:object].ThreadList(action: 'add') do
          xml[:object].EntryType do
            # if an agent is responding from Apptentive dashboard, it needs to be 2 (Staff Account)
              # 1 - Note
              # 2 - Staff Account
              # 3 - Customer
              # 4 - Customer Proxy
              # 5 - Chat
              # 6 - Rule Response
              # 7 - Rule Response Template
              # 8 - Voice Integration
            xml[:base].ID(id: 3)
          end
          xml[:object].Text(message)
        end
      end
    end
  end
end
