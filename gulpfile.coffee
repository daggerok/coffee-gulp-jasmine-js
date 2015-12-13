srcDir    = 'src/'
specDir   = 'test/'
buildDir  = 'dist/'
modules   = 'node_modules/'

coffees   = '**/*.coffee'
specs     = '**/*Test.js'
htmlFiles = '**/*.html'
jsFiles   = '**/*.js'

vendors   = [ modules + "jquery/dist/jquery.min.js" ]
scripts   = [ srcDir + coffees ]
jsScripts = [ buildDir + jsFiles ]
htmls     = [ srcDir + htmlFiles ]

gulp      = require 'gulp'
remove    = require 'gulp-rimraf'
streams   = require 'streamqueue'
coffee    = require 'gulp-coffee'
concat    = require 'gulp-concat'
uglify    = require 'gulp-uglify'
plumber   = require 'gulp-plumber'
htmlace   = require 'gulp-html-replace'
htmlify   = require 'gulp-minify-html'
jasmine   = require 'gulp-jasmine'
connect   = require 'gulp-connect'

require('colors')
log = (error) ->
  console.log [
    "BUILD FAILED: #{error.name ? ''}".red.underline
    '\u0007' # beep
    "#{error.code ? ''}"
    "#{error.message ? error}"
    "in #{error.filename ? ''}"
    "gulp plugin: #{error.plugin ? ''}"
  ].join '\n'
  this.end()

processCoffee = (scripts) ->
  gulp.src(scripts)
    .pipe(plumber())
    .pipe(coffee bare: true)
      .on 'error', log

gulp.task 'clean', ->
  gulp.src(buildDir)
    .pipe remove force: true

gulp.task 'clean-js', ->
  gulp.src(jsScripts)
    .pipe remove force: true

gulp.task 'js', ['clean-js'], ->
  streams
    objectMode: true,
    gulp.src(vendors),
    processCoffee scripts
  .pipe(plumber())
  .pipe(concat 'index.js')
  .pipe(plumber())
  .pipe(uglify())
  .pipe gulp.dest buildDir

gulp.task 'html', ->
  gulp.src(htmls)
    .pipe(plumber())
    .pipe htmlace
      js: 'index.js'
    .pipe(plumber())
    .pipe htmlify
      quotes: true
      conditionals: true
      spare: true
    .pipe gulp.dest buildDir

gulp.task 'default', ['js', 'html']

gulp.task 'html-dev', ->
  gulp.src(htmls)
    .pipe(gulp.dest buildDir)
    .pipe connect.reload()

vendors       = [ modules + "jquery/dist/jquery.js" ]
coffeeScripts = [ srcDir + coffees
                  specDir + coffees ]

gulp.task 'js-dev', ['clean-js'], ->
  streams
    objectMode: true,
    gulp.src(vendors),
    processCoffee coffeeScripts
  .pipe(gulp.dest buildDir)
  .pipe connect.reload()

specScripts = [ buildDir + specs ]

gulp.task 'test', ['js-dev'], ->
  gulp.src(specScripts)
    .pipe jasmine
      coffee: false
      autotest: true

gulp.task 'dev', ['test', 'html-dev', 'test']

gulp.task 'connect', ->
  connect.server
    root: buildDir
    livereload: true

gulp.task 'watch', ['dev', 'connect'], ->
  gulp.watch coffeeScripts, ['js-dev', 'test']
  gulp.watch htmls, ['html-dev']
