module Stripe
  class CardError < StripeError
    attr_reader :param, :code

    def initialize(message, param, code, http_status=nil, http_body=nil, json_body=nil,
                   http_headers=nil)
      super(message, http_status, http_body, json_body, http_headers)
      @param = param
      @code = code
    end
  end
end
