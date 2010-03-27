# encoding: utf-8

module Formidable
  module Coercions
    def self.coercions
      @@coercions ||= Hash.new
    end

    def coerce(type = nil, &block)
      if type && block.nil?
        Coercions.coercions[type]
      elsif type.nil? && block
        block.call(self.data)
      else
        raise ArgumentError, "provide block or type"
      end
    end
  end
end
