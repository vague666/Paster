package Paster::Controller::Paste;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::URL;
use Path::Tiny;

sub paste ($c) {
  my $config = $c->app->plugin('Config');

  my $get_paths = sub {
    my ($filename) = @_;
    my $host_path = $config->{'host_path'};

    unless($filename) {
      my @chars = split '', 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
      my $i = 0;
      my $namelength = 4;
      do {
        $i++;
        if($i >= ($config->{max_iter} // 100)) {
          $namelength += 1;
          $i = 0;
        }
        $filename = '';
        for(1 .. $namelength) {
          my $r = int(rand(@chars));
          $filename .= $chars[$r];
        }
      } while -e "$host_path/$filename";
    }
    my $host_url = $config->{'host_url'};
    (path($host_path, $filename), Mojo::URL->new($host_url)->path($filename));
  };

  my $files = $c->req->every_upload('file');
  if($files->[0] && length $files->[0]->filename > 0) {
    my @output;
    for my $ufile (@$files) {
      my ($fs, $url) = $get_paths->($ufile->filename);
      $ufile->move_to($fs);
      push @output, $url;
      $c->app->log->info("Wrote paste as $fs, weblink is $url");
    }

    $c->render(text => join("<br>", @output));
  }
  else {
    my $data = $c->param('paste');
    my $res;
    my @paths;

    my ($fs, $url) = $get_paths->();

    if(open my $fh, '>', $fs) {
      print $fh $data or $res = $!;
      close $fh if $fh;
    }
    else {
      $res = $!;
    }

    $c->app->log->info("Wrote paste as $fs, weblink is $url");
    $c->render(text => $res // "$url\n");
  }
}

1;
