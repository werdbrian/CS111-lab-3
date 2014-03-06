#! /usr/bin/perl -w

open(FOO, "ospfsmod.c") || die "Did you delete ospfsmod.c?";
$lines = 0;
$lines++ while defined($_ = <FOO>);
close FOO;

@tests = (
  #test to see if it works outside of file system
   [ 'ln -s hello.txt base/hello2.txt; cat base/hello2.txt',
      "Hello, world!"
    ],
    #test out symbolic link outside of file system
    [ 'echo aaa > base/hello.txt; cat base/hello2.txt',
      "aaa"
    ],
    # create a symbolic link inside file system
    [ 'ln -s hello.txt test/hello2.txt; cat test/hello2.txt',
      "Hello, world!"
    ],
    #test out symbolic link
    [ 'echo aaa > test/hello2.txt; cat test/hello.txt',
      "aaa"
    ],
    #delete a symbolic link
    [ 'unlink test/hello2.txt; ls test | grep hello2',
      ""
    ],
    #delete the symbolic link created for us originally when copied from base folder
    [ 'unlink test/link; ls test | grep link',
      ""
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
