package Paster;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  $ENV{"MOJO_MAX_MESSAGE_SIZE"} = $self->config('max_filesize');
#  $ENV{"MOJO_MAX_MESSAGE_SIZE"} = 3221225472;

  $self->config(hypnotoad => {
    listen => ['http://*:8080'],
    workers => 1
  });
  $self->plugin(SetUserGroup => {user => 'www', group => 'www'});
  $self->plugin(AccessLog => { log => 'log/access.log', format => 'combined' });
  $self->plugin('TagHelpers');

  # Router
  my $r = $self->routes;

  sub fourofour {
    my $self = shift;
    $self->rendered(404);
    $self->render(text => 'Not found!');
  };

  # Normal route to controller
  $r->get('/')->to(cb => \&fourofour);
  $r->post('/paste')->to('paste#paste');
  $r->get('/paste')->to('paste#form');
  $r->get('*')->to(cb => \&fourofour);
}

1;
