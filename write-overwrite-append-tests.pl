#! /usr/bin/perl -w

open(FOO, "ospfsmod.c") || die "Did you delete ospfsmod.c?";
$lines = 0;
$lines++ while defined($_ = <FOO>);
close FOO;

@tests = (
    # overwrite the first few bytes of a file
    [ "echo Bybye | dd bs=1 count=5 of=test/hello.txt conv=notrunc >/dev/null 2>&1 ; cat test/hello.txt",
      "Bybye, world!"
    ],
    #overwrite the first two blocks of a file1
    [ "echo je | dd bs=1 count=2 of=test/hello.txt conv=notrunc >/dev/null 2>&1 ; cat test/hello.txt",
      "jebye, world!"
    ],
    #overwrite the second block of a file                                                            
    [ "echo i | dd bs=1 count=1 seek=1 of=test/hello.txt conv=notrunc >/dev/null 2>&1 ; cat test/hello.txt",
      "jibye, world!"
    ],
    # overwrite the first 5 blocks of a file
    [ "echo Hello | dd bs=1 count=5 of=test/hello.txt conv=notrunc >/dev/null 2>&1 ; cat test/hello.txt",
      "Hello, world!"
    ],
    
    # append to a file
    [ 'echo hello >> test/hello.txt ; cat test/hello.txt',
      'Hello world! hello'
    ],

);

my($ntest) = 0;
my(@wanttests);

foreach $i (@ARGV) {
    $wanttests[$i] = 1 if (int($i) == $i && $i > 0 && $i <= @tests);
}

my($sh) = "bash";
my($tempfile) = "lab3test.txt";
my($ntestfailed) = 0;
my($ntestdone) = 0;

foreach $test (@tests) {
    $ntest++;
    next if (@wanttests && !$wanttests[$ntest]);
    $ntestdone++;
    print STDOUT "Running test $ntest\n";
    my($in, $want) = @$test;
    open(F, ">$tempfile") || die;
    print F $in, "\n";
    print STDERR "  ", $in, "\n";
    close(F);
    $result = `$sh < $tempfile 2>&1`;
    $result =~ s|\[\d+\]||g;
    $result =~ s|^\s+||g;
    $result =~ s|\s+| |g;
    $result =~ s|\s+$||;

    next if $result eq $want;
    next if $want eq 'Syntax error [NULL]' && $result eq '[NULL]';
    next if $result eq $want;
    print STDERR "Test $ntest FAILED!\n  input was \"$in\"\n  expected output like \"$want\"\n  got \"$result\"\n";
    $ntestfailed += 1;
}

unlink($tempfile);
my($ntestpassed) = $ntestdone - $ntestfailed;
print "$ntestpassed of $ntestdone tests passed\n";
exit(0);
