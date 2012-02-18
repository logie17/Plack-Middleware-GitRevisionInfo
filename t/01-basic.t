use HTTP::Request::Common;
use Plack::Builder;
use Plack::Test;
use Test::More;

my $body = ['<div>FooBar</div>'];
 
my $app = sub {
    my $env = shift;
    [200, ['Content-Type', 'text/html', 'Content-Length', length(join '', $body)], $body];
};
 
$app = builder {
    enable "Plack::Middleware::GitRevisionInfo", path => './t/git_repo';
    $app;
};

test_psgi $app, sub {
    my $cb = shift;
 
    my $res = $cb->(GET '/');
    is $res->code, 200;
    like $res->content, qr#<div>FooBar</div><!-- Revision:.*Date.*-->#;
};

$app = builder {
    enable "Plack::Middleware::GitRevisionInfo";
    return sub {
        my $env = shift;
        [200, ['Content-Type', 'text/html', 'Content-Length', length(join '', $body)], $body];
    }
};

test_psgi $app, sub {
    my $cb = shift;
 
    my $res = $cb->(GET '/');
    is $res->code, 200;
    is $res->content, '<div>FooBar</div>';
};

done_testing;
