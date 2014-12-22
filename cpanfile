requires 'perl', '5.10.1';
requires 'Business::ISBN';
requires 'LWP::Simple';
requires 'Data::Beacon', '0.3.1';
requires 'YAML';

# app
requires 'Plack::App::Directory::Template';
requires 'Plack::Middleware::Debug::TemplateToolkit';
requires 'Plack::Middleware::XForwardedFor';
