# YARD Generator (Atom package)

[![Build Status](https://travis-ci.org/carlosbaraza/yard.svg)](https://travis-ci.org/carlosbaraza/yard)

YARD is a commonly used Ruby documentation tool. This package will accelerate
the creation of the YARD-style comments for your methods and classes.

## Usage

To use it is as simple as situating on a method and pressing `ctrl + enter`.
This will analyse the method (and its params), class, or module and generate the following type of documentation:

```ruby
# Description of UndocumentedModule
module UndocumentedModule
  # Description of UndocumentedClass
  class UndocumentedClass

    # Description of #undocumented_method
    #
    # @param [Type] param1 describe_param1
    # @param [Type] param2 default: 3
    # @param [Type] param4 default: { foo: :bar, baz: 'qux' }
    # @return [Type] description_of_returned_object
    def undocumented_method(param1, param2=3, param4 = { foo: :bar, baz: 'qux' })
      'The method is not documented!'
    end

    # Description of #method_with_named_params
    #
    # @param [Type] param1 default: nil
    # @param [Type] param2 default: true
    # @param [Type] param3 default: nil
    # @return [Type] description_of_returned_object
    def method_with_named_params(param1:, param2: true, param3: nil)
      'The method is not documented!'
    end

    # Description of .undocumented_method
    #
    # @param [Type] param1 describe_param1
    # @param [Type] param2 default: 3
    # @return [Type] description_of_returned_object
    def self.undocumented_class_method(param1, param2=3)
      'The method is not documented!'
    end
  end
end
```

`Tab`/`shift + Tab` keys could be used to jump to the next param, description or
Type.

# Planned Future Development

### • Add support for Hash params with `@options`

```ruby
# Description of #undocumented_method
#
# @param [Type] param1
# @option [Type] foo default: nil
# @option [Type] bar default: nil
# @option [Type] baz default: nil
# @return [Type] description_of_returned_object
def undocumented_method(param1={ foo:, bar:, baz: })
  'The method is not documented!'
end
```

### • Implement for CONSTANTS:

```ruby
MY_CONSTANT = 'Important string'.freeze # Description of MY_CONSTANT
```

### • Add configuration for controlling spacing between lines

Add comment above or below the description/`@param`/`@return` _(and possibly add a blank line above the comment)_

```ruby
module UndocumentedModule
  class UndocumentedClass
    def undocumented_method(param1, param2=3)
      'The method is not documented!'
    end
  end
end
```

to

```ruby
#
# Description of UndocumentedModule
#
module UndocumentedModule

  # Description of UndocumentedClass
  #
  class UndocumentedClass
    # (this could be a blank line)
    # Description of #undocumented_method
    #
    # @param [Type] param1 describe param1
    #
    # @param [Type] param2 default: 3
    #
    #
    # @return [Type] description_of_returned_object
    #
    def undocumented_method(param1, param2=3)
      'The method is not documented!'
    end
  end
end
```
