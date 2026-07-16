# Testing

Enchant uses `@dashkite/amen` and `@dashkite/assert` for its testing framework. The testing approach relies on unit testing the individual action functions, evaluating that they behave correctly given mocked request, response, and context objects.

Testing focuses heavily on assertions for state mutations (like cache setting) and ensuring that policy application triggers the correct nested behavior based on conditions and context. The test suites are broken down primarily into action tests, which iterate over all registered actions and run their respective specifications.

To run the tests, use the following command:

```bash
npx genie test
```

This will invoke the Amen test runner, evaluate all assertions, and exit with an appropriate success code.
