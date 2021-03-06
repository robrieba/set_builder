require "test_helper"

class TraitsTest < ActiveSupport::TestCase
  include SetBuilder::Modifiers


  test "traits" do
    expected_traits = %w{age attended awesome born died name}
    assert_equal expected_traits, $friend_traits.collect(&:name).sort
  end

  test "traits' accessor" do
    traits = $friend_traits
    assert_kind_of SetBuilder::Traits, traits
    assert_equal "awesome", traits[0].name, "Array getter should still work like normal"
    assert_kind_of SetBuilder::Trait, traits[:born], "If you pass a string or symbol Traits should lookup a trait by name"
  end

  test "trait method is protected" do
    assert_raises NoMethodError, "this method is for use within class definition" do
      Friend.trait
    end
  end

  test "collection of modifiers" do
    expected_modifiers = %w{DatePreposition NumberPreposition StringPreposition}.collect {|name| "SetBuilder::Modifiers::#{name}"}
    assert_equal expected_modifiers, $friend_traits.modifiers.collect(&:name).sort
  end


  context "two collections of traits" do
    setup do
      @traits1 = SetBuilder::Traits.new do
        trait('who are "awesome"') { |query, scope| }
      end

      @traits2 = SetBuilder::Traits.new do
        trait('who are "living"') { |query, scope| }
      end
    end

    should "be concatenatable with `+`" do
      combined_traits = @traits1 + @traits2
      assert_kind_of SetBuilder::Traits, combined_traits
      assert_equal %w{awesome living}, combined_traits.map(&:name)
    end

    should "be concatenatable with `concat`" do
      combined_traits = @traits1.concat @traits2
      assert_kind_of SetBuilder::Traits, combined_traits
      assert_equal %w{awesome living}, combined_traits.map(&:name)
    end
  end


  test "to_json" do
    expected_json = [[["string","who "],
      ["enum",["are","are not"]],
      ["string", " "],
      ["name","awesome"]],
     [["string","who "],
      ["enum",["have","have not"]],
      ["string", " "],
      ["name","died"]],
     [["string","who were "],
      ["name","born"],
      ["string", " "],
      ["modifier","date"]],
     [["string","whose "],
      ["name","age"],
      ["string", " "],
      ["modifier","number"]],
     [["string","who "],
      ["enum",["have","have not"]],
      ["string", " "],
      ["name","attended"],
      ["string", " "],
      ["direct_object_type","school"]],
     [["string","whose "],
      ["name","name"],
      ["string", " "],
      ["modifier","string"]]].to_json
    assert_equal expected_json, $friend_traits.to_json
  end


end
