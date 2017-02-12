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
  
  $self->helper(render_field => sub {    
     my ($self, $table, $col, $value, $options) = @_;

     $options->{handler} //= $self->app->renderer->default_handler;
     $options->{format} = $self->stash('format') || $self->app->renderer->default_format;
  
     state $field_render_cache = {};

     my $datatype   = $self->stash('columns_meta')->{$col}->{data_type};
     my %render_args = ( value => $value, type => $datatype );
     
     if (my $template = $field_render_cache->{$table}->{$col}) {
        $self->render_to_string($template, %render_args);        
     }
     else {

        my $template_options = ["table/$table/field_$col",
                                "table/$table/field_$datatype",
                                'table/_default/field'];
        
        for my $template (@$template_options) {
          
          if($self->app->renderer->template_path({ template => $template,
                                                   format   => $options->{format},
                                                   handler  => $options->{handler} })) {
            $field_render_cache->{$table}->{$col} = $template;
            return $self->render_to_string($template, %render_args);
          }
        }
     }     
  });
  
  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/:table')->to('table#show');
}

1;
