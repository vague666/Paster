package Paster::Controller::Paste;
use Mojo::Base 'Mojolicious::Controller';

sub paste {
  my $self = shift;

  my $get_paths = sub {
    my ($filename) = @_;
    my $basepath = '/home/www/web/public/pastes';
    unless($filename) {
      my @chars = split '', 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
      do {
        $filename = '';
        for(1..4) {
          my $r = int(rand(@chars));
          $filename .= $chars[$r];
        }
      } while -e "$basepath/$filename";
    }
    my $host_url = $self->app->plugin('Config')->{'host_url'} // "https://localhost/";
    ("$basepath/$filename", "$host_url/$filename");
  };

  my $files = $self->req->every_upload('file');
  if($files->[0] && length $files->[0]->filename > 0) {
    my @output;
    for my $ufile (@$files) {
      my ($fs, $url) = $get_paths->($ufile->filename);
      $ufile->move_to($fs);
      push @output, $url;
      $self->app->log->info("Wrote paste as $fs, weblink is $url");
    }

    $self->render(text => join("<br>", @output));
  }
  else {
    my $data = $self->param('paste');
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

    $self->app->log->info("Wrote paste as $fs, weblink is $url");
    $self->render(text => $res // "$url\n");
  }
}

1;
