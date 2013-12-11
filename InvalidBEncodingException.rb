module BEncode
  class InvalidBEncodeException < StandardError
    def initialize(msg)
      super(msg)
    end
  end
