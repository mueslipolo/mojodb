package MojoDb;
use Mojo::Base 'Mojolicious';
use Schema;

has schema => sub {
  my $self = shift;
  return Schema->connect(@{$self->config('schema_connect')});
};

# This method will run once at server start
sub startup {
  my $self = shift;
  
  $self->plugin('Config');    
 
  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/:table')->to('table#show');
}

1;
