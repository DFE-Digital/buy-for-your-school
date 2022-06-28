module GivenWhenThen
  module ClassMethods
    def def_Given(name, *args, &block)
      _gwt_define(:Given, name, *args, &block)
    end

    def def_When(name, *args, &block)
      _gwt_define(:When, name, *args, &block)
    end

    def def_Then(name, *args, &block)
      _gwt_define(:Then, name, *args, &block)
    end

    private

    def _gwt_define(prefix, name, *args, &block)
      define_method("#{prefix} #{name}", *args, &block)
    end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def Given(name, *args)
    _gwt_call(:Given, name, *args)
  end

  def When(name, *args)
    _gwt_call(:When, name, *args)
  end

  def Then(name, *args)
    _gwt_call(:Then, name, *args)
  end

  def And(name, *args)
    _gwt_call(:And, name, *args)
  end

  private

  def _gwt_call(prefix, name, *args)
    if prefix == :And
      prefix = @_gwt_last_prefix || :Given
    end

    public_send("#{prefix} #{name}", *args)

  ensure
    @_gwt_last_prefix = prefix
  end
end

RSpec.configure do |c|
  c.include GivenWhenThen, type: :feature
end
