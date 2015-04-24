# YARD Generator (Atom package)

[![Build Status](https://travis-ci.org/carlosbaraza/yard.svg)](https://travis-ci.org/carlosbaraza/yard)

YARD is a commonly used Ruby documentation tool. This package will accelerate
the creation of the YARD-style comments for your methods and classes.

### Usage

To use it is as simple as situating on a method and pressing `ctrl + enter`.
This will analyse the method params and generate the following snippet for the
documentation:

```
class UndocumentedClass
  # Description of method
  #
  # @param [Type] param1 describe param1
  # @param [Type] param2=3 describe param2=3
  # @return [Type] description of returned object
  def undocumented_method(param1, param2=3)
    'The method is not documented!'
  end
end
```

`Tab`/`shift + Tab` keys could be used to jump to the next param, description or
Type.

### Future

I will update this package soon with more intelligence and features:
* **Analyse better the method params.
* **Implement for class.
