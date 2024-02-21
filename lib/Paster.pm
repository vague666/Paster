package Paster;

use Mojo::Base 'Mojolicious', -signatures;
use Mojo::Log;
use Mojo::Util 'url_unescape';
use Mojolicious::Types;
use File::Type;
use Path::Tiny;
use Data::Munge;

sub _get_file ($path) {
  no warnings 'newline';
  return -f $path && -r _ ? Mojo::Asset::File->new(path => url_unescape $path) : undef;
}

# This method will run once at server start
sub startup ($self) {
  my $config = $self->plugin('Config');

  $self->app->secrets($config->{secrets});
  $ENV{"MOJO_MAX_MESSAGE_SIZE"} = $config->{'max_filesize'} // 322122547;  # 300MB

  my ($user, $group) = split ':', $config->{'run_as'};
  die "Add run_as => 'user:group' in paster.conf, where user and group are existing values on your system" unless $user && $group;

  my $log = Mojo::Log->new(path => 'log/debug.log');
  $self->log($log);

  $self->plugin(SetUserGroup => {user => $user, group => $group});
  $self->plugin(AccessLog => { log => 'log/access.log', format => 'combined', level => 'warn' }) if $config->{'enable_logging'};
  $self->plugin('DefaultHelpers');
  $self->plugin('TagHelpers');

  my $mime_re = list2re $config->{render_as_text}->@*;

  # Router
  my $r = $self->routes;

  my $auth = $r->under('/paste' => sub ($c) {
    my $token = $config->{secrets}->[0];
    $c->stash(token => $token);

    # Authenticated?
    return 1 if $c->req->headers->header('Authorization') eq "Token $token"
             || $c->param('token') eq $token;

    # Not authenticated
    $c->render(text => "You're not authorized.", status => 401);
    return undef;
  });

  $auth->post('/')->to('paste#paste');
  $auth->get('/')->to('paste#form');

  # Normal route to controller
  $r->get('/*paste' => sub ($c) {
    my $file = _get_file(path($config->{host_path}, $c->param('paste')));
    if($file) {
      my $types = File::Type->new;
      my $ctype = $types->mime_type($file->path);
      if($ctype =~ m,$mime_re,i) {
        $ctype = 'text/plain';
      }

      $c->res->headers->content_disposition('inline');
      $c->res->headers->content_type($ctype);
      $c->reply->file($file->path);
    }
    else {
      $c->reply->txt_not_found;
    }
  });
  $r->get('/' => sub ($c) {
    $c->reply->txt_not_found;
  });
}

1;
