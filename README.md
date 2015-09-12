[![tag:?](https://img.shields.io/github/tag/stevetarver/example-grunt-browserify-coffee-coverage.svg)](https://github.com/stevetarver/example-grunt-browserify-coffee-coverage/releases)
[![license:mit](https://img.shields.io/badge/license-mit-green.svg)](#license)
[![build:?](https://img.shields.io/travis/stevetarver/example-grunt-browserify-coffee-coverage/master.svg)](https://travis-ci.org/stevetarver/example-grunt-browserify-coffee-coverage)
[![coverage:?](https://img.shields.io/coveralls/stevetarver/example-grunt-browserify-coffee-coverage/master.svg?style=flat-square)](https://coveralls.io/r/stevetarver/example-grunt-browserify-coffee-coverage)
[![codecov.io](http://codecov.io/github/stevetarver/example-grunt-browserify-coffee-coverage/coverage.svg?branch=master)](http://codecov.io/github/stevetarver/example-grunt-browserify-coffee-coverage?branch=master)
<br>
[![npm:](https://img.shields.io/npm/v/example-grunt-browserify-coffee-coverage.svg)](https://www.npmjs.com/package/example-grunt-browserify-coffee-coverage)
[![dependencies:?](https://img.shields.io/david/stevetarver/example-grunt-browserify-coffee-coverage.svg)](https://david-dm.org/stevetarver/example-grunt-browserify-coffee-coverage.svg)
[![devDependency Status](https://david-dm.org/stevetarver/example-grunt-browserify-coffee-coverage/dev-status.svg)](https://david-dm.org/stevetarver/example-grunt-browserify-coffee-coverage#info=devDependencies)

# Client side CoffeeScript code coverage

This project is minimal, including only what is needed to show how to generate code coverage with the following goals:

- Use CoffeeScript for everything except distributed files
- Run Mocha/Chai in an html page using PhantomJS
- Generate coverage reports as html for immediated viewing
- Upload coverage reports to CodeCov.io or Coveralls.io
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
5. Integrate with Travis, CodeCov.io, Coveralls.io, David-dm and use shields.io to generate badges for each.


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

## Integrating with Travis, CodeCov, Coveralls, and David-dm

It's hard to find quality code, so I love the badges that README.md files wear showing build status, code coverage, and dependency up-to-datedness. Now that our project has test coverage, let's hook that up to CI and coverage services so we can get some badges.

### Create accounts

Visit each of 

- [Travis](https://travis-ci.org)
- [CodeCov.io](https://codecov.io)
- [Coveralls.io](https://coveralls.io)

to create an account, link it to your GitHub account, and enable repos - it's free for open source projects. After each has sync'd to your GitHub account, you will be able to enable projects, and thereafter, Travis will build on every push if a ```.travis.yml``` exists, and our configuration will push to CodeCov.io and Coverall.io.

I include configuration for both CodeCov.io and Coveralls.io in case you have a preference - I haven't really figured out which I like better yet. 

CodeCov.io has a pretty cool Chrome, FireFox, Opera extension that overlays coverage information on several GitHub code views and works perfectly with the CoffeeScript coverage we have created. Check out an overview at [YouTube](https://www.youtube.com/watch?v=d6wJKODB8_g) and install from [here](https://github.com/codecov/browser-extension#codecov-browser-extension) Safari and IE are planned additions.

### Configure .travis.yml

Your basic ```.travis.yml``` looks like

```YAML
language: node_js
node_js:
  - '0.12'
before_install:
  - 'npm install -g grunt-cli'
after_success:
  - 'npm run-script codecov'
  - 'npm run-script coveralls'
```

Before Travis installs our package and builds it, we want grunt-cli installed globally so we can use it to run our build.

After our build completes successfully, we want to upload the coverage information to the coverage services. We will be using [codecov.io](https://www.npmjs.com/package/codecov.io) and [coveralls](https://www.npmjs.com/package/coveralls) respectively.

After those packages are installed, we can create scripts in our ```package.json``` to upload coverage.

```JavaScript
  "scripts": {
    "test": "grunt",
    "codecov": "cat ./coverage/lcov.info | ./node_modules/.bin/codecov",
    "coveralls": "cat ./coverage/lcov.info | ./node_modules/.bin/coveralls"
  },
```
After these changes are made, our next push will trigger a build and upload to the coverage services. You can visit each site to see how the build went and examine their offerings.

### David

[David](https://david-dm.org) is another great service that tracks your npm dependencies to show when they become out of date.

Clicking on the badge will take you to a david-dm page that lists all of your dependencies, your required version along with the stable and latest versions of those dependencies.

### shields.io

[shields.io](http://shields.io) provides badges for each of these services, and many more.

Check out the badges at the top of this page for a hint at how to decorate your page.

**NOTE**: I included the npm version badge as an example. Since I have not published this package to npm, it shows as invalid.

## Epilog

There you have it - 3 well chosen packages, a couple of Gruntfile configurations yielding a pattern I will use over and over again.

Things to look at (after install and build)

- The console after a build: shows well formatted specification results and coverage summary.
- build/index.html: Mocha prints to the console, but also has a sweet test results presentation.
- coverage/lcov-report/index.html: your coverage results with annotated CoffeeScript available through drill down.
