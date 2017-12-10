# YARD Generator (Atom package)

[![Build Status](https://travis-ci.org/carlosbaraza/yard.svg)](https://travis-ci.org/carlosbaraza/yard)

YARD is a commonly used Ruby documentation tool. This package will accelerate
the creation of the YARD-style comments for your methods and classes.

## Usage

To use it is as simple as moving the cursor below something that needs documentation and pressing `ctrl + enter`.

###### In many cases, this will be the body of a method, but if the cursor is above the topmost method it will search for the next, constant, class, or module.

This will analyse the method (and its params), class, constant, or module and generate the following type of documentation:

```ruby
# Description of UndocumentedModule
module UndocumentedModule
  # Description of UndocumentedClass
  class UndocumentedClass
    MY_CONSTANT = 'Important string'.freeze # Description of MY_CONSTANT

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

#### Snippets

| Type This then Tab | Produces This                                                                                                      |
| ------------------ | ------------------------------------------------------------------------------------------------------------------ |
| #@E                | `#\n# @example example here\n#`                                                                                    |
| #@O                | `# @option parent [Type] argument definition`                                                                      |
| #@P                | `# @param [Type] param_name describe_param_here`                                                                   |
| #@H                | `# @param [Type] argument# @option parent [Type] argument definition\n# @option parent [Type] argument definition` |
| #@R                | `# @return [Type] definition`                                                                                      |

## Configuration

Through configuration settings you can add a blank comment line above or below the
description, `@param`s, and `@return`, as well as ensure there is a blank line
above the generated comment.

```ruby
module UndocumentedModule
  class UndocumentedClass
    def undocumented_method(param1, param2=3)
      'The method is not documented!'
    end
  end
end
```

with minimal spacing changes to (everything set to false):

```ruby
# Description of UndocumentedModule
module UndocumentedModule
  # Description of UndocumentedClass
  class UndocumentedClass
    # Description of #undocumented_method
    # @param [Type] param1 describe param1
    # @param [Type] param2 default: 3
    # @return [Type] description_of_returned_object
    def undocumented_method(param1, param2=3)
      'The method is not documented!'
    end
  end
end
```

with maximum spacing changes to(everything set to true):

```ruby
#
# Description of UndocumentedModule
#
module UndocumentedModule

  #
  # Description of UndocumentedClass
  #
  class UndocumentedClass

    #
    # Description of #undocumented_method
    #
    #
    # @param [Type] param1 describe param1
    #
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

and any combination in between.

# Planned Future Development

### • Add support for interpreting Hash params with `@options`

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
