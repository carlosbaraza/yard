# YARD Generator (Atom package)

YARD is a commonly used Ruby documentation tool. This package will accelerate
the creation of the YARD-style comments for your methods and classes.

### Usage

To use it is as simple as situating at the top of the method to document and
press `ctrl + enter`. This will generate the following documentation:

```
class UndocumentedClass
  # Description of method
  #
  # @param param1 [Symbol] description of param1, and possible examples
  # @return [String] description of returned object
  def undocumented_method

  end
end
```

### Future

I will update this package soon with more intelligence and features:
* **Document the current method or class**, changing the cursor position
  to the top of the method or class.
* **Scan the method** to know what arguments are passed and so generate the
  proper documentation.
