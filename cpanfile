requires 'perl', '5.20';

requires 'CGI';
requires 'CGI::Session';
requires 'Log::Log4perl';
requires 'JSON::MaybeXS';
requires 'HTML::Entities';

on 'test' => sub {
    requires 'Test::More';
    requires 'Test::MockModule';
};
