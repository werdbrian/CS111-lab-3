#! /usr/bin/perl -w

open(FOO, "ospfsmod.c") || die "Did you delete ospfsmod.c?";
$lines = 0;
$lines++ while defined($_ = <FOO>);
close FOO;

@tests = (
    # read first byte of file
    [ 'diff base/hello.txt test/hello.txt >/dev/null 2>&1 && echo $?',
      "0"
    ],
    #read the first block of a file
    [ 'cmp base/pokercats.gif test/pokercats.gif >/dev/null 2>&1 && echo $?',
      "0"
    ],
    #read half of the first block of a file  
    [ 'ls -l test/pokercats.gif | awk "{ print \$5 }"',
      "91308"
    ],

    # read starting partway through the first block and into part of the next
    [ 'ls test | dd bs=1 of=test/dir-contents.txt >/dev/null 2>&1; ' .
      ' touch test/foo test/bar test/baz && '.
      ' rm    test/foo test/bar test/baz && '.
      'diff <( ls test ) test/dir-contents.txt',
      ''
    ],

    # read more than one block
    [ 'rm -f test/dir-contents.txt && ls test | grep dir-contents.txt',
      ''
    ],


    # try to read past the end of a file
    [ 'echo hello > test/file1 && cat test/file1',
      'hello'
    ],
    
    # try to read into an invalid buffer pointer
    [ 'echo hello > test/file1 ; echo goodbye >> test/file1 && cat test/file1',
      'hello goodbye'
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
