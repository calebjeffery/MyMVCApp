#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use LWP::UserAgent;

my $url = 'http://mymvcapp.local/cgi-bin/index.cgi';  # Replace with your actual URL

# Test case 1: HTTP request to index.cgi
subtest 'HTTP request to index.cgi' => sub {
    plan tests => 3;
    
    # Create a user agent object
    my $ua = LWP::UserAgent->new;
    
    # Perform the request
    my $response = $ua->get($url);
    
    # Check if HTTP request was successful
    ok($response->is_success, 'HTTP request successful');
    
    if ($response->is_success) {
        my $content = $response->decoded_content;
        
        # Check for specific output content
        like($content, qr/<title>My MVC App<\/title>/i, 'Check HTML title');
        like($content, qr/<h1>Welcome to My MVC App<\/h1>/i, 'Check main heading');
    }
};

done_testing();
