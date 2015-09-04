Package.describe({
  name: '3stack:savoury',
  version: '1.1.0',
  summary: 'Reactively show the user the status of their method call.',
  git: 'https://github.com/3stack-software/meteor-savoury',
  documentation: 'README.md'
});

Package.onUse(function (api) {
  api.versionsFrom('METEOR@1.1.0.2');

  api.use([
    'coffeescript',
    'logging',
    'underscore',
    'reactive-var',
    'templating',
    'spacebars'
  ], 'client');

  api.export('Savoury');

  api.addFiles([
    'savoury.html',
    'savoury.coffee'
  ], 'client');
});
