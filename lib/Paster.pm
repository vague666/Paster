package Paster;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;
  my $config = $self->plugin('Config');

  $ENV{"MOJO_MAX_MESSAGE_SIZE"} = $config->{'max_filesize'} // 322122547;  # 300MB

  $self->config(hypnotoad => {
    listen => ['http://*:8080'],
    workers => 1
  });

  my ($user, $group) = split ':', $config->{'run_as'};
  die "Add run_as => 'user:group' in paster.conf, where user and group are existing values on your system" unless $user && $group;

  $self->plugin(SetUserGroup => {user => $user, group => $group});
  $self->plugin(AccessLog => { log => 'log/access.log', format => 'combined' }) if $config->{'enable_logging'};
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
