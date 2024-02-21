package Paster::Controller::Paste;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::URL;
use Mojo::File qw(path tempfile);

$File::Temp::KEEP_ALL = 1;

sub paste ($c) {
  my $config = $c->app->plugin('Config');

  my $get_paths = sub ($filename = undef) {
    my $host_path = $config->{host_path};
    my $host_url = $config->{host_url};
    my $fs;

    $fs = tempfile(TEMPLATE => $config->{paste_template},
                   DIR => $host_path) unless $filename;

    my $path = Mojo::URL->new(($fs ? $fs : $filename)->basename);
    return (path($fs // path($host_path, $filename)), Mojo::URL->new($host_url)->path($path));
  };

  my @output;
  if(my $data = $c->param('paste')) {
    my $res;
    my @paths;

    my ($fs, $url) = $get_paths->();
    $c->app->log->debug("$url");

    $fs->spew($data, 'UTF-8') if $fs;
    push @output, $url;
  }
  else {
    for my $ufile ($c->req->every_upload('file')->@*) {
      next unless $ufile && length($ufile->filename);

      my $filename = $ufile->filename =~ s/\s/_/gr;

      my ($fs, $url) = $get_paths->(Mojo::File->new($filename));
      $c->app->log->debug($fs);
      $c->app->log->debug($filename);
      $ufile->move_to($fs);
      push @output, $url;
    }
  }

  $c->stash(url => shift @output);
  $c->render('paste/output', rest => \@output);
}

1;
