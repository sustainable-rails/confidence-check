# confidence\_check - make sure your test setup didn't break before running tests

Sometimes tests have some setup required before you run the test, and sometimes that setup is complicated, and sometimes that
setup can break if other parts of the system aren't working.  When that happens, you can a test failure that doesn't mean your
code is broken, just that some other code is broken.

Developers typically use three techniques to deal with this, none of them very good:

* Use the same assertions you use for tests
* Use `if` statements and explicitly fail
* Ignore this problem and hope it goes away

`confidence_check` allows you to validate the potentially complex conditions under which your test should be run to allow you to
focus on only what is wrong.

## Install

```
> gem install confidence-check
```

Or, if using a `Gemfile`:

```ruby
gem "confidence-check"
```

## Use - RSpec

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

## Use - Minitest

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

## Use - with Capybara

A handy use for confidence checks is when navigating a web page with Capybara. You must often perform several steps to get to
the page where you will the assert.  If you use the `*WithCapybara` versions of the modules, you can wrap your Capybara
navigation commands in a `confidence_check`:

### RSpec

```ruby
RSpec.configure do |c|
  c.include ConfidenceCheck::ForRSpec::WithCapybara
end
```

### Minitest

```ruby
# test/test_helper.rb

class ActiveSupport::TestCase
  include ConfidenceCheck::ForMinitest::WithCapybara

  # ...
end
```

## A Longer Example

A more realistic example is when testing something moderately complex like an integration or system test.

Suppose we have a web page that asks if you are 18 years old or not.  Suppose that this is the second webpage in a series, thus
the happy path is to visit the home page, click a link, at which point you are asked your age:

```ruby
visit "/"

click_on "Get Started"

click_on "18 or Over"
expect(page).to have_content("Great, you can use our service!")
```

Suppose that the "Get Started" link is changed to go somewhere else.  This test will break not with a failed assertion, but
because `click_on "18 or Over"` won't be there.  We could check for this like so:

```ruby
visit "/"

click_on "Get Started"
expect(page).to have_content("You must be 18 to use this service")

click_on "18 or Over"
expect(page).to have_content("Great, you can use our service!")
```

Now, the first `expect` will fail, which is better, but is it?  What are we testing here? We aren't *really* testing the
navigation from the home page, just the age check.  We can indicate this with `confidence_check`:

```
confidence_check do
  visit "/"

  click_on "Get Started"
  expect(page).to have_content("You must be 18 to use this service")
end

click_on "18 or Over"
expect(page).to have_content("Great, you can use our service!")
```

Now, if `visit`, `click_on`, or `expect` fail, the failure message will indicate "CONFIDENCE CHECK FAILED" and this indicates
that the code you are testing is not necessarily broken, but that some other dependent code is broken, so there's no sense
actually running the test until that gets fixed.
