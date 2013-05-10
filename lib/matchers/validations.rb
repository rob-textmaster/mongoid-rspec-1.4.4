require 'pry'
module Mongoid
  module Matchers
    module Validations

      class HaveValidationMatcher

        def initialize(field, validation_type)
          @field = field.to_s
          @type = validation_type.to_s
        end

        def matches?(actual)
          @klass = actual.is_a?(Class) ? actual : actual.class

          @validator = @klass.validators_on(@field).detect{|v| v.kind.to_s == @type }

          if @validator
            @negative_result_message = "#{@type.inspect} validator on #{@field.inspect}"
            @positive_result_message = "#{@type.inspect} validator on #{@field.inspect}"
            return false unless check_conditional_validations
          else
            @negative_result_message = "no #{@type.inspect} validator on #{@field.inspect}"
            return false
          end

          true
        end

        def if(condition)
          @expected_if_condition = extract_value_for_conditionals(condition)
          self
        end

        def unless(condition)
          @expected_unless_condition = extract_value_for_conditionals(condition)
          self
        end

        def check_conditional_validations
          unfreeze_options
          result = check_if_condition && check_unless_condition
          restore_initial_options
          result
        end

        def check_unless_condition
          actual_unless_condition = @validator.options.delete(:unless)
          return true unless actual_unless_condition
          @positive_result_message = @positive_result_message << ", with condition: 'unless: #{actual_unless_condition}'"
          @negative_result_message = @negative_result_message << ", expected condition: 'unless: #{@expected_unless_condition}', actual: '#{actual_unless_condition}'"
          actual_unless_condition.to_s == @expected_unless_condition.to_s
        end

        def check_if_condition
          actual_if_condition = @validator.options.delete(:if)
          return true unless actual_if_condition
          @positive_result_message = @positive_result_message << ", with condition: 'if: #{actual_if_condition}'"
          @negative_result_message = @negative_result_message << ", expected condition: 'if: #{@expected_if_condition}', actual: '#{actual_if_condition}'"

          actual_if_condition.to_s == @expected_if_condition.to_s
        end

        def failure_message_for_should
          "Expected #{@klass.inspect} to #{description}; instead got #{@negative_result_message}"
        end

        def failure_message_for_should_not
          "Expected #{@klass.inspect} to not #{description}; instead got #{@positive_result_message}"
        end

        def description
          "validate #{@type} of #{@field.inspect}"
        end

        def unfreeze_options
          @initial_options = @validator.options.dup
          @validator.instance_variable_set(:@options, @initial_options.dup)
        end

        def restore_initial_options
          @validator.instance_variable_set(:@options, @initial_options)
        end

        def extract_value_for_conditionals(condition)
          case condition
          when String, Symbol then condition
          when Proc           then "a Proc which could not be verified, please abstract it as a method"
          else "Unexpected condition value: #{condition.inspect}"
          end
        end
      end
    end
  end
end
