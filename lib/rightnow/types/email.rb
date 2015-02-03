# module RightNow::Types
#   class Email < RightNow::Type
#     attr_accessor :email_address
#
#     def initialize(email_address)
#       @email_address = email_address
#     end
#
#     def to_s
#       builder = super
#       builder.emails do |emails|
#         emails.EmailList(action: :add) do |email|
#           email.address = @email_address
#           email.addressType do |type|
#             type.ID(id: 0)
#           end
#         end
#       end
#     end
#   end
# end
