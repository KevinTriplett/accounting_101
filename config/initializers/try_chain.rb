module TryChain
  def try_chain(*method_list)
    target = self
    method_list.each do |method|
      target = target.send(method)
    end
    target
  rescue NoMethodError
    nil
  end
end

module NilTryChain
  def try_chain(*method_list)
    nil
  end
end

ActiveRecord::Base.__send__ :include, TryChain
NilClass.__send__ :include, NilTryChain