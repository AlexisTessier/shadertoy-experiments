var assert = require('assert');
var path = require('path');
var gulp =  require('gulp');
var header = require('gulp-header');
var footer = require('gulp-footer');
var concat = require('gulp-concat');

var argv = require('minimist')(process.argv.slice(2));

assert(typeof argv.exp === 'string', '--exp option must be a string');

var rootPath = path.join(__dirname, 'experiments', argv.exp);
var mainPath  = path.join(rootPath, 'main.glsl');
var optionDefine = path.join(rootPath, 'options.glsl');
var includeList = require(path.join(rootPath, 'includes.js'));

var includesPath = path.join(__dirname, 'includes');
var targets = [optionDefine];
for(var i=0,imax=includeList.length;i<imax;i++){
	targets.push(path.join(includesPath, includeList[i]+'.glsl'));
}
targets.push(mainPath);

var separator = '\n/*------------*/\n';
gulp.task('build', function() {
	return gulp.src(targets)
		.pipe(header(separator))
		.pipe(footer(separator))
		.pipe(concat('build.glsl'))
		.pipe(gulp.dest(rootPath));
});

gulp.task('watch', ['build'], function() {
	return gulp.watch(targets, ['build']);
})

gulp.task('default', ['build']);