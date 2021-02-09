# confidence\_check - Get confidence in your test setup

Sometimes tests have some setup required before you run the test, and sometimes that setup is complicated, and sometimes that
setup can break if other parts of the system aren't working.  When that happens, you can a test failure that doesn't mean your
code is broken, just that some other code is broken.

```ruby
visit "/"
click_on "sign_up"

fill_in :username, with: "davetron5000"
expect {
  click_on "Create an Account"
}.to change {
  Account.count
}.by(1)
```

What if the `sign_up` link is broken, but your account registration code is working perfectly?  You'll get a test failure on
that call to `fill_in`.  This is confusing.

```ruby
confidence_check do
  visit "/"
  click_on "sign_up"
end

fill_in :username, with: "davetron5000"
expect {
  click_on "Create an Account"
}.to change {
  Account.count
}.by(1)
```

Now, if something goes wrong getting to the page, i.e. setting up for your test, you'll get a different error: CONFIDENCE CHECK
FAILED.

This can help tremendously with isolating the root cause of a test failure.  Instead of digging into the code you are testing, you can quickly see that some *other* code that is needed just to run a test is broken.

## Install

```
> gem install confidence-check
```

Or, if using a `Gemfile`:

```ruby
gem "confidence-check"
```

### Setup - RSpec

1. Include `ConfidenceCheck::ForRSpec` in your test. The most common way is in your `spec_helper.rb`:

   ```ruby
   RSpec.configure do |c|
     c.include ConfidenceCheck::ForRSpec
   end
   ```
2. You can now call `confidence_check` anywhere you need to assert your test is set up:

   ```ruby
   RSpec.describe Person do
     include ConfidenceCheck
     describe "#age" do
       it "is based on birthdate" do
         person = create(:person)

         confidence_check do
           expect(person.birthdate).not_to be_nil
         end

         expect(person.age).to eq(47)
       end
     end
   end
   ```

## Setup - Minitest

1. Include `ConfidenceCheck::ForMinitest` in your test.  For Rails, you'd include this in `ActiveSupport::TestCase`:

   ```ruby
   # test/test_helper.rb

   class ActiveSupport::TestCase
     include ConfidenceCheck::ForMinitest

     # ...
   end
   ```
2. You can now call `confidence_check` anywhere you need to assert your test is set up:

   ```ruby
   class PersonTest < MiniTest::Test
     include ConfidenceCheck
     def test_age
       person = create(:person)

       confidence_check do
         refute_nil person.birthdate
       end

       assert_equal 47,person.age
     end
   end
   ```

### Setup - Custom

1. The module `ConfidenceCheck::CheckMethod` makes a call to `exception_klasses`, which returns an array of exception classes you want to rescue inside a `confidence_check` call.  You'll need to implement this yourself:

   ```ruby
   module MyCustomConfidenceCheck
     include ConfidenceCheck::CheckMethod
     def exception_klasses
       [ MyCustomError ]
     end
   end
   ```
2. Note that you can include any of the other modules as a base. For example, if you want to use RSpec but add your own
   additional method:
   ```ruby
   module MyCustomConfidenceCheck
     include ConfidenceCheck::ForRSpec
     include ConfidenceCheck::CheckMethod
     def exception_klasses
       super + [ MyCustomError ]
     end
   end
   ```
3. Now, you need to include this module in your tests.  HOw to do this dependson how you are writing tests, but hopefully it's
   as simple as `include MyCustomConfidenceCheck`

### Setup - with Capybara

Capybara raises several exceptions if navigation or page manipulation fails.  These are almost always the types of failures
a confidence check should notify you about because they usually mean a page or pages aren't even working enough for you to
execute a test.

If you use the `*WithCapybara` versions of the modules, you can wrap your Capybara navigation commands in a `confidence_check`:

#### RSpec

```ruby
RSpec.configure do |c|
  c.include ConfidenceCheck::ForRSpec::WithCapybara
end
```

#### Minitest

```ruby
# test/test_helper.rb

class ActiveSupport::TestCase
  include ConfidenceCheck::ForMinitest::WithCapybara

  # ...
end
```

#### Custom

```ruby
module MyCustomConfidenceCheck
  include ConfidenceCheck::CheckMethod
  def exception_klasses
    [ MyCustomError, Capybara::CapybaraError ]
  end
end

# OR, to e.g. re-use RSpec's

module MyCustomConfidenceCheck
  include ConfidenceCheck::ForRSpec::WithCapybara
  include ConfidenceCheck::CheckMethod
  def exception_klasses
    super + [ MyCustomError ]
  end
end
```

## Developing

* Set up with `bin/setup`
* Run tests with `bin/rspec` or `bin/rake`

