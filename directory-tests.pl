#! /usr/bin/perl -w

open(FOO, "ospfsmod.c") || die "Did you delete ospfsmod.c?";
$lines = 0;
$lines++ while defined($_ = <FOO>);
close FOO;

@tests = (
    # ls of root directory needs some tweaking
    [ 'ls / | md5sum',
      "374f503b210360722ae175bf02f94e4c -"
    ],
    # ls of root with -F flag needs some tweaking
    [ 'ls -F / | md5sum',
      "6d824ca9107961ba53cb9ee7e8a7f50e -"
    ],
    #ls of subdirectory  needs some tweaking
    [ 'ls  base/subdir',
      "message.txt"
    ],

    #ls of subdirectory using more than one data block placeholder
    [ "echo aaa",
      "aaa"
    ],
    #ls of subdirectory using indirect data blocks placeholder
    [ "echo aaa",
      "aaa"
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