require 'builder'
require 'rightnow/types/email'

module RightNow
  class Type

    attr_accessor :type

    def to_s
      builder = Builder::XmlMarkup.new
      builder.RNObjects(type: type)
    end

  end
end
