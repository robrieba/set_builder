require 'set_builder/modifier'


module SetBuilder
  class Constraint


    #
    # Sample constraints:
    #
    #     [:awesome],
    #     [:attended, "school"],
    #     [:died],
    #     [:name, {:is => "Jerome"}]]
    #
    def initialize(trait, *args, &block)
      @trait, @block = trait, block
      @direct_object = args.shift if trait.requires_direct_object?
      @modifiers = trait.modifiers.collect {|modifier_type| modifier_type.new(args.shift)}
    end



    attr_reader :trait, :direct_object, :modifiers, :negative
    alias :negative? :negative



    delegate :direct_object_required?,
             :direct_object_type,
             :to => :trait



    def valid?
      (!direct_object_required? or !direct_object.nil?) and modifiers.all?(&:valid?)
    end



    def to_s
      # p "ValueMap.to_s(#{direct_object_type} (#{direct_object_type.class}), #{direct_object} (#{direct_object.class}))"
      @description ||= begin
        description = trait.to_s(@negative)
        description << " #{ValueMap.to_s(direct_object_type, direct_object)}" if direct_object_required?
        description << " #{modifiers.collect{|m| m.to_s(@negative)}.join(" ")}" unless modifiers.empty?
        description
      end
    end



    def negate(value)
      @negative = value
      @negative = false unless trait.negative?
      self
    end



    def perform(scope)
      @block.call(self, scope)
    end



  end
end
