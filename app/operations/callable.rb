# frozen_string_literal: true

module Callable
  def self.extended(base)
    base.define_singleton_method(:call) do |*args, **kwargs, &block|
      new.call(*args, **kwargs, &block)
    end
  end
end
