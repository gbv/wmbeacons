requires 'perl', '5.14.1';
requires 'Business::ISBN13';
requires 'LWP::Simple';
requires 'YAML';

# app
requires 'Plack::App::Directory::Template';
requires 'Plack::Middleware::Debug::TemplateToolkit';
requires 'Plack::Middleware::XForwardedFor';
