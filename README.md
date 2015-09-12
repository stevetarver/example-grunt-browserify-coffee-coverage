# Client side CoffeeScript code coverage

This project is minimal, including only what is needed to show how to generate code coverage with the following goals:

- Use CoffeeScript for everything except distributed files
- Run Mocha/Chai in an html page using PhantomJS
- Generate coverage reports as html for immediated viewing and lcov.info for upload to CodeCov.io or Coveralls.io
- Coverage reports show annotated CoffeeScript although the tests were run against browserify'd JavaScript.
- Do not generate intermediate JavaScript files
- Only use Grunt plugins/Browserify transforms - no custom webhooks, shell scripts, etc.
- Use minimal packages


## Project setup

1. Clone me
2. In project root: ```npm install```
3. Run default grunt task to build, test, generate coverage: ```grunt```


## Why, oh why?

There are many solutions for plain JavaScript. I tried several and always got down to the last mile before failure: coverage reports don't show annotated CoffeeScript for one reason or another.

There are some articles written from a CoffeeScript perspective but they are awkward, using bash scripts, webhooks to write files, etc.

After a little work, I found a simple and straight-forward solution that meets all the above goals.

## Developing the Project

1. Create the testing infrastructure: ```client/specs/public``` contains a standard PhantomJS/Mocha test page that includes Mocha/Chai, the browserify'd test bundle, mocha styling, and a call to ```mocha.run()```
2. Create specifications in ```client/spec/specs``` and a single file ```client/spec/spec-main.coffee``` that includes all specs - primarily so you can order the specs to make the output more readable.
3. Create functionality in ```client/scripts```
4. Create a Gruntfile that will
  - Copy spec resources to the build directory
  - Browserify the specs and include coverage
  - Run Mocha in the html page under PhantomJS
  - Generate coverage reports


## The Tricks

### grunt-mocha-phantom-istanbul

[grunt-mocha-phantom-istanbul](https://www.npmjs.com/package/grunt-mocha-phantom-istanbul) is a [grunt-mocha](https://www.npmjs.com/package/grunt-mocha) fork with a small but powerful addition: the ability to extract Istanbul coverage information and write standard Istanbul reports.

This example runs the mocha tests and writes the lcov report to the coverage directory. This provides html for code improvement and lcov.info to upload to CodeCov.io.

```CoffeeScript
mocha:
  test:
    src: "#{testbuild}/index.html"
    options:
      run: true
      reporter: 'Spec'
      log: true
      logErrors: true
      coverage:
        lcovReport: 'coverage/'
```

It does not instrument the code so we will do that with...

### browserify-coffee-coverage

[browserify-coffee-coverage](https://www.npmjs.com/package/browserify-coffee-coverage) is a Browserify transform for the most excelent [coffee-coverage](https://www.npmjs.com/package/coffee-coverage) by [BENBRIA](http://www.benbria.com).

There are two options we need: instrumentor and ignore.

The instrumentor option lets us choose Istanbul as opposed to JSCoverage. The ignore option lets us exclude the test files from the coverage report.


### grunt-browserify

[grunt-browserify](https://www.npmjs.com/package/grunt-browserify) provides robust Browserify functionality in Grunt. 

The Browserify transform pipeline is normally given as an array of strings. 

Many transforms will take arguments and to accomodate this, grunt-browserify has a special syntax of:

```[<transform>, {arg1: 'value1', arg2: 'value2'}]```

Elements of the transform pipeline array may be either transform name, or the transform with args syntax above. More concretely:

```CoffeeScript
browserify:
  test:
    src:  "#{spec}/spec-main.coffee"
    dest: "#{testbuild}/js/spec-main.js"
    options:
      transform: [
        ['browserify-coffee-coverage', {instrumentor: 'istanbul', ignore: '**/spec/**'}],
        'jadify'
      ]
      debug: true

```


## Epilog

There you have it - 3 well chosen packages, a couple of Gruntfile configurations yielding a pattern I will use over and over again.

Things to look at (after install and build)

- The console after a build: shows well formatted specification results and coverage summary.
- build/index.html: Mocha prints to the console, but also has a sweet test results presentation.
- coverage/lcov-report/index.html: your coverage results with annotated CoffeeScript available through drill down.
